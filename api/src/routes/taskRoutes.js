const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const { validateCreateTask } = require('../validators/taskValidator');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route tasks đều yêu cầu đăng nhập
router.use(protect);

// Chức năng B2: Lấy danh sách công việc
router.get('/', taskController.getTasks);

// Chức năng B3: Xem chi tiết công việc
router.get('/:id', taskController.getTaskById);

// Chức năng B4: Cập nhật thông tin công việc
router.put('/:id', taskController.updateTask);

// Chức năng C2: Phân công người thực hiện chính & danh sách người tham gia
router.put('/:id/assign', taskController.assignTask);

// Chức năng B4: Đổi trạng thái nhanh công việc
router.patch('/:id/status', taskController.updateTaskStatus);

// Chức năng B5: Xóa công việc (Chỉ người tạo có quyền)
router.delete('/:id', taskController.deleteTask);

// Chức năng B1: Tạo mới công việc
router.post('/', validateCreateTask, taskController.createTask);

module.exports = router;
