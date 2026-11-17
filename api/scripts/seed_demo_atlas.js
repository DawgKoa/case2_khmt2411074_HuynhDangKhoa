const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: __dirname + '/../.env' });

const User = require('../src/models/User');
const Task = require('../src/models/Task');
const TaskActivity = require('../src/models/TaskActivity');
const Notification = require('../src/models/Notification');

async function seed() {
  console.log('Connecting to Atlas to seed demo tasks for Khoa...');
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB Atlas.');

  let khoa = await User.findOne({ email: 'dangkhoa15022006@gmail.com' });
  if (!khoa) {
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash('0866409678Khoa', salt);
    khoa = await User.create({
      fullName: 'Huỳnh Đăng Khoa',
      email: 'dangkhoa15022006@gmail.com',
      passwordHash: hash,
    });
  }

  let duy = await User.findOne({ email: 'duy.khmt2411073@gmail.com' });
  if (!duy) {
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash('123456', salt);
    duy = await User.create({
      fullName: 'Nguyễn Nhựt Duy',
      email: 'duy.khmt2411073@gmail.com',
      passwordHash: hash,
    });
  }

  // Clear existing tasks and activities for fresh clean demo
  await Task.deleteMany({});
  await TaskActivity.deleteMany({});
  await Notification.deleteMany({ userId: khoa._id });

  const now = new Date();
  const dayMs = 24 * 60 * 60 * 1000;

  // Task 1: Completed
  const t1 = await Task.create({
    title: 'Thiết kế giao diện Soft Neo-Brutalism',
    description: 'Chỉnh sửa toàn bộ card, button, text, chip sang phong cách Soft Neo-Brutalism mềm mại và tinh tế.',
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
      taskId: t1._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo công việc',
      createdAt: new Date(now.getTime() - 4 * dayMs),
    },
    {
      taskId: t1._id,
      userId: khoa._id,
      action: 'update_status',
      description: 'Chuyển trạng thái sang Đang làm',
      createdAt: new Date(now.getTime() - 2 * dayMs),
    },
    {
      taskId: t1._id,
      userId: khoa._id,
      action: 'update_status',
      description: 'Đã hoàn thành thiết kế giao diện theo đúng yêu cầu',
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
  ]);

  // Task 2: In Progress (Urgent)
  const t2 = await Task.create({
    title: 'Hoàn thiện báo cáo đồ án Case Study 2',
    description: 'Tổng hợp tài liệu 8 trang PDF, kịch bản 6 bước thuyết trình demo sản phẩm trước hội đồng.',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id, duy._id],
    priority: 'high',
    status: 'in_progress',
    startDate: new Date(now.getTime() - 2 * dayMs),
    dueDate: new Date(now.getTime() + 1 * dayMs),
    sharedWith: [{ userId: duy._id, role: 'editor', sharedAt: new Date(now.getTime() - 2 * dayMs) }],
  });

  await TaskActivity.create([
    {
      taskId: t2._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo công việc và gán thành viên',
      createdAt: new Date(now.getTime() - 2 * dayMs),
    },
    {
      taskId: t2._id,
      userId: khoa._id,
      action: 'update_status',
      description: 'Bắt đầu tổng hợp số liệu và kịch bản demo',
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
  ]);

  // Task 3: In Progress (Testing RBAC)
  const t3 = await Task.create({
    title: 'Kiểm thử API phân quyền RBAC và gửi mail SMTP',
    description: 'Kiểm thử phân quyền Owner vs Assignee và chức năng gửi mã OTP khôi phục mật khẩu qua Google Mail.',
    createdBy: khoa._id,
    primaryAssigneeId: duy._id,
    assigneeIds: [duy._id, khoa._id],
    priority: 'medium',
    status: 'in_progress',
    startDate: new Date(now.getTime() - 1 * dayMs),
    dueDate: new Date(now.getTime() + 2 * dayMs),
    sharedWith: [{ userId: duy._id, role: 'editor', sharedAt: new Date(now.getTime() - 1 * dayMs) }],
  });

  await TaskActivity.create([
    {
      taskId: t3._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo và phân công cho Nguyễn Nhựt Duy',
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
    {
      taskId: t3._id,
      userId: duy._id,
      action: 'update_status',
      description: 'Đã nhận task và chuyển trạng thái sang Đang làm',
      createdAt: new Date(now.getTime() - 12 * 60 * 60 * 1000),
    },
  ]);

  // Task 4: Todo (Chờ xử lý)
  const t4 = await Task.create({
    title: 'Chuẩn bị slide và kịch bản trả lời vấn đáp',
    description: 'In tài liệu 2 trang tóm tắt tính năng và bộ câu hỏi vấn đáp mang theo trong buổi báo cáo.',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id],
    priority: 'medium',
    status: 'todo',
    startDate: now,
    dueDate: new Date(now.getTime() + 3 * dayMs),
    sharedWith: [],
  });

  await TaskActivity.create([
    {
      taskId: t4._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo nhiệm vụ',
      createdAt: now,
    },
  ]);

  // Task 5: Completed (Triển khai MongoDB Atlas)
  const t5 = await Task.create({
    title: 'Triển khai cơ sở dữ liệu MongoDB Atlas Cloud',
    description: 'Cấu hình cụm Cluster0, mở truy cập mạng 0.0.0.0/0 và chuyển đổi kết nối backend an toàn.',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    assigneeIds: [khoa._id],
    priority: 'high',
    status: 'completed',
    startDate: new Date(now.getTime() - 3 * dayMs),
    dueDate: new Date(now.getTime() - 1 * dayMs),
    sharedWith: [],
  });

  await TaskActivity.create([
    {
      taskId: t5._id,
      userId: khoa._id,
      action: 'create',
      description: 'Khởi tạo nhiệm vụ kết nối Cloud',
      createdAt: new Date(now.getTime() - 3 * dayMs),
    },
    {
      taskId: t5._id,
      userId: khoa._id,
      action: 'update_status',
      description: 'Hoàn thành di chuyển dữ liệu sang Atlas',
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
  ]);

  // Seed Notifications for Khoa
  await Notification.create([
    {
      userId: khoa._id,
      type: 'task_assigned',
      title: 'Phân công công việc mới',
      message: 'Bạn được phân công làm người phụ trách chính cho nhiệm vụ "Hoàn thiện báo cáo đồ án Case Study 2".',
      taskId: t2._id,
      isRead: false,
      createdAt: new Date(now.getTime() - 2 * dayMs),
    },
    {
      userId: khoa._id,
      type: 'deadline_reminder',
      title: 'Nhắc nhở hạn chót công việc',
      message: 'Công việc "Hoàn thiện báo cáo đồ án Case Study 2" sắp đến hạn trong vòng 24 giờ tới.',
      taskId: t2._id,
      isRead: false,
      createdAt: new Date(now.getTime() - 6 * 60 * 60 * 1000),
    },
    {
      userId: khoa._id,
      type: 'task_status_changed',
      title: 'Cập nhật tiến độ nhiệm vụ',
      message: 'Nguyễn Nhựt Duy đã chuyển trạng thái công việc "Kiểm thử API phân quyền RBAC" sang Đang làm.',
      taskId: t3._id,
      isRead: true,
      createdAt: new Date(now.getTime() - 12 * 60 * 60 * 1000),
    },
    {
      userId: khoa._id,
      type: 'task_updated',
      title: 'Công việc đã hoàn thành',
      message: 'Nhiệm vụ "Thiết kế giao diện Soft Neo-Brutalism" đã được đánh dấu hoàn thành.',
      taskId: t1._id,
      isRead: true,
      createdAt: new Date(now.getTime() - 1 * dayMs),
    },
  ]);

  console.log('SEEDING ATLAS COMPLETED SUCCESSFULLY!');
  await mongoose.disconnect();
  process.exit(0);
}

seed().catch(err => {
  console.error('Seed error:', err);
  process.exit(1);
});
