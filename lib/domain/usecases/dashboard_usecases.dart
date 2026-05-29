import '../entities/dashboard_snapshot.dart';
import '../entities/movement_page.dart';
import '../entities/stock_by_tray_type.dart';
import '../entities/stock_summary.dart';
import '../entities/tray.dart';
import '../repositories/master_data_repository.dart';
import '../repositories/movement_repository.dart';
import '../repositories/stock_repository.dart';
import '../repositories/tray_repository.dart';

class GetDashboardSnapshotUseCase {
  GetDashboardSnapshotUseCase(
    this._trayRepository,
    this._masterDataRepository,
    this._movementRepository,
    this._stockRepository,
  );

  final TrayRepository _trayRepository;
  final MasterDataRepository _masterDataRepository;
  final MovementRepository _movementRepository;
  final StockRepository _stockRepository;

  Future<DashboardSnapshot> call() async {
    final results = await Future.wait<dynamic>([
      _trayRepository.getTrays(),
      _masterDataRepository.getLocations(),
      _movementRepository.getMovements(page: 1),
      _stockRepository.getStockSummary(),
      _stockRepository.getStockByTrayType(),
    ]);

    final trays = results[0] as List<Tray>;
    final locations = results[1] as List<dynamic>;
    final movements = results[2] as MovementPage;
    final stockSummary = results[3] as List<StockSummary>;
    final stockByTrayType = results[4] as List<StockByTrayType>;

    final totalStock = stockSummary.fold<int>(
      0,
      (running, item) => running + item.total,
    );

    return DashboardSnapshot(
      totalTrays: trays.length,
      totalLocations: locations.length,
      totalStock: totalStock,
      recentMovementsCount: movements.total,
      latestMovements: movements.items,
      stockByTrayType: stockByTrayType,
    );
  }
}
