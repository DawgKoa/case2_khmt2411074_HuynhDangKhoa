import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';
import '../../widgets/brutalist_user_picker.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _dueDate;
  String _priority = 'medium'; // low, medium, high
  String _status = 'todo'; // todo, in_progress

  // Assignment (C2)
  User? _primaryAssignee;
  List<User> _collaborators = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_dueDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryInk,
              onPrimary: Colors.white,
              surface: AppColors.scaffoldBackground,
              onSurface: AppColors.primaryInk,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_dueDate != null && _dueDate!.isBefore(_startDate!)) {
            _dueDate = _startDate;
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickPrimaryAssignee() async {
    final results = await BrutalistUserPicker.show(
      context: context,
      title: 'NGƯỜI PHỤ TRÁCH CHÍNH // C2',
      isMultiSelect: false,
      initialSelected: _primaryAssignee != null ? [_primaryAssignee!] : [],
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _primaryAssignee = results.first;
        if (!_collaborators.any((u) => u.id == _primaryAssignee!.id)) {
          _collaborators.add(_primaryAssignee!);
        }
      });
    }
  }

  Future<void> _pickCollaborators() async {
    final results = await BrutalistUserPicker.show(
      context: context,
      title: 'THÀNH VIÊN THAM GIA // C2',
      isMultiSelect: true,
      initialSelected: _collaborators,
    );

    if (results != null) {
      setState(() {
        _collaborators = results;
      });
    }
  }

  Future<void> _handleCreateTask() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate != null && _dueDate != null && _dueDate!.isBefore(_startDate!)) {
      setState(() {
        _errorMessage = 'Hạn hoàn thành không thể trước ngày bắt đầu!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final task = await _taskService.createTask(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        primaryAssigneeId: _primaryAssignee?.id,
        assigneeIds: _collaborators.map((u) => u.id).toList(),
      );

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
                  'Đã tạo công việc: "${task.title}"',
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

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'TẠO CÔNG VIỆC MỚI // B1 & C2',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BrutalistBadge(
                      text: 'TASK OPS // CREATE',
                      backgroundColor: AppColors.primaryAccent,
                      textColor: AppColors.primaryInk,
                      icon: Icons.add_task,
                    ),
                    BrutalistBadge(
                      text: 'MODULE B & C',
                      backgroundColor: AppColors.cardWhite,
                      textColor: AppColors.primaryInk,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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

                // Form Card
                BrutalistCard(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên công việc
                      BrutalistTextField(
                        label: 'Tên công việc *',
                        hintText: 'VD: Hoàn thiện báo cáo đồ án Case Study 2',
                        controller: _titleController,
                        prefixIcon: const Icon(Icons.title, color: AppColors.primaryInk),
                        validator: (val) => Validators.required(val, 'Tên công việc'),
                      ),
                      const SizedBox(height: 16),

                      // Mô tả
                      BrutalistTextField(
                        label: 'Mô tả chi tiết',
                        hintText: 'Nhập nội dung, yêu cầu cụ thể của công việc...',
                        controller: _descriptionController,
                        maxLines: 4,
                        prefixIcon: const Icon(Icons.notes, color: AppColors.primaryInk),
                      ),
                      const SizedBox(height: 20),

                      // PHÂN CÔNG NHÂN SỰ (C2)
                      Text(
                        'PHÂN CÔNG NHÂN SỰ (C2)',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Người phụ trách chính
                      GestureDetector(
                        onTap: _pickPrimaryAssignee,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryInk, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.primaryInk,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _primaryAssignee != null && _primaryAssignee!.fullName.isNotEmpty
                                      ? _primaryAssignee!.fullName[0].toUpperCase()
                                      : '★',
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
                                      'NGƯỜI PHỤ TRÁCH CHÍNH',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    Text(
                                      _primaryAssignee?.fullName ?? 'Mặc định (Bạn)',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryInk),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Thành viên tham gia
                      GestureDetector(
                        onTap: _pickCollaborators,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryInk, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.primaryInk,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.group_add, color: AppColors.primaryInk, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'THÀNH VIÊN CÙNG THAM GIA',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    Text(
                                      _collaborators.isEmpty
                                          ? 'Nhấn để chọn thành viên...'
                                          : 'Đã chọn ${_collaborators.length} thành viên',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _collaborators.isEmpty
                                            ? AppColors.secondaryText
                                            : AppColors.primaryInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 20, color: AppColors.primaryInk),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ngày bắt đầu & Hạn hoàn thành
                      Text(
                        'THỜI GIAN THỰC HIỆN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(isStart: true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.primaryInk,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryInk),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BẮT ĐẦU',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                          Text(
                                            _startDate != null ? dateFormat.format(_startDate!) : 'Chọn ngày',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _startDate != null ? AppColors.primaryInk : AppColors.secondaryText,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(isStart: false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryInk, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.primaryInk,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available_outlined, size: 16, color: AppColors.danger),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'HẠN CHÓT',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.danger,
                                            ),
                                          ),
                                          Text(
                                            _dueDate != null ? dateFormat.format(_dueDate!) : 'Chọn hạn',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _dueDate != null ? AppColors.primaryInk : AppColors.secondaryText,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mức độ ưu tiên
                      Text(
                        'MỨC ĐỘ ƯU TIÊN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityOption('low', 'THẤP', AppColors.secondarySurface),
                          const SizedBox(width: 8),
                          _buildPriorityOption('medium', 'TRUNG BÌNH', AppColors.primaryAccent),
                          const SizedBox(width: 8),
                          _buildPriorityOption('high', 'CAO / KHẨN', AppColors.danger),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Trạng thái ban đầu
                      Text(
                        'TRẠNG THÁI BAN ĐẦU',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusOption('todo', 'CHƯA THỰC HIỆN'),
                          const SizedBox(width: 8),
                          _buildStatusOption('in_progress', 'ĐANG THỰC HIỆN'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Nút Tạo công việc
                      BrutalistButton(
                        text: 'TẠO CÔNG VIỆC MỚI',
                        icon: Icons.check,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 52,
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                        onPressed: _handleCreateTask,
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

  Widget _buildPriorityOption(String value, String label, Color color) {
    final isSelected = _priority == value;
    final isHigh = value == 'high';

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primaryInk,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.primaryInk,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected && isHigh ? Colors.white : AppColors.primaryInk,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isSelected = _status == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _status = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primaryInk,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.primaryInk,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: AppColors.primaryInk,
            ),
          ),
        ),
      ),
    );
  }
}
