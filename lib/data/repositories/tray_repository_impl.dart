import '../../domain/entities/register_rfid_request.dart';
import '../../domain/entities/scrap_request.dart';
import '../../domain/entities/tray.dart';
import '../../domain/repositories/tray_repository.dart';
import '../datasources/tray_remote_datasource.dart';

class TrayRepositoryImpl implements TrayRepository {
  TrayRepositoryImpl(this._remoteDatasource);

  final TrayRemoteDatasource _remoteDatasource;

  @override
  Future<Tray> getTrayDetail(int id) {
    return _remoteDatasource.getTrayDetail(id);
  }

  @override
  Future<List<Tray>> getTrays({String? search}) {
    return _remoteDatasource.getTrays(search: search);
  }

  @override
  Future<void> registerRfid(RegisterRfidRequest request) {
    return _remoteDatasource.registerRfid(request);
  }

  @override
  Future<void> scrapTray(ScrapRequest request) {
    return _remoteDatasource.scrapTray(request);
  }
}
