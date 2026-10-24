import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final bool loggedIn = await authService.isLoggedIn();

  runApp(TaskManagerApp(isLoggedIn: loggedIn));
}

class TaskManagerApp extends StatelessWidget {
  final bool isLoggedIn;

  const TaskManagerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager // OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: isLoggedIn ? const TaskListScreen() : const LoginScreen(),
    );
  }
}
