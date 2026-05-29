package com.example.trays_monitoring

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	private val urovoRfidBridge = UrovoDt50RfidBridge()

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		urovoRfidBridge.register(flutterEngine, applicationContext)
	}
}
