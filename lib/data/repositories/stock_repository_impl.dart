import '../../domain/entities/stock_by_tray_type.dart';
import '../../domain/entities/stock_summary.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_remote_datasource.dart';

class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl(this._remoteDatasource);

  final StockRemoteDatasource _remoteDatasource;

  @override
  Future<List<StockByTrayType>> getStockByTrayType() {
    return _remoteDatasource.getStockByTrayType();
  }

  @override
  Future<List<StockSummary>> getStockSummary() {
    return _remoteDatasource.getStockSummary();
  }
}
