const Notification = require('../models/Notification');
const { checkAndSendDeadlineReminders } = require('../services/reminderService');

/**
 * Lấy danh sách thông báo của người dùng (D1)
 * GET /api/notifications
 */
const getNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const { isRead, limit = 50 } = req.query;

    const filter = { userId };
    if (isRead !== undefined) {
      filter.isRead = isRead === 'true';
    }

    const notifications = await Notification.find(filter)
      .populate('senderId', 'fullName email avatarUrl')
      .populate('taskId', 'title status priority dueDate')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit, 10));

    const unreadCount = await Notification.countDocuments({
      userId,
      isRead: false,
    });

    return res.status(200).json({
      status: 'success',
      results: notifications.length,
      unreadCount,
      data: {
        notifications,
      },
    });
  } catch (error) {
    console.error('[NotificationController.getNotifications] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy danh sách thông báo.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Lấy số lượng thông báo chưa đọc
 * GET /api/notifications/unread-count
 */
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user._id;
    const unreadCount = await Notification.countDocuments({
      userId,
      isRead: false,
    });

    return res.status(200).json({
      status: 'success',
      data: {
        unreadCount,
      },
    });
  } catch (error) {
    console.error('[NotificationController.getUnreadCount] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy số lượng thông báo chưa đọc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Đánh dấu 1 thông báo là đã đọc (D1)
 * PATCH /api/notifications/:id/read
 */
const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOneAndUpdate(
      { _id: id, userId },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy thông báo yêu cầu.',
      });
    }

    const unreadCount = await Notification.countDocuments({
      userId,
      isRead: false,
    });

    return res.status(200).json({
      status: 'success',
      message: 'Đã đánh dấu thông báo là đã đọc.',
      unreadCount,
      data: {
        notification,
      },
    });
  } catch (error) {
    console.error('[NotificationController.markAsRead] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi cập nhật trạng thái thông báo.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Đánh dấu TẤT CẢ thông báo là đã đọc (D1)
 * PATCH /api/notifications/read-all
 */
const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user._id;

    await Notification.updateMany({ userId, isRead: false }, { isRead: true });

    return res.status(200).json({
      status: 'success',
      message: 'Đã đánh dấu tất cả thông báo là đã đọc.',
      unreadCount: 0,
    });
  } catch (error) {
    console.error('[NotificationController.markAllAsRead] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi đánh dấu tất cả thông báo.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Xóa một thông báo (D1)
 * DELETE /api/notifications/:id
 */
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOneAndDelete({ _id: id, userId });
    if (!notification) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy thông báo để xóa.',
      });
    }

    return res.status(200).json({
      status: 'success',
      message: 'Đã xóa thông báo thành công.',
    });
  } catch (error) {
    console.error('[NotificationController.deleteNotification] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xóa thông báo.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Kích hoạt quét và gửi nhắc nhở hạn chót thủ công (D4)
 * POST /api/notifications/reminders/trigger
 */
const triggerDeadlineReminders = async (req, res) => {
  try {
    const result = await checkAndSendDeadlineReminders();
    return res.status(200).json({
      status: 'success',
      message: `Đã hoàn tất quét ${result.scannedTasks} công việc và gửi ${result.remindersSent} thông báo nhắc nhở.`,
      data: result,
    });
  } catch (error) {
    console.error('[NotificationController.triggerDeadlineReminders] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi quét hạn chót công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

module.exports = {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  triggerDeadlineReminders,
};
