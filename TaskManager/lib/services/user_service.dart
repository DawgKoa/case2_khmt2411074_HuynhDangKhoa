import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client = ApiClient.instance;

  /// Tìm kiếm người dùng theo email hoặc họ tên (C1)
  Future<List<User>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await _client.get(
      '/users/search',
      queryParameters: {'q': query.trim()},
    );

    final rawUsers = response['data']?['users'];
    if (rawUsers is! List) return [];

    return rawUsers.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
  }

  /// Lấy danh sách gợi ý người dùng trong hệ thống
  Future<List<User>> getSuggestedUsers() async {
    final response = await _client.get('/users');

    final rawUsers = response['data']?['users'];
    if (rawUsers is! List) return [];

    return rawUsers.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
  }
}
