const { getTaskPermission } = require('../services/taskService');

/**
 * Middleware kiểm tra quyền truy cập xem chi tiết công việc
 */
const requireTaskView = async (req, res, next) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    if (!taskId) {
      return res.status(400).json({
        status: 'error',
        message: 'Thiếu định danh công việc (taskId).',
      });
    }

    const permission = await getTaskPermission(taskId, req.user._id);
    if (!permission.exists) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    if (!permission.canView) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền xem thông tin công việc này.',
      });
    }

    req.task = permission.task;
    req.taskPermission = permission;
    next();
  } catch (error) {
    console.error('[permissionMiddleware.requireTaskView] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi kiểm tra quyền truy cập công việc.',
    });
  }
};

/**
 * Middleware kiểm tra quyền chỉnh sửa công việc:
 * - Chặn 'viewer' không được sửa (403)
 * - Cho phép 'creator', 'admin', 'editor', hoặc người thực hiện chính
 */
const requireTaskEdit = async (req, res, next) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    if (!taskId) {
      return res.status(400).json({
        status: 'error',
        message: 'Thiếu định danh công việc (taskId).',
      });
    }

    const permission = await getTaskPermission(taskId, req.user._id);
    if (!permission.exists) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    if (permission.isCreator || permission.isAdmin) {
      req.task = permission.task;
      req.taskPermission = permission;
      return next();
    }

    if (permission.isViewer) {
      return res.status(403).json({
        status: 'error',
        message: 'Thành viên chỉ có quyền xem (viewer), không được phép chỉnh sửa công việc.',
      });
    }

    if (!permission.canEdit) {
      return res.status(403).json({
        status: 'error',
        message: 'Bạn không có quyền chỉnh sửa công việc này (yêu cầu quyền Editor hoặc Quản trị viên).',
      });
    }

    req.task = permission.task;
    req.taskPermission = permission;
    next();
  } catch (error) {
    console.error('[permissionMiddleware.requireTaskEdit] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xác thực quyền chỉnh sửa công việc.',
    });
  }
};

/**
 * Middleware kiểm tra quyền quản lý công việc:
 * - Chỉ 'creator' hoặc 'admin' mới được phép xóa task hoặc quản lý quyền chia sẻ / phân công
 * - 'editor' và 'viewer' bị chặn (403)
 */
const requireTaskAdminOrCreator = async (req, res, next) => {
  try {
    const taskId = req.params.id || req.params.taskId;
    if (!taskId) {
      return res.status(400).json({
        status: 'error',
        message: 'Thiếu định danh công việc (taskId).',
      });
    }

    const permission = await getTaskPermission(taskId, req.user._id);
    if (!permission.exists) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy công việc yêu cầu.',
      });
    }

    // Nếu là creator hoặc admin thì ĐƯỢC PHÉP
    if (permission.isCreator || permission.isAdmin) {
      req.task = permission.task;
      req.taskPermission = permission;
      return next();
    }

    // Nếu chỉ là editor thì bị chặn với thông báo rõ ràng
    if (permission.isEditorOnly || permission.isEditor) {
      return res.status(403).json({
        status: 'error',
        message: 'Thành viên có quyền Editor chỉ được sửa nội dung công việc, không có quyền xóa hoặc quản lý chia sẻ/phân công.',
      });
    }

    return res.status(403).json({
      status: 'error',
      message: 'Chỉ người tạo hoặc Quản trị viên của công việc mới có quyền thực hiện thao tác này.',
    });
  } catch (error) {
    console.error('[permissionMiddleware.requireTaskAdminOrCreator] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi xác thực quyền quản trị công việc.',
    });
  }
};

module.exports = {
  requireTaskView,
  requireTaskEdit,
  requireTaskAdminOrCreator,
};
