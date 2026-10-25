const express = require('express');
const router = express.Router();
const statisticsController = require('../controllers/statisticsController');
const { protect } = require('../middleware/authMiddleware');

// Tất cả route thống kê đều yêu cầu đăng nhập
router.use(protect);

// GET /api/statistics/tasks
router.get('/tasks', statisticsController.getTaskStats);

// GET /api/statistics/assignments
router.get('/assignments', statisticsController.getAssignmentStats);

// GET /api/statistics/deadlines
router.get('/deadlines', statisticsController.getDeadlineStats);

// Default fallback GET /api/statistics
router.get('/', statisticsController.getTaskStats);

module.exports = router;
