import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Huy hiệu nhãn chuẩn Nivora Brutalist (Viền đen 1.5px, chữ JetBrains Mono in hoa)
class BrutalistBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BrutalistBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.primaryAccent,
    this.textColor = AppColors.primaryInk,
    this.icon,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  });

  factory BrutalistBadge.priority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const BrutalistBadge(
          text: 'HIGH',
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          icon: Icons.priority_high,
        );
      case 'medium':
        return const BrutalistBadge(
          text: 'MEDIUM',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
        );
      case 'low':
      default:
        return const BrutalistBadge(
          text: 'LOW',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.primaryInk,
        );
    }
  }

  factory BrutalistBadge.status(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const BrutalistBadge(
          text: 'COMPLETED',
          backgroundColor: AppColors.success,
          textColor: Colors.white,
          icon: Icons.check,
        );
      case 'in_progress':
        return const BrutalistBadge(
          text: 'IN PROGRESS',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
          icon: Icons.timelapse,
        );
      case 'todo':
      default:
        return const BrutalistBadge(
          text: 'TODO',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.primaryInk,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: AppColors.primaryInk,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: GoogleFonts.jetbrainsMono(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
