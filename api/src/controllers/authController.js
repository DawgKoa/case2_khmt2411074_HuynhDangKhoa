const bcrypt = require('bcryptjs');
const User = require('../models/User');

/**
 * Đăng ký tài khoản mới (A1)
 * POST /api/auth/register
 */
const register = async (req, res) => {
  try {
    const { fullName, email, password } = req.body;
    const cleanEmail = email.trim().toLowerCase();

    // 1. Kiểm tra email đã tồn tại hay chưa
    const existingUser = await User.findOne({ email: cleanEmail });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'Email này đã được sử dụng. Vui lòng chọn email khác.',
      });
    }

    // 2. Băm mật khẩu bằng bcryptjs
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // 3. Tạo tài khoản trong cơ sở dữ liệu
    const user = await User.create({
      fullName: fullName.trim(),
      email: cleanEmail,
      passwordHash,
    });

    return res.status(201).json({
      status: 'success',
      message: 'Đăng ký tài khoản thành công',
      data: {
        user: {
          id: user._id,
          fullName: user.fullName,
          email: user.email,
          avatarUrl: user.avatarUrl,
          createdAt: user.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('[AuthController.register] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi đăng ký tài khoản. Vui lòng thử lại sau.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

module.exports = {
  register,
};
