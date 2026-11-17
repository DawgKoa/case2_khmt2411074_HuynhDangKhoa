const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: __dirname + '/../.env' });

const User = require('../src/models/User');
const Task = require('../src/models/Task');
const TaskActivity = require('../src/models/TaskActivity');
const Notification = require('../src/models/Notification');

async function runAudit() {
  console.log('====================================================');
  console.log('🔍 KIỂM TRA TOÀN DIỆN DATABASE MONGODB ATLAS (AUDIT)');
  console.log('====================================================');
  console.log('URI:', process.env.MONGODB_URI.replace(/:([^:@]+)@/, ':****@'));

  const startConnect = Date.now();
  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 20000 });
  console.log(`✅ 1. Kết nối MongoDB Atlas: THÀNH CÔNG (${Date.now() - startConnect}ms)`);

  // 1. Kiểm tra Collections
  const collections = await mongoose.connection.db.listCollections().toArray();
  const colNames = collections.map(c => c.name);
  console.log(`✅ 2. Danh sách Collections (${colNames.length}):`, colNames.join(', '));

  // 2. Kiểm tra Users & Tài khoản chính
  const userCount = await User.countDocuments();
  console.log(`✅ 3. Số lượng Users: ${userCount}`);
  
  const khoa = await User.findOne({ email: 'dangkhoa15022006@gmail.com' });
  if (!khoa) {
    throw new Error('❌ Không tìm thấy tài khoản dangkhoa15022006@gmail.com!');
  }
  const isPassOk = await bcrypt.compare('0866409678Khoa', khoa.passwordHash);
  if (!isPassOk) {
    throw new Error('❌ Mật khẩu 0866409678Khoa không khớp!');
  }
  console.log(`✅ 4. Tài khoản chính: ${khoa.fullName} (${khoa.email}) - Mật khẩu '0866409678Khoa' CHÍNH XÁC 100%`);

  // 3. Kiểm tra Tasks
  const taskCount = await Task.countDocuments();
  const pendingTasks = await Task.countDocuments({ status: 'todo' });
  const inProgressTasks = await Task.countDocuments({ status: 'in_progress' });
  const completedTasks = await Task.countDocuments({ status: 'completed' });
  console.log(`✅ 5. Tổng số Tasks: ${taskCount} việc`);
  console.log(`   - Chờ xử lý (Todo): ${pendingTasks}`);
  console.log(`   - Đang làm (In Progress): ${inProgressTasks}`);
  console.log(`   - Hoàn thành (Completed): ${completedTasks}`);

  // 4. Kiểm tra Lịch sử hoạt động (Audit Trail)
  const activityCount = await TaskActivity.countDocuments();
  console.log(`✅ 6. Lịch sử hoạt động (Audit Trail): ${activityCount} bản ghi log`);

  // 5. Kiểm tra Thông báo (Notifications)
  const notifCount = await Notification.countDocuments();
  console.log(`✅ 7. Thông báo (Notifications): ${notifCount} thông báo`);

  // 6. Test ghi / sửa / xóa (CRUD Write test trên Atlas)
  console.log('🔄 Đang thử nghiệm thao tác Ghi / Cập nhật / Xóa trên Atlas...');
  const testTask = await Task.create({
    title: 'Audit Test Task - Live Check',
    description: 'Thử nghiệm ghi dữ liệu thời gian thực lên Atlas',
    createdBy: khoa._id,
    primaryAssigneeId: khoa._id,
    priority: 'low',
    status: 'todo',
    dueDate: new Date(Date.now() + 86400000),
  });
  console.log('   - Ghi (Create): OK -> ID:', testTask._id.toString());

  testTask.status = 'in_progress';
  await testTask.save();
  console.log('   - Sửa (Update status): OK -> in_progress');

  await Task.deleteOne({ _id: testTask._id });
  console.log('   - Xóa (Delete): OK -> Đã dọn dẹp task test');

  console.log('====================================================');
  console.log('🎉 TẤT CẢ DỮ LIỆU & QUYỀN GHI/ĐỌC TRÊN ATLAS ĐỀU HOÀN HẢO!');
  console.log('====================================================');

  await mongoose.disconnect();
  process.exit(0);
}

runAudit().catch(err => {
  console.error('Audit thất bại:', err);
  process.exit(1);
});
