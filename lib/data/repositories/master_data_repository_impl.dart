import '../../domain/entities/location.dart';
import '../../domain/entities/tray_type.dart';
import '../../domain/repositories/master_data_repository.dart';
import '../datasources/master_data_remote_datasource.dart';

class MasterDataRepositoryImpl implements MasterDataRepository {
  MasterDataRepositoryImpl(this._remoteDatasource);

  final MasterDataRemoteDatasource _remoteDatasource;

  @override
  Future<List<Location>> getLocations() {
    return _remoteDatasource.getLocations();
  }

  @override
  Future<List<TrayType>> getTrayTypes() {
    return _remoteDatasource.getTrayTypes();
  }
}
