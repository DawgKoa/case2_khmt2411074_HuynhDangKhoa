const validateRegister = (req, res, next) => {
  const { fullName, email, password } = req.body;

  if (!fullName || typeof fullName !== 'string' || fullName.trim().length === 0) {
    return res.status(400).json({
      status: 'error',
      message: 'Họ và tên là bắt buộc',
    });
  }

  if (!email || typeof email !== 'string' || email.trim().length === 0) {
    return res.status(400).json({
      status: 'error',
      message: 'Email là bắt buộc',
    });
  }

  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!emailRegex.test(email.trim())) {
    return res.status(400).json({
      status: 'error',
      message: 'Định dạng email không hợp lệ',
    });
  }

  if (!password || typeof password !== 'string' || password.length < 6) {
    return res.status(400).json({
      status: 'error',
      message: 'Mật khẩu phải chứa ít nhất 6 ký tự',
    });
  }

  next();
};

const validateLogin = (req, res, next) => {
  const { email, password } = req.body;

  if (!email || typeof email !== 'string' || email.trim().length === 0) {
    return res.status(400).json({
      status: 'error',
      message: 'Vui lòng nhập email đăng nhập',
    });
  }

  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!emailRegex.test(email.trim())) {
    return res.status(400).json({
      status: 'error',
      message: 'Định dạng email không hợp lệ',
    });
  }

  if (!password || typeof password !== 'string' || password.length === 0) {
    return res.status(400).json({
      status: 'error',
      message: 'Vui lòng nhập mật khẩu',
    });
  }

  next();
};

const validateChangePassword = (req, res, next) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || typeof currentPassword !== 'string' || currentPassword.length === 0) {
    return res.status(400).json({
      status: 'error',
      message: 'Vui lòng nhập mật khẩu hiện tại',
    });
  }

  if (!newPassword || typeof newPassword !== 'string' || newPassword.length < 6) {
    return res.status(400).json({
      status: 'error',
      message: 'Mật khẩu mới phải chứa ít nhất 6 ký tự',
    });
  }

  next();
};

module.exports = {
  validateRegister,
  validateLogin,
  validateChangePassword,
};
