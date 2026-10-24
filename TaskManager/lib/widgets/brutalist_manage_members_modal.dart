import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import 'brutalist_badge.dart';
import 'brutalist_button.dart';
import 'brutalist_card.dart';
import 'brutalist_share_modal.dart';

class BrutalistManageMembersModal {
  static Future<Task?> show({
    required BuildContext context,
    required Task task,
  }) {
    return showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManageMembersContent(initialTask: task),
    );
  }
}

class _ManageMembersContent extends StatefulWidget {
  final Task initialTask;

  const _ManageMembersContent({required this.initialTask});

  @override
  State<_ManageMembersContent> createState() => _ManageMembersContentState();
}

class _ManageMembersContentState extends State<_ManageMembersContent> {
  final _taskService = TaskService();
  late Task _task;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.initialTask;
  }

  Future<void> _updateRole(String memberId, String newRole) async {
    setState(() => _isLoading = true);

    try {
      final updated = await _taskService.updateMemberRole(_task.id, memberId, newRole);
      if (mounted) {
        setState(() {
          _task = updated;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ĐÃ CẬP NHẬT VAI TRÒ SANG ${newRole.toUpperCase()}'),
            backgroundColor: AppColors.primaryInk,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _confirmRevoke(String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.primaryInk, width: 2),
        ),
        title: Text(
          'XÁC NHẬN THU HỒI QUYỀN',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.danger,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn thu hồi quyền truy cập và xóa thành viên "$memberName" khỏi công việc này không?',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY BỎ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          BrutalistButton(
            text: 'THU HỒI',
            icon: Icons.person_remove,
            backgroundColor: AppColors.danger,
            textColor: Colors.white,
            height: 42,
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);

              try {
                final updated = await _taskService.revokeTaskMember(_task.id, memberId);
                if (mounted) {
                  setState(() {
                    _task = updated;
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ĐÃ THU HỒI QUYỀN TRUY CẬP CỦA $memberName'),
                      backgroundColor: AppColors.primaryInk,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRoleSelector(String memberId, String currentRole) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(
            top: BorderSide(color: AppColors.primaryInk, width: 3),
            left: BorderSide(color: AppColors.primaryInk, width: 2),
            right: BorderSide(color: AppColors.primaryInk, width: 2),
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'THAY ĐỔI VAI TRÒ (C4)',
              style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _buildRoleOptionTile('viewer', 'VIEWER (CHỈ XEM)', currentRole == 'viewer', () {
              Navigator.of(ctx).pop();
              _updateRole(memberId, 'viewer');
            }),
            const SizedBox(height: 8),
            _buildRoleOptionTile('editor', 'EDITOR (CHỈNH SỬA)', currentRole == 'editor', () {
              Navigator.of(ctx).pop();
              _updateRole(memberId, 'editor');
            }),
            const SizedBox(height: 8),
            _buildRoleOptionTile('admin', 'ADMIN (QUẢN TRỊ VIÊN)', currentRole == 'admin', () {
              Navigator.of(ctx).pop();
              _updateRole(memberId, 'admin');
            }),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOptionTile(String role, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: BrutalistCard(
        backgroundColor: isSelected ? AppColors.primaryAccent : AppColors.cardWhite,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            if (isSelected) const Icon(Icons.check, size: 18, color: AppColors.primaryInk),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                'QUẢN LÝ THÀNH VIÊN // C4',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.primaryInk,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryInk),
                onPressed: () => Navigator.of(context).pop(_task),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Members count summary
          Text(
            'DANH SÁCH THÀNH VIÊN (${_task.sharedWith.length + 1})',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 10),

          // List of members
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryInk,
                      strokeWidth: 3,
                    ),
                  )
                : ListView(
                    children: [
                      // Chủ sở hữu công việc (Owner)
                      if (_task.createdBy != null) ...[
                        BrutalistCard(
                          backgroundColor: AppColors.cardWhite,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _task.createdBy!.fullName.isNotEmpty
                                      ? _task.createdBy!.fullName[0].toUpperCase()
                                      : 'O',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _task.createdBy!.fullName,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryInk,
                                      ),
                                    ),
                                    Text(
                                      _task.createdBy!.email,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              BrutalistBadge(
                                text: 'CHỦ SỞ HỮU',
                                backgroundColor: AppColors.primaryAccent,
                                textColor: AppColors.primaryInk,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Danh sách thành viên được chia sẻ (sharedWith)
                      if (_task.sharedWith.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.group_outlined, size: 40, color: AppColors.secondaryText),
                                const SizedBox(height: 8),
                                Text(
                                  'CHƯA CHIA SẺ VỚI THÀNH VIÊN NÀO',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nhấn nút bên dưới để chia sẻ công việc cho đồng nghiệp.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._task.sharedWith.map((member) {
                          final role = member.role;
                          final roleBg = role == 'admin'
                              ? AppColors.danger
                              : role == 'editor'
                                  ? AppColors.primaryAccent
                                  : AppColors.secondarySurface;
                          final roleText = role == 'admin' ? Colors.white : AppColors.primaryInk;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: BrutalistCard(
                              backgroundColor: AppColors.cardWhite,
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondarySurface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      member.user.fullName.isNotEmpty
                                          ? member.user.fullName[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryInk,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.user.fullName,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryInk,
                                          ),
                                        ),
                                        Text(
                                          member.user.email,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Role changer button
                                  GestureDetector(
                                    onTap: () => _showRoleSelector(member.user.id, member.role),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: roleBg,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            member.role.toUpperCase(),
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: roleText,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_drop_down, size: 14, color: roleText),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Revoke button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                    tooltip: 'Thu hồi quyền truy cập',
                                    onPressed: () => _confirmRevoke(member.user.id, member.user.fullName),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
          ),
          const SizedBox(height: 12),

          // Add more button
          BrutalistButton(
            text: '+ CHIA SẺ THÊM THÀNH VIÊN',
            icon: Icons.person_add,
            backgroundColor: AppColors.primaryAccent,
            textColor: AppColors.primaryInk,
            onPressed: () async {
              final updated = await BrutalistShareModal.show(context: context, task: _task);
              if (updated != null && mounted) {
                setState(() => _task = updated);
              }
            },
          ),
        ],
      ),
    );
  }
}
