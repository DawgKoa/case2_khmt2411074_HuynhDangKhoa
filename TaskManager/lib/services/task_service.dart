import '../models/task.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _client = ApiClient.instance;

  /// Lấy danh sách công việc của người dùng hiện tại (B2)
  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    String? search,
    String? sortBy,
    String? order,
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

    final response = await _client.get('/tasks', queryParameters: queryParams);

    final rawTasks = response['data']?['tasks'];
    if (rawTasks is! List) {
      return [];
    }

    return rawTasks.map((t) => Task.fromJson(t as Map<String, dynamic>)).toList();
  }

  /// Tạo công việc mới (B1)
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
