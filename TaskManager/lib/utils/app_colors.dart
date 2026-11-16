import 'package:flutter/material.dart';

/// Bảng màu phong cách Soft Neo-Brutalism (Mềm mại, hiện đại, ấm áp & tinh tế)
class AppColors {
  AppColors._();

  /// Nền chính: Kem giấy ấm nhẹ nhàng (Scaffold Background)
  static const Color scaffoldBackground = Color(0xFFF7F5EE);

  /// Viền, chữ chính & thẻ tối: Xám than đậm tinh tế (#2C2C2C) thay cho đen tuyền
  static const Color primaryInk = Color(0xFF2C2C2C);

  /// Màu nhấn chính: Vàng pastel ấm / Amber dịu (Warm Pastel Yellow / Soft Amber)
  static const Color primaryAccent = Color(0xFFFEE07C);

  /// Màu nhấn phụ: Vàng bơ nhạt dịu mắt
  static const Color pastelYellow = Color(0xFFFEF3C7);

  /// Màu xanh pastel nhạt: Dùng cho trạng thái Online, Sẵn sàng, Thẻ thông tin
  static const Color pastelBlue = Color(0xFFE0F2FE);

  /// Màu xanh ngọc / lá pastel: Trạng thái hoàn thành, thành công
  static const Color pastelGreen = Color(0xFFDCFCE7);

  /// Màu trắng ngà ấm nhẹ (Ivory Soft)
  static const Color pastelIvory = Color(0xFFFDFBF7);

  /// Màu đỏ pastel dịu: Khẩn cấp / Ưu tiên cao / Quá hạn
  static const Color danger = Color(0xFFF87171);

  /// Màu đỏ pastel nhạt cho nền badge cảnh báo
  static const Color pastelRed = Color(0xFFFEE2E2);

  /// Bề mặt thẻ phụ / badge trung tính (Đổi từ xám cứng sang trắng ngà ấm)
  static const Color secondarySurface = Color(0xFFF4F1EA);

  /// Chữ phụ / Subtitle (Xám than trung tính, dễ đọc)
  static const Color secondaryText = Color(0xFF6B6963);

  /// Đường kẻ phân cách mảnh tinh tế
  static const Color divider = Color(0xFFE5E2D9);

  /// Bề mặt thẻ sáng / Ruột ô nhập liệu
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Màu hoàn thành / Thành công
  static const Color success = Color(0xFF10B981);

  /// Độ dày viền mảnh tinh tế theo phong cách Soft Neo-Brutalism (1.2px)
  static const double borderWidth = 1.2;

  /// Độ bo góc chuẩn cho card lớn (18px - 20px)
  static const double cardRadius = 18.0;

  /// Độ bo góc cho nút bấm và badge (Kiểu viên thuốc Pill-shape)
  static const double pillRadius = 28.0;

  /// Đổ bóng mỏng nhẹ tinh tế Soft Neo-Brutalism (Offset 2.0, 2.5px với viền xám than và bóng mờ nhẹ)
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: Color(0x2E2C2C2C),
      offset: Offset(2.0, 2.5),
      blurRadius: 0,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 4.0),
      blurRadius: 10.0,
      spreadRadius: 0,
    ),
  ];

  /// Đổ bóng mỏng nhẹ cho Card lớn / Modal Dialog
  static const List<BoxShadow> heavyHardShadow = [
    BoxShadow(
      color: Color(0x382C2C2C),
      offset: Offset(3.0, 3.5),
      blurRadius: 0,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 6.0),
      blurRadius: 14.0,
      spreadRadius: 0,
    ),
  ];
}
