package com.example.trays_monitoring

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
    }

    private var eventSink: EventChannel.EventSink? = null
    private var isScanning: Boolean = false
    private var flutterEngine: FlutterEngine? = null
    private var manager: RfidReaderMange? = null
    private var lastModuleStatus: String = "UNINITIALIZED"
    private var lastBatteryInfo: Map<String, Any?> = emptyMap()
    private var lastError: String? = null

    fun register(flutterEngine: FlutterEngine) {
        this.flutterEngine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMAND_CHANNEL)
            .setMethodCallHandler(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, TAG_EVENT_CHANNEL)
            .setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startScan" -> {
                result.success(startScan())
            }

            "stopScan" -> {
                stopScan()
                result.success(null)
            }

            "submitManualTag" -> {
                val epc = call.argument<String>("epc").orEmpty().trim().uppercase()
                if (epc.isNotEmpty()) {
                    emitTag(epc, "manual")
                }
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

    private fun startScan(): Map<String, Any> {
        val engine = flutterEngine ?: return deviceInfo().toMutableMap().apply {
            put("hardwareReady", false)
            put("notes", "Flutter engine is not attached to the RFID bridge yet.")
        }

        val rfidManager = manager ?: RfidReaderMange.getInstance().also {
            manager = it
        }

        val initializeCode = rfidManager.initialize(engine.applicationContext)
        val initializeMessage = rfidManager.getErrorMessage(initializeCode)
        val hardwareReady = initializeCode == 0

        isScanning = hardwareReady
        lastError = if (hardwareReady) null else initializeMessage.ifBlank { "initialize failed with code $initializeCode" }
        if (hardwareReady) {
            lastModuleStatus = "INITIALIZED"
            rfidManager.startMonitorModuleInfo(1500, moduleInfoCallback)
        }

        return deviceInfo().toMutableMap().apply {
            put("hardwareReady", hardwareReady)
            put("initializeCode", initializeCode)
            put("initializeMessage", initializeMessage)
            put(
                "notes",
                if (hardwareReady) {
                    "SDK initialized. This jar exposes module/battery monitoring; EPC inventory callbacks are not visible from the public API yet."
                } else {
                    "SDK initialization failed. Check the module connection, permissions, and vendor service state on the device."
                },
            )
        }
    }

    private fun stopScan() {
        isScanning = false
        manager?.release()
        lastModuleStatus = "RELEASED"
    }

    private fun emitTag(epc: String, source: String) {
        if (!isScanning) {
            return
        }

        eventSink?.success(
            mapOf(
                "epc" to epc,
                "source" to source,
                "deviceModel" to DEVICE_MODEL,
            ),
        )
    }

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
            lastError = listOfNotNull(code, message).joinToString(separator = ": ").ifBlank {
                "RFID module callback failure"
            }
            eventSink?.error("RFID_MODULE", lastError, null)
        }
    }

    private fun deviceInfo(): Map<String, Any> {
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
            "notes" to "UROVO serial-port RFID SDK integrated for module initialization and monitoring. EPC inventory still depends on additional vendor inventory/read API exposure.",
        )
    }
}