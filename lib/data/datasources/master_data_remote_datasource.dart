import '../../core/utils/json_utils.dart';
import '../models/location_model.dart';
import '../models/tray_type_model.dart';
import '../../services/api/api_service.dart';

class MasterDataRemoteDatasource {
  MasterDataRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<List<LocationModel>> getLocations() async {
    final response = await _apiService.get('/locations');
    return JsonUtils.unwrapList(
      response,
    ).map((entry) => LocationModel.fromJson(JsonUtils.asMap(entry))).toList();
  }

  Future<List<TrayTypeModel>> getTrayTypes() async {
    final response = await _apiService.get('/tray-types');
    return JsonUtils.unwrapList(
      response,
    ).map((entry) => TrayTypeModel.fromJson(JsonUtils.asMap(entry))).toList();
  }
}
