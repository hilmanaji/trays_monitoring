import 'package:dio/dio.dart';

import '../../core/utils/json_utils.dart';
import '../../data/models/user_model.dart';
import '../../services/api/api_service.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<String> login({required String nik, required String password}) async {
    final response = await _apiService.post(
      '/login',
      data: <String, dynamic>{'nik': nik, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final map = JsonUtils.asMap(response);
    final data = JsonUtils.unwrapMap(response);
    return JsonUtils.stringValue(map, const [
      'token',
    ], fallback: JsonUtils.stringValue(data, const ['token']));
  }

  Future<UserModel> currentUser() async {
    final response = await _apiService.get('/me');
    return UserModel.fromJson(JsonUtils.unwrapMap(response));
  }

  Future<void> logout() async {
    await _apiService.post('/logout');
  }
}
