import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../tasks/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService.instance;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _onlyUnread = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _notificationService.getNotifications(
        isRead: _onlyUnread ? false : null,
      );

      if (mounted) {
        setState(() {
          _notifications = result.notifications;
          _unreadCount = result.unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    try {
      final newUnreadCount = await _notificationService.markAsRead(notification.id);
      if (mounted) {
        setState(() {
          _unreadCount = newUnreadCount;
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(isRead: true);
          }
          if (_onlyUnread) {
            _notifications.removeWhere((n) => n.id == notification.id);
          }
        });
      }
    } catch (e) {
      _showSnackbar('Không thể đánh dấu đã đọc: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    try {
      await _notificationService.markAllAsRead();
      if (mounted) {
        setState(() {
          _unreadCount = 0;
          _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
          if (_onlyUnread) {
            _notifications.clear();
          }
        });
        _showSnackbar('Đã đánh dấu tất cả thông báo là đã đọc!');
      }
    } catch (e) {
      _showSnackbar('Lỗi khi đánh dấu tất cả: $e');
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      await _notificationService.deleteNotification(notification.id);
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
          if (!notification.isRead && _unreadCount > 0) {
            _unreadCount -= 1;
          }
        });
        _showSnackbar('Đã xóa thông báo');
      }
    } catch (e) {
      _showSnackbar('Không thể xóa thông báo: $e');
    }
  }

  void _onNotificationTap(AppNotification notification) async {
    // Đánh dấu đã đọc trước
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Nếu thông báo liên kết với một Task, chuyển sang màn hình TaskDetailScreen
    final taskId = notification.task?.id ?? notification.taskIdString;
    if (taskId != null && taskId.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        ),
      );
      _fetchNotifications();
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.primaryInk, width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    switch (type) {
      case 'task_assigned':
        return BrutalistBadge(
          text: 'PHÂN CÔNG',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
          icon: Icons.person_add_alt_1,
        );
      case 'task_shared':
        return BrutalistBadge(
          text: 'CHIA SẺ',
          backgroundColor: AppColors.primaryInk,
          textColor: Colors.white,
          icon: Icons.share,
        );
      case 'task_status_changed':
        return BrutalistBadge(
          text: 'TRẠNG THÁI',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.primaryInk,
          icon: Icons.sync_alt,
        );
      case 'task_reminder':
        return BrutalistBadge(
          text: 'HẠN CHÓT',
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          icon: Icons.alarm,
        );
      default:
        return BrutalistBadge(
          text: 'HỆ THỐNG',
          backgroundColor: AppColors.cardWhite,
          textColor: AppColors.primaryInk,
          icon: Icons.notifications,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'THÔNG BÁO // ALERTS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppColors.primaryInk,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all, size: 18, color: AppColors.primaryInk),
                label: Text(
                  'ĐỌC HẾT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryInk,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppColors.primaryInk, width: 1.5),
                  ),
                ),
              ),
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
      body: Column(
        children: [
          // Filter Tabs (Tất cả / Chưa đọc)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.cardWhite,
              border: Border(
                bottom: BorderSide(color: AppColors.primaryInk, width: 2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_onlyUnread) {
                        setState(() {
                          _onlyUnread = false;
                        });
                        _fetchNotifications();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_onlyUnread ? AppColors.primaryInk : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryInk, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'TẤT CẢ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: !_onlyUnread ? Colors.white : AppColors.primaryInk,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!_onlyUnread) {
                        setState(() {
                          _onlyUnread = true;
                        });
                        _fetchNotifications();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _onlyUnread ? AppColors.primaryAccent : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryInk, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CHƯA ĐỌC',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryInk,
                            ),
                          ),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primaryInk, width: 1),
                              ),
                              child: Text(
                                '$_unreadCount',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main notification list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryInk),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: BrutalistCard(
                            backgroundColor: AppColors.cardWhite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.danger, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'LỖI KẾT NỐI',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                BrutalistButton(
                                  text: 'THỬ LẠI',
                                  icon: Icons.refresh,
                                  onPressed: _fetchNotifications,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : _notifications.isEmpty
                        ? RefreshIndicator(
                            color: AppColors.primaryInk,
                            backgroundColor: AppColors.primaryAccent,
                            onRefresh: _fetchNotifications,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    child: BrutalistCard(
                                      backgroundColor: AppColors.cardWhite,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryAccent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primaryInk,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.notifications_off_outlined,
                                              size: 36,
                                              color: AppColors.primaryInk,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _onlyUnread
                                                ? 'KHÔNG CÓ THÔNG BÁO CHƯA ĐỌC'
                                                : 'HỘP THƯ THÔNG BÁO TRỐNG',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primaryInk,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Bạn đã cập nhật tất cả thông tin mới nhất về công việc và thành viên nhóm.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primaryInk,
                            backgroundColor: AppColors.primaryAccent,
                            onRefresh: _fetchNotifications,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final item = _notifications[index];
                                final hasTask = item.task != null ||
                                    (item.taskIdString != null &&
                                        item.taskIdString!.isNotEmpty);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: InkWell(
                                    onTap: () => _onNotificationTap(item),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: item.isRead
                                            ? AppColors.cardWhite
                                            : const Color(0xFFFFFBEA), // Light Turmeric tint for unread
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: item.isRead
                                              ? AppColors.primaryInk
                                              : AppColors.primaryInk,
                                          width: item.isRead ? 2.0 : 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryInk,
                                            offset: item.isRead
                                                ? const Offset(3, 3)
                                                : const Offset(4, 4),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Unread accent indicator ribbon
                                          if (!item.isRead)
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: 6,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primaryAccent,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              item.isRead ? 14 : 18,
                                              14,
                                              14,
                                              14,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Top row: Type badge + timestamp + delete
                                                Row(
                                                  children: [
                                                    _buildTypeBadge(item.type),
                                                    const Spacer(),
                                                    Text(
                                                      DateFormat('HH:mm  dd/MM')
                                                          .format(item.createdAt.toLocal()),
                                                      style: GoogleFonts.jetBrainsMono(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.secondaryText,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    InkWell(
                                                      onTap: () => _deleteNotification(item),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.cardWhite,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: AppColors.primaryInk,
                                                            width: 1.2,
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          size: 14,
                                                          color: AppColors.primaryInk,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),

                                                // Notification Title
                                                Text(
                                                  item.title,
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppColors.primaryInk,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),

                                                // Notification Body
                                                Text(
                                                  item.message,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.primaryInk,
                                                    height: 1.35,
                                                  ),
                                                ),

                                                // Sender info if available
                                                if (item.sender != null) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.person_pin,
                                                        size: 14,
                                                        color: AppColors.secondaryText,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Từ: ${item.sender!.fullName}',
                                                        style: GoogleFonts.jetBrainsMono(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.secondaryText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                // Task Link CTA
                                                if (hasTask) ...[
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.scaffoldBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: AppColors.primaryInk,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.arrow_forward,
                                                          size: 14,
                                                          color: AppColors.primaryInk,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          'XEM CÔNG VIỆC LIÊN QUAN',
                                                          style: GoogleFonts.spaceGrotesk(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w900,
                                                            color: AppColors.primaryInk,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
