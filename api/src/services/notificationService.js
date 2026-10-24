const Notification = require('../models/Notification');
const User = require('../models/User');
const {
  sendTaskAssignmentEmail,
  sendTaskSharedEmail,
  sendTaskStatusChangedEmail,
  sendTaskReminderEmail,
} = require('./emailService');

/**
 * Tạo một thông báo trong ứng dụng (In-app Notification - D1)
 */
const createNotification = async ({
  userId,
  senderId = null,
  taskId = null,
  type = 'general',
  title,
  message,
}) => {
  try {
    // Không gửi thông báo cho chính người thao tác
    if (senderId && userId.toString() === senderId.toString()) {
      return null;
    }

    const notification = await Notification.create({
      userId,
      senderId,
      taskId,
      type,
      title,
      message,
    });

    return notification;
  } catch (error) {
    console.error('[NotificationService.createNotification] Error:', error);
    return null;
  }
};

/**
 * Thông báo khi được phân công vào công việc (D1 + D3 Email)
 */
const notifyTaskAssignment = async ({ task, assignerId, recipientIds }) => {
  try {
    const assigner = await User.findById(assignerId).select('fullName email');
    const assignerName = assigner?.fullName || 'Một thành viên';

    for (const recipientId of recipientIds) {
      if (recipientId.toString() !== assignerId.toString()) {
        await createNotification({
          userId: recipientId,
          senderId: assignerId,
          taskId: task._id,
          type: 'task_assigned',
          title: 'BẠN ĐƯỢC PHÂN CÔNG CÔNG VIỆC MỚI',
          message: `Bạn vừa được phân công vào công việc: "${task.title}".`,
        });

        // Email notification (D3)
        const recipient = await User.findById(recipientId).select('fullName email');
        if (recipient && recipient.email) {
          sendTaskAssignmentEmail({
            to: recipient.email,
            recipientName: recipient.fullName,
            taskTitle: task.title,
            assignerName,
            dueDate: task.dueDate,
            priority: task.priority,
          }).catch((err) => console.error('[NotificationService] Assignment email error:', err));
        }
      }
    }
  } catch (error) {
    console.error('[NotificationService.notifyTaskAssignment] Error:', error);
  }
};

/**
 * Thông báo khi được chia sẻ công việc (D1 + D3 Email)
 */
const notifyTaskShared = async ({ task, sharerId, recipientId, role }) => {
  try {
    if (recipientId.toString() !== sharerId.toString()) {
      await createNotification({
        userId: recipientId,
        senderId: sharerId,
        taskId: task._id,
        type: 'task_shared',
        title: 'CÔNG VIỆC ĐƯỢC CHIA SẺ VỚI BẠN',
        message: `Bạn được cấp quyền ${role.toUpperCase()} trong công việc: "${task.title}".`,
      });

      // Email notification (D3)
      const [sharer, recipient] = await Promise.all([
        User.findById(sharerId).select('fullName email'),
        User.findById(recipientId).select('fullName email'),
      ]);

      if (recipient && recipient.email) {
        sendTaskSharedEmail({
          to: recipient.email,
          recipientName: recipient.fullName,
          taskTitle: task.title,
          sharerName: sharer?.fullName || 'Một thành viên',
          role,
        }).catch((err) => console.error('[NotificationService] Share email error:', err));
      }
    }
  } catch (error) {
    console.error('[NotificationService.notifyTaskShared] Error:', error);
  }
};

/**
 * Thông báo khi trạng thái công việc thay đổi (D1 + D3 Email)
 */
const notifyStatusChanged = async ({ task, updaterId, newStatus }) => {
  try {
    const statusLabels = {
      todo: 'CHỜ XỬ LÝ',
      in_progress: 'ĐANG LÀM',
      completed: 'HOÀN THÀNH',
      cancelled: 'ĐÃ HỦY',
    };

    const statusText = statusLabels[newStatus] || newStatus.toUpperCase();

    // Thu thập tất cả người liên quan (Creator + Assignees + Shared)
    const allRecipientIds = new Set();
    if (task.createdBy) allRecipientIds.add(task.createdBy.toString());
    if (task.primaryAssigneeId) allRecipientIds.add(task.primaryAssigneeId.toString());
    if (Array.isArray(task.assigneeIds)) {
      task.assigneeIds.forEach((a) => allRecipientIds.add(a.toString()));
    }
    if (Array.isArray(task.sharedWith)) {
      task.sharedWith.forEach((s) => allRecipientIds.add(s.userId.toString()));
    }

    const updater = await User.findById(updaterId).select('fullName email');
    const updaterName = updater?.fullName || 'Một thành viên';

    for (const recipientId of allRecipientIds) {
      if (recipientId !== updaterId.toString()) {
        await createNotification({
          userId: recipientId,
          senderId: updaterId,
          taskId: task._id,
          type: 'task_status_changed',
          title: 'TRẠNG THÁI CÔNG VIỆC THAY ĐỔI',
          message: `Công việc "${task.title}" vừa được chuyển sang trạng thái "${statusText}".`,
        });

        // Email notification (D3)
        const recipient = await User.findById(recipientId).select('fullName email');
        if (recipient && recipient.email) {
          sendTaskStatusChangedEmail({
            to: recipient.email,
            recipientName: recipient.fullName,
            taskTitle: task.title,
            updaterName,
            newStatus,
          }).catch((err) => console.error('[NotificationService] Status email error:', err));
        }
      }
    }
  } catch (error) {
    console.error('[NotificationService.notifyStatusChanged] Error:', error);
  }
};

module.exports = {
  createNotification,
  notifyTaskAssignment,
  notifyTaskShared,
  notifyStatusChanged,
};
