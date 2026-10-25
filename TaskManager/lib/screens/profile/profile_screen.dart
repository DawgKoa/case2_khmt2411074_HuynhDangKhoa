import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';
import '../../widgets/brutalist_avatar.dart';
import '../auth/login_screen.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _obscureCurrentPw = true;
  bool _obscureNewPw = true;
  bool _obscureConfirmNewPw = true;

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  String? _errorMessage;
  String? _passwordErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _avatarUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getProfile();
      setState(() {
        _user = user;
        _fullNameController.text = user.fullName;
        _avatarUrlController.text = user.avatarUrl ?? '';
      });
    } catch (e) {
      final cachedUser = await _authService.getCurrentUser();
      setState(() {
        _user = cachedUser;
        if (cachedUser != null) {
          _fullNameController.text = cachedUser.fullName;
          _avatarUrlController.text = cachedUser.avatarUrl ?? '';
        }
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

  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await _authService.updateProfile(
        fullName: _fullNameController.text,
        avatarUrl: _avatarUrlController.text,
      );

      setState(() {
        _user = updatedUser;
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
              const Icon(Icons.check_circle_outline, color: AppColors.primaryInk, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cập nhật thông tin cá nhân thành công!',
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
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _passwordErrorMessage = null;
    });

    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      // Hiển thị Dialog thông báo thành công và chuyển hướng đăng nhập lại
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
              const Icon(Icons.lock_reset, color: AppColors.primaryAccent, size: 28),
              const SizedBox(width: 10),
              Text(
                'ĐỔI MẬT KHẨU THÀNH CÔNG',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryInk,
                ),
              ),
            ],
          ),
          content: Text(
            'Mật khẩu của bạn đã được cập nhật thành công. Vì lý do an toàn, phiên làm việc đã kết thúc. Vui lòng đăng nhập lại bằng mật khẩu mới.',
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordErrorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.primaryInk, width: 2),
        ),
        title: Text(
          'XÁC NHẬN ĐĂNG XUẤT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryInk,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống Task Manager?',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          BrutalistButton(
            text: 'ĐĂNG XUẤT',
            icon: Icons.logout,
            backgroundColor: AppColors.danger,
            textColor: Colors.white,
            height: 42,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String createdDateStr = _user?.createdAt != null
        ? dateFormat.format(_user!.createdAt!.toLocal())
        : 'Chưa có thông tin';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'HỒ SƠ CÁ NHÂN',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryInk),
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutConfirmDialog,
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryInk,
                strokeWidth: 3,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Badge & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BrutalistBadge(
                          text: 'MODULE A // PROFILE & SECURITY',
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          icon: Icons.shield_outlined,
                        ),
                        BrutalistBadge(
                          text: 'A4 READY',
                          backgroundColor: AppColors.secondarySurface,
                          textColor: AppColors.primaryInk,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'TÀI KHOẢN & BẢO MẬT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quản lý thông tin hồ sơ và đổi mật khẩu bảo mật tài khoản.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Banner hồ sơ nếu có
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

                    // Profile Hero Card
                    BrutalistCard(
                      backgroundColor: AppColors.cardWhite,
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          // Avatar Box (Synchronized BrutalistAvatar)
                          BrutalistAvatar(
                            avatarUrl: _avatarUrlController.text.isNotEmpty
                                ? _avatarUrlController.text
                                : _user?.avatarUrl,
                            name: _user?.fullName ?? 'U',
                            size: 68,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          const SizedBox(width: 16),

                          // User Info preview
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.fullName ?? 'Chưa cập nhật',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryInk,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user?.email ?? '',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'NGÀY TẠO: $createdDateStr',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondaryText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Chỉnh sửa thông tin
                    Form(
                      key: _profileFormKey,
                      child: BrutalistCard(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_outlined, color: AppColors.primaryInk, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'CHỈNH SỬA THÔNG TIN',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Họ và tên
                            BrutalistTextField(
                              label: 'Họ và tên',
                              hintText: 'Nhập họ và tên đầy đủ',
                              controller: _fullNameController,
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryInk),
                              validator: (val) => Validators.required(val, 'Họ và tên'),
                            ),
                            const SizedBox(height: 16),

                            // Email (Read only)
                            BrutalistTextField(
                              label: 'Email (Cố định)',
                              hintText: _user?.email ?? '',
                              enabled: false,
                              controller: TextEditingController(text: _user?.email ?? ''),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 16),

                            // Chọn nhanh Preset Avatar
                            Text(
                              'CHỌN AVATAR NHANH (HOẶC NHẬP LINK WEB)',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondaryText,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: BrutalistAvatar.presets.entries.map((entry) {
                                  final isSelected = _avatarUrlController.text.trim() == entry.key;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _avatarUrlController.text = entry.key;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? AppColors.danger : Colors.transparent,
                                                width: 2.5,
                                              ),
                                            ),
                                            child: BrutalistAvatar(
                                              avatarUrl: entry.key,
                                              name: entry.value.label,
                                              size: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.value.label,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                              color: isSelected ? AppColors.danger : AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // URL Ảnh đại diện
                            BrutalistTextField(
                              label: 'Đường dẫn ảnh đại diện (Tùy chọn)',
                              hintText: 'https://example.com/avatar.jpg',
                              controller: _avatarUrlController,
                              prefixIcon: const Icon(Icons.image_outlined, color: AppColors.primaryInk),
                            ),
                            const SizedBox(height: 24),

                            // Nút lưu thay đổi hồ sơ
                            BrutalistButton(
                              text: 'LƯU THAY ĐỔI HỒ SƠ',
                              icon: Icons.save_outlined,
                              isLoading: _isSaving,
                              width: double.infinity,
                              height: 52,
                              backgroundColor: AppColors.primaryAccent,
                              textColor: AppColors.primaryInk,
                              onPressed: _handleSave,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Đổi Mật Khẩu (A4)
                    Form(
                      key: _passwordFormKey,
                      child: BrutalistCard(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.password_outlined, color: AppColors.primaryInk, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'ĐỔI MẬT KHẨU',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nhập mật khẩu cũ và đặt mật khẩu mới tối thiểu 6 ký tự.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Error Banner đổi mật khẩu nếu có
                            if (_passwordErrorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _passwordErrorMessage!,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Mật khẩu hiện tại
                            BrutalistTextField(
                              label: 'Mật khẩu hiện tại',
                              hintText: 'Nhập mật khẩu cũ',
                              controller: _currentPasswordController,
                              obscureText: _obscureCurrentPw,
                              prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppColors.primaryInk),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrentPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.primaryInk,
                                ),
                                onPressed: () => setState(() => _obscureCurrentPw = !_obscureCurrentPw),
                              ),
                              validator: (val) => Validators.required(val, 'Mật khẩu hiện tại'),
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
                              obscureText: _obscureConfirmNewPw,
                              prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primaryInk),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmNewPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.primaryInk,
                                ),
                                onPressed: () => setState(() => _obscureConfirmNewPw = !_obscureConfirmNewPw),
                              ),
                              validator: (val) => Validators.confirmPassword(val, _newPasswordController.text),
                            ),
                            const SizedBox(height: 24),

                            // Nút Đổi mật khẩu
                            BrutalistButton(
                              text: 'CẬP NHẬT MẬT KHẨU',
                              icon: Icons.key_outlined,
                              isLoading: _isChangingPassword,
                              width: double.infinity,
                              height: 52,
                              backgroundColor: AppColors.cardWhite,
                              textColor: AppColors.primaryInk,
                              onPressed: _handleChangePassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Nút Đăng Xuất (A4)
                    BrutalistButton(
                      text: 'ĐĂNG XUẤT KHỎI HỆ THỐNG',
                      icon: Icons.logout,
                      height: 50,
                      backgroundColor: AppColors.danger,
                      textColor: Colors.white,
                      onPressed: _showLogoutConfirmDialog,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
    );
  }
}
