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
import '../tasks/task_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;

  const LoginScreen({super.key, this.initialEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
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
      final user = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Thông báo thành công chuẩn Brutalist
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
              const Icon(Icons.verified_user_outlined, color: AppColors.primaryInk, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chào mừng ${user.fullName} trở lại!',
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

      // Chuyển hướng đến màn hình chính danh sách công việc
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TaskListScreen()),
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
              text: 'LOGIN GATEWAY',
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
                      icon: Icons.lock_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Title
                Text(
                  'ĐĂNG NHẬP',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: AppColors.primaryInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đăng nhập tài khoản để quản lý công việc và phân quyền nhóm.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 24),

                // Error Banner
                if (_errorMessage != null) ...[
                  BrutalistCard(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 22),
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

                // Form Container Card
                BrutalistCard(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                        hintText: 'Nhập mật khẩu tài khoản',
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
                        validator: (val) => Validators.required(val, 'Mật khẩu'),
                      ),
                      const SizedBox(height: 24),

                      // Nút Đăng nhập
                      BrutalistButton(
                        text: 'ĐĂNG NHẬP HỆ THỐNG',
                        icon: Icons.login,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 52,
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                        onPressed: _handleLogin,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Link chuyển sang Đăng ký
                BrutalistCard(
                  backgroundColor: AppColors.secondarySurface.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shadowOffset: const Offset(2, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CHƯA CÓ TÀI KHOẢN? ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'ĐĂNG KÝ NGAY',
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
