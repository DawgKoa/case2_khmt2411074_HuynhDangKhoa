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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Status Bar Stamp (Soft Neo-Brutalism Pill Badges)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          BrutalistBadge(
                            text: 'System // v1.0',
                            backgroundColor: AppColors.primaryAccent,
                            textColor: AppColors.primaryInk,
                            borderRadius: 20.0,
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                          ),
                          BrutalistBadge(
                            text: 'Offline / Online Ready',
                            backgroundColor: AppColors.pastelBlue,
                            textColor: AppColors.primaryInk,
                            borderRadius: 20.0,
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Spacer(),

                      // Giant Hero Icon (Soft Rounded Container with Subtle Shadow)
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(
                              color: AppColors.primaryInk,
                              width: AppColors.borderWidth,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x302C2C2C),
                                offset: Offset(2.5, 3.0),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: Color(0x10000000),
                                offset: Offset(0, 6.0),
                                blurRadius: 14.0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.task_alt_rounded,
                              size: 44,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title: TASK MANAGER
                      Text(
                        'TASK MANAGER',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle: Workforce Coordination OS (Title Case, Sans-serif)
                      Text(
                        'Workforce Coordination OS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Feature Highlights Card (Soft Neo-Brutalism Card)
                      BrutalistCard(
                        backgroundColor: AppColors.cardWhite,
                        borderRadius: 20.0,
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              icon: Icons.group_work_outlined,
                              title: 'Giao việc & Phân quyền',
                              subtitle: 'Chỉ định phụ trách chính, cấp quyền Viewer / Editor',
                            ),
                            const Divider(color: AppColors.divider, height: 18, thickness: 1.0),
                            _buildFeatureRow(
                              icon: Icons.notifications_active_outlined,
                              title: 'Thông báo & Email',
                              subtitle: 'Nhận email và thông báo tức thời khi có thay đổi',
                            ),
                            const Divider(color: AppColors.divider, height: 18, thickness: 1.0),
                            _buildFeatureRow(
                              icon: Icons.analytics_outlined,
                              title: 'Theo dõi tiến độ',
                              subtitle: 'Thống kê hạn chót, mức ưu tiên và trạng thái',
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 18),

                      // Action Buttons: Pill-shaped Buttons
                      BrutalistButton(
                        text: 'ĐĂNG NHẬP HỆ THỐNG',
                        icon: Icons.login_rounded,
                        height: 50,
                        borderRadius: 28.0,
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      BrutalistButton(
                        text: 'TẠO TÀI KHOẢN MỚI',
                        icon: Icons.person_add_alt_1_rounded,
                        height: 50,
                        borderRadius: 28.0,
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

                      // Student Footer Info (Title Case, Sans-serif)
                      Text(
                        'KHMT2411074 • Huỳnh Đăng Khoa',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
            color: AppColors.pastelYellow,
            borderRadius: BorderRadius.circular(11.0),
            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
          ),
          child: Icon(icon, size: 19, color: AppColors.primaryInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
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
