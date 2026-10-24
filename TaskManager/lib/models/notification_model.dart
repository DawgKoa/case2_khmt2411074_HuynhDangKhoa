import 'user.dart';

class NotificationTaskSummary {
  final String id;
  final String title;
  final String status;
  final String priority;
  final DateTime? dueDate;

  NotificationTaskSummary({
    required this.id,
    required this.title,
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
  });

  factory NotificationTaskSummary.fromJson(Map<String, dynamic> json) {
    return NotificationTaskSummary(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? 'Công việc',
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
    );
  }
}

class AppNotification {
  final String id;
  final String userId;
  final User? sender;
  final NotificationTaskSummary? task;
  final String? taskIdString;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    this.sender,
    this.task,
    this.taskIdString,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    User? senderUser;
    if (json['senderId'] is Map<String, dynamic>) {
      senderUser = User.fromJson(json['senderId']);
    }

    NotificationTaskSummary? taskSummary;
    String? rawTaskId;
    if (json['taskId'] is Map<String, dynamic>) {
      taskSummary = NotificationTaskSummary.fromJson(json['taskId']);
      rawTaskId = taskSummary.id;
    } else if (json['taskId'] != null) {
      rawTaskId = json['taskId'].toString();
    }

    return AppNotification(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      sender: senderUser,
      task: taskSummary,
      taskIdString: rawTaskId,
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      sender: sender,
      task: task,
      taskIdString: taskIdString,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
