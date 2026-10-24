import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Cấu hình Theme chuẩn phong cách Nivora Brutalist
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryAccent,
        onPrimary: AppColors.primaryInk,
        surface: AppColors.scaffoldBackground,
        onSurface: AppColors.primaryInk,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1.5,
        space: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldBackground,
        foregroundColor: AppColors.primaryInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryInk,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: TextTheme(
        // Tiêu đề lớn (Space Grotesk)
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryInk,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryInk,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryInk,
        ),
        // Tiêu đề con & Thẻ (Space Grotesk)
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryInk,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryInk,
        ),
        // Nhãn, Deadline, Trạng thái (JetBrains Mono UPPERCASE)
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: AppColors.primaryInk,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: AppColors.primaryInk,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.secondaryText,
        ),
        // Nội dung chính (Inter)
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryInk,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryInk,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
