import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Thẻ Card chuẩn Nivora Brutalist (Viền đen 2px, bóng cứng Offset(3,3), không blur)
class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.cardWhite,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderWidth = AppColors.borderWidth,
    this.borderRadius = 8.0,
    this.shadowOffset = const Offset(3.0, 3.0),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryInk,
            offset: shadowOffset,
            blurRadius: 0,
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
