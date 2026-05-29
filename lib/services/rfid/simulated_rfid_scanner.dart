import 'dart:async';

import 'rfid_scanner_interface.dart';

class SimulatedRFIDScanner implements RFIDScannerInterface {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool _isScanning = false;

  @override
  Future<void> startScan() async {
    _isScanning = true;
    // TODO(UROVO): keep this simulator for non-RFID Android phones and desktop
    // testing. UROVO DT50(P) hardware uses the platform-channel scanner.
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
    // TODO(UROVO): mirror any extra cleanup the DT50(P) SDK needs once the
    // final native integration is connected.
  }

  @override
  Stream<String> get scannedTags => _controller.stream;

  void emitTag(String epc) {
    if (!_isScanning) {
      return;
    }
    final normalized = epc.trim().toUpperCase();
    if (normalized.isEmpty) {
      return;
    }
    _controller.add(normalized);
  }

  void dispose() {
    _controller.close();
  }
}
