import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  // static const String _defaultServerUrl = 'http://access-siix.test:8080';
  static const String _defaultServerUrl = 'http://192.168.62.38';
  static const String _androidEmulatorServerUrl = 'http://10.0.2.2:8080';

  static const String _serverUrlFromEnvironment = String.fromEnvironment(
    'API_SERVER_URL',
    defaultValue: '',
  );
  static const String _baseUrlFromEnvironment = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get serverUrl {
    if (_serverUrlFromEnvironment.isNotEmpty) {
      return _serverUrlFromEnvironment;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorServerUrl;
    }

    return _defaultServerUrl;
  }

  static String get apiPathPrefix {
    const pathPrefixFromEnvironment = String.fromEnvironment(
      'API_PATH_PREFIX',
      defaultValue: '/api/v1',
    );
    if (pathPrefixFromEnvironment.isEmpty) {
      return '';
    }
    return pathPrefixFromEnvironment.startsWith('/')
        ? pathPrefixFromEnvironment
        : '/$pathPrefixFromEnvironment';
  }

  static String get baseUrl {
    if (_baseUrlFromEnvironment.isNotEmpty) {
      return _baseUrlFromEnvironment;
    }
    return '$serverUrl$apiPathPrefix';
  }

  static String? get hostHeaderOverride {
    final isDefaultAndroidEmulatorRoute =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _serverUrlFromEnvironment.isEmpty &&
        _baseUrlFromEnvironment.isEmpty;

    if (!isDefaultAndroidEmulatorRoute) {
      return null;
    }

    if (serverUrl != _androidEmulatorServerUrl) {
      return null;
    }

    return Uri.parse(_defaultServerUrl).authority;
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const String pendingMovementsBox = 'pending_movements';
}
