import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;

  const TaskEditScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime? _startDate;
  DateTime? _dueDate;
  late String _priority;
  late String _status;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _startDate = widget.task.startDate;
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryInk,
            onPrimary: AppColors.cardWhite,
            surface: AppColors.cardWhite,
            onSurface: AppColors.primaryInk,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryInk,
            onPrimary: AppColors.cardWhite,
            surface: AppColors.cardWhite,
            onSurface: AppColors.primaryInk,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedTask = await _taskService.updateTask(
        widget.task.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ĐÃ CẬP NHẬT CÔNG VIỆC THÀNH CÔNG',
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'CHỈNH SỬA CÔNG VIỆC // B4',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrutalistBadge(
                    text: 'EDIT MODE // TASK OPS',
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.primaryInk,
                    icon: Icons.edit,
                  ),
                  BrutalistBadge(
                    text: '#${widget.task.id.length > 6 ? widget.task.id.substring(widget.task.id.length - 6).toUpperCase() : widget.task.id}',
                    backgroundColor: AppColors.secondarySurface,
                    textColor: AppColors.primaryInk,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                BrutalistCard(
                  backgroundColor: const Color(0xFFFED7D7),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tiêu đề
              BrutalistTextField(
                label: 'TIÊU ĐỀ CÔNG VIỆC *',
                controller: _titleController,
                hintText: 'Nhập tiêu đề công việc...',
                prefixIcon: const Icon(Icons.title, color: AppColors.primaryInk),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Tiêu đề không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả
              BrutalistTextField(
                label: 'MÔ TẢ CHI TIẾT',
                controller: _descController,
                hintText: 'Nhập mô tả chi tiết yêu cầu công việc...',
                prefixIcon: const Icon(Icons.notes, color: AppColors.primaryInk),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Trạng thái hiện tại
              Text(
                'TRẠNG THÁI TIẾN ĐỘ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusChip('todo', 'CHỜ XỬ LÝ', AppColors.secondarySurface),
                  const SizedBox(width: 8),
                  _buildStatusChip('in_progress', 'ĐANG LÀM', AppColors.primaryAccent),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusChip('completed', 'HOÀN THÀNH', const Color(0xFF9AE6B4)),
                  const SizedBox(width: 8),
                  _buildStatusChip('cancelled', 'ĐÃ HỦY', AppColors.danger, textWhite: true),
                ],
              ),
              const SizedBox(height: 20),

              // Mức độ ưu tiên
              Text(
                'MỨC ĐỘ ƯU TIÊN',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('low', 'THẤP', AppColors.secondarySurface),
                  const SizedBox(width: 8),
                  _buildPriorityChip('medium', 'TRUNG BÌNH', AppColors.primaryAccent),
                  const SizedBox(width: 8),
                  _buildPriorityChip('high', 'CAO', AppColors.danger, textWhite: true),
                ],
              ),
              const SizedBox(height: 20),

              // Thời gian bắt đầu & hạn chót
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NGÀY BẮT ĐẦU',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickStartDate,
                          child: BrutalistCard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            backgroundColor: AppColors.cardWhite,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryInk),
                                const SizedBox(width: 8),
                                Text(
                                  _startDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                      : 'CHỌN NGÀY',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HẠN HOÀN THÀNH',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDueDate,
                          child: BrutalistCard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            backgroundColor: AppColors.cardWhite,
                            child: Row(
                              children: [
                                const Icon(Icons.event_available, size: 16, color: AppColors.primaryInk),
                                const SizedBox(width: 8),
                                Text(
                                  _dueDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                                      : 'CHỌN HẠN',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit & Cancel buttons
              BrutalistButton(
                text: 'LƯU THAY ĐỔI',
                icon: Icons.check,
                backgroundColor: AppColors.primaryAccent,
                textColor: AppColors.primaryInk,
                isLoading: _isLoading,
                onPressed: _submitUpdate,
              ),
              const SizedBox(height: 12),
              BrutalistButton(
                text: 'HỦY BỎ',
                icon: Icons.close,
                backgroundColor: AppColors.secondarySurface,
                textColor: AppColors.primaryInk,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color color, {bool textWhite = false}) {
    final isSelected = _status == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              color: isSelected && textWhite ? Colors.white : AppColors.primaryInk,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color, {bool textWhite = false}) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              color: isSelected && textWhite ? Colors.white : AppColors.primaryInk,
            ),
          ),
        ),
      ),
    );
  }
}
