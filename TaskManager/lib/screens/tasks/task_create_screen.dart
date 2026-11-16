import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
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
      title: 'Người phụ trách chính',
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
      title: 'Thành viên tham gia',
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
          'Tạo công việc mới',
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

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

                      // Phân công nhân sự
                      Text(
                        'Phân công nhân sự',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Người phụ trách chính
                      GestureDetector(
                        onTap: _pickPrimaryAssignee,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x202C2C2C),
                                offset: Offset(2, 2.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _primaryAssignee != null && _primaryAssignee!.fullName.isNotEmpty
                                      ? _primaryAssignee!.fullName[0].toUpperCase()
                                      : '★',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
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
                                      'Người phụ trách chính',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _primaryAssignee?.fullName ?? 'Mặc định (Bạn)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.primaryInk),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Thành viên tham gia
                      GestureDetector(
                        onTap: _pickCollaborators,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x202C2C2C),
                                offset: Offset(2, 2.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.group_add_rounded, color: AppColors.primaryInk, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thành viên cùng tham gia',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _collaborators.isEmpty
                                          ? 'Nhấn để chọn thành viên...'
                                          : 'Đã chọn ${_collaborators.length} thành viên',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _collaborators.isEmpty
                                            ? AppColors.secondaryText
                                            : AppColors.primaryInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.primaryInk),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ngày bắt đầu & Hạn hoàn thành
                      Text(
                        'Thời gian thực hiện',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(isStart: true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x202C2C2C),
                                      offset: Offset(2, 2.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryInk),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bắt đầu',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _startDate != null ? dateFormat.format(_startDate!) : 'Chọn ngày',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x202C2C2C),
                                      offset: Offset(2, 2.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available_outlined, size: 18, color: AppColors.danger),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hạn chót',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.danger,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _dueDate != null ? dateFormat.format(_dueDate!) : 'Chọn hạn',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
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
                        'Mức độ ưu tiên',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildPriorityOption('low', 'Thấp', AppColors.secondarySurface),
                          const SizedBox(width: 8),
                          _buildPriorityOption('medium', 'Trung bình', AppColors.primaryAccent),
                          const SizedBox(width: 8),
                          _buildPriorityOption('high', 'Ưu tiên cao', AppColors.pastelRed),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Trạng thái ban đầu
                      Text(
                        'Trạng thái ban đầu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStatusOption('todo', 'Chờ xử lý'),
                          const SizedBox(width: 8),
                          _buildStatusOption('in_progress', 'Đang làm'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Nút Tạo công việc
                      BrutalistButton(
                        text: 'Tạo công việc mới',
                        icon: Icons.check_rounded,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryInk,
              width: AppColors.borderWidth,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x202C2C2C),
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected && isHigh ? const Color(0xFFDC2626) : AppColors.primaryInk,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryInk,
              width: AppColors.borderWidth,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x202C2C2C),
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: AppColors.primaryInk,
            ),
          ),
        ),
      ),
    );
  }
}
