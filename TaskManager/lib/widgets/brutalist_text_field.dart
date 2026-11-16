import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Ô nhập liệu chuẩn Soft Neo-Brutalism (Viền than mảnh 1.2px, bo góc 14px, bóng nhẹ êm ái)
class BrutalistTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const BrutalistTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<BrutalistTextField> createState() => _BrutalistTextFieldState();
}

class _BrutalistTextFieldState extends State<BrutalistTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: AppColors.primaryInk,
          ),
        ),
        const SizedBox(height: 7),
        // Input Box with Soft Neo-Brutalist Shadow
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.cardWhite : AppColors.secondarySurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: _errorText != null ? AppColors.danger : AppColors.primaryInk,
              width: AppColors.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x222C2C2C),
                offset: Offset(2.0, 2.0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x08000000),
                offset: Offset(0, 3.0),
                blurRadius: 6.0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            onChanged: (val) {
              if (widget.validator != null) {
                setState(() {
                  _errorText = widget.validator!(val);
                });
              }
              if (widget.onChanged != null) {
                widget.onChanged!(val);
              }
            },
            validator: (val) {
              final err = widget.validator?.call(val);
              setState(() {
                _errorText = err;
              });
              return err;
            },
            style: GoogleFonts.inter(
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryInk,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14.5,
                color: AppColors.secondaryText.withValues(alpha: 0.6),
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              _errorText!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
