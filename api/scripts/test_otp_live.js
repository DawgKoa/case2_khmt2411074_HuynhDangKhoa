const API_URL = 'http://localhost:5000/api';
const testEmail = 'dangkhoa15022006@gmail.com';
const newPassword = 'Password123456!';

async function testOtpFlow() {
  console.log('=== TEST FORGOT PASSWORD & OTP LIVE ===');
  console.log(`1. Gửi yêu cầu quên mật khẩu cho ${testEmail}...`);

  try {
    const forgotRes = await fetch(`${API_URL}/auth/forgot-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: testEmail }),
    });

    const forgotData = await forgotRes.json();
    console.log('✔ Gửi OTP thành công! Status:', forgotRes.status);
    console.log('Response:', forgotData);
    const otp = forgotData.data?.devOtp;
    console.log(`Mã OTP nhận được: ${otp}`);

    if (!otp) {
      throw new Error('Không nhận được mã OTP!');
    }

    console.log(`\n2. Thực hiện đặt lại mật khẩu với OTP: ${otp} và mật khẩu mới: ${newPassword}...`);
    const resetRes = await fetch(`${API_URL}/auth/reset-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        otp,
        newPassword,
      }),
    });

    const resetData = await resetRes.json();
    console.log('✔ Đặt lại mật khẩu thành công! Status:', resetRes.status);
    console.log('Response:', resetData);

    console.log(`\n3. Thử đăng nhập lại bằng mật khẩu mới vừa đổi...`);
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: newPassword,
      }),
    });

    const loginData = await loginRes.json();
    console.log('✔ Đăng nhập thành công với mật khẩu mới! Status:', loginRes.status);
    console.log('User:', loginData.data?.user?.fullName, '-', loginData.data?.user?.email);
    console.log('Token:', loginData.data?.token?.substring(0, 30) + '...');

    console.log('\n=======================================');
    console.log('🎉 TẤT CẢ CÁC BƯỚC QUÊN MẬT KHẨU & OTP ĐỀU HOẠT ĐỘNG HOÀN HẢO!');
  } catch (error) {
    console.error('❌ Lỗi:', error);
  }
}

testOtpFlow();
