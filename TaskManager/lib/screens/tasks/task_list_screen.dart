import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_task_card.dart';
import '../auth/welcome_screen.dart';
import '../profile/profile_screen.dart';
import 'task_create_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _authService = AuthService();
  final _taskService = TaskService();

  User? _currentUser;
  List<Task> _tasks = [];
  bool _isLoadingTasks = true;
  String? _errorMessage;

  // Filter tab: all, todo, in_progress, completed
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadUser(),
      _fetchTasks(),
    ]);
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

  void _onStatusFilterSelected(String filter) {
    if (_selectedStatusFilter == filter) return;
    setState(() {
      _selectedStatusFilter = filter;
    });
    _fetchTasks();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'TASK MANAGER // OS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primaryInk),
            tooltip: 'Hồ sơ cá nhân',
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryInk),
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutConfirmDialog,
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
                    // System header tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BrutalistBadge(
                          text: 'MODULE B // TASK OPS',
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
                          icon: Icons.assignment_outlined,
                        ),
                        BrutalistBadge(
                          text: '${_tasks.length} CÔNG VIỆC',
                          backgroundColor: AppColors.cardWhite,
                          textColor: AppColors.primaryInk,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // User greeting card (clickable to profile)
                    BrutalistCard(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: AppColors.cardWhite,
                      onTap: _openProfile,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryInk, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (_currentUser?.fullName.isNotEmpty == true)
                                  ? _currentUser!.fullName[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryInk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser?.fullName.toUpperCase() ?? 'NGƯỜI DÙNG',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentUser?.email ?? '---',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryInk),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick filter tabs (Brutalist style chips)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'TẤT CẢ'),
                          const SizedBox(width: 8),
                          _buildFilterChip('todo', 'CHỜ XỬ LÝ'),
                          const SizedBox(width: 8),
                          _buildFilterChip('in_progress', 'ĐANG LÀM'),
                          const SizedBox(width: 8),
                          _buildFilterChip('completed', 'HOÀN THÀNH'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DANH SÁCH NHIỆM VỤ (B2)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        Text(
                          'KÉO XUỐNG ĐỂ TẢI LẠI',
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
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryInk, width: 2),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 34,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CHƯA CÓ CÔNG VIỆC NÀO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryInk,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedStatusFilter == 'all'
                              ? 'Bạn chưa tạo hoặc chưa được phân công công việc nào. Hãy khởi tạo công việc đầu tiên ngay!'
                              : 'Không có công việc nào trong trạng thái đã chọn.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        BrutalistButton(
                          text: '+ TẠO CÔNG VIỆC ĐẦU TIÊN',
                          icon: Icons.add,
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.primaryInk,
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
                        onTap: () {
                          // Xem chi tiết công việc (B3 sẽ điều hướng tới TaskDetailScreen)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Công việc: ${task.title}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: AppColors.primaryInk,
                              duration: const Duration(seconds: 1),
                            ),
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryInk, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryInk,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Icon(Icons.add, size: 30, color: AppColors.primaryInk),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;

    return GestureDetector(
      onTap: () => _onStatusFilterSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryInk, width: 2),
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
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: AppColors.primaryInk,
          ),
        ),
      ),
    );
  }
}
