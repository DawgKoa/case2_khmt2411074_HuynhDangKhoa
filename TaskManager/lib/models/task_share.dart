import 'user.dart';

class TaskShare {
  final String id;
  final String taskId;
  final User? user;
  final String userId;
  final String permission; // 'viewer', 'editor', 'admin'
  final User? sharedBy;
  final String? sharedById;
  final DateTime? createdAt;

  TaskShare({
    required this.id,
    required this.taskId,
    this.user,
    required this.userId,
    this.permission = 'viewer',
    this.sharedBy,
    this.sharedById,
    this.createdAt,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    User? parsedUser;
    String rawUserId = '';
    if (json['userId'] is Map<String, dynamic>) {
      parsedUser = User.fromJson(json['userId']);
      rawUserId = parsedUser.id;
    } else if (json['userId'] != null) {
      rawUserId = json['userId'].toString();
    }

    User? parsedSharedBy;
    String? rawSharedById;
    if (json['sharedBy'] is Map<String, dynamic>) {
      parsedSharedBy = User.fromJson(json['sharedBy']);
      rawSharedById = parsedSharedBy.id;
    } else if (json['sharedBy'] != null) {
      rawSharedById = json['sharedBy'].toString();
    }

    return TaskShare(
      id: json['id'] ?? json['_id'] ?? '',
      taskId: json['taskId']?.toString() ?? '',
      user: parsedUser,
      userId: rawUserId,
      permission: json['permission'] ?? 'viewer',
      sharedBy: parsedSharedBy,
      sharedById: rawSharedById,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'permission': permission,
      if (sharedById != null) 'sharedBy': sharedById,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
