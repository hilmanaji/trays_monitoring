import '../entities/movement_page.dart';
import '../entities/movement_request.dart';
import '../entities/pending_movement.dart';

abstract class MovementRepository {
  Future<MovementPage> getMovements({
    int page = 1,
    String? search,
    int? locationId,
    DateTime? date,
  });

  Future<void> createMovement(MovementRequest request);
  Future<void> savePendingMovement(PendingMovement movement);
  Future<List<PendingMovement>> getPendingMovements();
  Future<void> syncPendingMovements();
}
