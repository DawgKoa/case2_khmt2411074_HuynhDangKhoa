const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route users đều cần đăng nhập
router.use(protect);

// Chức năng C1: Tìm kiếm người dùng theo email hoặc họ tên
router.get('/search', userController.searchUsers);

// Lấy danh sách gợi ý người dùng
router.get('/', userController.getUsers);

// Lấy chi tiết thông tin người dùng theo ID
router.get('/:id', userController.getUserById);

module.exports = router;
