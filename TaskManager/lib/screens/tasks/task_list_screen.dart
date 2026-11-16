import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_task_card.dart';
import '../../widgets/brutalist_avatar.dart';
import '../../widgets/quick_status_bottom_sheet.dart';
import '../auth/welcome_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notification_screen.dart';
import '../stats/statistics_screen.dart';
import '../../services/notification_service.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _authService = AuthService();
  final _taskService = TaskService();
  final _notificationService = NotificationService.instance;
  int _unreadNotificationCount = 0;

  User? _currentUser;
  List<Task> _tasks = [];
  bool _isLoadingTasks = true;
  String? _errorMessage;

  // Search & Filters (B6)
  final TextEditingController _searchController = TextEditingController();
  String _selectedScopeFilter = 'all'; // all, created_by_me, assigned_to_me, shared_with_me (C5)
  String _selectedStatusFilter = 'all'; // all, todo, in_progress, completed, cancelled
  String _selectedPriorityFilter = 'all'; // all, high, medium, low
  String _selectedSortBy = 'createdAt'; // createdAt, dueDate, priority, title
  String _selectedOrder = 'desc'; // desc, asc
  String _sortLabel = 'MỚI NHẤT';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadUser(),
      _fetchTasks(),
      _fetchUnreadNotificationCount(),
    ]);
  }

  Future<void> _fetchUnreadNotificationCount() async {
    try {
      final res = await _notificationService.getNotifications(isRead: false, limit: 1);
      if (mounted) {
        setState(() {
          _unreadNotificationCount = res.unreadCount;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUser() async {
    try {
      final cachedUser = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = cachedUser;
        });
      }

      final latestUser = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _currentUser = latestUser;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoadingTasks = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _taskService.getTasks(
        status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
        priority: _selectedPriorityFilter == 'all' ? null : _selectedPriorityFilter,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        sortBy: _selectedSortBy,
        order: _selectedOrder,
        filterType: _selectedScopeFilter == 'all' ? null : _selectedScopeFilter,
      );
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingTasks = false;
        });
      }
    }
  }

  void _onScopeFilterSelected(String scope) {
    if (_selectedScopeFilter == scope) return;
    setState(() {
      _selectedScopeFilter = scope;
    });
    _fetchTasks();
  }

  void _onStatusFilterSelected(String filter) {
    if (_selectedStatusFilter == filter) return;
    setState(() {
      _selectedStatusFilter = filter;
    });
    _fetchTasks();
  }

  void _onPriorityFilterSelected(String filter) {
    if (_selectedPriorityFilter == filter) return;
    setState(() {
      _selectedPriorityFilter = filter;
    });
    _fetchTasks();
  }

  void _showSortBottomSheet() {
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
              'Sắp xếp công việc',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryInk,
              ),
            ),
            const SizedBox(height: 14),
            _buildSortOption('createdAt', 'desc', 'Mới nhất (Ngày tạo giảm dần)'),
            const SizedBox(height: 8),
            _buildSortOption('createdAt', 'asc', 'Cũ nhất (Ngày tạo tăng dần)'),
            const SizedBox(height: 8),
            _buildSortOption('dueDate', 'asc', 'Hạn chót gần nhất'),
            const SizedBox(height: 8),
            _buildSortOption('dueDate', 'desc', 'Hạn chót xa nhất'),
            const SizedBox(height: 8),
            _buildSortOption('priority', 'desc', 'Ưu tiên cao đến thấp'),
            const SizedBox(height: 8),
            _buildSortOption('title', 'asc', 'Theo bảng chữ cái (A ➔ Z)'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String sortBy, String order, String label) {
    final isSelected = _selectedSortBy == sortBy && _selectedOrder == order;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortBy = sortBy;
          _selectedOrder = order;
          _sortLabel = label.split(' (')[0];
        });
        Navigator.of(context).pop();
        _fetchTasks();
      },
      child: BrutalistCard(
        backgroundColor: isSelected ? AppColors.primaryAccent : AppColors.cardWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.primaryInk,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 20, color: AppColors.primaryInk),
          ],
        ),
      ),
    );
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

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
    if (mounted) {
      _fetchUnreadNotificationCount();
      _fetchTasks();
    }
  }

  Future<void> _openStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    _loadUser();
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskCreateScreen()),
    );
    if (result == true) {
      _fetchTasks();
    }
  }

  Future<void> _openTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          taskId: task.id,
          initialTask: task,
        ),
      ),
    );
    if (result == true || mounted) {
      _fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Task Manager',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined, size: 24, color: AppColors.primaryInk),
            tooltip: 'Thống kê & Báo cáo',
            onPressed: _openStatistics,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 24, color: AppColors.primaryInk),
                tooltip: 'Thông báo',
                onPressed: _openNotifications,
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _unreadNotificationCount > 99 ? '99+' : '$_unreadNotificationCount',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 24, color: AppColors.primaryInk),
            tooltip: 'Hồ sơ cá nhân',
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 24, color: AppColors.primaryInk),
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutConfirmDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryInk,
        backgroundColor: AppColors.primaryAccent,
        onRefresh: () async {
          await Future.wait([
            _loadUser(),
            _fetchTasks(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tiêu đề đầu danh sách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng quan công việc',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                          ),
                          child: Text(
                            '${_tasks.length} công việc',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // User greeting card (clickable to profile)
                    BrutalistCard(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: AppColors.cardWhite,
                      onTap: _openProfile,
                      child: Row(
                        children: [
                          BrutalistAvatar(
                            avatarUrl: _currentUser?.avatarUrl,
                            name: _currentUser?.fullName ?? 'U',
                            size: 48,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser?.fullName.toUpperCase() ?? 'NGƯỜI DÙNG',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _currentUser?.email ?? '---',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryInk),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scope Filter Tabs (C5)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Tất cả', _selectedScopeFilter, _onScopeFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('created_by_me', 'Tôi tạo', _selectedScopeFilter, _onScopeFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('assigned_to_me', 'Được giao', _selectedScopeFilter, _onScopeFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('shared_with_me', 'Được chia sẻ', _selectedScopeFilter, _onScopeFilterSelected),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar (B6)
                    Container(
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
                          BoxShadow(
                            color: Color(0x06000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _fetchTasks(),
                        onChanged: (text) {
                          if (text.isEmpty) {
                            _fetchTasks();
                          }
                        },
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryInk,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm công việc...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.primaryInk),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.primaryInk),
                                  onPressed: () {
                                    _searchController.clear();
                                    _fetchTasks();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Filter chips (Row 1)
                    Text(
                      'Trạng thái',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Tất cả', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('todo', 'Chờ xử lý', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('in_progress', 'Đang làm', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('completed', 'Hoàn thành', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('cancelled', 'Đã hủy', _selectedStatusFilter, _onStatusFilterSelected),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Priority Filter chips (Row 2)
                    Text(
                      'Mức độ ưu tiên',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Tất cả', _selectedPriorityFilter, _onPriorityFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('high', 'Ưu tiên cao', _selectedPriorityFilter, _onPriorityFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('medium', 'Trung bình', _selectedPriorityFilter, _onPriorityFilterSelected),
                          const SizedBox(width: 8),
                          _buildFilterChip('low', 'Thấp', _selectedPriorityFilter, _onPriorityFilterSelected),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section Title & Sort Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh sách công việc',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showSortBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x202C2C2C),
                                  offset: Offset(1.5, 1.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.primaryInk),
                                const SizedBox(width: 4),
                                Text(
                                  _sortLabel,
                                  style: GoogleFonts.plusJakartaSans(
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
                  ],
                ),
              ),
            ),

            // Task List or States (Loading / Error / Empty / Tasks)
            if (_isLoadingTasks)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryInk,
                    strokeWidth: 3,
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: BrutalistCard(
                    backgroundColor: AppColors.cardWhite,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
                        const SizedBox(height: 10),
                        Text(
                          'KHÔNG THỂ TẢI CÔNG VIỆC',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        BrutalistButton(
                          text: 'THỬ LẠI',
                          icon: Icons.refresh,
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          onPressed: _fetchTasks,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_tasks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BrutalistCard(
                    backgroundColor: AppColors.cardWhite,
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 36,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'CHƯA CÓ CÔNG VIỆC NÀO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchController.text.isNotEmpty || _selectedStatusFilter != 'all' || _selectedPriorityFilter != 'all'
                              ? 'Không tìm thấy công việc nào phù hợp với bộ lọc hoặc từ khóa tìm kiếm.'
                              : 'Bạn chưa tạo hoặc chưa được phân công công việc nào. Hãy khởi tạo công việc đầu tiên ngay!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A4740),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        BrutalistButton(
                          text: 'Tạo công việc mới',
                          icon: Icons.add,
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          height: 52,
                          onPressed: _openCreateTask,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = _tasks[index];
                      return BrutalistTaskCard(
                        task: task,
                        currentUserId: _currentUser?.id,
                        onTap: () => _openTaskDetail(task),
                        onStatusTap: () {
                          QuickStatusBottomSheet.show(
                            context: context,
                            task: task,
                            onUpdated: (_) => _fetchTasks(),
                          );
                        },
                      );
                    },
                    childCount: _tasks.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _openCreateTask,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(29),
            border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332C2C2C),
                offset: Offset(2.5, 3.0),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Color(0x10000000),
                offset: Offset(0, 4.0),
                blurRadius: 8.0,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, size: 32, color: AppColors.primaryInk),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryInk, width: AppColors.borderWidth),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x282C2C2C),
                    offset: Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            color: AppColors.primaryInk,
          ),
        ),
      ),
    );
  }
}
