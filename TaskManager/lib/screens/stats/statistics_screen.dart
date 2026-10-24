import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_stats.dart';
import '../../services/stats_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatsService _statsService = StatsService.instance;

  TaskStatsData? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedTimeRange = 'all'; // all, today, week, month
  String _selectedScope = 'all'; // all, created_by_me, assigned_to_me

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _statsService.getTaskStats(
        timeRange: _selectedTimeRange,
        scope: _selectedScope,
      );

      if (mounted) {
        setState(() {
          _stats = data;
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

  void _onTimeRangeChanged(String range) {
    if (_selectedTimeRange == range) return;
    setState(() {
      _selectedTimeRange = range;
    });
    _fetchStats();
  }

  void _onScopeChanged(String scope) {
    if (_selectedScope == scope) return;
    setState(() {
      _selectedScope = scope;
    });
    _fetchStats();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryInk : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryInk, width: 1.8),
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
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isSelected ? Colors.white : AppColors.primaryInk,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryInk, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryInk,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isAlert ? Colors.white : AppColors.secondaryText,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: isAlert ? Colors.white : AppColors.primaryInk,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isAlert ? Colors.white70 : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int count,
    required int percentage,
    required Color fillColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryInk,
                ),
              ),
              Text(
                '$count ($percentage%)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primaryInk, width: 1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percentage / 100.0).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'THỐNG KÊ // ANALYTICS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryInk),
            tooltip: 'Làm mới số liệu',
            onPressed: _fetchStats,
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
      body: RefreshIndicator(
        color: AppColors.primaryInk,
        backgroundColor: AppColors.primaryAccent,
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrutalistBadge(
                    text: 'MODULE E // KPI REPORT',
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.primaryInk,
                    icon: Icons.pie_chart_outline,
                  ),
                  BrutalistBadge(
                    text: 'REAL-TIME DATA',
                    backgroundColor: AppColors.cardWhite,
                    textColor: AppColors.primaryInk,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter Controls Card
              BrutalistCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KHOẢNG THỜI GIAN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'TẤT CẢ',
                          isSelected: _selectedTimeRange == 'all',
                          onTap: () => _onTimeRangeChanged('all'),
                        ),
                        _buildFilterChip(
                          label: 'HÔM NAY',
                          isSelected: _selectedTimeRange == 'today',
                          onTap: () => _onTimeRangeChanged('today'),
                        ),
                        _buildFilterChip(
                          label: '7 NGÀY QUA',
                          isSelected: _selectedTimeRange == 'week',
                          onTap: () => _onTimeRangeChanged('week'),
                        ),
                        _buildFilterChip(
                          label: 'THÁNG NÀY',
                          isSelected: _selectedTimeRange == 'month',
                          onTap: () => _onTimeRangeChanged('month'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.primaryInk, thickness: 1.2),
                    const SizedBox(height: 8),
                    Text(
                      'PHẠM VI CÔNG VIỆC',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'TẤT CẢ LIÊN QUAN',
                          isSelected: _selectedScope == 'all',
                          onTap: () => _onScopeChanged('all'),
                        ),
                        _buildFilterChip(
                          label: 'TÔI TẠO',
                          isSelected: _selectedScope == 'created_by_me',
                          onTap: () => _onScopeChanged('created_by_me'),
                        ),
                        _buildFilterChip(
                          label: 'GIAO CHO TÔI',
                          isSelected: _selectedScope == 'assigned_to_me',
                          onTap: () => _onScopeChanged('assigned_to_me'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Loading / Error / Content
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryInk),
                  ),
                )
              else if (_errorMessage != null)
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'LỖI TẢI THỐNG KÊ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 14),
                      BrutalistButton(
                        text: 'TẢI LẠI',
                        icon: Icons.refresh,
                        onPressed: _fetchStats,
                      ),
                    ],
                  ),
                )
              else if (_stats != null) ...[
                // Top KPI Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        label: 'TỔNG CÔNG VIỆC',
                        value: '${_stats!.summary.totalTasks}',
                        subtitle: 'Phạm vi đang lọc',
                        backgroundColor: AppColors.cardWhite,
                        textColor: AppColors.primaryInk,
                        icon: Icons.list_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        label: 'HOÀN THÀNH',
                        value: '${_stats!.byStatus.completed.count}',
                        subtitle: 'Tỷ lệ: ${_stats!.summary.completionRate}%',
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.primaryInk,
                        icon: Icons.task_alt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        label: 'ĐANG LÀM',
                        value: '${_stats!.byStatus.inProgress.count}',
                        subtitle: 'Đang triển khai',
                        backgroundColor: AppColors.cardWhite,
                        textColor: AppColors.primaryInk,
                        icon: Icons.hourglass_top,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        label: 'QUÁ HẠN',
                        value: '${_stats!.deadlines.overdue}',
                        subtitle: _stats!.deadlines.overdue > 0
                            ? 'Cần xử lý khẩn cấp'
                            : 'Tiến độ rất tốt',
                        backgroundColor: _stats!.deadlines.overdue > 0
                            ? AppColors.danger
                            : AppColors.cardWhite,
                        textColor: _stats!.deadlines.overdue > 0
                            ? Colors.white
                            : AppColors.primaryInk,
                        icon: Icons.warning_amber_rounded,
                        isAlert: _stats!.deadlines.overdue > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Overall Completion Progress Meter
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HIỆU SUẤT HOÀN THÀNH',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.primaryInk,
                            ),
                          ),
                          Text(
                            '${_stats!.summary.completionRate}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryInk, width: 2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (_stats!.summary.completionRate / 100.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tỷ lệ hoàn thành đúng hạn: ${_stats!.summary.completedOnTimeRate}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown by Status
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHÂN BỔ THEO TRẠNG THÁI',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        label: 'Chờ xử lý (TODO)',
                        count: _stats!.byStatus.todo.count,
                        percentage: _stats!.byStatus.todo.percentage,
                        fillColor: AppColors.secondarySurface,
                      ),
                      _buildProgressBar(
                        label: 'Đang làm (IN PROGRESS)',
                        count: _stats!.byStatus.inProgress.count,
                        percentage: _stats!.byStatus.inProgress.percentage,
                        fillColor: AppColors.primaryAccent,
                      ),
                      _buildProgressBar(
                        label: 'Hoàn thành (COMPLETED)',
                        count: _stats!.byStatus.completed.count,
                        percentage: _stats!.byStatus.completed.percentage,
                        fillColor: AppColors.primaryInk,
                      ),
                      _buildProgressBar(
                        label: 'Đã hủy (CANCELLED)',
                        count: _stats!.byStatus.cancelled.count,
                        percentage: _stats!.byStatus.cancelled.percentage,
                        fillColor: AppColors.danger,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown by Priority
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHÂN BỔ THEO ĐỘ ƯU TIÊN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        label: 'Khẩn cấp / Cao (HIGH)',
                        count: _stats!.byPriority.high.count,
                        percentage: _stats!.byPriority.high.percentage,
                        fillColor: AppColors.danger,
                      ),
                      _buildProgressBar(
                        label: 'Trung bình (MEDIUM)',
                        count: _stats!.byPriority.medium.count,
                        percentage: _stats!.byPriority.medium.percentage,
                        fillColor: AppColors.primaryAccent,
                      ),
                      _buildProgressBar(
                        label: 'Thấp (LOW)',
                        count: _stats!.byPriority.low.count,
                        percentage: _stats!.byPriority.low.percentage,
                        fillColor: AppColors.secondarySurface,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deadline Health Monitor
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GIÁM SÁT HẠN CHÓT (DEADLINES)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _stats!.deadlines.overdue > 0
                                    ? const Color(0xFFFFECEB)
                                    : AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primaryInk, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_stats!.deadlines.overdue}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: _stats!.deadlines.overdue > 0
                                          ? AppColors.danger
                                          : AppColors.primaryInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'QUÁ HẠN',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _stats!.deadlines.dueSoon > 0
                                    ? const Color(0xFFFFFBEA)
                                    : AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primaryInk, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_stats!.deadlines.dueSoon}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TRONG 24H',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primaryInk, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_stats!.deadlines.completedOnTime}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ĐÚNG HẠN',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Team Workload Ranking (E3)
                if (_stats!.memberWorkloads.isNotEmpty) ...[
                  BrutalistCard(
                    backgroundColor: AppColors.cardWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KHỐI LƯỢNG CÔNG VIỆC THÀNH VIÊN (E3)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stats!.memberWorkloads.length,
                          separatorBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: AppColors.scaffoldBackground, thickness: 1.5),
                          ),
                          itemBuilder: (context, index) {
                            final member = _stats!.memberWorkloads[index];
                            final rate = member.taskCount > 0
                                ? Math.round((member.completedCount / member.taskCount) * 100)
                                : 0;

                            return Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? AppColors.primaryAccent
                                        : AppColors.scaffoldBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryInk,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '#${index + 1}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryInk,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.user.fullName,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryInk,
                                        ),
                                      ),
                                      Text(
                                        member.user.email,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primaryInk,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${member.completedCount}/${member.taskCount} XONG',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryInk,
                                        ),
                                      ),
                                      Text(
                                        '$rate%',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Math {
  static int round(num value) => value.round();
}
