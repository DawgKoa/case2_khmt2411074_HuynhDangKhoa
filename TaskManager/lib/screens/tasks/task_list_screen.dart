import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../auth/welcome_screen.dart';
import '../profile/profile_screen.dart';
import 'task_create_screen.dart';

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

    try {
      final latestUser = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _currentUser = latestUser;
        });
      }
    } catch (_) {}
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.primaryInk, width: 2),
        ),
        title: Text(
          'XÁC NHẬN ĐĂNG XUẤT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryInk,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống Task Manager?',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          BrutalistButton(
            text: 'ĐĂNG XUẤT',
            icon: Icons.logout,
            backgroundColor: AppColors.danger,
            textColor: Colors.white,
            height: 42,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    _loadUser();
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskCreateScreen()),
    );
    if (result == true) {
      _loadUser();
    }
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
            icon: const Icon(Icons.person_outline, color: AppColors.primaryInk),
            tooltip: 'Hồ sơ cá nhân',
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryInk),
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutConfirmDialog,
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
                        text: 'MODULE B // TASK OPS',
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                        icon: Icons.assignment_outlined,
                      ),
                      BrutalistBadge(
                        text: 'B1 READY',
                        backgroundColor: AppColors.secondarySurface,
                        textColor: AppColors.primaryInk,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Info Hero Card (Clickable to edit profile)
                  BrutalistCard(
                    padding: const EdgeInsets.all(20.0),
                    backgroundColor: AppColors.cardWhite,
                    onTap: _openProfile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryInk),
                          ],
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
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            BrutalistBadge(
                              text: 'CHỈNH SỬA HỒ SƠ ➔',
                              backgroundColor: AppColors.primaryAccent,
                              textColor: AppColors.primaryInk,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Card for Task Creation (B1)
                  BrutalistCard(
                    backgroundColor: AppColors.cardWhite,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_task, color: AppColors.primaryInk, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'TẠO CÔNG VIỆC MỚI (B1)',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Khởi tạo nhiệm vụ mới, thiết lập hạn hoàn thành, mức độ ưu tiên (Low, Medium, High) và trạng thái ban đầu.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        BrutalistButton(
                          text: '+ THÊM CÔNG VIỆC MỚI',
                          icon: Icons.add,
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          width: double.infinity,
                          onPressed: _openCreateTask,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logout Card
                  BrutalistButton(
                    text: 'ĐĂNG XUẤT PHIÊN LÀM VIỆC',
                    icon: Icons.logout,
                    backgroundColor: AppColors.secondarySurface,
                    textColor: AppColors.primaryInk,
                    width: double.infinity,
                    onPressed: _showLogoutConfirmDialog,
                  ),
                ],
              ),
            ),
      floatingActionButton: GestureDetector(
        onTap: _openCreateTask,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryInk, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryInk,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Icon(Icons.add, size: 30, color: AppColors.primaryInk),
        ),
      ),
    );
  }
}
