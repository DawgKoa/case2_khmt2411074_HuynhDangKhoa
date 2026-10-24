const Task = require('../models/Task');
const Notification = require('../models/Notification');
const { sendTaskReminderEmail } = require('./emailService');

/**
 * Quét các công việc sắp tới hạn hoặc quá hạn và gửi thông báo nhắc nhở (D4)
 */
const checkAndSendDeadlineReminders = async () => {
  try {
    const now = new Date();
    const next24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const dedupeWindowHours = 12; // Không gửi lại nếu đã gửi trong 12 giờ qua
    const dedupeSince = new Date(now.getTime() - dedupeWindowHours * 60 * 60 * 1000);

    // Tìm các task chưa hoàn thành và có dueDate <= next24Hours
    const upcomingTasks = await Task.find({
      dueDate: { $ne: null, $lte: next24Hours },
      status: { $in: ['todo', 'in_progress'] },
    })
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    let remindersSent = 0;
    const reminderDetails = [];

    for (const task of upcomingTasks) {
      const diffMs = new Date(task.dueDate).getTime() - now.getTime();
      const hoursLeft = Math.round(diffMs / (1000 * 60 * 60));
      const isOverdue = diffMs < 0;

      // Danh sách người cần nhắc nhở (Primary Assignee + Assignees + Creator)
      const usersToNotify = new Map();
      if (task.primaryAssigneeId?._id) {
        usersToNotify.set(task.primaryAssigneeId._id.toString(), task.primaryAssigneeId);
      }
      if (Array.isArray(task.assigneeIds)) {
        task.assigneeIds.forEach((u) => {
          if (u?._id) usersToNotify.set(u._id.toString(), u);
        });
      }
      if (task.createdBy?._id) {
        usersToNotify.set(task.createdBy._id.toString(), task.createdBy);
      }

      for (const [userIdStr, userObj] of usersToNotify.entries()) {
        // Kiểm tra deduplication
        const existingNotif = await Notification.findOne({
          userId: userIdStr,
          taskId: task._id,
          type: 'task_reminder',
          createdAt: { $gte: dedupeSince },
        });

        if (!existingNotif) {
          const title = isOverdue
            ? `⚠️ CÔNG VIỆC QUÁ HẠN: ${task.title}`
            : `⚠️ SẮP TỚI HẠN CHÓT: ${task.title}`;
          const message = isOverdue
            ? `Công việc "${task.title}" đã quá hạn vào ${new Date(task.dueDate).toLocaleString('vi-VN')}. Vui lòng kiểm tra và xử lý ngay.`
            : `Công việc "${task.title}" sẽ tới hạn trong khoảng ${hoursLeft > 0 ? hoursLeft : 1} giờ nữa (${new Date(task.dueDate).toLocaleString('vi-VN')}).`;

          // Tạo In-app notification (D1/D4)
          await Notification.create({
            userId: userObj._id,
            taskId: task._id,
            type: 'task_reminder',
            title,
            message,
          });

          // Gửi Email nhắc nhở (D3/D4)
          if (userObj.email) {
            sendTaskReminderEmail({
              to: userObj.email,
              recipientName: userObj.fullName,
              taskTitle: task.title,
              dueDate: task.dueDate,
              priority: task.priority,
              hoursLeft: isOverdue ? 0 : hoursLeft,
            }).catch((err) =>
              console.error('[ReminderService] Email send error:', err)
            );
          }

          remindersSent++;
          reminderDetails.push({
            taskId: task._id,
            taskTitle: task.title,
            recipientEmail: userObj.email,
            isOverdue,
            hoursLeft,
          });
        }
      }
    }

    console.log(
      `[ReminderService] Scanned ${upcomingTasks.length} tasks, sent ${remindersSent} reminders.`
    );
    return {
      scannedTasks: upcomingTasks.length,
      remindersSent,
      details: reminderDetails,
    };
  } catch (error) {
    console.error('[ReminderService.checkAndSendDeadlineReminders] Error:', error);
    throw error;
  }
};

let reminderInterval = null;

const startReminderCron = (intervalMinutes = 30) => {
  if (reminderInterval) {
    clearInterval(reminderInterval);
  }

  // Chạy ngay 1 lần sau 5 giây khởi động
  setTimeout(() => {
    checkAndSendDeadlineReminders().catch((err) =>
      console.error('[ReminderService] Initial scan failed:', err)
    );
  }, 5000);

  // Định kỳ lặp lại
  reminderInterval = setInterval(() => {
    checkAndSendDeadlineReminders().catch((err) =>
      console.error('[ReminderService] Periodic scan failed:', err)
    );
  }, intervalMinutes * 60 * 1000);

  console.log(
    `[ReminderService] Scheduled deadline reminder job running every ${intervalMinutes} minutes.`
  );
};

module.exports = {
  checkAndSendDeadlineReminders,
  startReminderCron,
};
