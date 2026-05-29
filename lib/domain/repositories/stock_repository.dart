import '../entities/stock_by_tray_type.dart';
import '../entities/stock_summary.dart';

abstract class StockRepository {
  Future<List<StockSummary>> getStockSummary();
  Future<List<StockByTrayType>> getStockByTrayType();
}
