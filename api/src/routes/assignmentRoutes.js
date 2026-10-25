const express = require('express');
const router = express.Router({ mergeParams: true });
const assignmentController = require('../controllers/assignmentController');
const { protect } = require('../middleware/authMiddleware');
const {
  requireTaskView,
  requireTaskAdminOrCreator,
} = require('../middleware/permissionMiddleware');

// Tất cả route phân công đều yêu cầu đăng nhập
router.use(protect);

// GET /api/tasks/:id/assignees
router.get('/', requireTaskView, assignmentController.getAssignees);

// POST /api/tasks/:id/assignees
router.post('/', requireTaskAdminOrCreator, assignmentController.addAssignee);

// PATCH /api/tasks/:id/assignees/:userId
router.patch('/:userId', requireTaskAdminOrCreator, assignmentController.updateAssignee);

// DELETE /api/tasks/:id/assignees/:userId
router.delete('/:userId', requireTaskAdminOrCreator, assignmentController.removeAssignee);

module.exports = router;
