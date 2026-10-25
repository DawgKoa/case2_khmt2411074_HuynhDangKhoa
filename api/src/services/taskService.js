const TaskActivity = require('../models/TaskActivity');
const TaskShare = require('../models/TaskShare');
const Task = require('../models/Task');

/**
 * Ghi lại nhật ký hoạt động của Task vào collection TaskActivity
 */
const recordActivity = async ({ taskId, userId, action, details = {} }) => {
  try {
    const activity = await TaskActivity.create({
      taskId,
      userId,
      action,
      details,
    });
    return activity;
  } catch (error) {
    console.error('[TaskService.recordActivity] Error:', error);
    return null;
  }
};

/**
 * Lấy lịch sử hoạt động của một công việc
 */
const getTaskActivities = async (taskId) => {
  return TaskActivity.find({ taskId })
    .populate('userId', 'fullName email avatarUrl')
    .sort({ createdAt: -1 });
};

/**
 * Đồng bộ hoặc cập nhật bản ghi trong collection TaskShare
 */
const syncTaskShare = async ({ taskId, userId, permission, sharedBy }) => {
  try {
    const share = await TaskShare.findOneAndUpdate(
      { taskId, userId },
      { permission, sharedBy },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );
    return share;
  } catch (error) {
    console.error('[TaskService.syncTaskShare] Error:', error);
    return null;
  }
};

/**
 * Xóa quyền chia sẻ trong collection TaskShare
 */
const removeTaskShare = async ({ taskId, userId }) => {
  try {
    await TaskShare.findOneAndDelete({ taskId, userId });
    return true;
  } catch (error) {
    console.error('[TaskService.removeTaskShare] Error:', error);
    return false;
  }
};

/**
 * Helper chuẩn hóa kiểm tra quyền hạn của người dùng (RBAC)
 * Quy định:
 * - 'viewer': chỉ được xem, KHÔNG được sửa, KHÔNG được xóa, KHÔNG được phân quyền
 * - 'editor': được sửa task/status, KHÔNG được xóa task, KHÔNG được quản lý chia sẻ
 * - 'admin' hoặc 'creator': toàn quyền sửa, xóa, chia sẻ, phân công
 */
const getTaskPermission = async (taskOrId, userId) => {
  let task = taskOrId;
  if (typeof taskOrId === 'string' || taskOrId._bsontype === 'ObjectID') {
    task = await Task.findById(taskOrId);
  }

  if (!task) {
    return {
      exists: false,
      isCreator: false,
      isAdmin: false,
      isEditor: false,
      isEditorOnly: false,
      isViewer: false,
      canView: false,
      canEdit: false,
      canDelete: false,
      canManageShare: false,
    };
  }

  const userIdStr = userId?.toString();
  const creatorIdStr = task.createdBy?._id?.toString() || task.createdBy?.toString();
  const isCreator = creatorIdStr === userIdStr;

  // Kiểm tra trong TaskShare collection trước
  let sharedRole = null;
  const dbShare = await TaskShare.findOne({ taskId: task._id, userId });
  if (dbShare) {
    sharedRole = dbShare.permission;
  } else if (Array.isArray(task.sharedWith)) {
    const member = task.sharedWith.find(
      (m) => (m.userId?._id?.toString() || m.userId?.toString()) === userIdStr
    );
    if (member) sharedRole = member.role;
  }

  const isPrimary =
    (task.primaryAssigneeId?._id?.toString() ||
      task.primaryAssigneeId?.toString()) === userIdStr;
  const isAssignee =
    Array.isArray(task.assigneeIds) &&
    task.assigneeIds.some(
      (a) => (a._id?.toString() || a.toString()) === userIdStr
    );

  const isAdmin = isCreator || sharedRole === 'admin';
  const isEditor = isAdmin || sharedRole === 'editor';
  const isEditorOnly = !isAdmin && sharedRole === 'editor';
  const isViewer = !isAdmin && !isEditorOnly && sharedRole === 'viewer';

  return {
    exists: true,
    task,
    isCreator,
    isAdmin,
    isEditor,
    isEditorOnly,
    isViewer,
    isAssignee,
    isPrimary,
    canView: isCreator || isAdmin || isEditor || isViewer || isAssignee || isPrimary,
    canEdit: isAdmin || isEditor || isPrimary,
    canDelete: isCreator || isAdmin,
    canManageShare: isCreator || isAdmin,
  };
};

module.exports = {
  recordActivity,
  getTaskActivities,
  syncTaskShare,
  removeTaskShare,
  getTaskPermission,
};
