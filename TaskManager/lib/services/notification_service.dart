import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationResult {
  final List<AppNotification> notifications;
  final int unreadCount;

  NotificationResult({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final ApiClient _client = ApiClient.instance;

  /// Lấy danh sách thông báo và số lượng chưa đọc (D1/D2)
  Future<NotificationResult> getNotifications({bool? isRead, int limit = 50}) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
    };
    if (isRead != null) {
      queryParams['isRead'] = isRead.toString();
    }

    final response = await _client.get(
      '/notifications',
      queryParameters: queryParams,
    );

    final List<dynamic> notifList =
        response['data']?['notifications'] as List<dynamic>? ?? [];
    final notifications = notifList
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();

    final unreadCount = (response['unreadCount'] as num?)?.toInt() ?? 0;

    return NotificationResult(
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  /// Đánh dấu 1 thông báo là đã đọc
  Future<int> markAsRead(String id) async {
    final response = await _client.patch('/notifications/$id/read');
    return (response['unreadCount'] as num?)?.toInt() ?? 0;
  }

  /// Đánh dấu tất cả thông báo là đã đọc
  Future<void> markAllAsRead() async {
    await _client.patch('/notifications/read-all');
  }

  /// Xóa một thông báo
  Future<void> deleteNotification(String id) async {
    await _client.delete('/notifications/$id');
  }
}
