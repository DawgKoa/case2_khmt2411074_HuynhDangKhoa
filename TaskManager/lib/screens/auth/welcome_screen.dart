import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // Hero Icon trung tâm
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
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
                              size: 46,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tên ứng dụng
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
                      const SizedBox(height: 8),

                      // Mô tả phụ tiếng Việt thân thiện
                      Text(
                        'Ứng dụng quản lý và giao việc nhóm',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Thẻ tóm tắt tính năng chính
                      BrutalistCard(
                        backgroundColor: AppColors.cardWhite,
                        borderRadius: 20.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              icon: Icons.group_work_outlined,
                              title: 'Giao việc & Phân quyền',
                              subtitle: 'Chỉ định người phụ trách chính, cấp quyền xem hoặc chỉnh sửa',
                            ),
                            const Divider(color: AppColors.divider, height: 20, thickness: 1.0),
                            _buildFeatureRow(
                              icon: Icons.notifications_active_outlined,
                              title: 'Thông báo & Email',
                              subtitle: 'Nhận thông báo và email tự động khi có thay đổi công việc',
                            ),
                            const Divider(color: AppColors.divider, height: 20, thickness: 1.0),
                            _buildFeatureRow(
                              icon: Icons.analytics_outlined,
                              title: 'Theo dõi tiến độ',
                              subtitle: 'Thống kê hạn hoàn thành, mức độ ưu tiên và trạng thái',
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      // Nút Đăng nhập & Đăng ký
                      BrutalistButton(
                        text: 'Đăng nhập',
                        icon: Icons.login_rounded,
                        height: 52,
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
                      const SizedBox(height: 12),

                      BrutalistButton(
                        text: 'Đăng ký tài khoản',
                        icon: Icons.person_add_alt_1_rounded,
                        height: 52,
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
                      const SizedBox(height: 20),

                      // Thông tin sinh viên thực hiện
                      Text(
                        'Huỳnh Đăng Khoa • KHMT2411074',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.pastelYellow,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryInk),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
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
