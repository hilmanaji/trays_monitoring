import '../../core/utils/json_utils.dart';
import '../../services/api/api_service.dart';
import '../models/stock_by_tray_type_model.dart';
import '../models/stock_summary_model.dart';

class StockRemoteDatasource {
  StockRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<List<StockSummaryModel>> getStockSummary() async {
    final response = await _apiService.get('/stocks/summary');
    return JsonUtils.unwrapList(response)
        .map((entry) => StockSummaryModel.fromJson(JsonUtils.asMap(entry)))
        .toList();
  }

  Future<List<StockByTrayTypeModel>> getStockByTrayType() async {
    final response = await _apiService.get('/stocks/by-tray-type');
    return JsonUtils.unwrapList(response)
        .map((entry) => StockByTrayTypeModel.fromJson(JsonUtils.asMap(entry)))
        .toList();
  }
}
