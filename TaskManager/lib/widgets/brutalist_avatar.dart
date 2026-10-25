import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class BrutalistAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final TextStyle? textStyle;

  const BrutalistAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 40.0,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.textStyle,
  });

  /// Danh sách Preset Avatar không phụ thuộc mạng, hoạt động offline 100%
  static final Map<String, ({IconData icon, Color bg, Color fg, String label})> presets = {
    'preset:bot': (
      icon: Icons.smart_toy_outlined,
      bg: AppColors.primaryAccent,
      fg: AppColors.primaryInk,
      label: 'BOT'
    ),
    'preset:dev': (
      icon: Icons.terminal,
      bg: AppColors.primaryInk,
      fg: Colors.white,
      label: 'DEV'
    ),
    'preset:lead': (
      icon: Icons.bolt,
      bg: AppColors.danger,
      fg: Colors.white,
      label: 'LEAD'
    ),
    'preset:rocket': (
      icon: Icons.rocket_launch_outlined,
      bg: AppColors.primaryAccent,
      fg: AppColors.primaryInk,
      label: 'PRO'
    ),
    'preset:brain': (
      icon: Icons.psychology_outlined,
      bg: const Color(0xFF9AE6B4),
      fg: AppColors.primaryInk,
      label: 'ARCH'
    ),
    'preset:shield': (
      icon: Icons.shield_outlined,
      bg: AppColors.secondarySurface,
      fg: AppColors.primaryInk,
      label: 'OPS'
    ),
  };

  String _getInitials(String val) {
    if (val.trim().isEmpty) return '?';
    final parts = val.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        Border.all(
          color: AppColors.primaryInk,
          width: size > 32 ? 2.0 : 1.5,
        );

    final effectiveRadius = shape == BoxShape.circle
        ? null
        : (borderRadius ?? BorderRadius.circular(size * 0.2));

    final effectiveBg = backgroundColor ?? AppColors.primaryAccent;
    final initials = _getInitials(name);
    final fontSize = size * 0.38;

    Widget fallbackContent = Center(
      child: Text(
        initials,
        style: textStyle ??
            GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryInk,
            ),
      ),
    );

    // Kiểm tra xem có phải preset avatar không
    final trimmedUrl = avatarUrl?.trim();
    if (trimmedUrl != null && presets.containsKey(trimmedUrl)) {
      final p = presets[trimmedUrl]!;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: p.bg,
          shape: shape,
          borderRadius: effectiveRadius,
          border: effectiveBorder,
        ),
        child: Center(
          child: Icon(
            p.icon,
            size: size * 0.55,
            color: p.fg,
          ),
        ),
      );
    }

    // Kiểm tra xem có phải link ảnh web không (http / https)
    final isNetworkUrl = trimmedUrl != null &&
        trimmedUrl.isNotEmpty &&
        (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://'));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: shape,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(size)
            : (effectiveRadius ?? BorderRadius.zero),
        child: isNetworkUrl
            ? Image.network(
                trimmedUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallbackContent,
              )
            : fallbackContent,
      ),
    );
  }
}
