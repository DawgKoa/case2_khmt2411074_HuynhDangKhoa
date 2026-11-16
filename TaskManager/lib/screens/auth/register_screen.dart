import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Hiển thị thông báo thành công chuẩn Brutalist
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
              const Icon(Icons.check_circle, color: AppColors.primaryInk, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đăng ký thành công tài khoản ${user.fullName}!',
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

      // Chuyển hướng sang màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: user.email),
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
          'Đăng ký tài khoản',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Title
                Text(
                  'Tạo tài khoản mới',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.primaryInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đăng ký thành viên để bắt đầu quản lý và phân công công việc.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
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

                // Input Card Form
                BrutalistCard(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Họ và tên
                      BrutalistTextField(
                        label: 'Họ và tên',
                        hintText: 'VD: Huỳnh Đăng Khoa',
                        controller: _fullNameController,
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryInk),
                        validator: (val) => Validators.required(val, 'Họ và tên'),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      BrutalistTextField(
                        label: 'Email',
                        hintText: 'VD: user@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryInk),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),

                      // Mật khẩu
                      BrutalistTextField(
                        label: 'Mật khẩu',
                        hintText: 'Tối thiểu 6 ký tự',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryInk),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.primaryInk,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 16),

                      // Xác nhận mật khẩu
                      BrutalistTextField(
                        label: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu ở trên',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primaryInk),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.primaryInk,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (val) => Validators.confirmPassword(val, _passwordController.text),
                      ),
                      const SizedBox(height: 24),

                      // Nút Đăng ký
                      BrutalistButton(
                        text: 'Đăng ký',
                        icon: Icons.arrow_forward_rounded,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 52,
                        borderRadius: 28.0,
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Link chuyển sang Đăng nhập
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  borderRadius: 16.0,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shadowOffset: const Offset(2, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
                          'Đăng nhập ngay',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
