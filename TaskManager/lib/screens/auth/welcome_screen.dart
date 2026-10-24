import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Status Bar Stamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrutalistBadge(
                    text: 'SYSTEM // V1.0',
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.primaryInk,
                  ),
                  BrutalistBadge(
                    text: 'OFFLINE / ONLINE READY',
                    backgroundColor: AppColors.secondarySurface,
                    textColor: AppColors.primaryInk,
                  ),
                ],
              ),
              const Spacer(),

              // Giant Hero Typography Stamp
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryInk,
                      width: AppColors.borderWidth,
                    ),
                    boxShadow: AppColors.heavyHardShadow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.task_alt,
                      size: 48,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'TASK MANAGER',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'WORKFORCE COORDINATION OS',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 28),

              // Feature Highlights Card
              BrutalistCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      icon: Icons.group_work_outlined,
                      title: 'GIAO VIỆC & PHÂN QUYỀN',
                      subtitle: 'Chỉ định phụ trách chính, cấp quyền Viewer / Editor',
                    ),
                    const Divider(color: AppColors.divider, height: 20, thickness: 1),
                    _buildFeatureRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'THÔNG BÁO & EMAIL',
                      subtitle: 'Nhận email và thông báo tức thời khi có thay đổi',
                    ),
                    const Divider(color: AppColors.divider, height: 20, thickness: 1),
                    _buildFeatureRow(
                      icon: Icons.analytics_outlined,
                      title: 'THEO DÕI TIẾN ĐỘ',
                      subtitle: 'Thống kê hạn chót, mức ưu tiên và trạng thái',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons: ĐĂNG NHẬP & ĐĂNG KÝ
              BrutalistButton(
                text: 'ĐĂNG NHẬP HỆ THỐNG',
                icon: Icons.login,
                height: 52,
                backgroundColor: AppColors.primaryAccent,
                textColor: AppColors.primaryInk,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              BrutalistButton(
                text: 'TẠO TÀI KHOẢN MỚI',
                icon: Icons.person_add_alt,
                height: 52,
                backgroundColor: AppColors.cardWhite,
                textColor: AppColors.primaryInk,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Student Footer Info
              Text(
                'KHMT2411074 • HUỲNH ĐĂNG KHOA',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryInk,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
