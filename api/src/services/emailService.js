const { createTransporter } = require('../config/email');

/**
 * Gửi email chứa mã OTP đặt lại mật khẩu
 */
const sendOtpEmail = async ({ to, otp, fullName }) => {
  const mailOptions = {
    from: process.env.EMAIL_FROM || '"Task Manager App" <noreply@taskmanager.com>',
    to,
    subject: `[Task Manager] Mã xác thực đặt lại mật khẩu: ${otp}`,
    html: `
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
    `,
  };

  try {
    const transporter = createTransporter();
    const info = await transporter.sendMail(mailOptions);
    console.log(`[EmailService] OTP email sent to ${to}. MessageId: ${info.messageId}`);
    return { success: true };
  } catch (error) {
    console.warn(`[EmailService] SMTP send failed (${error.message}). [DEV/FALLBACK OTP for ${to}]: ${otp}`);
    return { success: false, fallbackOtp: otp, error: error.message };
  }
};

module.exports = {
  sendOtpEmail,
};
