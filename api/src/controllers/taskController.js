const Task = require('../models/Task');

/**
 * Lấy danh sách công việc của người dùng hiện tại (B2 & B6)
 * GET /api/tasks
 * Hỗ trợ tìm kiếm (q), lọc theo status, priority và sắp xếp (sortBy, order)
 */
const getTasks = async (req, res) => {
  try {
    const userId = req.user._id;
    const { status, priority, q, sortBy, order } = req.query;

    // Filter cơ bản: user là người tạo HOẶC nằm trong danh sách phân công
    const andConditions = [
      {
        $or: [
          { createdBy: userId },
          { assigneeIds: userId },
          { primaryAssigneeId: userId },
        ],
      },
    ];

    if (status && ['todo', 'in_progress', 'completed', 'cancelled'].includes(status)) {
      andConditions.push({ status });
    }

    if (priority && ['low', 'medium', 'high'].includes(priority)) {
      andConditions.push({ priority });
    }

    if (q && q.trim() !== '') {
      andConditions.push({
        $or: [
          { title: { $regex: q.trim(), $options: 'i' } },
          { description: { $regex: q.trim(), $options: 'i' } },
        ],
      });
    }

    const filter = { $and: andConditions };

    // Xử lý sắp xếp
    let sortOptions = { createdAt: -1 };
    if (sortBy === 'dueDate') {
      sortOptions = { dueDate: order === 'desc' ? -1 : 1, createdAt: -1 };
    } else if (sortBy === 'createdAt') {
      sortOptions = { createdAt: order === 'asc' ? 1 : -1 };
    } else if (sortBy === 'title') {
      sortOptions = { title: order === 'desc' ? -1 : 1 };
    }

    let tasks = await Task.find(filter)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .sort(sortOptions);

    // Nếu sắp xếp theo priority: high -> medium -> low hoặc ngược lại
    if (sortBy === 'priority') {
      const priorityWeights = { high: 3, medium: 2, low: 1 };
      const multiplier = order === 'asc' ? 1 : -1;
      tasks = tasks.sort((a, b) => {
        const weightA = priorityWeights[a.priority] || 0;
        const weightB = priorityWeights[b.priority] || 0;
        return (weightA - weightB) * multiplier;
      });
    }

    return res.status(200).json({
      status: 'success',
      results: tasks.length,
      data: {
        tasks,
      },
    });
  } catch (error) {
    console.error('[TaskController.getTasks] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy danh sách công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Lấy chi tiết một công việc theo ID (B3)
 * GET /api/tasks/:id
 */
const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id.toString();

    const task = await Task.findById(id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    // Kiểm tra quyền xem: Phải là người tạo hoặc người được phân công
    const isCreator = task.createdBy?._id?.toString() === userId;
    const isPrimary = task.primaryAssigneeId?._id?.toString() === userId;
    const isAssignee = task.assigneeIds?.some(
      (a) => a._id?.toString() === userId
    );

    if (!isCreator && !isPrimary && !isAssignee) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền truy cập công việc này.',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: {
        task,
      },
    });
  } catch (error) {
    console.error('[TaskController.getTaskById] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy chi tiết công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

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

/**
 * Cập nhật toàn bộ thông tin công việc (B4)
 * PUT /api/tasks/:id
 */
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    // Quyền sửa: Người tạo HOẶC người được phân công
    const isCreator = task.createdBy.toString() === userId;
    const isPrimary = task.primaryAssigneeId?.toString() === userId;
    const isAssignee = task.assigneeIds?.some((a) => a.toString() === userId);

    if (!isCreator && !isPrimary && !isAssignee) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền chỉnh sửa công việc này.',
      });
    }

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

    if (title !== undefined) {
      if (typeof title !== 'string' || title.trim() === '') {
        return res.status(400).json({
          status: 'error',
          message: 'Tiêu đề công việc không được để trống.',
        });
      }
      task.title = title.trim();
    }

    if (description !== undefined) {
      task.description = description.trim();
    }

    if (startDate !== undefined) {
      task.startDate = startDate ? new Date(startDate) : null;
    }

    if (dueDate !== undefined) {
      task.dueDate = dueDate ? new Date(dueDate) : null;
    }

    if (priority !== undefined) {
      if (!['low', 'medium', 'high'].includes(priority)) {
        return res.status(400).json({
          status: 'error',
          message: 'Mức độ ưu tiên không hợp lệ (low, medium, high).',
        });
      }
      task.priority = priority;
    }

    if (status !== undefined) {
      if (!['todo', 'in_progress', 'completed', 'cancelled'].includes(status)) {
        return res.status(400).json({
          status: 'error',
          message: 'Trạng thái không hợp lệ (todo, in_progress, completed, cancelled).',
        });
      }
      task.status = status;
    }

    if (Array.isArray(assigneeIds)) {
      task.assigneeIds = assigneeIds;
    }

    if (primaryAssigneeId !== undefined) {
      task.primaryAssigneeId = primaryAssigneeId || null;
    }

    await task.save();

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật công việc thành công.',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.updateTask] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi cập nhật công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Đổi trạng thái nhanh công việc (B4)
 * PATCH /api/tasks/:id/status
 */
const updateTaskStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user._id.toString();

    if (!status || !['todo', 'in_progress', 'completed', 'cancelled'].includes(status)) {
      return res.status(400).json({
        status: 'error',
        message: 'Trạng thái công việc không hợp lệ (todo, in_progress, completed, cancelled).',
      });
    }

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    // Quyền: Người tạo hoặc người được phân công
    const isCreator = task.createdBy.toString() === userId;
    const isPrimary = task.primaryAssigneeId?.toString() === userId;
    const isAssignee = task.assigneeIds?.some((a) => a.toString() === userId);

    if (!isCreator && !isPrimary && !isAssignee) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền thay đổi trạng thái công việc này.',
      });
    }

    task.status = status;
    await task.save();

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật trạng thái thành công.',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.updateTaskStatus] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi cập nhật trạng thái công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Xóa công việc (B5)
 * DELETE /api/tasks/:id
 * Chỉ người tạo (createdBy) mới có quyền xóa
 */
const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    // Chỉ người tạo công việc mới có quyền xóa
    if (task.createdBy.toString() !== userId) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo công việc mới có quyền xóa công việc này.',
      });
    }

    await Task.findByIdAndDelete(id);

    return res.status(200).json({
      status: 'success',
      message: 'Xóa công việc thành công.',
    });
  } catch (error) {
    console.error('[TaskController.deleteTask] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xóa công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Phân công người thực hiện chính & danh sách người tham gia (C2)
 * PUT /api/tasks/:id/assign
 */
const assignTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { primaryAssigneeId, assigneeIds } = req.body;
    const userId = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const isCreator = task.createdBy.toString() === userId;
    if (!isCreator) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo công việc mới có quyền phân công người thực hiện.',
      });
    }

    if (primaryAssigneeId !== undefined) {
      task.primaryAssigneeId = primaryAssigneeId || null;
    }

    if (Array.isArray(assigneeIds)) {
      task.assigneeIds = assigneeIds;
    }

    await task.save();

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật phân công công việc thành công.',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.assignTask] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi phân công công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

module.exports = {
  getTasks,
  getTaskById,
  createTask,
  updateTask,
  updateTaskStatus,
  deleteTask,
  assignTask,
};
