import '../../core/errors/app_exception.dart';
import '../../domain/entities/movement_page.dart';
import '../../domain/entities/movement_request.dart';
import '../../domain/entities/pending_movement.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_remote_datasource.dart';
import '../datasources/pending_movement_local_datasource.dart';
import '../models/pending_movement_model.dart';

class MovementRepositoryImpl implements MovementRepository {
  MovementRepositoryImpl(this._remoteDatasource, this._localDatasource);

  final MovementRemoteDatasource _remoteDatasource;
  final PendingMovementLocalDatasource _localDatasource;

  @override
  Future<void> createMovement(MovementRequest request) {
    return _remoteDatasource.createMovement(request);
  }

  @override
  Future<MovementPage> getMovements({
    int page = 1,
    String? search,
    int? locationId,
    DateTime? date,
  }) {
    return _remoteDatasource.getMovements(
      page: page,
      search: search,
      locationId: locationId,
      date: date,
    );
  }

  @override
  Future<List<PendingMovement>> getPendingMovements() {
    return _localDatasource.getAll();
  }

  @override
  Future<void> savePendingMovement(PendingMovement movement) {
    return _localDatasource.save(PendingMovementModel.fromEntity(movement));
  }

  @override
  Future<void> syncPendingMovements() async {
    final pending = await _localDatasource.getAll();
    for (final movement in pending) {
      try {
        await _remoteDatasource.createMovement(
          MovementRequest(
            fromLocationId: movement.fromLocationId,
            toLocationId: movement.toLocationId,
            rfids: movement.rfids,
          ),
        );
        await _localDatasource.remove(movement.localId);
      } on AppException catch (error) {
        if (error.type == AppExceptionType.network ||
            error.type == AppExceptionType.timeout) {
          return;
        }
      }
    }
  }
}
