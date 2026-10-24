const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateRegister } = require('../validators/authValidator');

// Chức năng A1: Đăng ký tài khoản
router.post('/register', validateRegister, authController.register);

module.exports = router;
