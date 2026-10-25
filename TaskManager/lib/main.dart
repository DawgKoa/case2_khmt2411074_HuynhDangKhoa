export 'app.dart';

import 'package:flutter/material.dart';
import 'app.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final bool loggedIn = await authService.isLoggedIn();

  runApp(TaskManagerApp(isLoggedIn: loggedIn));
}
