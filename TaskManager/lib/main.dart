import 'package:flutter/material.dart';
import 'screens/auth/register_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager // OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const RegisterScreen(),
    );
  }
}
