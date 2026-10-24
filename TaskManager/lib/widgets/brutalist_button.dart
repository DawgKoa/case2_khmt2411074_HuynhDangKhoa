import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Nút bấm chuẩn Nivora Brutalist với hiệu ứng nhấn chìm vật lý (Tactile physical tap)
class BrutalistButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final double borderRadius;

  const BrutalistButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.primaryAccent,
    this.textColor = AppColors.primaryInk,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.width,
    this.borderRadius = 8.0,
  });

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;
    final double offset = _isPressed ? 0.0 : 3.0;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(_isPressed ? 3.0 : 0.0, _isPressed ? 3.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: isEnabled ? widget.backgroundColor : AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: AppColors.primaryInk,
            width: AppColors.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryInk,
              offset: Offset(offset, offset),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      color: widget.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
