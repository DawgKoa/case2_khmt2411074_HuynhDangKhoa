const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const {
  validateRegister,
  validateLogin,
  validateChangePassword,
  validateForgotPassword,
  validateResetPassword,
} = require('../validators/authValidator');
const { protect } = require('../middleware/authMiddleware');

// Chức năng A1: Đăng ký tài khoản
router.post('/register', validateRegister, authController.register);

// Chức năng A2: Đăng nhập tài khoản
router.post('/login', validateLogin, authController.login);

// Chức năng A3: Xem và cập nhật thông tin cá nhân
router.get('/me', protect, authController.getMe);
router.put('/me', protect, authController.updateMe);

// Chức năng A4: Đổi mật khẩu
router.put('/change-password', protect, validateChangePassword, authController.changePassword);

// Chức năng mở rộng: Quên mật khẩu & Đặt lại mật khẩu qua OTP
router.post('/forgot-password', validateForgotPassword, authController.forgotPassword);
router.post('/reset-password', validateResetPassword, authController.resetPassword);

module.exports = router;
