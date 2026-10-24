const Task = require('../models/Task');
const User = require('../models/User');
const { notifyTaskAssignment, notifyTaskShared, notifyStatusChanged } = require('../services/notificationService');

/**
 * Helper kiểm tra quyền của người dùng đối với task (RBAC)
 * Trả về: { isCreator, isAdmin, isEditor, isViewer, canEdit, canDelete }
 */
const checkUserPermission = (task, userIdStr) => {
  const isCreator = task.createdBy?._id?.toString() === userIdStr || task.createdBy?.toString() === userIdStr;

  const sharedMember = task.sharedWith?.find(
    (m) => (m.userId?._id?.toString() || m.userId?.toString()) === userIdStr
  );

  const sharedRole = sharedMember ? sharedMember.role : null;
  const isAdmin = isCreator || sharedRole === 'admin';
  const isEditor = isAdmin || sharedRole === 'editor';
  const isAssignee = task.assigneeIds?.some(
    (a) => (a._id?.toString() || a.toString()) === userIdStr
  );
  const isPrimary = (task.primaryAssigneeId?._id?.toString() || task.primaryAssigneeId?.toString()) === userIdStr;

  return {
    isCreator,
    isAdmin,
    isEditor,
    isViewer: sharedRole === 'viewer',
    isAssignee,
    isPrimary,
    canView: isCreator || isAdmin || isEditor || sharedRole === 'viewer' || isAssignee || isPrimary,
    canEdit: isAdmin || isEditor || isPrimary,
    canDelete: isCreator || isAdmin,
  };
};

/**
 * Lấy danh sách công việc của người dùng hiện tại (B2, B6 & C3, C5)
 * GET /api/tasks
 */
const getTasks = async (req, res) => {
  try {
    const userId = req.user._id;
    const { status, priority, q, sortBy, order, filterType } = req.query;

    // Filter cơ bản: user là creator, assignee, primaryAssignee HOẶC nằm trong sharedWith
    let baseOrConditions = [
      { createdBy: userId },
      { assigneeIds: userId },
      { primaryAssigneeId: userId },
      { 'sharedWith.userId': userId },
    ];

    // Hỗ trợ tab C5: created_by_me, assigned_to_me, shared_with_me
    if (filterType === 'created_by_me') {
      baseOrConditions = [{ createdBy: userId }];
    } else if (filterType === 'assigned_to_me') {
      baseOrConditions = [
        { primaryAssigneeId: userId },
        { assigneeIds: userId },
      ];
    } else if (filterType === 'shared_with_me') {
      baseOrConditions = [{ 'sharedWith.userId': userId }];
    }

    const andConditions = [{ $or: baseOrConditions }];

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
      .populate('sharedWith.userId', 'fullName email avatarUrl')
      .sort(sortOptions);

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
 * Lấy chi tiết một công việc theo ID (B3 & C3)
 * GET /api/tasks/:id
 */
const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;
    const userIdStr = req.user._id.toString();

    const task = await Task.findById(id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, userIdStr);
    if (!permission.canView) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền truy cập công việc này.',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: {
        task,
        userRole: permission.isCreator
          ? 'owner'
          : permission.isAdmin
          ? 'admin'
          : permission.isEditor
          ? 'editor'
          : permission.isViewer
          ? 'viewer'
          : 'member',
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
      sharedWith,
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
      sharedWith: Array.isArray(sharedWith) ? sharedWith : [],
      startDate: startDate ? new Date(startDate) : null,
      dueDate: dueDate ? new Date(dueDate) : null,
      priority: priority || 'medium',
      status: status || 'todo',
    });

    notifyTaskAssignment({ task, assignerId: req.user._id, recipientIds: initialAssignees });
    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

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
 * Cập nhật toàn bộ thông tin công việc (B4 & C3 RBAC)
 * PUT /api/tasks/:id
 */
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const userIdStr = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, userIdStr);
    if (!permission.canEdit) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền chỉnh sửa công việc này (yêu cầu quyền Editor hoặc Admin).',
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

    const oldStatus = task.status;
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

    if (status !== undefined && status !== oldStatus) {
      notifyStatusChanged({ task, updaterId: req.user._id, newStatus: status });
    }

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

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
 * Đổi trạng thái nhanh công việc (B4 & C3 RBAC)
 * PATCH /api/tasks/:id/status
 */
const updateTaskStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userIdStr = req.user._id.toString();

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

    const permission = checkUserPermission(task, userIdStr);
    if (!permission.canEdit) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền thay đổi trạng thái công việc này.',
      });
    }

    task.status = status;
    await task.save();

    notifyStatusChanged({ task, updaterId: req.user._id, newStatus: status });
    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

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
 * Xóa công việc (B5 & C3 RBAC)
 * DELETE /api/tasks/:id
 * Người tạo (createdBy) hoặc Admin được chia sẻ mới có quyền xóa
 */
const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;
    const userIdStr = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, userIdStr);
    if (!permission.canDelete) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo hoặc Quản trị viên mới có quyền xóa công việc này.',
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
    const userIdStr = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, userIdStr);
    if (!permission.isAdmin) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo hoặc Quản trị viên mới có quyền phân công người thực hiện.',
      });
    }

    if (primaryAssigneeId !== undefined) {
      task.primaryAssigneeId = primaryAssigneeId || null;
    }

    if (Array.isArray(assigneeIds)) {
      task.assigneeIds = assigneeIds;
    }

    await task.save();

    const recipientsToNotify = [];
    if (Array.isArray(assigneeIds)) recipientsToNotify.push(...assigneeIds);
    if (primaryAssigneeId && !recipientsToNotify.some(id => id.toString() === primaryAssigneeId.toString())) {
      recipientsToNotify.push(primaryAssigneeId);
    }
    if (recipientsToNotify.length > 0) {
      notifyTaskAssignment({ task, assignerId: req.user._id, recipientIds: recipientsToNotify });
    }

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

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

/**
 * Chia sẻ công việc và phân quyền RBAC (C3)
 * POST /api/tasks/:id/share
 */
const shareTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { userId, email, role } = req.body;
    const currentUserIdStr = req.user._id.toString();

    const validRoles = ['viewer', 'editor', 'admin'];
    const targetRole = validRoles.includes(role) ? role : 'viewer';

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, currentUserIdStr);
    if (!permission.isAdmin) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo hoặc Quản trị viên của công việc mới có quyền chia sẻ.',
      });
    }

    // Tìm người dùng được chia sẻ
    let targetUser = null;
    if (userId) {
      targetUser = await User.findById(userId);
    } else if (email) {
      targetUser = await User.findOne({ email: email.trim().toLowerCase() });
    }

    if (!targetUser) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy người dùng cần chia sẻ.',
      });
    }

    const targetUserIdStr = targetUser._id.toString();

    // Không thể tự chia sẻ cho chính người tạo
    if (task.createdBy.toString() === targetUserIdStr) {
      return res.status(400).json({
        status: 'error',
        message: 'Người dùng này là chủ sở hữu công việc, không cần chia sẻ.',
      });
    }

    // Cập nhật hoặc thêm vào danh sách sharedWith
    const existingIndex = task.sharedWith.findIndex(
      (m) => m.userId.toString() === targetUserIdStr
    );

    if (existingIndex > -1) {
      task.sharedWith[existingIndex].role = targetRole;
      task.sharedWith[existingIndex].sharedAt = new Date();
    } else {
      task.sharedWith.push({
        userId: targetUser._id,
        role: targetRole,
        sharedAt: new Date(),
      });
    }

    // Đảm bảo user có trong assigneeIds để công việc xuất hiện trong danh sách của họ
    if (!task.assigneeIds.some((a) => a.toString() === targetUserIdStr)) {
      task.assigneeIds.push(targetUser._id);
    }

    await task.save();

    notifyTaskShared({ task, sharerId: req.user._id, recipientId: targetUser._id, role: targetRole });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: `Đã chia sẻ công việc cho ${targetUser.fullName} với quyền ${targetRole.toUpperCase()}.`,
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.shareTask] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi chia sẻ công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Thay đổi vai trò thành viên trong công việc (C4)
 * PATCH /api/tasks/:id/members/:memberId
 */
const updateMemberRole = async (req, res) => {
  try {
    const { id, memberId } = req.params;
    const { role } = req.body;
    const currentUserIdStr = req.user._id.toString();

    const validRoles = ['viewer', 'editor', 'admin'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({
        status: 'error',
        message: 'Vai trò không hợp lệ (viewer, editor, admin).',
      });
    }

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, currentUserIdStr);
    if (!permission.isAdmin) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo hoặc Quản trị viên mới có quyền đổi vai trò thành viên.',
      });
    }

    if (task.createdBy.toString() === memberId) {
      return res.status(400).json({
        status: 'error',
        message: 'Không thể thay đổi vai trò của Chủ sở hữu công việc.',
      });
    }

    const memberIndex = task.sharedWith.findIndex(
      (m) => m.userId.toString() === memberId
    );

    if (memberIndex === -1) {
      return res.status(404).json({
        status: 'error',
        message: 'Thành viên này không nằm trong danh sách được chia sẻ của công việc.',
      });
    }

    task.sharedWith[memberIndex].role = role;
    await task.save();

    notifyTaskShared({ task, sharerId: req.user._id, recipientId: memberId, role });
    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật vai trò thành viên thành công.',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.updateMemberRole] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi thay đổi vai trò thành viên.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Thu hồi quyền truy cập / Xóa thành viên khỏi công việc (C4)
 * DELETE /api/tasks/:id/members/:memberId
 */
const revokeTaskMember = async (req, res) => {
  try {
    const { id, memberId } = req.params;
    const currentUserIdStr = req.user._id.toString();

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    const permission = checkUserPermission(task, currentUserIdStr);
    if (!permission.isAdmin) {
      return res.status(403).json({
        status: 'error',
        message: 'Chỉ người tạo hoặc Quản trị viên mới có quyền thu hồi quyền thành viên.',
      });
    }

    if (task.createdBy.toString() === memberId) {
      return res.status(400).json({
        status: 'error',
        message: 'Không thể thu hồi quyền của Chủ sở hữu công việc.',
      });
    }

    // Xóa khỏi sharedWith
    task.sharedWith = task.sharedWith.filter(
      (m) => m.userId.toString() !== memberId
    );

    // Xóa khỏi assigneeIds
    task.assigneeIds = task.assigneeIds.filter(
      (a) => a.toString() !== memberId
    );

    // Nếu là primaryAssigneeId thì reset về createdBy
    if (task.primaryAssigneeId?.toString() === memberId) {
      task.primaryAssigneeId = task.createdBy;
    }

    await task.save();
    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Thu hồi quyền truy cập của thành viên thành công.',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskController.revokeTaskMember] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi thu hồi quyền thành viên.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};


/**
 * Thống kê công việc và hiệu suất (E1)
 * GET /api/tasks/stats/summary
 */
const getTaskStats = async (req, res) => {
  try {
    const userId = req.user._id;
    const { timeRange = 'all', scope = 'all' } = req.query;

    let baseFilter = {};
    if (scope === 'created_by_me') {
      baseFilter.createdBy = userId;
    } else if (scope === 'assigned_to_me') {
      baseFilter.$or = [{ primaryAssigneeId: userId }, { assigneeIds: userId }];
    } else if (scope === 'shared_with_me') {
      baseFilter['sharedWith.userId'] = userId;
    } else {
      baseFilter.$or = [
        { createdBy: userId },
        { primaryAssigneeId: userId },
        { assigneeIds: userId },
        { 'sharedWith.userId': userId },
      ];
    }

    const now = new Date();
    if (timeRange === 'today') {
      const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      baseFilter.createdAt = { $gte: startOfDay };
    } else if (timeRange === 'week') {
      const startOfWeek = new Date(now);
      startOfWeek.setDate(now.getDate() - 7);
      baseFilter.createdAt = { $gte: startOfWeek };
    } else if (timeRange === 'month') {
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      baseFilter.createdAt = { $gte: startOfMonth };
    }

    const tasks = await Task.find(baseFilter)
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('createdBy', 'fullName email avatarUrl');

    const totalTasks = tasks.length;

    // Status counts
    let todoCount = 0;
    let inProgressCount = 0;
    let completedCount = 0;
    let cancelledCount = 0;

    // Priority counts
    let highPriorityCount = 0;
    let mediumPriorityCount = 0;
    let lowPriorityCount = 0;

    // Deadline & performance metrics
    let overdueCount = 0;
    let dueSoonCount = 0;
    let completedOnTimeCount = 0;

    const next24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    // Member workload map: userId -> { user, taskCount, completedCount }
    const memberWorkloadMap = new Map();

    for (const task of tasks) {
      // Status
      if (task.status === 'todo') todoCount++;
      else if (task.status === 'in_progress') inProgressCount++;
      else if (task.status === 'completed') completedCount++;
      else if (task.status === 'cancelled') cancelledCount++;

      // Priority
      if (task.priority === 'high') highPriorityCount++;
      else if (task.priority === 'medium') mediumPriorityCount++;
      else if (task.priority === 'low') lowPriorityCount++;

      // Deadlines
      if (task.dueDate) {
        const dueTime = new Date(task.dueDate).getTime();
        const isCompleted = task.status === 'completed';

        if (!isCompleted && task.status !== 'cancelled' && dueTime < now.getTime()) {
          overdueCount++;
        } else if (!isCompleted && task.status !== 'cancelled' && dueTime >= now.getTime() && dueTime <= next24h.getTime()) {
          dueSoonCount++;
        }

        if (isCompleted) {
          const updatedTime = new Date(task.updatedAt).getTime();
          if (updatedTime <= dueTime) {
            completedOnTimeCount++;
          }
        }
      } else if (task.status === 'completed') {
        completedOnTimeCount++;
      }

      // Member workload
      const assignees = [];
      if (task.primaryAssigneeId) assignees.push(task.primaryAssigneeId);
      if (Array.isArray(task.assigneeIds)) {
        task.assigneeIds.forEach((a) => {
          if (!assignees.some((existing) => existing._id?.toString() === a._id?.toString())) {
            assignees.push(a);
          }
        });
      }

      for (const assignee of assignees) {
        if (!assignee?._id) continue;
        const idStr = assignee._id.toString();
        if (!memberWorkloadMap.has(idStr)) {
          memberWorkloadMap.set(idStr, {
            user: {
              id: idStr,
              fullName: assignee.fullName,
              email: assignee.email,
              avatarUrl: assignee.avatarUrl,
            },
            taskCount: 0,
            completedCount: 0,
          });
        }
        const memberStat = memberWorkloadMap.get(idStr);
        memberStat.taskCount++;
        if (task.status === 'completed') {
          memberStat.completedCount++;
        }
      }
    }

    const completionRate = totalTasks > 0 ? Math.round((completedCount / totalTasks) * 100) : 0;
    const memberWorkloads = Array.from(memberWorkloadMap.values()).sort(
      (a, b) => b.taskCount - a.taskCount
    );

    return res.status(200).json({
      status: 'success',
      data: {
        timeRange,
        scope,
        summary: {
          totalTasks,
          completionRate,
          completedOnTimeRate: completedCount > 0 ? Math.round((completedOnTimeCount / completedCount) * 100) : 100,
        },
        byStatus: {
          todo: { count: todoCount, percentage: totalTasks > 0 ? Math.round((todoCount / totalTasks) * 100) : 0 },
          inProgress: { count: inProgressCount, percentage: totalTasks > 0 ? Math.round((inProgressCount / totalTasks) * 100) : 0 },
          completed: { count: completedCount, percentage: totalTasks > 0 ? Math.round((completedCount / totalTasks) * 100) : 0 },
          cancelled: { count: cancelledCount, percentage: totalTasks > 0 ? Math.round((cancelledCount / totalTasks) * 100) : 0 },
        },
        byPriority: {
          high: { count: highPriorityCount, percentage: totalTasks > 0 ? Math.round((highPriorityCount / totalTasks) * 100) : 0 },
          medium: { count: mediumPriorityCount, percentage: totalTasks > 0 ? Math.round((mediumPriorityCount / totalTasks) * 100) : 0 },
          low: { count: lowPriorityCount, percentage: totalTasks > 0 ? Math.round((lowPriorityCount / totalTasks) * 100) : 0 },
        },
        deadlines: {
          overdue: overdueCount,
          dueSoon: dueSoonCount,
          completedOnTime: completedOnTimeCount,
        },
        memberWorkloads,
      },
    });
  } catch (error) {
    console.error('[TaskController.getTaskStats] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy dữ liệu thống kê công việc.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

module.exports = {
  getTasks,
  getTaskById,
  getTaskStats,
  createTask,
  updateTask,
  updateTaskStatus,
  deleteTask,
  assignTask,
  shareTask,
  updateMemberRole,
  revokeTaskMember,
};
