import '../../core/utils/json_utils.dart';
import '../../domain/entities/register_rfid_request.dart';
import '../../domain/entities/scrap_request.dart';
import '../../services/api/api_service.dart';
import '../models/tray_model.dart';

class TrayRemoteDatasource {
  TrayRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<List<TrayModel>> getTrays({String? search}) async {
    final response = await _apiService.get(
      '/trays',
      queryParameters: <String, dynamic>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return JsonUtils.unwrapList(
      response,
    ).map((entry) => TrayModel.fromJson(JsonUtils.asMap(entry))).toList();
  }

  Future<TrayModel> getTrayDetail(int id) async {
    final response = await _apiService.get('/trays/$id');
    return TrayModel.fromJson(JsonUtils.unwrapMap(response));
  }

  Future<void> registerRfid(RegisterRfidRequest request) async {
    await _apiService.post(
      '/rfid/register',
      data: <String, dynamic>{
        'epc': request.epc,
        'rfid_epc': request.epc,
        'tray_type_id': request.trayTypeId,
        'initial_location_id': request.locationId,
      },
    );
  }

  Future<void> scrapTray(ScrapRequest request) async {
    await _apiService.post(
      '/trays/scrap',
      data: <String, dynamic>{
        'epc': request.epc,
        'rfid_epc': request.epc,
        'reason': request.reason,
        'remarks': request.remarks,
      },
    );
  }
}
