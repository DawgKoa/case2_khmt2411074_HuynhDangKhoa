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

      // Chuyển hướng hoặc reset form
      _passwordController.clear();
      _confirmPasswordController.clear();
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
          'TASK MANAGER // OS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BrutalistBadge(
              text: 'V1.0',
              backgroundColor: AppColors.secondarySurface,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: AppColors.primaryInk,
            height: 2,
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
                // Tag & Badge
                Row(
                  children: [
                    BrutalistBadge(
                      text: 'MODULE A // AUTHENTICATION',
                      backgroundColor: AppColors.primaryAccent,
                      textColor: AppColors.primaryInk,
                      icon: Icons.shield_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Title
                Text(
                  'TẠO TÀI KHOẢN',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
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
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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
                        text: 'ĐĂNG KÝ TÀI KHOẢN',
                        icon: Icons.arrow_forward,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 52,
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
                  backgroundColor: AppColors.secondarySurface.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shadowOffset: const Offset(2, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ĐÃ CÓ TÀI KHOẢN? ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Điều hướng sang đăng nhập khi làm chức năng A2
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng Đăng nhập (A2) sẽ hoàn thiện ở bước tiếp theo!')),
                          );
                        },
                        child: Text(
                          'ĐĂNG NHẬP NGAY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
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
      ),
    );
  }
}
