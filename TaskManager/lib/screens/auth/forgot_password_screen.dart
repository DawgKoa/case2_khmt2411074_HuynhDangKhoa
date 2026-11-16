import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _emailController;
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _obscureNewPw = true;
  bool _obscureConfirmPw = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.forgotPassword(
        email: _emailController.text,
      );

      setState(() {
        _isOtpSent = true;
        _otpController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.primaryInk, width: 2),
          ),
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_outlined, color: AppColors.primaryInk, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đã gửi mã OTP đến ${_emailController.text}!',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.primaryInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_resetFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _authService.resetPassword(
        email: _emailController.text,
        otp: _otpController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      // Hiển thị Dialog thông báo thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.primaryInk, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 28),
              const SizedBox(width: 10),
              Text(
                'ĐẶT LẠI THÀNH CÔNG',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryInk,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryInk,
            ),
          ),
          actions: [
            BrutalistButton(
              text: 'ĐĂNG NHẬP NGAY',
              backgroundColor: AppColors.primaryAccent,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(initialEmail: _emailController.text),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Quên mật khẩu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryInk,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge & Title
              Row(
                children: [
                  BrutalistBadge(
                    text: _isOtpSent ? 'Bước 2: Đổi mật khẩu mới' : 'Bước 1: Nhận mã xác thực OTP',
                    backgroundColor: _isOtpSent ? AppColors.pastelGreen : AppColors.pastelYellow,
                    textColor: _isOtpSent ? const Color(0xFF15803D) : AppColors.primaryInk,
                    icon: _isOtpSent ? Icons.verified_outlined : Icons.lock_reset_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Đặt lại mật khẩu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isOtpSent
                    ? 'Nhập mã OTP 6 số đã gửi đến email của bạn và đặt mật khẩu mới.'
                    : 'Nhập email đã đăng ký. Hệ thống sẽ gửi mã xác thực OTP 6 số để bạn thiết lập lại mật khẩu.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 24),

              // Error Banner nếu có
              if (_errorMessage != null) ...[
                BrutalistCard(
                  backgroundColor: AppColors.pastelRed,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Bước 1: Form nhập Email
              if (!_isOtpSent) ...[
                Form(
                  key: _emailFormKey,
                  child: BrutalistCard(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        BrutalistTextField(
                          label: 'Email tài khoản',
                          hintText: 'VD: user@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryInk),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 24),
                        BrutalistButton(
                          text: 'Gửi mã xác thực OTP',
                          icon: Icons.send_rounded,
                          isLoading: _isLoading,
                          width: double.infinity,
                          height: 52,
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          onPressed: _handleSendOtp,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Bước 2: Form nhập OTP và Mật khẩu mới
                Form(
                  key: _resetFormKey,
                  child: BrutalistCard(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Email (cố định)
                        BrutalistTextField(
                          label: 'Email nhận mã',
                          enabled: false,
                          controller: _emailController,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 16),

                        // Ô nhập mã OTP 6 số
                        BrutalistTextField(
                          label: 'Mã xác thực OTP (6 số)',
                          hintText: '123456',
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primaryInk),
                          validator: (val) {
                            if (val == null || val.trim().length != 6) {
                              return 'Mã OTP phải gồm đúng 6 chữ số';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Mật khẩu mới
                        BrutalistTextField(
                          label: 'Mật khẩu mới',
                          hintText: 'Tối thiểu 6 ký tự',
                          controller: _newPasswordController,
                          obscureText: _obscureNewPw,
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryInk),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.primaryInk,
                            ),
                            onPressed: () => setState(() => _obscureNewPw = !_obscureNewPw),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),

                        // Xác nhận mật khẩu mới
                        BrutalistTextField(
                          label: 'Xác nhận mật khẩu mới',
                          hintText: 'Nhập lại mật khẩu mới',
                          controller: _confirmNewPasswordController,
                          obscureText: _obscureConfirmPw,
                          prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primaryInk),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.primaryInk,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPw = !_obscureConfirmPw),
                          ),
                          validator: (val) => Validators.confirmPassword(val, _newPasswordController.text),
                        ),
                        const SizedBox(height: 24),

                        // Nút Đổi mật khẩu
                        BrutalistButton(
                          text: 'Xác nhận đặt lại mật khẩu',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: _isLoading,
                          width: double.infinity,
                          height: 52,
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          onPressed: _handleResetPassword,
                        ),
                        const SizedBox(height: 12),

                        // Nút gửi lại mã OTP
                        TextButton.icon(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.secondaryText),
                          label: Text(
                            'Gửi lại mã OTP mới',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Nút quay lại đăng nhập
              BrutalistCard(
                backgroundColor: AppColors.secondarySurface.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shadowOffset: const Offset(2, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bạn đã nhớ mật khẩu? ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Quay lại đăng nhập',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryInk,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
