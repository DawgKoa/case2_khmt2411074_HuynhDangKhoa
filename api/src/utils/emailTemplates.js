/**
 * Brutalist HTML Email Templates for Task Manager App
 * Case Study 2 - Mobile Neo-Brutalist styling
 */

const getOtpTemplate = (fullName, otp) => `
  <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 2px solid #050504; padding: 24px; background-color: #EFEDE0;">
    <h2 style="color: #050504; margin-top: 0; text-transform: uppercase;">TASK MANAGER // BẢO MẬT HỆ THỐNG</h2>
    <p>Xin chào <strong>${fullName || 'bạn'}</strong>,</p>
    <p>Hệ thống nhận được yêu cầu đặt lại mật khẩu cho tài khoản liên kết với email này.</p>
    <div style="background-color: #FFFFFF; border: 2px solid #050504; padding: 16px; margin: 20px 0; text-align: center;">
      <p style="margin: 0 0 8px 0; font-size: 13px; color: #5E584C; font-weight: bold; letter-spacing: 1px;">MÃ XÁC THỰC OTP (HẾT HẠN TRONG 15 PHÚT)</p>
      <span style="font-size: 32px; font-weight: 900; letter-spacing: 6px; color: #050504; background-color: #F6B400; padding: 4px 16px; display: inline-block; border: 1.5px solid #050504;">${otp}</span>
    </div>
    <p style="font-size: 13px; color: #5E584C;">Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này hoặc liên hệ quản trị viên để bảo vệ tài khoản.</p>
    <hr style="border: none; border-top: 1.5px solid #7E817B; margin: 24px 0;" />
    <p style="font-size: 11px; color: #7E817B; margin-bottom: 0;">Case Study 2 - Ứng dụng Quản lý và Giao công việc nhóm</p>
  </div>
`;

const getTaskAssignmentTemplate = ({
  recipientName,
  taskTitle,
  assignerName,
  dueDate,
  priority,
}) => {
  const priorityLabels = {
    high: 'KHẨN CẤP / CAO',
    medium: 'TRUNG BÌNH',
    low: 'THẤP',
  };
  const priorityText = priorityLabels[priority] || (priority ? priority.toUpperCase() : 'TRUNG BÌNH');
  const dueDateText = dueDate ? new Date(dueDate).toLocaleString('vi-VN') : 'Không có hạn chót';

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 2px solid #050504; padding: 24px; background-color: #EFEDE0;">
      <div style="display: inline-block; background-color: #F6B400; color: #050504; font-weight: 900; font-size: 12px; padding: 4px 8px; border: 1.5px solid #050504; margin-bottom: 12px;">
        MODULE D // EMAIL NOTIFICATION
      </div>
      <h2 style="color: #050504; margin-top: 0; text-transform: uppercase;">BẠN ĐƯỢC PHÂN CÔNG CÔNG VIỆC MỚI</h2>
      <p>Xin chào <strong>${recipientName || 'bạn'}</strong>,</p>
      <p><strong>${assignerName || 'Một thành viên'}</strong> vừa phân công bạn tham gia thực hiện công việc:</p>
      
      <div style="background-color: #FFFFFF; border: 2px solid #050504; padding: 18px; margin: 20px 0; box-shadow: 3px 3px 0px #050504;">
        <h3 style="margin: 0 0 10px 0; color: #050504; font-size: 18px;">${taskTitle}</h3>
        <p style="margin: 4px 0; font-size: 13px; color: #5E584C;"><strong>Mức độ ưu tiên:</strong> <span style="color: ${priority === 'high' ? '#F61F01' : '#050504'}; font-weight: bold;">${priorityText}</span></p>
        <p style="margin: 4px 0; font-size: 13px; color: #5E584C;"><strong>Hạn chót hoàn thành:</strong> ${dueDateText}</p>
      </div>

      <p style="font-size: 13px; color: #5E584C;">Vui lòng mở ứng dụng <strong>Task Manager</strong> để xem chi tiết tiến độ và thực hiện công việc.</p>
      <hr style="border: none; border-top: 1.5px solid #7E817B; margin: 24px 0;" />
      <p style="font-size: 11px; color: #7E817B; margin-bottom: 0;">Case Study 2 - Ứng dụng Quản lý và Giao công việc nhóm</p>
    </div>
  `;
};

const getTaskSharedTemplate = ({
  recipientName,
  taskTitle,
  sharerName,
  role,
}) => {
  const roleLabels = {
    viewer: 'NGƯỜI XEM (VIEWER)',
    editor: 'NGƯỜI CHỈNH SỬA (EDITOR)',
    admin: 'QUẢN TRỊ VIÊN (ADMIN)',
  };
  const roleText = roleLabels[role] || (role ? role.toUpperCase() : 'VIEWER');

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 2px solid #050504; padding: 24px; background-color: #EFEDE0;">
      <div style="display: inline-block; background-color: #F6B400; color: #050504; font-weight: 900; font-size: 12px; padding: 4px 8px; border: 1.5px solid #050504; margin-bottom: 12px;">
        MODULE D // COLLABORATION
      </div>
      <h2 style="color: #050504; margin-top: 0; text-transform: uppercase;">CÔNG VIỆC ĐƯỢC CHIA SẺ VỚI BẠN</h2>
      <p>Xin chào <strong>${recipientName || 'bạn'}</strong>,</p>
      <p><strong>${sharerName || 'Một thành viên'}</strong> vừa chia sẻ quyền truy cập công việc với bạn:</p>
      
      <div style="background-color: #FFFFFF; border: 2px solid #050504; padding: 18px; margin: 20px 0; box-shadow: 3px 3px 0px #050504;">
        <h3 style="margin: 0 0 10px 0; color: #050504; font-size: 18px;">${taskTitle}</h3>
        <p style="margin: 4px 0; font-size: 13px; color: #5E584C;"><strong>Vai trò được cấp:</strong> <span style="background-color: #050504; color: #FFFFFF; padding: 2px 8px; font-weight: bold; border-radius: 4px;">${roleText}</span></p>
      </div>

      <p style="font-size: 13px; color: #5E584C;">Bạn có thể mở ứng dụng <strong>Task Manager</strong> để bắt đầu xem và cộng tác trong công việc này.</p>
      <hr style="border: none; border-top: 1.5px solid #7E817B; margin: 24px 0;" />
      <p style="font-size: 11px; color: #7E817B; margin-bottom: 0;">Case Study 2 - Ứng dụng Quản lý và Giao công việc nhóm</p>
    </div>
  `;
};

const getTaskStatusChangedTemplate = ({
  recipientName,
  taskTitle,
  updaterName,
  newStatus,
}) => {
  const statusLabels = {
    todo: 'CHỜ XỬ LÝ',
    in_progress: 'ĐANG LÀM',
    completed: 'HOÀN THÀNH',
    cancelled: 'ĐÃ HỦY',
  };
  const statusText = statusLabels[newStatus] || newStatus.toUpperCase();

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 2px solid #050504; padding: 24px; background-color: #EFEDE0;">
      <div style="display: inline-block; background-color: #F6B400; color: #050504; font-weight: 900; font-size: 12px; padding: 4px 8px; border: 1.5px solid #050504; margin-bottom: 12px;">
        MODULE D // STATUS UPDATE
      </div>
      <h2 style="color: #050504; margin-top: 0; text-transform: uppercase;">TRẠNG THÁI CÔNG VIỆC THAY ĐỔI</h2>
      <p>Xin chào <strong>${recipientName || 'bạn'}</strong>,</p>
      <p><strong>${updaterName || 'Một thành viên'}</strong> vừa cập nhật trạng thái của công việc:</p>
      
      <div style="background-color: #FFFFFF; border: 2px solid #050504; padding: 18px; margin: 20px 0; box-shadow: 3px 3px 0px #050504;">
        <h3 style="margin: 0 0 10px 0; color: #050504; font-size: 18px;">${taskTitle}</h3>
        <p style="margin: 4px 0; font-size: 13px; color: #5E584C;"><strong>Trạng thái mới:</strong> <span style="background-color: #F6B400; color: #050504; padding: 2px 8px; font-weight: bold; border: 1px solid #050504;">${statusText}</span></p>
      </div>

      <p style="font-size: 13px; color: #5E584C;">Mở ứng dụng <strong>Task Manager</strong> để cập nhật tiến trình mới nhất.</p>
      <hr style="border: none; border-top: 1.5px solid #7E817B; margin: 24px 0;" />
      <p style="font-size: 11px; color: #7E817B; margin-bottom: 0;">Case Study 2 - Ứng dụng Quản lý và Giao công việc nhóm</p>
    </div>
  `;
};

const getTaskReminderTemplate = ({
  recipientName,
  taskTitle,
  dueDate,
  hoursLeft,
}) => {
  const dueDateText = dueDate ? new Date(dueDate).toLocaleString('vi-VN') : 'Sắp tới hạn';

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 2px solid #050504; padding: 24px; background-color: #EFEDE0;">
      <div style="display: inline-block; background-color: #F61F01; color: #FFFFFF; font-weight: 900; font-size: 12px; padding: 4px 8px; border: 1.5px solid #050504; margin-bottom: 12px;">
        MODULE D // DEADLINE REMINDER
      </div>
      <h2 style="color: #050504; margin-top: 0; text-transform: uppercase;">⚠️ CẢNH BÁO HẠN CHÓT CÔNG VIỆC</h2>
      <p>Xin chào <strong>${recipientName || 'bạn'}</strong>,</p>
      <p>Công việc sau sắp hết hạn trong vòng <strong>${hoursLeft !== undefined ? hoursLeft + ' giờ tới' : 'thời gian tới'}</strong>:</p>
      
      <div style="background-color: #FFFFFF; border: 2px solid #050504; padding: 18px; margin: 20px 0; box-shadow: 3px 3px 0px #050504;">
        <h3 style="margin: 0 0 10px 0; color: #050504; font-size: 18px;">${taskTitle}</h3>
        <p style="margin: 4px 0; font-size: 13px; color: #F61F01; font-weight: bold;">Hạn chót: ${dueDateText}</p>
      </div>

      <p style="font-size: 13px; color: #5E584C;">Vui lòng hoàn thành công việc hoặc liên hệ quản trị viên để gia hạn thời gian.</p>
      <hr style="border: none; border-top: 1.5px solid #7E817B; margin: 24px 0;" />
      <p style="font-size: 11px; color: #7E817B; margin-bottom: 0;">Case Study 2 - Ứng dụng Quản lý và Giao công việc nhóm</p>
    </div>
  `;
};

module.exports = {
  getOtpTemplate,
  getTaskAssignmentTemplate,
  getTaskSharedTemplate,
  getTaskStatusChangedTemplate,
  getTaskReminderTemplate,
};
