/**
 * Centralized Error Handling Middlewares
 */

const notFound = (req, res, next) => {
  const error = new Error(`Không tìm thấy đường dẫn - ${req.originalUrl}`);
  res.status(404);
  next(error);
};

const errorHandler = (err, req, res, next) => {
  let statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  let message = err.message || 'Lỗi máy chủ nội bộ.';

  // Mongoose CastError (Sai định dạng ObjectId)
  if (err.name === 'CastError' && err.kind === 'ObjectId') {
    statusCode = 400;
    message = 'Định dạng mã ID không hợp lệ.';
  }

  // Mongoose Duplicate Key (Trùng lặp index unique)
  if (err.code === 11000) {
    statusCode = 400;
    const field = Object.keys(err.keyValue || {})[0] || 'dữ liệu';
    message = `Bản ghi với ${field} này đã tồn tại trong hệ thống.`;
  }

  // Mongoose Validation Error
  if (err.name === 'ValidationError') {
    statusCode = 400;
    const errors = Object.values(err.errors).map((e) => e.message);
    message = errors.join(', ');
  }

  // JWT error
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Mã xác thực không hợp lệ.';
  }
  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.';
  }

  console.error(`[ErrorHandler] [${req.method}] ${req.originalUrl} - Status: ${statusCode}:`, err);

  return res.status(statusCode).json({
    status: 'error',
    message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

module.exports = {
  notFound,
  errorHandler,
};
