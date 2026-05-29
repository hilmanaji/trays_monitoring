import 'rfid_scanner_interface.dart';
import 'simulated_rfid_scanner.dart';
import 'urovo_dt50_rfid_scanner.dart';

class RFIDService {
  RFIDService(this._scanner);

  final RFIDScannerInterface _scanner;

  Stream<String> get scannedTags => _scanner.scannedTags;

  Future<void> startScan() {
    return _scanner.startScan();
  }

  Future<void> stopScan() {
    return _scanner.stopScan();
  }

  Future<void> submitManualTag(String epc) async {
    if (_scanner case final SimulatedRFIDScanner scanner) {
      scanner.emitTag(epc);
      return;
    }

    if (_scanner case final UrovoDT50RfidScanner scanner) {
      await scanner.emitManualTag(epc);
      return;
    }

    // TODO(UROVO): if the final UROVO SDK path requires a dedicated trigger
    // broadcast or service binder for manual EPC injection, route it here.
  }
}
