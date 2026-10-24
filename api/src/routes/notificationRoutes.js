const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route thông báo đều yêu cầu đăng nhập
router.use(protect);

// Chức năng D1: Lấy danh sách thông báo
router.get('/', notificationController.getNotifications);

// Chức năng D1: Đánh dấu tất cả thông báo là đã đọc
router.patch('/read-all', notificationController.markAllAsRead);

// Chức năng D4: Kích hoạt quét và gửi thông báo nhắc nhở hạn chót
router.post('/reminders/trigger', notificationController.triggerDeadlineReminders);

// Chức năng D1: Đánh dấu 1 thông báo là đã đọc
router.patch('/:id/read', notificationController.markAsRead);

// Chức năng D1: Xóa một thông báo
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;
