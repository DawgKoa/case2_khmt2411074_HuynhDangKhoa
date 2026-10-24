const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  try {
    let token;

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer ')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        status: 'error',
        message: 'Bạn chưa đăng nhập. Vui lòng cung cấp token xác thực.',
      });
    }

    // Xác minh token
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'super_secret_jwt_key_task_manager_casestudy2_2026'
    );

    // Lấy thông tin người dùng từ ID trong token
    const currentUser = await User.findById(decoded.id).select('-passwordHash');
    if (!currentUser) {
      return res.status(401).json({
        status: 'error',
        message: 'Tài khoản liên kết với token này không còn tồn tại.',
      });
    }

    req.user = currentUser;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        status: 'error',
        message: 'Mã xác thực (Token) không hợp lệ.',
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        status: 'error',
        message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      });
    }

    console.error('[authMiddleware] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xác thực quyền truy cập.',
    });
  }
};

module.exports = {
  protect,
};
