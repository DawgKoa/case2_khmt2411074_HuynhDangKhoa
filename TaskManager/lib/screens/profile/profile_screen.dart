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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _avatarUrlController.dispose();
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
      // Nếu API lỗi, thử lấy từ cache offline
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

    if (!_formKey.currentState!.validate()) {
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

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BrutalistBadge(
              text: 'PROFILE // A3',
              backgroundColor: AppColors.primaryAccent,
              textColor: AppColors.primaryInk,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Badge & Title
                      Row(
                        children: [
                          BrutalistBadge(
                            text: 'MODULE A // USER IDENTITY',
                            backgroundColor: AppColors.secondarySurface,
                            textColor: AppColors.primaryInk,
                            icon: Icons.badge_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'THÔNG TIN TÀI KHOẢN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Xem và chỉnh sửa thông tin hiển thị của bạn trên hệ thống.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error Banner nếu có
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
                            // Avatar Box
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: AppColors.primaryInk,
                                  width: AppColors.borderWidth,
                                ),
                                boxShadow: AppColors.hardShadow,
                              ),
                              child: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: Image.network(
                                        _user!.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Center(
                                          child: Text(
                                            _getInitials(_user?.fullName ?? ''),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primaryInk,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        _getInitials(_user?.fullName ?? ''),
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryInk,
                                        ),
                                      ),
                                    ),
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
                      const SizedBox(height: 20),

                      // Edit Form Card
                      BrutalistCard(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHỈNH SỬA THÔNG TIN',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryInk,
                              ),
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

                            // URL Ảnh đại diện
                            BrutalistTextField(
                              label: 'Đường dẫn ảnh đại diện (Tùy chọn)',
                              hintText: 'https://example.com/avatar.jpg',
                              controller: _avatarUrlController,
                              prefixIcon: const Icon(Icons.image_outlined, color: AppColors.primaryInk),
                            ),
                            const SizedBox(height: 24),

                            // Nút lưu thay đổi
                            BrutalistButton(
                              text: 'LƯU THAY ĐỔI',
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
