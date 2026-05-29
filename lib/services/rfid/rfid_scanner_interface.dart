abstract class RFIDScannerInterface {
  Future<void> startScan();
  Future<void> stopScan();
  Stream<String> get scannedTags;
}
