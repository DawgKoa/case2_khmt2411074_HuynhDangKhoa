import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
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

  /// Đăng nhập tài khoản & Lưu JWT token vào SharedPreferences (A2)
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post('/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    final data = response['data'];
    if (data == null || data['token'] == null || data['user'] == null) {
      throw ApiException('Dữ liệu đăng nhập trả về không hợp lệ');
    }

    final String token = data['token'];
    final user = User.fromJson(data['user']);

    // Lưu token và thông tin user vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyToken, token);
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));

    return user;
  }

  /// Lấy thông tin hồ sơ người dùng từ máy chủ (A3)
  Future<User> getProfile() async {
    final response = await _client.get('/auth/me');
    final userData = response['data']?['user'];
    if (userData == null) {
      throw ApiException('Không thể tải thông tin hồ sơ');
    }

    final user = User.fromJson(userData);

    // Cập nhật lại bộ nhớ đệm
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));

    return user;
  }

  /// Cập nhật thông tin cá nhân (A3)
  Future<User> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final response = await _client.put('/auth/me', {
      'fullName': fullName.trim(),
      'avatarUrl': avatarUrl?.trim() ?? '',
    });

    final userData = response['data']?['user'];
    if (userData == null) {
      throw ApiException('Không thể cập nhật hồ sơ');
    }

    final user = User.fromJson(userData);

    // Cập nhật lại bộ nhớ đệm
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));

    return user;
  }

  /// Đổi mật khẩu tài khoản khi đã đăng nhập (A4)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    // Sau khi đổi mật khẩu, xóa phiên đăng nhập để người dùng đăng nhập lại
    await logout();
  }

  /// Yêu cầu gửi mã OTP quên mật khẩu
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _client.post('/auth/forgot-password', {
      'email': email.trim().toLowerCase(),
    });
    return (response['data'] is Map<String, dynamic>)
        ? response['data']
        : <String, dynamic>{};
  }

  /// Xác thực mã OTP và đặt lại mật khẩu mới
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _client.post('/auth/reset-password', {
      'email': email.trim().toLowerCase(),
      'otp': otp.trim(),
      'newPassword': newPassword,
    });
    return response['message']?.toString() ?? 'Đặt lại mật khẩu thành công';
  }

  /// Kiểm tra trạng thái đã đăng nhập hay chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    return token != null && token.isNotEmpty;
  }

  /// Lấy token hiện tại
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }

  /// Lấy thông tin người dùng đang đăng nhập từ bộ nhớ máy
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.keyUserData);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserData);
  }
}
