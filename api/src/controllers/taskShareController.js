const Task = require('../models/Task');
const User = require('../models/User');
const TaskShare = require('../models/TaskShare');
const { recordActivity, syncTaskShare, removeTaskShare } = require('../services/taskService');
const { notifyTaskShared } = require('../services/notificationService');

/**
 * Lấy danh sách chia sẻ quyền của công việc
 * GET /api/tasks/:id/shares
 */
const getShares = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;

    const task = await Task.findById(taskId)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    let shares = await TaskShare.find({ taskId })
      .populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email avatarUrl')
      .sort({ createdAt: -1 });

    // Tự động đồng bộ từ task.sharedWith nếu TaskShare chưa có dữ liệu
    if (shares.length === 0 && Array.isArray(task.sharedWith) && task.sharedWith.length > 0) {
      for (const item of task.sharedWith) {
        if (item.userId) {
          const targetUid = item.userId._id || item.userId;
          await syncTaskShare({
            taskId: task._id,
            userId: targetUid,
            permission: item.role || 'viewer',
            sharedBy: task.createdBy._id || task.createdBy,
          });
        }
      }

      shares = await TaskShare.find({ taskId })
        .populate('userId', 'fullName email avatarUrl')
        .populate('sharedBy', 'fullName email avatarUrl')
        .sort({ createdAt: -1 });
    }

    return res.status(200).json({
      status: 'success',
      results: shares.length,
      data: {
        shares,
        sharedWith: task.sharedWith,
      },
    });
  } catch (error) {
    console.error('[TaskShareController.getShares] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy danh sách chia sẻ quyền.',
    });
  }
};

/**
 * Chia sẻ công việc cho thành viên (lưu vào cả TaskShare và Task.sharedWith)
 * POST /api/tasks/:id/shares
 */
const createShare = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    const { userId, email, permission, role } = req.body;

    const targetPermission = permission || role || 'viewer';
    if (!['viewer', 'editor', 'admin'].includes(targetPermission)) {
      return res.status(400).json({
        status: 'error',
        message: 'Quyền truy cập không hợp lệ (viewer, editor, admin).',
      });
    }

    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

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
    if (task.createdBy.toString() === targetUserIdStr) {
      return res.status(400).json({
        status: 'error',
        message: 'Người dùng này là chủ sở hữu công việc, không thể chia sẻ lại.',
      });
    }

    // 1. Lưu/cập nhật vào collection TaskShare
    const shareDoc = await syncTaskShare({
      taskId: task._id,
      userId: targetUser._id,
      permission: targetPermission,
      sharedBy: req.user._id,
    });

    // 2. Đồng bộ vào task.sharedWith để tương thích hoàn toàn với Flutter
    const existingIndex = task.sharedWith.findIndex(
      (m) => (m.userId?._id?.toString() || m.userId?.toString()) === targetUserIdStr
    );

    if (existingIndex > -1) {
      task.sharedWith[existingIndex].role = targetPermission;
      task.sharedWith[existingIndex].sharedAt = new Date();
    } else {
      task.sharedWith.push({
        userId: targetUser._id,
        role: targetPermission,
        sharedAt: new Date(),
      });
    }

    if (!task.assigneeIds.some((a) => (a._id?.toString() || a.toString()) === targetUserIdStr)) {
      task.assigneeIds.push(targetUser._id);
    }

    await task.save();

    // 3. Ghi log hoạt động vào TaskActivity
    await recordActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'task_shared',
      details: {
        recipientId: targetUser._id,
        recipientName: targetUser.fullName,
        permission: targetPermission,
      },
    });

    // 4. Gửi thông báo
    notifyTaskShared({
      task,
      sharerId: req.user._id,
      recipientId: targetUser._id,
      role: targetPermission,
    });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    return res.status(201).json({
      status: 'success',
      message: `Đã chia sẻ quyền ${targetPermission.toUpperCase()} cho ${targetUser.fullName}.`,
      data: {
        share: shareDoc,
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskShareController.createShare] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi chia sẻ công việc.',
    });
  }
};

/**
 * Cập nhật vai trò / quyền chia sẻ
 * PATCH /api/tasks/:id/shares/:shareId
 * Hỗ trợ shareId là TaskShare._id HOẶC userId
 */
const updateShare = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    const { shareId } = req.params;
    const { permission, role } = req.body;

    const targetPermission = permission || role;
    if (!['viewer', 'editor', 'admin'].includes(targetPermission)) {
      return res.status(400).json({
        status: 'error',
        message: 'Quyền truy cập không hợp lệ (viewer, editor, admin).',
      });
    }

    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    // Tìm TaskShare bằng shareId hoặc bằng userId
    let shareDoc = await TaskShare.findOne({
      taskId,
      $or: [{ _id: shareId.match(/^[0-9a-fA-F]{24}$/) ? shareId : null }, { userId: shareId }],
    });

    let targetUserIdStr = shareDoc ? shareDoc.userId.toString() : shareId;

    if (shareDoc) {
      shareDoc.permission = targetPermission;
      shareDoc.sharedBy = req.user._id;
      await shareDoc.save();
    } else {
      shareDoc = await syncTaskShare({
        taskId,
        userId: targetUserIdStr,
        permission: targetPermission,
        sharedBy: req.user._id,
      });
    }

    // Cập nhật trong task.sharedWith
    const memberIndex = task.sharedWith.findIndex(
      (m) => (m.userId?._id?.toString() || m.userId?.toString()) === targetUserIdStr
    );

    if (memberIndex > -1) {
      task.sharedWith[memberIndex].role = targetPermission;
      await task.save();
    }

    // Ghi nhật ký
    await recordActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'share_permission_updated',
      details: {
        targetUserId: targetUserIdStr,
        permission: targetPermission,
      },
    });

    notifyTaskShared({
      task,
      sharerId: req.user._id,
      recipientId: targetUserIdStr,
      role: targetPermission,
    });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Cập nhật quyền chia sẻ thành công.',
      data: {
        share: shareDoc,
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskShareController.updateShare] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi cập nhật quyền chia sẻ.',
    });
  }
};

/**
 * Xóa / thu hồi quyền chia sẻ
 * DELETE /api/tasks/:id/shares/:shareId
 * Hỗ trợ shareId là TaskShare._id HOẶC userId
 */
const deleteShare = async (req, res) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    const { shareId } = req.params;

    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    let shareDoc = await TaskShare.findOne({
      taskId,
      $or: [{ _id: shareId.match(/^[0-9a-fA-F]{24}$/) ? shareId : null }, { userId: shareId }],
    });

    const targetUserIdStr = shareDoc ? shareDoc.userId.toString() : shareId;

    if (task.createdBy.toString() === targetUserIdStr) {
      return res.status(400).json({
        status: 'error',
        message: 'Không thể thu hồi quyền của chủ sở hữu công việc.',
      });
    }

    // Xóa khỏi TaskShare
    await TaskShare.deleteMany({
      taskId,
      $or: [{ _id: shareId.match(/^[0-9a-fA-F]{24}$/) ? shareId : null }, { userId: targetUserIdStr }],
    });

    // Xóa khỏi task.sharedWith
    task.sharedWith = task.sharedWith.filter(
      (m) => (m.userId?._id?.toString() || m.userId?.toString()) !== targetUserIdStr
    );

    // Xóa khỏi task.assigneeIds
    task.assigneeIds = task.assigneeIds.filter(
      (a) => (a._id?.toString() || a.toString()) !== targetUserIdStr
    );

    // Nếu là primaryAssigneeId thì reset
    if (task.primaryAssigneeId?.toString() === targetUserIdStr) {
      task.primaryAssigneeId = task.createdBy;
    }

    await task.save();

    await recordActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'share_revoked',
      details: {
        revokedUserId: targetUserIdStr,
      },
    });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('sharedWith.userId', 'fullName email avatarUrl');

    return res.status(200).json({
      status: 'success',
      message: 'Thu hồi quyền truy cập thành công.',
      data: {
        task: populatedTask,
      },
    });
  } catch (error) {
    console.error('[TaskShareController.deleteShare] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi thu hồi quyền chia sẻ.',
    });
  }
};

module.exports = {
  getShares,
  createShare,
  updateShare,
  deleteShare,
};
