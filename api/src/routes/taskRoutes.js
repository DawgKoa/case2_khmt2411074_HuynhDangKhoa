const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const { validateCreateTask } = require('../validators/taskValidator');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route tasks đều yêu cầu đăng nhập
router.use(protect);

// Chức năng B2: Lấy danh sách công việc
router.get('/', taskController.getTasks);

// Chức năng E1: Thống kê công việc và hiệu suất (Đặt trước /:id)
router.get('/stats/summary', taskController.getTaskStats);

// Chức năng B1: Tạo mới công việc
router.post('/', validateCreateTask, taskController.createTask);

// Gắn sub-router cho người phân công (/api/tasks/:id/assignees)
router.use('/:id/assignees', require('./assignmentRoutes'));

// Gắn sub-router cho chia sẻ công việc (/api/tasks/:id/shares)
router.use('/:id/shares', require('./taskShareRoutes'));

// Nhật ký hoạt động của công việc
router.get('/:id/activities', taskController.getTaskActivities);

// Danh sách email log của công việc
router.get('/:id/email-logs', taskController.getTaskEmailLogs);

// Chức năng B4: Đổi trạng thái nhanh công việc
router.patch('/:id/status', taskController.updateTaskStatus);

// Chức năng C2 (Legacy Alias): Phân công người thực hiện chính & danh sách người tham gia
router.put('/:id/assign', taskController.assignTask);

// Chức năng C3 (Legacy Alias): Chia sẻ công việc và phân quyền RBAC
router.post('/:id/share', taskController.shareTask);

// Chức năng C4 (Legacy Alias): Thay đổi vai trò thành viên
router.patch('/:id/members/:memberId', taskController.updateMemberRole);

// Chức năng C4 (Legacy Alias): Thu hồi quyền truy cập / Xóa thành viên
router.delete('/:id/members/:memberId', taskController.revokeTaskMember);

// Chức năng B3: Xem chi tiết công việc
router.get('/:id', taskController.getTaskById);

// Chức năng B4: Cập nhật thông tin công việc
router.put('/:id', taskController.updateTask);

// Chức năng B5: Xóa công việc (Chỉ người tạo hoặc Admin có quyền)
router.delete('/:id', taskController.deleteTask);

module.exports = router;
