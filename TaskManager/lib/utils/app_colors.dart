import 'package:flutter/material.dart';

/// Bảng màu chuẩn Nivora Brutalist (Mobile Neo-Brutalism & Warm Retro-Industrial)
class AppColors {
  AppColors._();

  /// Nền chính: Kem giấy ấm (Scaffold Background)
  static const Color scaffoldBackground = Color(0xFFEFEDE0);

  /// Viền, chữ chính, bóng cứng & thẻ tối (Primary Ink / Dark Card)
  static const Color primaryInk = Color(0xFF050504);

  /// Màu nhấn chính: Vàng nghệ (Active Button, Progress, Highlight)
  static const Color primaryAccent = Color(0xFFF6B400);

  /// Màu khẩn cấp / Ưu tiên cao / Báo lỗi (Danger / Urgent / Overdue)
  static const Color danger = Color(0xFFF61F01);

  /// Bề mặt thẻ phụ: Xám đá ấm (Secondary Surface)
  static const Color secondarySurface = Color(0xFFB5B4AC);

  /// Chữ phụ / Icon không hoạt động (Deep Brownish Grey)
  static const Color secondaryText = Color(0xFF5E584C);

  /// Đường kẻ phân cách (Light Moss Grey)
  static const Color divider = Color(0xFF7E817B);

  /// Bề mặt thẻ sáng / Ruột ô nhập liệu
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Màu hoàn thành / Thành công
  static const Color success = Color(0xFF1E824C);

  /// Độ dày viền mực chuẩn
  static const double borderWidth = 2.0;

  /// Đổ bóng cứng chuẩn không làm mờ (Hard Drop Shadow)
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: primaryInk,
      offset: Offset(3.0, 3.0),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  /// Đổ bóng cứng đậm hơn cho Hero Card hoặc Dialog
  static const List<BoxShadow> heavyHardShadow = [
    BoxShadow(
      color: primaryInk,
      offset: Offset(5.0, 5.0),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];
}
