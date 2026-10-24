import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient.instance;

  /// Đăng ký tài khoản mới (A1)
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.post('/auth/register', {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    final userData = response['data']?['user'];
    if (userData == null) {
      throw ApiException('Dữ liệu người dùng trả về không hợp lệ');
    }

    return User.fromJson(userData);
  }
}
