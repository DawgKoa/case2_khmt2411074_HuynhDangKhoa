const Task = require('../models/Task');
const User = require('../models/User');
const { recordActivity } = require('../services/taskService');
const { notifyTaskAssignment } = require('../services/notificationService');

/**
 * Lấy danh sách người được phân công của công việc
 * GET /api/tasks/:id/assignees
 */
const getAssignees = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;

    const task = await Task.findById(taskId)
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('createdBy', 'fullName email avatarUrl');

    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: {
        primaryAssignee: task.primaryAssigneeId,
        assignees: task.assigneeIds,
      },
    });
  } catch (error) {
    console.error('[AssignmentController.getAssignees] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy danh sách phân công.',
    });
  }
};

/**
 * Thêm người thực hiện vào công việc
 * POST /api/tasks/:id/assignees
 */
const addAssignee = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    const { userId, isPrimary } = req.body;

    if (!userId) {
      return res.status(400).json({
        status: 'error',
        message: 'Thiếu thông tin người dùng cần phân công (userId).',
      });
    }

    const [task, targetUser] = await Promise.all([
      Task.findById(taskId),
      User.findById(userId),
    ]);

    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    if (!targetUser) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy người dùng cần phân công.',
      });
    }

    const userIdStr = targetUser._id.toString();
    const alreadyAssigned = task.assigneeIds.some(
      (a) => a.toString() === userIdStr
    );

    if (!alreadyAssigned) {
      task.assigneeIds.push(targetUser._id);
    }

    if (isPrimary) {
      task.primaryAssigneeId = targetUser._id;
    }

    await task.save();

    // Ghi nhật ký hoạt động
    await recordActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'assignee_added',
      details: {
        targetUserId: targetUser._id,
        targetUserName: targetUser.fullName,
        isPrimary: !!isPrimary,
      },
    });

    // Gửi thông báo
    notifyTaskAssignment({
      task,
      assignerId: req.user._id,
      recipientIds: [targetUser._id],
    });

    const populatedTask = await Task.findById(task._id)
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: `Đã phân công ${targetUser.fullName} vào công việc.`,
      data: {
        primaryAssignee: populatedTask.primaryAssigneeId,
        assignees: populatedTask.assigneeIds,
      },
    });
  } catch (error) {
    console.error('[AssignmentController.addAssignee] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi thêm người thực hiện.',
    });
  }
};

/**
 * Cập nhật vai trò phân công (đặt làm người thực hiện chính)
 * PATCH /api/tasks/:id/assignees/:userId
 */
const updateAssignee = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    const { userId } = req.params;
    const { isPrimary } = req.body;

    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const targetUser = await User.findById(userId);
    if (!targetUser) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy người dùng được chọn.',
      });
    }

    const userIdStr = targetUser._id.toString();
    if (!task.assigneeIds.some((a) => a.toString() === userIdStr)) {
      task.assigneeIds.push(targetUser._id);
    }

    if (isPrimary) {
      task.primaryAssigneeId = targetUser._id;
    } else if (task.primaryAssigneeId?.toString() === userIdStr) {
      task.primaryAssigneeId = task.createdBy;
    }

    await task.save();

    await recordActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'assignee_updated',
      details: {
        targetUserId: targetUser._id,
        targetUserName: targetUser.fullName,
        isPrimary: !!isPrimary,
      },
    });

    const populatedTask = await Task.findById(task._id)
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật phân công thành công.',
      data: {
        primaryAssignee: populatedTask.primaryAssigneeId,
        assignees: populatedTask.assigneeIds,
      },
    });
  } catch (error) {
    console.error('[AssignmentController.updateAssignee] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi cập nhật phân công.',
    });
  }
};

/**
 * Xóa người thực hiện khỏi công việc
 * DELETE /api/tasks/:id/assignees/:userId
 */
const removeAssignee = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    const { userId } = req.params;

    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const userIdStr = userId.toString();
    task.assigneeIds = task.assigneeIds.filter(
      (a) => a.toString() !== userIdStr
    );

    if (task.primaryAssigneeId?.toString() === userIdStr) {
      task.primaryAssigneeId = task.createdBy;
    }

    await task.save();

    await recordActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'assignee_removed',
      details: {
        removedUserId: userIdStr,
      },
    });

    const populatedTask = await Task.findById(task._id)
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Đã xóa người thực hiện khỏi công việc.',
      data: {
        primaryAssignee: populatedTask.primaryAssigneeId,
        assignees: populatedTask.assigneeIds,
      },
    });
  } catch (error) {
    console.error('[AssignmentController.removeAssignee] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xóa người thực hiện.',
    });
  }
};

module.exports = {
  getAssignees,
  addAssignee,
  updateAssignee,
  removeAssignee,
};
