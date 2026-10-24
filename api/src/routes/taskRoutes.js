const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const { validateCreateTask } = require('../validators/taskValidator');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route tasks đều yêu cầu đăng nhập
router.use(protect);

// Chức năng B1: Tạo mới công việc
router.post('/', validateCreateTask, taskController.createTask);

module.exports = router;
