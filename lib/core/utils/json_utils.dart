typedef JsonMap = Map<String, dynamic>;

class JsonUtils {
  const JsonUtils._();

  static JsonMap asMap(dynamic value) {
    if (value is JsonMap) {
      return value;
    }
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    return <String, dynamic>{};
  }

  static List<dynamic> asList(dynamic value) {
    return value is List ? value : <dynamic>[];
  }

  static String stringValue(
    dynamic json,
    List<String> keys, {
    String fallback = '',
  }) {
    final map = asMap(json);
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
    }
    return fallback;
  }

  static int intValue(dynamic json, List<String> keys, {int fallback = 0}) {
    final map = asMap(json);
    for (final key in keys) {
      final value = map[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return fallback;
  }

  static DateTime? dateTimeValue(dynamic json, List<String> keys) {
    final rawValue = stringValue(json, keys);
    if (rawValue.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawValue);
  }

  static List<String> stringList(dynamic value) {
    return asList(value)
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  static List<dynamic> unwrapList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    final map = asMap(payload);
    for (final key in const ['data', 'items', 'rows']) {
      final candidate = map[key];
      if (candidate is List) {
        return candidate;
      }
      if (candidate is Map) {
        final nested = asMap(candidate);
        for (final nestedKey in const ['data', 'items', 'rows']) {
          final nestedCandidate = nested[nestedKey];
          if (nestedCandidate is List) {
            return nestedCandidate;
          }
        }
      }
    }

    return <dynamic>[];
  }

  static JsonMap unwrapMap(dynamic payload) {
    final map = asMap(payload);
    final data = map['data'];
    if (data is Map) {
      return asMap(data);
    }
    return map;
  }
}
