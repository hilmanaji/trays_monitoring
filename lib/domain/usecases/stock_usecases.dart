import '../entities/stock_by_tray_type.dart';
import '../entities/stock_summary.dart';
import '../repositories/stock_repository.dart';

class GetStockSummaryUseCase {
  GetStockSummaryUseCase(this._repository);

  final StockRepository _repository;

  Future<List<StockSummary>> call() {
    return _repository.getStockSummary();
  }
}

class GetStockByTrayTypeUseCase {
  GetStockByTrayTypeUseCase(this._repository);

  final StockRepository _repository;

  Future<List<StockByTrayType>> call() {
    return _repository.getStockByTrayType();
  }
}
