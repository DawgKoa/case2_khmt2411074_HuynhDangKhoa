import '../models/task.dart';
import '../models/task_activity.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _client = ApiClient.instance;

  /// Lấy danh sách công việc của người dùng hiện tại (B2, B6 & C5)
  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    String? search,
    String? sortBy,
    String? order,
    String? filterType,
  }) async {
    final Map<String, String> queryParams = {};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (priority != null && priority.isNotEmpty && priority != 'all') {
      queryParams['priority'] = priority;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['q'] = search.trim();
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (order != null && order.isNotEmpty) {
      queryParams['order'] = order;
    }
    if (filterType != null && filterType.isNotEmpty && filterType != 'all') {
      queryParams['filterType'] = filterType;
    }

    final response = await _client.get('/tasks', queryParameters: queryParams);

    final rawTasks = response['data']?['tasks'];
    if (rawTasks is! List) {
      return [];
    }

    return rawTasks.map((t) => Task.fromJson(t as Map<String, dynamic>)).toList();
  }

  /// Lấy chi tiết công việc theo ID (B3)
  Future<Task> getTaskById(String taskId) async {
    final response = await _client.get('/tasks/$taskId');

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không tìm thấy dữ liệu công việc');
    }

    return Task.fromJson(taskData);
  }

  /// Lấy lịch sử hoạt động của công việc
  Future<List<TaskActivity>> getTaskActivities(String taskId) async {
    final response = await _client.get('/tasks/$taskId/activities');

    final raw = response['data']?['activities'];
    if (raw is! List) return [];

    return raw.map((a) => TaskActivity.fromJson(a as Map<String, dynamic>)).toList();
  }

  /// Cập nhật thông tin công việc (B4)
  Future<Task> updateTask(
    String taskId, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    String? priority,
    String? status,
    List<String>? assigneeIds,
    String? primaryAssigneeId,
  }) async {
    final Map<String, dynamic> data = {};

    if (title != null) data['title'] = title.trim();
    if (description != null) data['description'] = description.trim();
    if (startDate != null) {
      data['startDate'] = startDate.toIso8601String();
    }
    if (dueDate != null) {
      data['dueDate'] = dueDate.toIso8601String();
    }
    if (priority != null) data['priority'] = priority;
    if (status != null) data['status'] = status;
    if (assigneeIds != null) data['assigneeIds'] = assigneeIds;
    if (primaryAssigneeId != null) data['primaryAssigneeId'] = primaryAssigneeId;

    final response = await _client.put('/tasks/$taskId', data);

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không nhận được dữ liệu công việc cập nhật');
    }

    return Task.fromJson(taskData);
  }

  /// Phân công người thực hiện chính & danh sách người tham gia (C2)
  Future<Task> assignTask(
    String taskId, {
    String? primaryAssigneeId,
    List<String>? assigneeIds,
  }) async {
    final Map<String, dynamic> data = {};
    if (primaryAssigneeId != null) {
      data['primaryAssigneeId'] = primaryAssigneeId;
    }
    if (assigneeIds != null) {
      data['assigneeIds'] = assigneeIds;
    }

    final response = await _client.put('/tasks/$taskId/assign', data);

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không nhận được dữ liệu công việc sau khi phân công');
    }

    return Task.fromJson(taskData);
  }

  /// Chia sẻ công việc và phân quyền RBAC (C3)
  Future<Task> shareTask(
    String taskId, {
    String? userId,
    String? email,
    String role = 'viewer',
  }) async {
    final Map<String, dynamic> data = {
      'role': role,
    };
    if (userId != null && userId.isNotEmpty) data['userId'] = userId;
    if (email != null && email.isNotEmpty) data['email'] = email;

    final response = await _client.post('/tasks/$taskId/share', data);

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không nhận được dữ liệu công việc sau khi chia sẻ');
    }

    return Task.fromJson(taskData);
  }

  /// Thay đổi vai trò thành viên trong công việc (C4)
  Future<Task> updateMemberRole(String taskId, String memberId, String role) async {
    final response = await _client.patch('/tasks/$taskId/members/$memberId', {
      'role': role,
    });

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không nhận được dữ liệu công việc sau khi đổi vai trò');
    }

    return Task.fromJson(taskData);
  }

  /// Thu hồi quyền truy cập / Xóa thành viên khỏi công việc (C4)
  Future<Task> revokeTaskMember(String taskId, String memberId) async {
    final response = await _client.delete('/tasks/$taskId/members/$memberId');

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không nhận được dữ liệu công việc sau khi thu hồi quyền');
    }

    return Task.fromJson(taskData);
  }

  /// Đổi trạng thái nhanh công việc (B4)
  Future<Task> updateTaskStatus(String taskId, String status) async {
    final response = await _client.patch('/tasks/$taskId/status', {
      'status': status,
    });

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Không nhận được dữ liệu công việc cập nhật trạng thái');
    }

    return Task.fromJson(taskData);
  }

  /// Xóa công việc (B5 - chỉ người tạo mới có quyền)
  Future<void> deleteTask(String taskId) async {
    await _client.delete('/tasks/$taskId');
  }

  /// Tạo công việc mới (B1 & C2)
  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    String priority = 'medium',
    String status = 'todo',
    List<String>? assigneeIds,
    String? primaryAssigneeId,
  }) async {
    final Map<String, dynamic> data = {
      'title': title.trim(),
      'description': description?.trim() ?? '',
      'priority': priority,
      'status': status,
    };

    if (startDate != null) {
      data['startDate'] = startDate.toIso8601String();
    }
    if (dueDate != null) {
      data['dueDate'] = dueDate.toIso8601String();
    }
    if (assigneeIds != null && assigneeIds.isNotEmpty) {
      data['assigneeIds'] = assigneeIds;
    }
    if (primaryAssigneeId != null) {
      data['primaryAssigneeId'] = primaryAssigneeId;
    }

    final response = await _client.post('/tasks', data);

    final taskData = response['data']?['task'];
    if (taskData == null) {
      throw ApiException('Dữ liệu công việc trả về không hợp lệ');
    }

    return Task.fromJson(taskData);
  }
}
