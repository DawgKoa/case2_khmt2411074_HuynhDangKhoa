import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/quick_status_bottom_sheet.dart';
import 'task_edit_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final Task? initialTask;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.initialTask,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _taskService = TaskService();

  Task? _task;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _task = widget.initialTask;
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    setState(() {
      _isLoading = _task == null;
      _errorMessage = null;
    });

    try {
      final fetched = await _taskService.getTaskById(widget.taskId);
      if (mounted) {
        setState(() {
          _task = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _openQuickStatus() {
    if (_task == null) return;
    QuickStatusBottomSheet.show(
      context: context,
      task: _task!,
      onUpdated: (updated) {
        setState(() {
          _task = updated;
        });
      },
    );
  }

  Future<void> _openEditTask() async {
    if (_task == null) return;
    final updated = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditScreen(task: _task!),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _task = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'CHI TIẾT CÔNG VIỆC // B3',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryInk),
            tooltip: 'Chỉnh sửa',
            onPressed: _openEditTask,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryInk),
            tooltip: 'Tải lại',
            onPressed: _fetchTaskDetails,
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
          : _errorMessage != null && task == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: BrutalistCard(
                      backgroundColor: AppColors.cardWhite,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
                          const SizedBox(height: 12),
                          Text(
                            'LỖI TẢI DỮ LIỆU',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryInk,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BrutalistButton(
                            text: 'THỬ LẠI',
                            icon: Icons.refresh,
                            backgroundColor: AppColors.primaryAccent,
                            textColor: AppColors.primaryInk,
                            onPressed: _fetchTaskDetails,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : task == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      color: AppColors.primaryInk,
                      backgroundColor: AppColors.primaryAccent,
                      onRefresh: _fetchTaskDetails,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Tag Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BrutalistBadge(
                                  text: 'TASK ID: #${task.id.length > 8 ? task.id.substring(task.id.length - 8).toUpperCase() : task.id.toUpperCase()}',
                                  backgroundColor: AppColors.secondarySurface,
                                  textColor: AppColors.primaryInk,
                                ),
                                _buildStatusBadge(task.status),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Main Title Card
                            BrutalistCard(
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor: AppColors.cardWhite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryInk,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      _buildPriorityBadge(task.priority),
                                      const SizedBox(width: 8),
                                      if (task.createdAt != null)
                                        Text(
                                          'TẠO NGÀY: ${DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt!)}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description Section
                            BrutalistCard(
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor: AppColors.cardWhite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.description_outlined, size: 18, color: AppColors.primaryInk),
                                      const SizedBox(width: 8),
                                      Text(
                                        'MÔ TẢ CÔNG VIỆC',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: AppColors.primaryInk,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 1.5,
                                    color: AppColors.divider.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    task.description.trim().isNotEmpty
                                        ? task.description.trim()
                                        : 'Không có nội dung mô tả chi tiết cho công việc này.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: task.description.trim().isNotEmpty
                                          ? AppColors.primaryInk
                                          : AppColors.secondaryText,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Timeline & Deadline Card
                            _buildTimelineCard(task),
                            const SizedBox(height: 16),

                            // People Involved (CreatedBy & Assignees)
                            _buildPeopleCard(task),
                            const SizedBox(height: 20),

                            // Action Buttons (B4)
                            BrutalistButton(
                              text: 'CHUYỂN TRẠNG THÁI NHANH',
                              icon: Icons.sync,
                              backgroundColor: AppColors.primaryAccent,
                              textColor: AppColors.primaryInk,
                              onPressed: _openQuickStatus,
                            ),
                            const SizedBox(height: 12),
                            BrutalistButton(
                              text: 'CHỈNH SỬA CÔNG VIỆC',
                              icon: Icons.edit_note,
                              backgroundColor: AppColors.cardWhite,
                              textColor: AppColors.primaryInk,
                              onPressed: _openEditTask,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildTimelineCard(Task task) {
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(now) &&
        task.status != 'completed';

    return BrutalistCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: AppColors.cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 18, color: AppColors.primaryInk),
              const SizedBox(width: 8),
              Text(
                'TIẾN ĐỘ THỜI GIAN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.primaryInk,
                ),
              ),
              const Spacer(),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primaryInk, width: 1.5),
                  ),
                  child: Text(
                    'ĐÃ QUÁ HẠN',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1.5,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),

          // Start Date & Due Date rows
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NGÀY BẮT ĐẦU',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.startDate != null
                          ? DateFormat('dd/MM/yyyy').format(task.startDate!)
                          : 'CHƯA ĐẶT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryInk,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1.5, height: 40, color: AppColors.divider.withValues(alpha: 0.5)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HẠN HOÀN THÀNH',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isOverdue ? AppColors.danger : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.dueDate != null
                          ? DateFormat('dd/MM/yyyy').format(task.dueDate!)
                          : 'KHÔNG CÓ HẠN',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isOverdue ? AppColors.danger : AppColors.primaryInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleCard(Task task) {
    return BrutalistCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: AppColors.cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 18, color: AppColors.primaryInk),
              const SizedBox(width: 8),
              Text(
                'NHÂN SỰ PHỤ TRÁCH',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.primaryInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1.5,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),

          // Người tạo
          Text(
            'NGƯỜI TẠO CÔNG VIỆC',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          _buildUserTile(task.createdBy, isCreator: true),

          const SizedBox(height: 16),

          // Người phụ trách chính
          Text(
            'NGƯỜI PHỤ TRÁCH CHÍNH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          _buildUserTile(task.primaryAssignee ?? task.createdBy, isPrimary: true),

          // Danh sách người được gán nếu có
          if (task.assignees.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'DANH SÁCH THÀNH VIÊN GIAO VIỆC (${task.assignees.length})',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.assignees.map((user) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryInk, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.primaryInk),
                      const SizedBox(width: 4),
                      Text(
                        user.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryInk,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTile(User? user, {bool isCreator = false, bool isPrimary = false}) {
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'Không rõ';
    final email = user?.email.isNotEmpty == true ? user!.email : '---';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryInk, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primaryAccent : AppColors.cardWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryInk, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
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
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryInk,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'in_progress':
        return BrutalistBadge(
          text: 'ĐANG LÀM',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
          icon: Icons.sync,
        );
      case 'completed':
        return BrutalistBadge(
          text: 'HOÀN THÀNH',
          backgroundColor: const Color(0xFF9AE6B4),
          textColor: AppColors.primaryInk,
          icon: Icons.check_circle_outline,
        );
      case 'cancelled':
        return BrutalistBadge(
          text: 'ĐÃ HỦY',
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          icon: Icons.cancel_outlined,
        );
      case 'todo':
      default:
        return BrutalistBadge(
          text: 'CHỜ XỬ LÝ',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.primaryInk,
          icon: Icons.hourglass_empty,
        );
    }
  }

  Widget _buildPriorityBadge(String priority) {
    switch (priority) {
      case 'high':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.priority_high, size: 12, color: Colors.white),
              const SizedBox(width: 2),
              Text(
                'ƯU TIÊN CAO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 'medium':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Text(
            'TRUNG BÌNH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryInk,
            ),
          ),
        );
      case 'low':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Text(
            'THẤP',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryInk,
            ),
          ),
        );
    }
  }
}
