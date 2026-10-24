const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateRegister, validateLogin } = require('../validators/authValidator');

// Chức năng A1: Đăng ký tài khoản
router.post('/register', validateRegister, authController.register);

// Chức năng A2: Đăng nhập tài khoản
router.post('/login', validateLogin, authController.login);

module.exports = router;
