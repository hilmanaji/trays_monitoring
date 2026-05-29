import '../entities/movement_page.dart';
import '../entities/movement_request.dart';
import '../entities/pending_movement.dart';
import '../repositories/movement_repository.dart';

class CreateTrayMovementUseCase {
  CreateTrayMovementUseCase(this._repository);

  final MovementRepository _repository;

  Future<void> call(MovementRequest request) {
    return _repository.createMovement(request);
  }
}

class GetMovementHistoryUseCase {
  GetMovementHistoryUseCase(this._repository);

  final MovementRepository _repository;

  Future<MovementPage> call({
    int page = 1,
    String? search,
    int? locationId,
    DateTime? date,
  }) {
    return _repository.getMovements(
      page: page,
      search: search,
      locationId: locationId,
      date: date,
    );
  }
}

class SavePendingMovementUseCase {
  SavePendingMovementUseCase(this._repository);

  final MovementRepository _repository;

  Future<void> call(PendingMovement movement) {
    return _repository.savePendingMovement(movement);
  }
}

class SyncPendingMovementsUseCase {
  SyncPendingMovementsUseCase(this._repository);

  final MovementRepository _repository;

  Future<void> call() {
    return _repository.syncPendingMovements();
  }
}
