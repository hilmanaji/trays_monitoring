import 'package:intl/intl.dart';

import '../../domain/entities/movement_request.dart';
import '../../services/api/api_service.dart';
import '../models/movement_page_model.dart';

class MovementRemoteDatasource {
  MovementRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<MovementPageModel> getMovements({
    int page = 1,
    String? search,
    int? locationId,
    DateTime? date,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    final trimmedSearch = search?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      queryParameters['search'] = trimmedSearch;
    }
    if (locationId != null) {
      queryParameters['location_id'] = locationId;
    }
    if (date != null) {
      queryParameters['date'] = DateFormat('yyyy-MM-dd').format(date);
    }

    final response = await _apiService.get(
      '/tray-movements',
      queryParameters: queryParameters,
    );
    return MovementPageModel.fromJson(response);
  }

  Future<void> createMovement(MovementRequest request) async {
    await _apiService.post(
      '/tray-movements',
      data: <String, dynamic>{
        'from_location_id': request.fromLocationId,
        'to_location_id': request.toLocationId,
        'rfids': request.rfids,
      },
    );
  }
}
