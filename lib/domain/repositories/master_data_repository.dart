import '../entities/location.dart';
import '../entities/tray_type.dart';

abstract class MasterDataRepository {
  Future<List<Location>> getLocations();
  Future<List<TrayType>> getTrayTypes();
}
