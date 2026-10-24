const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

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

module.exports = {
  register,
  login,
  getMe,
  updateMe,
};
