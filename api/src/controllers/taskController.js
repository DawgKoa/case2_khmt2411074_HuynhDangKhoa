const Task = require('../models/Task');

/**
 * Tạo mới công việc (B1)
 * POST /api/tasks
 */
const createTask = async (req, res) => {
  try {
    const {
      title,
      description,
      startDate,
      dueDate,
      priority,
      status,
      assigneeIds,
      primaryAssigneeId,
    } = req.body;

    const initialAssignees =
      Array.isArray(assigneeIds) && assigneeIds.length > 0
        ? assigneeIds
        : [req.user._id];

    const initialPrimary = primaryAssigneeId || req.user._id;

    const task = await Task.create({
      title: title.trim(),
      description: description ? description.trim() : '',
      createdBy: req.user._id,
      assigneeIds: initialAssignees,
      primaryAssigneeId: initialPrimary,
      startDate: startDate ? new Date(startDate) : null,
      dueDate: dueDate ? new Date(dueDate) : null,
      priority: priority || 'medium',
      status: status || 'todo',
    });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.status(201).json({
      status: 'success',
      message: 'Tạo công việc thành công',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.createTask] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi tạo công việc mới.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

module.exports = {
  createTask,
};
