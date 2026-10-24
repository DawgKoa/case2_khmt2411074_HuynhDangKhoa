const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { sendOtpEmail } = require('../services/emailService');

const generateToken = (user) => {
  return jwt.sign(
    { id: user._id, email: user.email },
    process.env.JWT_SECRET || 'super_secret_jwt_key_task_manager_casestudy2_2026',
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

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

/**
 * Đăng nhập tài khoản & nhận JWT token (A2)
 * POST /api/auth/login
 */
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const cleanEmail = email.trim().toLowerCase();

    // 1. Tìm người dùng theo email
    const user = await User.findOne({ email: cleanEmail });
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Email hoặc mật khẩu không chính xác',
      });
    }

    // 2. So khớp mật khẩu với bản băm
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Email hoặc mật khẩu không chính xác',
      });
    }

    // 3. Tạo JWT token
    const token = generateToken(user);

    return res.status(200).json({
      status: 'success',
      message: 'Đăng nhập thành công',
      data: {
        token,
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
    console.error('[AuthController.login] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi đăng nhập. Vui lòng thử lại sau.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Lấy thông tin tài khoản người dùng hiện tại (A3)
 * GET /api/auth/me
 */
const getMe = async (req, res) => {
  return res.status(200).json({
    status: 'success',
    data: {
      user: {
        id: req.user._id,
        fullName: req.user.fullName,
        email: req.user.email,
        avatarUrl: req.user.avatarUrl,
        createdAt: req.user.createdAt,
        updatedAt: req.user.updatedAt,
      },
    },
  });
};

/**
 * Cập nhật thông tin cá nhân (A3)
 * PUT /api/auth/me
 */
const updateMe = async (req, res) => {
  try {
    const { fullName, avatarUrl } = req.body;
    const updates = {};

    if (fullName !== undefined) {
      if (typeof fullName !== 'string' || fullName.trim().length === 0) {
        return res.status(400).json({
          status: 'error',
          message: 'Họ và tên không được để trống',
        });
      }
      updates.fullName = fullName.trim();
    }

    if (avatarUrl !== undefined) {
      updates.avatarUrl = typeof avatarUrl === 'string' ? avatarUrl.trim() : '';
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      updates,
      { new: true, runValidators: true }
    ).select('-passwordHash');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật thông tin cá nhân thành công',
      data: {
        user: {
          id: updatedUser._id,
          fullName: updatedUser.fullName,
          email: updatedUser.email,
          avatarUrl: updatedUser.avatarUrl,
          createdAt: updatedUser.createdAt,
          updatedAt: updatedUser.updatedAt,
        },
      },
    });
  } catch (error) {
    console.error('[AuthController.updateMe] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi cập nhật thông tin cá nhân.',
    });
  }
};

/**
 * Đổi mật khẩu khi đã đăng nhập (A4)
 * PUT /api/auth/change-password
 */
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // 1. Lấy thông tin người dùng kèm theo passwordHash
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Tài khoản không tồn tại',
      });
    }

    // 2. So khớp mật khẩu hiện tại
    const isCurrentValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isCurrentValid) {
      return res.status(400).json({
        status: 'error',
        message: 'Mật khẩu hiện tại không chính xác',
      });
    }

    // 3. Mật khẩu mới không được trùng mật khẩu cũ
    const isSamePassword = await bcrypt.compare(newPassword, user.passwordHash);
    if (isSamePassword) {
      return res.status(400).json({
        status: 'error',
        message: 'Mật khẩu mới không được trùng với mật khẩu hiện tại',
      });
    }

    // 4. Băm mật khẩu mới và lưu
    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(newPassword, salt);
    await user.save();

    return res.status(200).json({
      status: 'success',
      message: 'Đổi mật khẩu thành công. Vui lòng đăng nhập lại.',
    });
  } catch (error) {
    console.error('[AuthController.changePassword] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi đổi mật khẩu.',
    });
  }
};

/**
 * Yêu cầu gửi mã OTP đặt lại mật khẩu (Quên mật khẩu)
 * POST /api/auth/forgot-password
 */
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const cleanEmail = email.trim().toLowerCase();

    // 1. Tìm tài khoản theo email
    const user = await User.findOne({ email: cleanEmail });
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy tài khoản với địa chỉ email này.',
      });
    }

    // 2. Tạo mã OTP ngẫu nhiên 6 chữ số
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expires = new Date(Date.now() + 15 * 60 * 1000); // 15 phút

    user.resetPasswordOtp = otp;
    user.resetPasswordOtpExpires = expires;
    await user.save();

    // 3. Gửi email chứa mã OTP
    const mailRes = await sendOtpEmail({
      to: user.email,
      otp,
      fullName: user.fullName,
    });

    return res.status(200).json({
      status: 'success',
      message: 'Mã xác thực OTP đã được gửi đến email của bạn.',
      data: {
        email: user.email,
        // Cung cấp OTP trực tiếp nếu là môi trường dev hoặc gửi mail fallback để dễ test
        devOtp: mailRes.fallbackOtp || (process.env.NODE_ENV !== 'production' ? otp : undefined),
      },
    });
  } catch (error) {
    console.error('[AuthController.forgotPassword] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xử lý yêu cầu quên mật khẩu.',
    });
  }
};

/**
 * Xác thực mã OTP và đặt mật khẩu mới
 * POST /api/auth/reset-password
 */
const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const cleanEmail = email.trim().toLowerCase();

    // 1. Tìm tài khoản với email, mã OTP khớp và chưa hết hạn
    const user = await User.findOne({
      email: cleanEmail,
      resetPasswordOtp: otp.trim(),
      resetPasswordOtpExpires: { $gt: new Date() },
    });

    if (!user) {
      return res.status(400).json({
        status: 'error',
        message: 'Mã xác thực OTP không chính xác hoặc đã hết thời gian hiệu lực (15 phút).',
      });
    }

    // 2. Băm mật khẩu mới
    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(newPassword, salt);
    user.resetPasswordOtp = null;
    user.resetPasswordOtpExpires = null;
    await user.save();

    return res.status(200).json({
      status: 'success',
      message: 'Đặt lại mật khẩu thành công! Bạn có thể đăng nhập ngay bằng mật khẩu mới.',
    });
  } catch (error) {
    console.error('[AuthController.resetPassword] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi đặt lại mật khẩu.',
    });
  }
};

module.exports = {
  register,
  login,
  getMe,
  updateMe,
  changePassword,
  forgotPassword,
  resetPassword,
};
