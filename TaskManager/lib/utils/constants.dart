import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static const String appName = 'TASK MANAGER';
  static const String appSubtitle = 'WORKFORCE OS // V1.0';

  /// Lấy Base URL phù hợp cho từng môi trường (Android Emulator dùng 10.0.2.2)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  // Khóa lưu SharedPreferences
  static const String keyToken = 'auth_jwt_token';
  static const String keyUserData = 'auth_user_data';
}
