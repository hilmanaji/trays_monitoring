import '../../core/storage/hive_storage_service.dart';
import '../models/pending_movement_model.dart';

class PendingMovementLocalDatasource {
  PendingMovementLocalDatasource(this._storageService);

  final HiveStorageService _storageService;

  Future<void> save(PendingMovementModel movement) async {
    await _storageService.pendingMovementsBox.put(
      movement.localId,
      movement.toJson(),
    );
  }

  Future<List<PendingMovementModel>> getAll() async {
    return _storageService.pendingMovementsBox.values
        .map(
          (entry) => PendingMovementModel.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<void> remove(String localId) async {
    await _storageService.pendingMovementsBox.delete(localId);
  }
}
