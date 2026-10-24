const validateCreateTask = (req, res, next) => {
  const { title, priority, status, startDate, dueDate } = req.body;

  if (!title || typeof title !== 'string' || title.trim().length === 0) {
    return res.status(400).json({
      status: 'error',
      message: 'Tên công việc không được để trống',
    });
  }

  if (priority && !['low', 'medium', 'high'].includes(priority)) {
    return res.status(400).json({
      status: 'error',
      message: 'Mức độ ưu tiên không hợp lệ (low, medium, high)',
    });
  }

  if (status && !['todo', 'in_progress', 'completed'].includes(status)) {
    return res.status(400).json({
      status: 'error',
      message: 'Trạng thái không hợp lệ (todo, in_progress, completed)',
    });
  }

  if (startDate && isNaN(Date.parse(startDate))) {
    return res.status(400).json({
      status: 'error',
      message: 'Ngày bắt đầu không đúng định dạng ngày hợp lệ',
    });
  }

  if (dueDate && isNaN(Date.parse(dueDate))) {
    return res.status(400).json({
      status: 'error',
      message: 'Hạn hoàn thành không đúng định dạng ngày hợp lệ',
    });
  }

  if (startDate && dueDate && new Date(dueDate) < new Date(startDate)) {
    return res.status(400).json({
      status: 'error',
      message: 'Hạn hoàn thành không thể trước ngày bắt đầu',
    });
  }

  next();
};

module.exports = {
  validateCreateTask,
};
