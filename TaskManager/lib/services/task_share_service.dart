import '../models/task_share.dart';
import 'api_client.dart';

class TaskShareService {
  TaskShareService._();
  static final TaskShareService instance = TaskShareService._();

  final ApiClient _client = ApiClient.instance;

  /// Lấy danh sách chia sẻ của công việc
  Future<List<TaskShare>> getShares(String taskId) async {
    final response = await _client.get('/tasks/$taskId/shares');

    final raw = response['data']?['shares'];
    if (raw is! List) return [];

    return raw.map((s) => TaskShare.fromJson(s as Map<String, dynamic>)).toList();
  }

  /// Chia sẻ công việc với người dùng qua userId hoặc email
  Future<TaskShare> createShare(
    String taskId, {
    String? userId,
    String? email,
    String permission = 'viewer',
  }) async {
    final Map<String, dynamic> body = {
      'permission': permission,
    };
    if (userId != null && userId.isNotEmpty) body['userId'] = userId;
    if (email != null && email.isNotEmpty) body['email'] = email;

    final response = await _client.post('/tasks/$taskId/shares', body);

    final shareData = response['data']?['share'];
    if (shareData == null) {
      throw ApiException('Không nhận được dữ liệu chia sẻ');
    }

    return TaskShare.fromJson(shareData as Map<String, dynamic>);
  }

  /// Cập nhật quyền chia sẻ của thành viên
  Future<TaskShare> updateShare(
    String taskId,
    String shareId,
    String permission,
  ) async {
    final response = await _client.patch(
      '/tasks/$taskId/shares/$shareId',
      {'permission': permission},
    );

    final shareData = response['data']?['share'];
    if (shareData == null) {
      throw ApiException('Không nhận được dữ liệu cập nhật quyền chia sẻ');
    }

    return TaskShare.fromJson(shareData as Map<String, dynamic>);
  }

  /// Thu hồi quyền chia sẻ của thành viên
  Future<void> deleteShare(String taskId, String shareId) async {
    await _client.delete('/tasks/$taskId/shares/$shareId');
  }
}
