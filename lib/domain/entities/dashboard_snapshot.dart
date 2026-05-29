import 'stock_by_tray_type.dart';
import 'tray_movement.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.totalTrays,
    required this.totalLocations,
    required this.totalStock,
    required this.recentMovementsCount,
    required this.latestMovements,
    required this.stockByTrayType,
  });

  final int totalTrays;
  final int totalLocations;
  final int totalStock;
  final int recentMovementsCount;
  final List<TrayMovement> latestMovements;
  final List<StockByTrayType> stockByTrayType;
}
