const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route email-logs đều yêu cầu đăng nhập
router.use(protect);

// POST /api/email-logs/:id/retry
router.post('/:id/retry', taskController.retryEmail);

module.exports = router;
