import 'package:intl/intl.dart';

/// Tiện ích định dạng ngày tháng hiển thị theo phong cách Brutalist
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeDateFormat = DateFormat('HH:mm  dd/MM');
  static final DateFormat _fullTimeDateFormat = DateFormat('HH:mm - dd/MM/yyyy');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm');

  /// Định dạng chỉ ngày: dd/MM/yyyy
  static String formatDate(DateTime? date, {String fallback = 'Chưa đặt'}) {
    if (date == null) return fallback;
    return _dateFormat.format(date.toLocal());
  }

  /// Định dạng ngày và giờ: dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime? date, {String fallback = 'Chưa đặt'}) {
    if (date == null) return fallback;
    return _dateTimeFormat.format(date.toLocal());
  }

  /// Định dạng giờ và ngày ngắn: HH:mm  dd/MM
  static String formatTimeDate(DateTime? date, {String fallback = ''}) {
    if (date == null) return fallback;
    return _timeDateFormat.format(date.toLocal());
  }

  /// Định dạng đầy đủ giờ và ngày: HH:mm - dd/MM/yyyy
  static String formatFullTimeDate(DateTime? date, {String fallback = ''}) {
    if (date == null) return fallback;
    return _fullTimeDateFormat.format(date.toLocal());
  }

  /// Định dạng chỉ giờ: HH:mm
  static String formatTimeOnly(DateTime? date, {String fallback = ''}) {
    if (date == null) return fallback;
    return _timeOnlyFormat.format(date.toLocal());
  }

  /// Định dạng khoảng thời gian tương đối (relative time)
  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return _dateFormat.format(date.toLocal());
    }
  }
}
