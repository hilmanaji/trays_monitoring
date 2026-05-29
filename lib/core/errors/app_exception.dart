enum AppExceptionType {
  unauthorized,
  validation,
  server,
  network,
  timeout,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
    this.statusCode,
    this.validationErrors,
  });

  final AppExceptionType type;
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? validationErrors;

  String get displayMessage {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return message;
    }

    final flattened = validationErrors!.entries
        .expand((entry) => entry.value)
        .where((entry) => entry.trim().isNotEmpty)
        .toList();
    if (flattened.isEmpty) {
      return message;
    }

    return flattened.join('\n');
  }

  @override
  String toString() {
    return 'AppException(type: $type, statusCode: $statusCode, message: $message)';
  }
}
