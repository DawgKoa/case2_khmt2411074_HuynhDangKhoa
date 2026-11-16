import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Thẻ Card chuẩn Soft Neo-Brutalism (Viền than mảnh 1.2px, bo góc 18px, bóng đổ êm ái)
class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final List<BoxShadow>? customShadow;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.cardWhite,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderWidth = AppColors.borderWidth,
    this.borderRadius = AppColors.cardRadius,
    this.shadowOffset = const Offset(2.0, 2.5),
    this.customShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primaryInk,
          width: borderWidth,
        ),
        boxShadow: customShadow ??
            [
              BoxShadow(
                color: const Color(0x282C2C2C),
                offset: shadowOffset,
                blurRadius: 0,
                spreadRadius: 0,
              ),
              const BoxShadow(
                color: Color(0x0A000000),
                offset: Offset(0, 4.0),
                blurRadius: 8.0,
                spreadRadius: 0,
              ),
            ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
