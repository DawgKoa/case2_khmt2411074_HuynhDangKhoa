import 'user.dart';

class TaskActivity {
  final String id;
  final String taskId;
  final User? user;
  final String userId;
  final String action;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  TaskActivity({
    required this.id,
    required this.taskId,
    this.user,
    required this.userId,
    required this.action,
    this.details = const {},
    required this.createdAt,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    User? parsedUser;
    String rawUserId = '';
    if (json['userId'] is Map<String, dynamic>) {
      parsedUser = User.fromJson(json['userId']);
      rawUserId = parsedUser.id;
    } else if (json['userId'] != null) {
      rawUserId = json['userId'].toString();
    }

    return TaskActivity(
      id: json['id'] ?? json['_id'] ?? '',
      taskId: json['taskId']?.toString() ?? '',
      user: parsedUser,
      userId: rawUserId,
      action: json['action'] ?? '',
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : {},
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get actionLabel {
    switch (action) {
      case 'task_created':
        return 'TẠO CÔNG VIỆC';
      case 'task_updated':
        return 'CẬP NHẬT CÔNG VIỆC';
      case 'status_changed':
        return 'ĐỔI TRẠNG THÁI';
      case 'task_assigned':
        return 'PHÂN CÔNG';
      case 'task_shared':
        return 'CHIA SẺ QUYỀN';
      case 'assignee_added':
        return 'THÊM THÀNH VIÊN';
      case 'assignee_updated':
        return 'CẬP NHẬT PHÂN CÔNG';
      case 'assignee_removed':
        return 'XÓA PHÂN CÔNG';
      case 'share_permission_updated':
      case 'member_role_updated':
        return 'ĐỔI VAI TRÒ';
      case 'share_revoked':
      case 'member_revoked':
        return 'THU HỒI QUYỀN';
      case 'task_deleted':
        return 'XÓA CÔNG VIỆC';
      default:
        return action.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get description {
    switch (action) {
      case 'task_created':
        return 'Khởi tạo công việc mới vào hệ thống.';
      case 'task_updated':
        return 'Cập nhật lại thông tin nội dung công việc.';
      case 'status_changed':
        final newStatus = details['newStatus'] ?? '';
        final statusMap = {
          'todo': 'CHỜ XỬ LÝ',
          'in_progress': 'ĐANG LÀM',
          'completed': 'HOÀN THÀNH',
          'cancelled': 'ĐÃ HỦY',
        };
        final text = statusMap[newStatus] ?? newStatus;
        return 'Chuyển trạng thái sang $text.';
      case 'task_assigned':
        return 'Cập nhật lại danh sách phân công nhân sự.';
      case 'task_shared':
        final perm = (details['permission'] ?? details['role'] ?? 'viewer').toString().toUpperCase();
        return 'Chia sẻ công việc với quyền $perm.';
      case 'assignee_added':
        final name = details['targetUserName'] ?? 'thành viên';
        return 'Thêm $name vào danh sách thực hiện.';
      case 'assignee_updated':
        final isPrimary = details['isPrimary'] == true;
        return isPrimary ? 'Đặt làm người thực hiện chính.' : 'Cập nhật vai trò thực hiện.';
      case 'assignee_removed':
        return 'Xóa thành viên khỏi danh sách thực hiện.';
      case 'share_permission_updated':
      case 'member_role_updated':
        final role = (details['permission'] ?? details['role'] ?? '').toString().toUpperCase();
        return 'Đổi vai trò thành viên sang $role.';
      case 'share_revoked':
      case 'member_revoked':
        return 'Thu hồi quyền truy cập công việc của thành viên.';
      default:
        return 'Thao tác ghi nhận trên công việc.';
    }
  }
}
