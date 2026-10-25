const Task = require('../models/Task');

/**
 * Helper tính toán toàn bộ thống kê công việc theo phạm vi và thời gian
 */
const calculateStats = async (userId, query) => {
  const { timeRange = 'all', scope = 'all' } = query;

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
  let todoCount = 0;
  let inProgressCount = 0;
  let completedCount = 0;
  let cancelledCount = 0;

  let highPriorityCount = 0;
  let mediumPriorityCount = 0;
  let lowPriorityCount = 0;

  let overdueCount = 0;
  let dueSoonCount = 0;
  let completedOnTimeCount = 0;

  const overdueTaskList = [];
  const dueSoonTaskList = [];

  const next24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  const memberWorkloadMap = new Map();

  for (const task of tasks) {
    if (task.status === 'todo') todoCount++;
    else if (task.status === 'in_progress') inProgressCount++;
    else if (task.status === 'completed') completedCount++;
    else if (task.status === 'cancelled') cancelledCount++;

    if (task.priority === 'high') highPriorityCount++;
    else if (task.priority === 'medium') mediumPriorityCount++;
    else if (task.priority === 'low') lowPriorityCount++;

    if (task.dueDate) {
      const dueTime = new Date(task.dueDate).getTime();
      const isCompleted = task.status === 'completed';

      if (!isCompleted && task.status !== 'cancelled' && dueTime < now.getTime()) {
        overdueCount++;
        overdueTaskList.push({
          id: task._id,
          title: task.title,
          dueDate: task.dueDate,
          priority: task.priority,
          status: task.status,
          primaryAssignee: task.primaryAssigneeId,
        });
      } else if (!isCompleted && task.status !== 'cancelled' && dueTime >= now.getTime() && dueTime <= next24h.getTime()) {
        dueSoonCount++;
        dueSoonTaskList.push({
          id: task._id,
          title: task.title,
          dueDate: task.dueDate,
          priority: task.priority,
          status: task.status,
          primaryAssignee: task.primaryAssigneeId,
        });
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
          inProgressCount: 0,
          overdueCount: 0,
        });
      }
      const memberStat = memberWorkloadMap.get(idStr);
      memberStat.taskCount++;
      if (task.status === 'completed') {
        memberStat.completedCount++;
      } else if (task.status === 'in_progress') {
        memberStat.inProgressCount++;
      }
      if (task.dueDate && new Date(task.dueDate).getTime() < now.getTime() && task.status !== 'completed' && task.status !== 'cancelled') {
        memberStat.overdueCount++;
      }
    }
  }

  const completionRate = totalTasks > 0 ? Math.round((completedCount / totalTasks) * 100) : 0;
  const memberWorkloads = Array.from(memberWorkloadMap.values())
    .map((m) => ({
      ...m,
      completionRate: m.taskCount > 0 ? Math.round((m.completedCount / m.taskCount) * 100) : 0,
    }))
    .sort((a, b) => b.taskCount - a.taskCount);

  return {
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
    overdueTaskList,
    dueSoonTaskList,
    memberWorkloads,
  };
};

/**
 * Thống kê tổng quan công việc
 * GET /api/statistics/tasks
 */
const getTaskStats = async (req, res) => {
  try {
    const stats = await calculateStats(req.user._id, req.query);
    return res.status(200).json({
      status: 'success',
      data: stats,
    });
  } catch (error) {
    console.error('[StatisticsController.getTaskStats] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy thống kê công việc.',
    });
  }
};

/**
 * Thống kê phân công và khối lượng công việc của từng thành viên
 * GET /api/statistics/assignments
 */
const getAssignmentStats = async (req, res) => {
  try {
    const stats = await calculateStats(req.user._id, req.query);
    return res.status(200).json({
      status: 'success',
      data: {
        timeRange: stats.timeRange,
        scope: stats.scope,
        memberWorkloads: stats.memberWorkloads,
        totalAssignedMembers: stats.memberWorkloads.length,
      },
    });
  } catch (error) {
    console.error('[StatisticsController.getAssignmentStats] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy thống kê phân công.',
    });
  }
};

/**
 * Thống kê hạn chót và tiến độ hoàn thành
 * GET /api/statistics/deadlines
 */
const getDeadlineStats = async (req, res) => {
  try {
    const stats = await calculateStats(req.user._id, req.query);
    return res.status(200).json({
      status: 'success',
      data: {
        timeRange: stats.timeRange,
        deadlines: stats.deadlines,
        overdueTasks: stats.overdueTaskList,
        dueSoonTasks: stats.dueSoonTaskList,
      },
    });
  } catch (error) {
    console.error('[StatisticsController.getDeadlineStats] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy thống kê hạn chót.',
    });
  }
};

module.exports = {
  calculateStats,
  getTaskStats,
  getAssignmentStats,
  getDeadlineStats,
};
