import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../auth/login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'TASK MANAGER // OS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryInk),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: AppColors.primaryInk,
            height: 2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryInk,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Session status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BrutalistBadge(
                        text: 'SESSION ACTIVE // JWT STORED',
                        backgroundColor: AppColors.success,
                        textColor: Colors.white,
                        icon: Icons.check_circle_outline,
                      ),
                      BrutalistBadge(
                        text: 'MODULE A2 OK',
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Info Hero Card
                  BrutalistCard(
                    padding: const EdgeInsets.all(20.0),
                    backgroundColor: AppColors.cardWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÀI KHOẢN ĐANG ĐĂNG NHẬP',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentUser?.fullName.toUpperCase() ?? 'NGƯỜI DÙNG',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 16, color: AppColors.secondaryText),
                            const SizedBox(width: 6),
                            Text(
                              _currentUser?.email ?? '---',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Placeholder Card for Module B
                  BrutalistCard(
                    backgroundColor: AppColors.secondarySurface.withValues(alpha: 0.15),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.dashboard_outlined, color: AppColors.primaryInk, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'DANH SÁCH CÔNG VIỆC',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Xác thực token JWT đã lưu thành công vào bộ nhớ máy (SharedPreferences). Chức năng Quản lý công việc (CRUD) sẽ được kết nối ở Module B.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        BrutalistButton(
                          text: 'ĐĂNG XUẤT PHIÊN LÀM VIỆC',
                          icon: Icons.logout,
                          backgroundColor: AppColors.secondarySurface,
                          textColor: AppColors.primaryInk,
                          width: double.infinity,
                          onPressed: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
