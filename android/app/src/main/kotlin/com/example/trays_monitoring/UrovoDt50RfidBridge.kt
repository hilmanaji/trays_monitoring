package com.example.trays_monitoring

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import com.urovo.rfid.RfidReaderMange
import com.urovo.rfid.RfidReaderMangeModuleInfoCallBack
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class UrovoDt50RfidBridge : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        private const val COMMAND_CHANNEL = "trays_monitoring/rfid/urovo_dt50/commands"
        private const val TAG_EVENT_CHANNEL = "trays_monitoring/rfid/urovo_dt50/tags"
        private const val DEVICE_MODEL = "UROVO DT50(P)"
        private const val BARCODE_ENGINE = "HS7"
        private const val RFID_CHIP = "Impinj E710/E510"

        // UROVO DT50 broadcasts one of these intent actions when RFID tags are scanned.
        // The physical trigger button causes the system RFID service to inventory tags
        // and then broadcast the result. Try all known action variants; update this list
        // if you identify the exact action for your firmware version.
        private val RFID_INTENT_ACTIONS = listOf(
            "com.urovo.rfid.READ_RESULT",
            "com.urovo.rfid.action.TAG_FOUND",
            "com.urovo.rfid.action.READ",
            "urovo.intent.rfid.read",
            "com.urovo.action.rfid",
            "android.intent.action.RFID_RESULT",
        )

        // Possible extra key names carrying a single EPC string in the broadcast intent.
        private val EPC_STRING_KEYS = listOf("epc", "epc_data", "rfid_data", "tag_epc", "rfidData")

        // Possible extra key names carrying an array / list of EPC strings.
        private val EPC_LIST_KEYS = listOf("epcs", "epc_list", "tag_list", "rfid_list", "epcList", "tagList")
    }

    private var eventSink: EventChannel.EventSink? = null
    private var isScanning: Boolean = false
    private var flutterEngine: FlutterEngine? = null
    private var applicationContext: Context? = null
    private var manager: RfidReaderMange? = null
    private var lastModuleStatus: String = "UNINITIALIZED"
    private var lastBatteryInfo: Map<String, Any?> = emptyMap()
    private var lastError: String? = null
    private var isReceiverRegistered: Boolean = false

    // Receives RFID scan-result broadcasts emitted by the UROVO DT50 system RFID service.
    private val rfidBroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (!isScanning) return
            parseEpcsFromIntent(intent).forEach { epc -> emitTag(epc, "hardware") }
        }
    }

    fun register(flutterEngine: FlutterEngine, applicationContext: Context) {
        this.flutterEngine = flutterEngine
        this.applicationContext = applicationContext
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMAND_CHANNEL)
            .setMethodCallHandler(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, TAG_EVENT_CHANNEL)
            .setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startScan" -> result.success(startScan())
            "stopScan" -> {
                stopScan()
                result.success(null)
            }
            "submitManualTag" -> {
                val epc = call.argument<String>("epc").orEmpty().trim().uppercase()
                if (epc.isNotEmpty()) emitTag(epc, "manual")
                result.success(null)
            }
            "getDeviceInfo" -> result.success(deviceInfo())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // -------------------------------------------------------------------------
    // Scan lifecycle
    // -------------------------------------------------------------------------

    private fun startScan(): Map<String, Any?> {
        val context = applicationContext ?: return deviceInfo().toMutableMap().apply {
            put("hardwareReady", false)
            put("notes", "Application context is not attached to the RFID bridge yet.")
        }

        // Initialise the UROVO serial-port RFID SDK (module power, serial port, etc.).
        val rfidManager = manager ?: RfidReaderMange.getInstance().also { manager = it }
        val initCode = rfidManager.initialize(context)
        val initMessage = rfidManager.getErrorMessage(initCode)
        val hardwareReady = initCode == 0

        isScanning = hardwareReady
        lastError = if (hardwareReady) null else initMessage.ifBlank { "initialize failed with code $initCode" }

        if (hardwareReady) {
            lastModuleStatus = "INITIALIZED"
            rfidManager.startMonitorModuleInfo(1500, moduleInfoCallback)
        }

        // Register a BroadcastReceiver so we capture the intent the UROVO DT50 system
        // RFID service fires when the physical trigger button is pressed and tags are read.
        registerRfidReceiver(context)

        return deviceInfo().toMutableMap().apply {
            put("hardwareReady", hardwareReady)
            put("initializeCode", initCode)
            put("initializeMessage", initMessage)
            put("rfidIntentActions", RFID_INTENT_ACTIONS)
            put(
                "notes",
                if (hardwareReady) {
                    "SDK initialised. Listening for RFID broadcast intents from the UROVO system service. Press the physical trigger to scan."
                } else {
                    "SDK initialisation failed. Check module connection, permissions, and vendor service state on the device."
                },
            )
        }
    }

    private fun stopScan() {
        isScanning = false
        applicationContext?.let { unregisterRfidReceiver(it) }
        manager?.release()
        lastModuleStatus = "RELEASED"
    }

    // -------------------------------------------------------------------------
    // Broadcast receiver helpers
    // -------------------------------------------------------------------------

    private fun registerRfidReceiver(context: Context) {
        if (isReceiverRegistered) return
        val filter = IntentFilter().apply {
            RFID_INTENT_ACTIONS.forEach { addAction(it) }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ requires the export flag for receivers that accept
            // broadcasts from other apps / system services.
            context.registerReceiver(rfidBroadcastReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(rfidBroadcastReceiver, filter)
        }
        isReceiverRegistered = true
    }

    private fun unregisterRfidReceiver(context: Context) {
        if (!isReceiverRegistered) return
        try {
            context.unregisterReceiver(rfidBroadcastReceiver)
        } catch (_: IllegalArgumentException) {
            // Already unregistered — safe to ignore.
        }
        isReceiverRegistered = false
    }

    // Parse all EPC strings that may be present in a UROVO RFID broadcast intent.
    // Different firmware versions use different extra key names and value types.
    private fun parseEpcsFromIntent(intent: Intent): List<String> {
        val epcs = mutableListOf<String>()

        // Single-EPC string extras
        for (key in EPC_STRING_KEYS) {
            intent.getStringExtra(key)?.let { raw ->
                val epc = raw.trim().uppercase()
                if (epc.isNotEmpty()) epcs.add(epc)
            }
        }

        // Multi-EPC extras (String array or ArrayList<String>)
        for (key in EPC_LIST_KEYS) {
            intent.getStringArrayExtra(key)?.forEach { raw ->
                val epc = raw.trim().uppercase()
                if (epc.isNotEmpty()) epcs.add(epc)
            }
            intent.getStringArrayListExtra(key)?.forEach { raw ->
                val epc = raw.trim().uppercase()
                if (epc.isNotEmpty()) epcs.add(epc)
            }
        }

        return epcs.distinct()
    }

    // -------------------------------------------------------------------------
    // Emit helpers
    // -------------------------------------------------------------------------

    private fun emitTag(epc: String, source: String) {
        if (!isScanning) return
        eventSink?.success(
            mapOf(
                "epc" to epc,
                "source" to source,
                "deviceModel" to DEVICE_MODEL,
            ),
        )
    }

    // -------------------------------------------------------------------------
    // Module-info monitoring callback (battery + module status)
    // -------------------------------------------------------------------------

    private val moduleInfoCallback = object : RfidReaderMangeModuleInfoCallBack {
        override fun onReadBatteryInfo(info: MutableMap<String, Any>?) {
            lastBatteryInfo = info.orEmpty()
            eventSink?.success(
                mapOf(
                    "event" to "batteryInfo",
                    "batteryInfo" to lastBatteryInfo,
                    "deviceModel" to DEVICE_MODEL,
                ),
            )
        }

        override fun onModuleStatus(status: String?) {
            lastModuleStatus = status.orEmpty().ifBlank { "UNKNOWN" }
            eventSink?.success(
                mapOf(
                    "event" to "moduleStatus",
                    "status" to lastModuleStatus,
                    "deviceModel" to DEVICE_MODEL,
                ),
            )
        }

        override fun onFail(code: String?, message: String?) {
            lastError = listOfNotNull(code, message).joinToString(": ").ifBlank { "RFID module callback failure" }
            eventSink?.error("RFID_MODULE", lastError, null)
        }
    }

    // -------------------------------------------------------------------------
    // Device info
    // -------------------------------------------------------------------------

    private fun deviceInfo(): Map<String, Any?> {
        return mapOf(
            "deviceModel" to DEVICE_MODEL,
            "barcodeEngine" to BARCODE_ENGINE,
            "rfidChip" to RFID_CHIP,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "manufacturer" to Build.MANUFACTURER,
            "hardwareReady" to isScanning,
            "rfidModel" to manager?.getRfidModel().orEmpty(),
            "moduleStatus" to lastModuleStatus,
            "batteryInfo" to lastBatteryInfo,
            "lastError" to lastError,
            "notes" to "UROVO serial-port RFID SDK integrated. EPC tags are captured via system RFID broadcast intents when the physical trigger is pressed.",
        )
    }
}
