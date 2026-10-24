import '../models/task.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _client = ApiClient.instance;

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
