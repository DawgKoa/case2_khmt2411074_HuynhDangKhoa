import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import 'brutalist_card.dart';

class QuickStatusBottomSheet {
  static void show({
    required BuildContext context,
    required Task task,
    required Function(Task updatedTask) onUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _QuickStatusModalContent(
        task: task,
        onUpdated: onUpdated,
      ),
    );
  }
}

class _QuickStatusModalContent extends StatefulWidget {
  final Task task;
  final Function(Task updatedTask) onUpdated;

  const _QuickStatusModalContent({
    required this.task,
    required this.onUpdated,
  });

  @override
  State<_QuickStatusModalContent> createState() => _QuickStatusModalContentState();
}

class _QuickStatusModalContentState extends State<_QuickStatusModalContent> {
  final _taskService = TaskService();
  bool _isLoading = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
  }

  Future<void> _updateStatus(String status) async {
    if (status == widget.task.status) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedStatus = status;
    });

    try {
      final updated = await _taskService.updateTaskStatus(widget.task.id, status);
      if (!mounted) return;

      widget.onUpdated(updated);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ĐÃ ĐỔI TRẠNG THÁI THÀNH CÔNG',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryInk,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'LỖI: ${e.toString().replaceAll('Exception: ', '')}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Drag handle bar
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

          Text(
            'CHUYỂN TRẠNG THÁI NHANH (B4)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 18),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryInk,
                  strokeWidth: 3,
                ),
              ),
            )
          else ...[
            _buildStatusOption(
              status: 'todo',
              title: 'CHỜ XỬ LÝ (TODO)',
              subtitle: 'Công việc mới tiếp nhận hoặc chưa bắt đầu',
              color: AppColors.secondarySurface,
              icon: Icons.hourglass_empty,
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              status: 'in_progress',
              title: 'ĐANG LÀM (IN PROGRESS)',
              subtitle: 'Đang trong quá trình triển khai thực hiện',
              color: AppColors.primaryAccent,
              icon: Icons.sync,
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              status: 'completed',
              title: 'HOÀN THÀNH (COMPLETED)',
              subtitle: 'Đã hoàn tất toàn bộ yêu cầu công việc',
              color: const Color(0xFF9AE6B4),
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              status: 'cancelled',
              title: 'ĐÃ HỦY (CANCELLED)',
              subtitle: 'Hủy bỏ không tiếp tục thực hiện',
              color: AppColors.danger,
              icon: Icons.cancel_outlined,
              textWhite: true,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String status,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    bool textWhite = false,
  }) {
    final isCurrent = _selectedStatus == status;

    return GestureDetector(
      onTap: () => _updateStatus(status),
      child: BrutalistCard(
        backgroundColor: isCurrent ? color : AppColors.cardWhite,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrent && textWhite ? Colors.white : AppColors.primaryInk,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCurrent && textWhite ? AppColors.danger : Colors.white,
              ),
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
                      fontWeight: FontWeight.w800,
                      color: isCurrent && textWhite ? Colors.white : AppColors.primaryInk,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isCurrent && textWhite
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Icon(
                Icons.check,
                color: textWhite ? Colors.white : AppColors.primaryInk,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
