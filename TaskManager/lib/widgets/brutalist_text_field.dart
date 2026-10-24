import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Ô nhập liệu chuẩn Nivora Brutalist (Viền đen 2px, bóng cứng Offset(3,3), nhãn Mono sắc nét)
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
          widget.label.toUpperCase(),
          style: GoogleFonts.jetbrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        const SizedBox(height: 6),
        // Input Box with Hard Shadow
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.cardWhite : AppColors.secondarySurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: _errorText != null ? AppColors.danger : AppColors.primaryInk,
              width: AppColors.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryInk,
                offset: Offset(3.0, 3.0),
                blurRadius: 0,
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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryInk,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText.withOpacity(0.7),
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0), // Hidden inside standard field
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
