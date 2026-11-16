import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Huy hiệu nhãn phong cách Soft Neo-Brutalism (Viên thuốc Pill-shape, viền than 1.2px, sans-serif bo tròn)
class BrutalistBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isUppercase;

  const BrutalistBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.primaryAccent,
    this.textColor = AppColors.primaryInk,
    this.icon,
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    this.borderRadius = 20.0,
    this.isUppercase = false,
  });

  factory BrutalistBadge.priority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const BrutalistBadge(
          text: 'Ưu tiên cao',
          backgroundColor: AppColors.pastelRed,
          textColor: Color(0xFFDC2626),
          icon: Icons.priority_high_rounded,
        );
      case 'medium':
        return const BrutalistBadge(
          text: 'Trung bình',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
        );
      case 'low':
      default:
        return const BrutalistBadge(
          text: 'Thấp',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.secondaryText,
        );
    }
  }

  factory BrutalistBadge.status(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const BrutalistBadge(
          text: 'Đã hoàn thành',
          backgroundColor: AppColors.pastelGreen,
          textColor: Color(0xFF15803D),
          icon: Icons.check_circle_outline_rounded,
        );
      case 'in_progress':
        return const BrutalistBadge(
          text: 'Đang thực hiện',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
          icon: Icons.timelapse_rounded,
        );
      case 'cancelled':
        return const BrutalistBadge(
          text: 'Đã hủy',
          backgroundColor: AppColors.pastelRed,
          textColor: Color(0xFFB91C1C),
          icon: Icons.cancel_outlined,
        );
      case 'todo':
      default:
        return const BrutalistBadge(
          text: 'Chưa thực hiện',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.secondaryText,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primaryInk,
          width: AppColors.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x182C2C2C),
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2.5, color: textColor),
            const SizedBox(width: 4.5),
          ],
          Text(
            isUppercase ? text.toUpperCase() : text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
