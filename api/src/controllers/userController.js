const User = require('../models/User');

/**
 * Tìm kiếm người dùng theo email hoặc họ tên (C1)
 * GET /api/users/search?q=...
 */
const searchUsers = async (req, res) => {
  try {
    const { q } = req.query;
    const currentUserId = req.user._id;

    if (!q || q.trim() === '') {
      return res.status(200).json({
        status: 'success',
        results: 0,
        data: {
          users: [],
        },
      });
    }

    const searchQuery = q.trim();

    // Tìm kiếm regex không phân biệt hoa thường theo email hoặc fullName
    const users = await User.find({
      $and: [
        {
          $or: [
            { email: { $regex: searchQuery, $options: 'i' } },
            { fullName: { $regex: searchQuery, $options: 'i' } },
          ],
        },
      ],
    })
      .select('_id fullName email avatarUrl role')
      .limit(20);

    return res.status(200).json({
      status: 'success',
      results: users.length,
      data: {
        users,
      },
    });
  } catch (error) {
    console.error('[UserController.searchUsers] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi tìm kiếm người dùng.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Lấy danh sách người dùng trong hệ thống (phục vụ gợi ý danh sách thành viên)
 * GET /api/users
 */
const getUsers = async (req, res) => {
  try {
    const users = await User.find()
      .select('_id fullName email avatarUrl role')
      .limit(30)
      .sort({ fullName: 1 });

    return res.status(200).json({
      status: 'success',
      results: users.length,
      data: {
        users,
      },
    });
  } catch (error) {
    console.error('[UserController.getUsers] Error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Lỗi máy chủ khi lấy danh sách người dùng.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

module.exports = {
  searchUsers,
  getUsers,
};
