import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import 'brutalist_button.dart';
import 'brutalist_card.dart';
import 'brutalist_user_picker.dart';

class BrutalistShareModal {
  static Future<Task?> show({
    required BuildContext context,
    required Task task,
  }) {
    return showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShareModalContent(task: task),
    );
  }
}

class _ShareModalContent extends StatefulWidget {
  final Task task;

  const _ShareModalContent({required this.task});

  @override
  State<_ShareModalContent> createState() => _ShareModalContentState();
}

class _ShareModalContentState extends State<_ShareModalContent> {
  final _taskService = TaskService();
  final _emailController = TextEditingController();

  User? _selectedUser;
  String _selectedRole = 'viewer'; // viewer, editor, admin
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickUser() async {
    final results = await BrutalistUserPicker.show(
      context: context,
      title: 'CHỌN NGƯỜI DÙNG ĐỂ CHIA SẺ',
      isMultiSelect: false,
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _selectedUser = results.first;
        _emailController.text = _selectedUser!.email;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitShare() async {
    final email = _emailController.text.trim();
    if (_selectedUser == null && email.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng chọn người dùng hoặc nhập email!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedTask = await _taskService.shareTask(
        widget.task.id,
        userId: _selectedUser?.id,
        email: _selectedUser == null ? email : null,
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ĐÃ CHIA SẺ CÔNG VIỆC VỚI QUYỀN ${_selectedRole.toUpperCase()}',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryInk,
        ),
      );

      Navigator.of(context).pop(updatedTask);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: const Border(
          top: BorderSide(color: AppColors.primaryInk, width: 3),
          left: BorderSide(color: AppColors.primaryInk, width: 2),
          right: BorderSide(color: AppColors.primaryInk, width: 2),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryInk,
            offset: Offset(0, -3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primaryInk,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHIA SẺ CÔNG VIỆC // C3 (RBAC)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.primaryInk,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryInk),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_errorMessage != null) ...[
            BrutalistCard(
              backgroundColor: const Color(0xFFFED7D7),
              padding: const EdgeInsets.all(10),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Chọn người dùng
          Text(
            'CHỌN NGƯỜI ĐƯỢC CHIA SẺ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickUser,
            child: BrutalistCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: AppColors.cardWhite,
              child: Row(
                children: [
                  const Icon(Icons.person_search, color: AppColors.primaryInk, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedUser != null
                          ? '${_selectedUser!.fullName} (${_selectedUser!.email})'
                          : (_emailController.text.isNotEmpty
                              ? _emailController.text
                              : 'Nhấn để tìm kiếm hoặc chọn thành viên...'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedUser != null || _emailController.text.isNotEmpty
                            ? AppColors.primaryInk
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.primaryInk),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chọn quyền RBAC
          Text(
            'VAI TRÒ & PHÂN QUYỀN (RBAC)',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),

          _buildRoleOption(
            role: 'viewer',
            title: 'VIEWER (CHỈ XEM)',
            subtitle: 'Chỉ có quyền xem tiến độ và chi tiết, không được chỉnh sửa hay đổi trạng thái.',
            color: AppColors.secondarySurface,
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            role: 'editor',
            title: 'EDITOR (CHỈNH SỬA)',
            subtitle: 'Được quyền cập nhật nội dung, hạn chót và đổi trạng thái tiến độ công việc.',
            color: AppColors.primaryAccent,
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            role: 'admin',
            title: 'ADMIN (QUẢN TRỊ VIÊN)',
            subtitle: 'Toàn quyền quản trị công việc: chỉnh sửa, phân công, chia sẻ thêm hoặc xóa.',
            color: AppColors.danger,
            textWhite: true,
          ),
          const SizedBox(height: 20),

          // Submit button
          BrutalistButton(
            text: 'XÁC NHẬN CHIA SẺ',
            icon: Icons.share,
            backgroundColor: AppColors.primaryAccent,
            textColor: AppColors.primaryInk,
            isLoading: _isLoading,
            onPressed: _submitShare,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String title,
    required String subtitle,
    required Color color,
    bool textWhite = false,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: BrutalistCard(
        backgroundColor: isSelected ? color : AppColors.cardWhite,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected && textWhite ? Colors.white : AppColors.primaryInk,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isSelected && textWhite ? Colors.white : AppColors.primaryInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected && textWhite
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
