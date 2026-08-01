import 'package:intl/intl.dart';

class DateTimeFormatter {
  const DateTimeFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return _dateFormat.format(value.toLocal());
  }

  static String formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return _dateTimeFormat.format(value.toLocal());
  }

  /// Clock-only form used by the dense soft-UI rows (activity feed, sync line).
  static String formatTime(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return _timeFormat.format(value.toLocal());
  }
}
