import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'utils/app_theme.dart';

class TaskManagerApp extends StatelessWidget {
  final bool isLoggedIn;

  const TaskManagerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager // OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: isLoggedIn ? const TaskListScreen() : const WelcomeScreen(),
    );
  }
}
