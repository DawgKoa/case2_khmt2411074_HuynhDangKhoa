require('dotenv').config();
const { createTransporter } = require('./src/config/email');

async function testEmailConnection() {
  console.log('--- KIỂM TRA KẾT NỐI SMTP EMAIL ---');
  console.log(`SMTP Host: ${process.env.SMTP_HOST || 'smtp.gmail.com'}`);
  console.log(`SMTP Port: ${process.env.SMTP_PORT || '587'}`);
  console.log(`SMTP User: ${process.env.SMTP_USER || '(Chưa cấu hình)'}`);

  if (!process.env.SMTP_USER || process.env.SMTP_USER === 'test@gmail.com') {
    console.warn('\n⚠️ CẢNH BÁO: Bạn đang dùng email placeholder (test@gmail.com).');
    console.warn('Vui lòng mở file api/.env và cập nhật SMTP_USER & SMTP_PASS bằng Gmail thật và App Password (16 ký tự).\n');
  }

  const transporter = createTransporter();

  try {
    console.log('1. Đang xác thực thông tin đăng nhập SMTP...');
    await transporter.verify();
    console.log('✅ Xác thực máy chủ SMTP thành công!');

    console.log('2. Đang gửi email thử nghiệm...');
    const info = await transporter.sendMail({
      from: process.env.EMAIL_FROM || `"Task Manager App" <${process.env.SMTP_USER}>`,
      to: process.env.SMTP_USER,
      subject: '🚀 [Task Manager] Kiểm tra kết nối Email thành công',
      html: `
        <div style="font-family: sans-serif; border: 2px solid #000; padding: 20px; background: #EFEDE0; max-width: 500px;">
          <h2 style="margin-top: 0; background: #F6B400; padding: 10px; border: 2px solid #000;">TASK MANAGER - EMAIL VERIFIED</h2>
          <p>Xin chào <b>${process.env.SMTP_USER}</b>,</p>
          <p>Hệ thống gửi email thông báo của ứng dụng Task Manager (Case Study 2) đã được kết nối thành công!</p>
          <p>Các tính năng sau đã sẵn sàng hoạt động:</p>
          <ul>
            <li>Gửi mã OTP khi quên mật khẩu</li>
            <li>Thông báo khi được giao việc hoặc chia sẻ quyền</li>
            <li>Thông báo thay đổi trạng thái và nhắc việc trước hạn 24 giờ</li>
          </ul>
          <hr style="border: 1px dashed #000;" />
          <p style="font-size: 12px; color: #555;">Thời gian gửi: ${new Date().toLocaleString('vi-VN')}</p>
        </div>
      `,
    });

    console.log(`✅ Đã gửi email thử nghiệm thành công! Message ID: ${info.messageId}`);
    console.log('Vui lòng kiểm tra hộp thư đến (hoặc thư mục Spam) của bạn.');
  } catch (error) {
    console.error('\n❌ GỬI EMAIL THẤT BẠI:');
    console.error(error.message);
    console.log('\n💡 HƯỚNG DẪN KHẮC PHỤC KHI DÙNG GMAIL:');
    console.log('1. Đảm bảo tài khoản Gmail đã bật Xác thực 2 bước (2-Step Verification).');
    console.log('2. Tạo "Mật khẩu ứng dụng" (App Password) tại: https://myaccount.google.com/apppasswords');
    console.log('3. Điền mật khẩu 16 chữ cái (không có khoảng trắng) vào biến SMTP_PASS trong file api/.env');
  }
}

testEmailConnection();
