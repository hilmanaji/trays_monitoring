import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/session_coordinator.dart';

class ApiService {
  ApiService(this._tokenStorage, this._sessionCoordinator)
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout: ApiConstants.connectTimeout,
          headers: <String, dynamic>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (ApiConstants.hostHeaderOverride != null)
              'Host': ApiConstants.hostHeaderOverride,
          },
        ),
      ) {
    _configureInterceptors();
  }

  final Dio _dio;
  final SecureTokenStorage _tokenStorage;
  final SessionCoordinator _sessionCoordinator;

  void _configureInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final mappedException = _mapDioException(error);
          if (mappedException.type == AppExceptionType.unauthorized) {
            await _tokenStorage.clearToken();
            _sessionCoordinator.markUnauthorized();
          }
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: mappedException,
            ),
          );
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw _unwrapException(error);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (error) {
      throw _unwrapException(error);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw _unwrapException(error);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw _unwrapException(error);
    }
  }

  AppException _unwrapException(DioException error) {
    if (error.error is AppException) {
      return error.error! as AppException;
    }
    return _mapDioException(error);
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppException(
        type: AppExceptionType.timeout,
        message: 'The server took too long to respond.',
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return const AppException(
        type: AppExceptionType.network,
        message: 'Network failure. Check your connection and try again.',
      );
    }

    final statusCode = error.response?.statusCode;
    final responseBody = JsonUtils.asMap(error.response?.data);

    if (statusCode == 401) {
      return const AppException(
        type: AppExceptionType.unauthorized,
        statusCode: 401,
        message: 'Your session has expired. Please sign in again.',
      );
    }

    if (statusCode == 422) {
      return AppException(
        type: AppExceptionType.validation,
        statusCode: 422,
        message: JsonUtils.stringValue(responseBody, const [
          'message',
        ], fallback: 'Validation failed.'),
        validationErrors: _validationErrors(responseBody['errors']),
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppException(
        type: AppExceptionType.server,
        statusCode: statusCode,
        message: JsonUtils.stringValue(responseBody, const [
          'message',
        ], fallback: 'Server error. Please try again later.'),
      );
    }

    return AppException(
      type: AppExceptionType.unknown,
      statusCode: statusCode,
      message: JsonUtils.stringValue(responseBody, const [
        'message',
      ], fallback: 'Unexpected error occurred.'),
    );
  }

  Map<String, List<String>>? _validationErrors(dynamic payload) {
    final map = JsonUtils.asMap(payload);
    if (map.isEmpty) {
      return null;
    }

    final result = <String, List<String>>{};
    for (final entry in map.entries) {
      result[entry.key] = JsonUtils.stringList(entry.value);
    }
    return result;
  }
}
