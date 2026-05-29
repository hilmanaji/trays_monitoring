import '../entities/location.dart';
import '../entities/tray_type.dart';
import '../repositories/master_data_repository.dart';

class GetLocationsUseCase {
  GetLocationsUseCase(this._repository);

  final MasterDataRepository _repository;

  Future<List<Location>> call() {
    return _repository.getLocations();
  }
}

class GetTrayTypesUseCase {
  GetTrayTypesUseCase(this._repository);

  final MasterDataRepository _repository;

  Future<List<TrayType>> call() {
    return _repository.getTrayTypes();
  }
}
