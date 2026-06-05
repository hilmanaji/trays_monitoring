import 'dart:async';

import 'package:flutter/services.dart';

import 'rfid_scanner_interface.dart';

class UrovoDT50RfidScanner implements RFIDScannerInterface {
  UrovoDT50RfidScanner({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel(_commandChannelName),
       _eventChannel = eventChannel ?? const EventChannel(_eventChannelName) {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _handleNativeEvent,
      onError: _handleNativeError,
    );
  }

  static const String deviceModel = 'UROVO DT50(P)';
  static const String barcodeEngine = 'HS7';
  static const String rfidChip = 'Impinj E710/E510';
  static const String _commandChannelName =
      'trays_monitoring/rfid/urovo_dt50/commands';
  static const String _eventChannelName =
      'trays_monitoring/rfid/urovo_dt50/tags';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  late final StreamSubscription<dynamic> _eventSubscription;

  bool _isScanning = false;

  @override
  Stream<String> get scannedTags => _controller.stream;

  @override
  Future<void> startScan() async {
    await _methodChannel.invokeMethod<void>('startScan', _deviceDescriptor());
    _isScanning = true;
  }

  @override
  Future<void> stopScan() async {
    await _methodChannel.invokeMethod<void>('stopScan');
    _isScanning = false;
  }

  Future<void> emitManualTag(String epc) async {
    final normalized = epc.trim().toUpperCase();
    if (normalized.isEmpty) {
      return;
    }

    await _methodChannel.invokeMethod<void>(
      'submitManualTag',
      <String, dynamic>{'epc': normalized},
    );
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final response = await _methodChannel.invokeMapMethod<String, dynamic>(
      'getDeviceInfo',
    );
    return response ?? _deviceDescriptor();
  }

  void dispose() {
    _eventSubscription.cancel();
    _controller.close();
  }

  void _handleNativeEvent(dynamic event) {
    // Map events without an 'epc' key are module-status / battery-info
    // notifications — skip them so they never enter the EPC stream.
    final normalized = switch (event) {
      final String value => value.trim().toUpperCase(),
      final Map<dynamic, dynamic> value when value.containsKey('epc') =>
        (value['epc']?.toString() ?? '').trim().toUpperCase(),
      _ => '',
    };

    if (normalized.isEmpty) return;

    _controller.add(normalized);
  }

  void _handleNativeError(Object error, StackTrace stackTrace) {
    _controller.addError(error, stackTrace);
  }

  Map<String, dynamic> _deviceDescriptor() {
    return <String, dynamic>{
      'deviceModel': deviceModel,
      'barcodeEngine': barcodeEngine,
      'rfidChip': rfidChip,
      'isScanning': _isScanning,
    };
  }
}
