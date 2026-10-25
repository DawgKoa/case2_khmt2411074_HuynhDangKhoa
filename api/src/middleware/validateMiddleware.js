/**
 * Validation Middleware helper
 * Standardizes 400 validation error responses
 */

const validate = (validatorFn) => {
  return (req, res, next) => {
    try {
      const error = validatorFn(req.body, req.params, req.query);
      if (error) {
        return res.status(400).json({
          status: 'error',
          message: error,
        });
      }
      next();
    } catch (err) {
      return res.status(400).json({
        status: 'error',
        message: err.message || 'Dữ liệu yêu cầu không hợp lệ.',
      });
    }
  };
};

module.exports = {
  validate,
};
