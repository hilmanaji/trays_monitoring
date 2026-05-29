import '../entities/register_rfid_request.dart';
import '../entities/scrap_request.dart';
import '../entities/tray.dart';

abstract class TrayRepository {
  Future<List<Tray>> getTrays({String? search});
  Future<Tray> getTrayDetail(int id);
  Future<void> registerRfid(RegisterRfidRequest request);
  Future<void> scrapTray(ScrapRequest request);
}
