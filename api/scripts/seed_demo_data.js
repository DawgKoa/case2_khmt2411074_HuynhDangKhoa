const mongoose = require('mongoose');
require('dotenv').config({ path: __dirname + '/../.env' });

const User = require('../src/models/User');
const Task = require('../src/models/Task');
const TaskActivity = require('../src/models/TaskActivity');
const Notification = require('../src/models/Notification');

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('[Seed] Connected to MongoDB');

  const khoa = await User.findOne({ email: 'dangkhoa15022006@gmail.com' });
  let duy = await User.findOne({ email: 'duy.khmt2411073@gmail.com' });

  if (!khoa) {
    console.error('User Khoa not found!');
    process.exit(1);
  }

  if (!duy) {
    duy = await User.create({
      fullName: 'Nguyễn Nhựt Duy',
      email: 'duy.khmt2411073@gmail.com',
      password: 'Password123!',
      role: 'user',
    });
    console.log('[Seed] Created user Duy');
  }

  const now = new Date();
  const dayMs = 24 * 60 * 60 * 1000;

  // 1. Task Completed (Đã xong)
  const task1 = await Task.create({
    title: 'Thiết kế giao diện Soft Neo-Brutalism',
    description: 'Điều chỉnh toàn bộ card, button, text, chip sang phong cách Soft Neo-Brutalism mềm mại và rõ nét.',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id],
    priority: 'high',
    status: 'completed',
    startDate: new Date(now.getTime() - 4 * dayMs),
    dueDate: new Date(now.getTime() - 1 * dayMs),
    sharedWith: [{ userId: duy._id, role: 'viewer', sharedAt: new Date(now.getTime() - 3 * dayMs) }],
  });

  await TaskActivity.create([
    {
      taskId: task1._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo công việc',
      createdAt: new Date(now.getTime() - 4 * dayMs),
    },
    {
      taskId: task1._id,
      userId: khoa._id,
      action: 'update_status',
      description: 'Chuyển trạng thái sang Đang làm',
      createdAt: new Date(now.getTime() - 2 * dayMs),
    },
    {
      taskId: task1._id,
      userId: khoa._id,
      action: 'update_status',
      description: 'Đã hoàn thành thiết kế giao diện theo yêu cầu',
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
  ]);

  // 2. Task In Progress (Đang làm, sắp tới hạn)
  const task2 = await Task.create({
    title: 'Hoàn thiện báo cáo đồ án Case Study 2',
    description: 'Tổng hợp sơ đồ kiến trúc, tài liệu API, hướng dẫn chạy ứng dụng và chuẩn bị slide thuyết trình.',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id, duy._id],
    priority: 'high',
    status: 'in_progress',
    startDate: new Date(now.getTime() - 1 * dayMs),
    dueDate: new Date(now.getTime() + 1 * dayMs),
    sharedWith: [{ userId: duy._id, role: 'editor', sharedAt: new Date(now.getTime() - 1 * dayMs) }],
  });

  await TaskActivity.create([
    {
      taskId: task2._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo công việc báo cáo',
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
    {
      taskId: task2._id,
      userId: khoa._id,
      action: 'assign',
      description: 'Phân công Nguyễn Nhựt Duy cùng phối hợp làm báo cáo',
      createdAt: new Date(now.getTime() - 12 * 3600 * 1000),
    },
  ]);

  // 3. Task In Progress do Duy giao cho Khoa (RBAC Admin)
  const task3 = await Task.create({
    title: 'Kiểm thử API phân quyền RBAC và gửi mail SMTP',
    description: 'Thực hiện kiểm thử phân quyền các vai trò Viewer, Editor, Admin và kiểm tra nhận mail tự động.',
    createdBy: duy._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id],
    priority: 'medium',
    status: 'in_progress',
    startDate: now,
    dueDate: new Date(now.getTime() + 3 * dayMs),
    sharedWith: [{ userId: khoa._id, role: 'admin', sharedAt: now }],
  });

  await TaskActivity.create([
    {
      taskId: task3._id,
      userId: duy._id,
      action: 'create',
      description: 'Khởi tạo công việc kiểm thử',
      createdAt: now,
    },
    {
      taskId: task3._id,
      userId: duy._id,
      action: 'share',
      description: 'Cấp quyền Quản trị viên (Admin) cho Huỳnh Đăng Khoa',
      createdAt: now,
    },
  ]);

  // 4. Task Todo (Chờ xử lý, Low priority)
  const task4 = await Task.create({
    title: 'Nghiên cứu tài liệu Docker & CI/CD pipeline',
    description: 'Đọc tài liệu về Docker compose và GitHub Actions để tự động hóa build ứng dụng Flutter và Node.js.',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id],
    priority: 'low',
    status: 'todo',
    startDate: new Date(now.getTime() + 1 * dayMs),
    dueDate: new Date(now.getTime() + 7 * dayMs),
    sharedWith: [],
  });

  await TaskActivity.create([
    {
      taskId: task4._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo công việc nghiên cứu',
      createdAt: now,
    },
  ]);

  // 5. Notifications cho Huỳnh Đăng Khoa
  await Notification.deleteMany({ userId: khoa._id });
  await Notification.create([
    {
      userId: khoa._id,
      title: 'Công việc mới được giao',
      message: 'Nguyễn Nhựt Duy đã giao cho bạn công việc "Kiểm thử API phân quyền RBAC và gửi mail SMTP".',
      type: 'task_assigned',
      taskId: task3._id,
      isRead: false,
      createdAt: new Date(now.getTime() - 10 * 60 * 1000),
    },
    {
      userId: khoa._id,
      title: 'Nhắc nhở hạn hoàn thành',
      message: 'Công việc "Hoàn thiện báo cáo đồ án Case Study 2" còn 24 giờ nữa là đến hạn.',
      type: 'deadline_reminder',
      taskId: task2._id,
      isRead: false,
      createdAt: new Date(now.getTime() - 30 * 60 * 1000),
    },
    {
      userId: khoa._id,
      title: 'Cập nhật phân quyền',
      message: 'Bạn được chỉ định vai trò Quản trị viên trong công việc "Hoan thien Giao dien Module B".',
      type: 'task_shared',
      taskId: task1._id,
      isRead: true,
      createdAt: new Date(now.getTime() - 2 * 3600 * 1000),
    },
  ]);

  console.log('[Seed] Successfully created demo tasks, activities, and notifications for Huỳnh Đăng Khoa!');
  process.exit(0);
}

seed().catch(err => {
  console.error('[Seed Error]', err);
  process.exit(1);
});
