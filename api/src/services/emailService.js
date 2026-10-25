const { createTransporter } = require('../config/email');
const EmailLog = require('../models/EmailLog');
const {
  getOtpTemplate,
  getTaskAssignmentTemplate,
  getTaskSharedTemplate,
  getTaskStatusChangedTemplate,
  getTaskReminderTemplate,
} = require('../utils/emailTemplates');

const defaultFrom = process.env.EMAIL_FROM || '"Task Manager App" <noreply@taskmanager.com>';

/**
 * Helper ghi lại log email và thực thi gửi qua nodemailer
 */
const sendAndLogEmail = async ({ taskId = null, recipientEmail, eventType, subject, html }) => {
  let emailLog;
  try {
    emailLog = await EmailLog.create({
      taskId,
      recipientEmail: recipientEmail.trim().toLowerCase(),
      eventType,
      subject,
      status: 'pending',
      attempts: 1,
    });
  } catch (err) {
    console.error('[EmailService] Failed to create EmailLog record:', err);
  }

  const mailOptions = {
    from: defaultFrom,
    to: recipientEmail,
    subject,
    html,
  };

  try {
    const transporter = createTransporter();
    const info = await transporter.sendMail(mailOptions);
    console.log(`[EmailService] ${eventType} email sent to ${recipientEmail}. MessageId: ${info.messageId}`);

    if (emailLog) {
      emailLog.status = 'sent';
      emailLog.sentAt = new Date();
      await emailLog.save();
    }

    return { success: true, emailLogId: emailLog?._id };
  } catch (error) {
    console.warn(`[EmailService] SMTP send failed for ${recipientEmail} (${error.message}).`);

    if (emailLog) {
      emailLog.status = 'failed';
      emailLog.errorMessage = error.message;
      await emailLog.save();
    }

    return { success: false, error: error.message, emailLogId: emailLog?._id };
  }
};

/**
 * Gửi email chứa mã OTP đặt lại mật khẩu (A4)
 */
const sendOtpEmail = async ({ to, otp, fullName }) => {
  const subject = `[Task Manager] Mã xác thực đặt lại mật khẩu: ${otp}`;
  const html = getOtpTemplate(fullName, otp);

  const result = await sendAndLogEmail({
    taskId: null,
    recipientEmail: to,
    eventType: 'forgot_password_otp',
    subject,
    html,
  });

  return { ...result, fallbackOtp: otp };
};

/**
 * Gửi email thông báo khi được phân công công việc mới (D3)
 */
const sendTaskAssignmentEmail = async ({
  to,
  recipientName,
  taskTitle,
  assignerName,
  dueDate,
  priority,
  taskId = null,
}) => {
  const subject = `[Task Manager] Phân công công việc mới: ${taskTitle}`;
  const html = getTaskAssignmentTemplate({
    recipientName,
    taskTitle,
    assignerName,
    dueDate,
    priority,
  });

  return sendAndLogEmail({
    taskId,
    recipientEmail: to,
    eventType: 'task_assigned',
    subject,
    html,
  });
};

/**
 * Gửi email thông báo khi được chia sẻ công việc (D3)
 */
const sendTaskSharedEmail = async ({
  to,
  recipientName,
  taskTitle,
  sharerName,
  role,
  taskId = null,
}) => {
  const subject = `[Task Manager] Công việc được chia sẻ: ${taskTitle}`;
  const html = getTaskSharedTemplate({
    recipientName,
    taskTitle,
    sharerName,
    role,
  });

  return sendAndLogEmail({
    taskId,
    recipientEmail: to,
    eventType: 'task_shared',
    subject,
    html,
  });
};

/**
 * Gửi email thông báo khi trạng thái công việc thay đổi (D3)
 */
const sendTaskStatusChangedEmail = async ({
  to,
  recipientName,
  taskTitle,
  updaterName,
  newStatus,
  taskId = null,
}) => {
  const statusLabels = {
    todo: 'CHỜ XỬ LÝ',
    in_progress: 'ĐANG LÀM',
    completed: 'HOÀN THÀNH',
    cancelled: 'ĐÃ HỦY',
  };
  const statusText = statusLabels[newStatus] || (newStatus ? newStatus.toUpperCase() : 'CẬP NHẬT');
  const subject = `[Task Manager] Trạng thái cập nhật: ${taskTitle} [${statusText}]`;
  const html = getTaskStatusChangedTemplate({
    recipientName,
    taskTitle,
    updaterName,
    newStatus,
  });

  return sendAndLogEmail({
    taskId,
    recipientEmail: to,
    eventType: 'task_status_changed',
    subject,
    html,
  });
};

/**
 * Gửi email nhắc nhở hạn chót công việc (D4)
 */
const sendTaskReminderEmail = async ({
  to,
  recipientName,
  taskTitle,
  dueDate,
  priority,
  hoursLeft,
  taskId = null,
}) => {
  const subject = `[Task Manager] ⚠️ NHẮC NHỞ HẠN CHÓT: ${taskTitle}`;
  const html = getTaskReminderTemplate({
    recipientName,
    taskTitle,
    dueDate,
    priority,
    hoursLeft,
  });

  return sendAndLogEmail({
    taskId,
    recipientEmail: to,
    eventType: 'deadline_reminder',
    subject,
    html,
  });
};

/**
 * Thử gửi lại email đã thất bại (Retry Email)
 * POST /api/email-logs/:id/retry
 */
const retryEmailLog = async (logId) => {
  const emailLog = await EmailLog.findById(logId);
  if (!emailLog) {
    throw new Error('Không tìm thấy bản ghi email log.');
  }

  emailLog.attempts = (emailLog.attempts || 0) + 1;

  const mailOptions = {
    from: defaultFrom,
    to: emailLog.recipientEmail,
    subject: emailLog.subject,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; border: 2px solid #050504; background: #EFEDE0;">
        <h3 style="margin-top: 0;">[THỬ LẠI / RETRY] ${emailLog.subject}</h3>
        <p>Email này được thử gửi lại từ hàng đợi Task Manager.</p>
        <p>Sự kiện: <strong>${emailLog.eventType}</strong></p>
      </div>
    `,
  };

  try {
    const transporter = createTransporter();
    const info = await transporter.sendMail(mailOptions);
    emailLog.status = 'sent';
    emailLog.sentAt = new Date();
    emailLog.errorMessage = null;
    await emailLog.save();
    return { success: true, emailLog, messageId: info.messageId };
  } catch (err) {
    emailLog.status = 'failed';
    emailLog.errorMessage = err.message;
    await emailLog.save();
    return { success: false, emailLog, error: err.message };
  }
};

module.exports = {
  sendOtpEmail,
  sendTaskAssignmentEmail,
  sendTaskSharedEmail,
  sendTaskStatusChangedEmail,
  sendTaskReminderEmail,
  retryEmailLog,
};
