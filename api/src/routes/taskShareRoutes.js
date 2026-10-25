const express = require('express');
const router = express.Router({ mergeParams: true });
const taskShareController = require('../controllers/taskShareController');
const { protect } = require('../middleware/authMiddleware');
const {
  requireTaskView,
  requireTaskAdminOrCreator,
} = require('../middleware/permissionMiddleware');

// Tất cả route chia sẻ đều yêu cầu đăng nhập
router.use(protect);

// GET /api/tasks/:id/shares
router.get('/', requireTaskView, taskShareController.getShares);

// POST /api/tasks/:id/shares
router.post('/', requireTaskAdminOrCreator, taskShareController.createShare);

// PATCH /api/tasks/:id/shares/:shareId
router.patch('/:shareId', requireTaskAdminOrCreator, taskShareController.updateShare);

// DELETE /api/tasks/:id/shares/:shareId
router.delete('/:shareId', requireTaskAdminOrCreator, taskShareController.deleteShare);

module.exports = router;
