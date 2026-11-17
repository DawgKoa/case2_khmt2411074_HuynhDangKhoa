const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const htmlContent = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Bộ Câu Hỏi Vấn Đáp - Task Manager</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');

    @page {
      size: A4 portrait;
      margin: 10mm 12mm 10mm 12mm;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
    }

    body {
      font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
      background-color: #FAF8F5;
      color: #2C2C2C;
      font-size: 12px;
      line-height: 1.45;
    }

    .page {
      width: 100%;
      height: 277mm;
      max-height: 277mm;
      position: relative;
      page-break-after: always;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      overflow: hidden;
      padding: 2mm 0;
    }

    .page:last-child {
      page-break-after: avoid;
    }

    .header-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 7px;
      border-bottom: 1.5px solid #2C2C2C;
      margin-bottom: 10px;
    }

    .header-title {
      font-size: 14.5px;
      font-weight: 800;
      color: #2C2C2C;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .badge-pill {
      background: #FEE07C;
      border: 1.2px solid #2C2C2C;
      padding: 2px 9px;
      border-radius: 999px;
      font-weight: 700;
      font-size: 11px;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
    }

    .badge-blue { background: #D0EBFF; }
    .badge-green { background: #D3F9D8; }

    .card {
      background: #FFFFFF;
      border: 1.3px solid #2C2C2C;
      border-radius: 11px;
      padding: 9px 12px;
      box-shadow: 2px 2px 0px #2C2C2C;
      margin-bottom: 9px;
    }

    .card-yellow { background: #FFF9E6; }
    .card-blue { background: #F0F7FF; }
    .card-green { background: #F2FAF3; }
    .card-orange { background: #FFF4EB; }

    h2 {
      font-size: 13.5px;
      font-weight: 800;
      color: #2C2C2C;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .qa-box {
      background: #FFFFFF;
      border: 1.2px solid #2C2C2C;
      border-radius: 10px;
      padding: 8px 11px;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
      margin-bottom: 7px;
    }

    .question {
      font-size: 12px;
      font-weight: 800;
      color: #D9480F;
      margin-bottom: 3px;
      display: flex;
      align-items: flex-start;
      gap: 5px;
    }

    .answer {
      font-size: 11.5px;
      color: #222;
      line-height: 1.4;
      padding-left: 14px;
    }

    .answer strong {
      color: #000;
    }

    .code-tag {
      font-family: monospace;
      font-size: 11px;
      background: #F1F3F5;
      border: 1px solid #CED4DA;
      padding: 1px 5px;
      border-radius: 4px;
      color: #C92A2A;
      font-weight: 700;
    }

    table {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0;
      border: 1.3px solid #2C2C2C;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 2px 2px 0px #2C2C2C;
      font-size: 11px;
      margin-bottom: 9px;
    }

    th {
      background: #FEE07C;
      color: #2C2C2C;
      font-weight: 800;
      padding: 6px 8px;
      text-align: left;
      border-bottom: 1.3px solid #2C2C2C;
      border-right: 1px solid #2C2C2C;
    }

    th:last-child { border-right: none; }

    td {
      padding: 5px 8px;
      border-bottom: 1px solid #E2D9CC;
      border-right: 1px solid #E2D9CC;
      background: #FFFFFF;
      vertical-align: top;
    }

    td:last-child { border-right: none; }
    tr:last-child td { border-bottom: none; }

    .footer-bar {
      display: flex;
      justify-content: space-between;
      border-top: 1.2px solid #D0C4B4;
      padding-top: 5px;
      font-size: 10.5px;
      color: #666;
      font-weight: 600;
      margin-top: auto;
    }
  </style>
</head>
<body>

  <!-- ==================== TRANG 1 ==================== -->
  <div class="page">
    <div>
      <div class="header-bar">
        <div class="header-title">
          <span>🎯 BỘ CÂU HỎI VẤN ĐÁP BẢO VỆ ĐỒ ÁN — TASK MANAGER</span>
        </div>
        <div class="badge-pill">Huỳnh Đăng Khoa • KHMT2411074</div>
      </div>

      <!-- Mục 1: Bảng tra cứu vị trí code -->
      <h2>📁 1. Thầy Hỏi: "Chức Năng Này Nằm Ở Đâu Trong Code?"</h2>
      <table>
        <thead>
          <tr>
            <th style="width: 25%;">Chức năng cần tìm</th>
            <th style="width: 37%;">Màn hình Flutter (lib/screens/...)</th>
            <th style="width: 38%;">Xử lý Backend & DB (api/src/...)</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Đăng nhập / Đổi mật khẩu</strong></td>
            <td><code>auth/login_screen.dart</code><br><code>auth/forgot_password_screen.dart</code></td>
            <td><code>controllers/authController.js</code><br><code>services/emailService.js</code></td>
          </tr>
          <tr>
            <td><strong>Lọc việc & Tìm kiếm</strong></td>
            <td><code>tasks/task_list_screen.dart</code></td>
            <td><code>controllers/taskController.js</code></td>
          </tr>
          <tr>
            <td><strong>Tạo việc & Phân công</strong></td>
            <td><code>tasks/task_create_screen.dart</code></td>
            <td><code>controllers/taskController.js</code></td>
          </tr>
          <tr>
            <td><strong>Chi tiết & RBAC & Lịch sử</strong></td>
            <td><code>tasks/task_detail_screen.dart</code></td>
            <td><code>middleware/permissionMiddleware.js</code><br><code>models/TaskActivity.js</code></td>
          </tr>
          <tr>
            <td><strong>Thống kê KPI & Xuất báo cáo</strong></td>
            <td><code>stats/statistics_screen.dart</code></td>
            <td><code>controllers/statisticsController.js</code></td>
          </tr>
          <tr>
            <td><strong>Thông báo In-App</strong></td>
            <td><code>notifications/notification_screen.dart</code></td>
            <td><code>controllers/notificationController.js</code></td>
          </tr>
        </tbody>
      </table>

      <!-- Mục 2: Câu hỏi về OTP -->
      <h2>🔐 2. Nhóm Câu Hỏi Về Mã OTP & Quên Mật Khẩu (Cực Hay Hỏi!)</h2>

      <div class="qa-box">
        <div class="question">❓ Câu 1: "Mã OTP này được sinh ra ở đâu? Lưu ở đâu? Gồm mấy chữ số?"</div>
        <div class="answer">
          • <strong>Sinh ra ở:</strong> Backend Node.js (file <span class="code-tag">authController.js</span>, hàm <code>forgotPassword</code>) bằng hàm ngẫu nhiên gồm <strong>6 chữ số</strong>.<br>
          • <strong>Lưu ở:</strong> Database MongoDB trong collection <span class="code-tag">User</span> (trường <code>resetPasswordOtp</code> kèm thời gian hết hạn <code>resetPasswordOtpExpires</code>).<br>
          • <strong>Mobile App:</strong> Chỉ hiển thị ô nhập mã, hoàn toàn không tự sinh hay biết trước mã.
        </div>
      </div>

      <div class="qa-box">
        <div class="question">❓ Câu 2: "Mã OTP có thời hạn bao lâu? Nếu nhập sai hoặc dùng lại có được không?"</div>
        <div class="answer">
          • <strong>Thời hạn hiệu lực:</strong> Chính xác <strong>15 phút</strong> (TTL). Quá 15 phút mã tự vô hiệu hóa.<br>
          • <strong>Xác thực:</strong> Backend truy vấn <code>resetPasswordOtpExpires &gt; Date.now()</code>, nếu sai mã hoặc hết hạn sẽ trả lỗi <code>400 Bad Request</code>.<br>
          • <strong>Chống dùng lại:</strong> Ngay khi đổi mật khẩu xong, hệ thống gán <code>user.resetPasswordOtp = null</code> (hủy mã ngay lập tức).
        </div>
      </div>

      <div class="qa-box">
        <div class="question">❓ Câu 3: "Làm sao app gửi được email mã OTP thật vào Gmail của người dùng?"</div>
        <div class="answer">
          • Ở Backend dùng thư viện <span class="code-tag">Nodemailer</span> (file <code>emailService.js</code>).<br>
          • Kết nối qua máy chủ <strong>Google SMTP Server</strong> (host: <code>smtp.gmail.com</code>, cổng <code>587</code>) sử dụng Mật khẩu ứng dụng (App Password) của Gmail.<br>
          • Mail gửi đến hộp thư Gmail thật chỉ sau 2-3 giây.
        </div>
      </div>

      <div class="qa-box">
        <div class="question">❓ Câu 4: "Tại sao em chọn gửi OTP qua Email mà không gửi qua SMS?"</div>
        <div class="answer">
          • Gửi qua SMS cần đăng ký dịch vụ Brandname tốn phí duy trì và phí từng tin nhắn.<br>
          • Giải pháp Email qua Google SMTP <strong>hoàn toàn miễn phí</strong>, ổn định, định dạng HTML giao diện đẹp mắt, rất phù hợp và tối ưu cho đồ án sinh viên.
        </div>
      </div>

    </div>

    <div class="footer-bar">
      <span>Tài liệu phục vụ buổi vấn đáp đề tài Task Manager</span>
      <span>Trang 1 / 2</span>
    </div>
  </div>

  <!-- ==================== TRANG 2 ==================== -->
  <div class="page">
    <div>
      <div class="header-bar">
        <div class="header-title">
          <span>🎯 BỘ CÂU HỎI VẤN ĐÁP BẢO VỆ ĐỒ ÁN (TIẾP THEO)</span>
        </div>
        <div class="badge-pill badge-green">Huỳnh Đăng Khoa • KHMT2411074</div>
      </div>

      <!-- Mục 3: Bảo mật & Đăng nhập -->
      <h2>🛡️ 3. Nhóm Câu Hỏi Về Bảo Mật Mật Khẩu & Đăng Nhập</h2>

      <div class="qa-box">
        <div class="question">❓ Câu 5: "Mật khẩu của người dùng lưu trong database có bị lộ không? Có mã hóa không?"</div>
        <div class="answer">
          • Mật khẩu được <strong>băm 1 chiều (hash)</strong> bằng thuật toán <span class="code-tag">bcrypt</span> với <code>Salt rounds = 10</code> trước khi lưu vào MongoDB.<br>
          • Kể cả quản trị viên mở Database ra xem cũng chỉ thấy chuỗi băm ngẫu nhiên, hoàn toàn không thể dịch ngược lại thành mật khẩu gốc.
        </div>
      </div>

      <div class="qa-box">
        <div class="question">❓ Câu 6: "App quản lý phiên đăng nhập như thế nào? Tắt app mở lại có bắt đăng nhập lại không?"</div>
        <div class="answer">
          • Khi đăng nhập đúng, Backend cấp một mã <span class="code-tag">JWT Token</span> (JSON Web Token).<br>
          • Ứng dụng Flutter lưu token vào bộ nhớ máy (<span class="code-tag">SharedPreferences</span>).<br>
          • Khi mở lại app, file <code>main.dart</code> kiểm tra token còn hợp lệ thì cho vào thẳng màn hình chính, không cần đăng nhập lại.
        </div>
      </div>

      <!-- Mục 4: Phân quyền & Audit Trail -->
      <h2>👥 4. Nhóm Câu Hỏi Về Phân Quyền (RBAC) & Nhật Ký Hoạt Động</h2>

      <div class="qa-box">
        <div class="question">❓ Câu 7: "Hệ thống kiểm tra phân quyền thế nào? Lỡ ai đó dùng Postman gọi API sửa task người khác thì sao?"</div>
        <div class="answer">
          • Phân quyền được bảo vệ <strong>2 lớp</strong>:<br>
          &nbsp;&nbsp;1. <em>Ở Mobile:</em> Ẩn/hiện nút bấm tùy theo người dùng là Owner hay Assignee.<br>
          &nbsp;&nbsp;2. <em>Ở Backend:</em> Middleware <span class="code-tag">permissionMiddleware.js</span> kiểm tra <code>userId</code> trong Token với <code>creatorId</code> của Task. Nếu không có quyền, Backend lập tức chặn và trả về mã lỗi <strong>403 Forbidden</strong>, dù gọi qua Postman cũng không thể can thiệp dữ liệu.
        </div>
      </div>

      <div class="qa-box">
        <div class="question">❓ Câu 8: "Lịch sử hoạt động (Audit Trail) được lưu vết như thế nào?"</div>
        <div class="answer">
          • Mỗi khi có thao tác quan trọng (tạo việc, chuyển trạng thái sang Đang làm/Hoàn thành), hàm trong <span class="code-tag">taskController.js</span> tự động ghi 1 dòng log vào bảng <span class="code-tag">TaskActivity</span> gồm: <code>taskId</code>, <code>userId</code>, <code>action</code> và thời gian <code>createdAt</code>.<br>
          • Màn hình chi tiết gọi API lấy danh sách này hiển thị thành dòng thời gian (Timeline) trực quan, đảm bảo tính minh bạch trách nhiệm.
        </div>
      </div>

      <!-- Mục 5: Mẹo trả lời vấn đáp -->
      <div class="card card-yellow" style="margin-top: 10px; margin-bottom: 0;">
        <h2 style="font-size: 13px; margin-bottom: 4px;">💡 3 Mẹo Vàng Khi Trả Lời Vấn Đáp Với Giảng Viên:</h2>
        <p style="font-size: 11.5px; color: #333; line-height: 1.4; margin-bottom: 0;">
          1. <strong>Nói ngắn gọn & có từ khóa:</strong> Trả lời thẳng vào trọng tâm kèm tên công nghệ (VD: <em>"Dạ em dùng bcrypt băm mật khẩu"</em>, <em>"Mã OTP 6 số lưu ở MongoDB có thời hạn 15 phút"</em>).<br>
          2. <strong>Nếu Thầy bảo mở code:</strong> Bấm mở ngay file tương ứng ở bảng Mục 1 bên trang 1.<br>
          3. <strong>Thái độ tự tin, khiêm tốn:</strong> Lắng nghe hết câu hỏi rồi mới trả lời. Nếu Thầy góp ý nâng cấp thì ghi nhận: <em>"Dạ em cảm ơn Thầy/Cô, em sẽ tiếp thu để hoàn thiện thêm ạ!"</em>
        </p>
      </div>

    </div>

    <div class="footer-bar">
      <span>Tài liệu phục vụ buổi vấn đáp đề tài Task Manager</span>
      <span>Trang 2 / 2</span>
    </div>
  </div>

</body>
</html>
`;

const docsHtmlPath = path.join('D:\\casestudy2', 'docs', 'bo_cau_hoi_van_dap.html');
const pdfDownloadsPath = path.join(process.env.USERPROFILE, 'Downloads', 'Bo_Cau_Hoi_Van_Dap_Task_Manager.pdf');
const pdfDocsPath = path.join('D:\\casestudy2', 'Bo_Cau_Hoi_Van_Dap_Task_Manager.pdf');

fs.writeFileSync(docsHtmlPath, htmlContent, 'utf8');
console.log('HTML written to:', docsHtmlPath);

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const cmd = `"${edgePath}" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="${pdfDownloadsPath}" "file:///${docsHtmlPath.replace(/\\\\/g, '/')}"`;

console.log('Generating PDF to Downloads folder...');
execSync(cmd);
console.log('PDF generated at Downloads:', pdfDownloadsPath);

// Copy to project root as well
fs.copyFileSync(pdfDownloadsPath, pdfDocsPath);
console.log('Copied to project root:', pdfDocsPath);

if (fs.existsSync(pdfDownloadsPath)) {
  const stats = fs.statSync(pdfDownloadsPath);
  console.log('PDF size in Downloads:', stats.size, 'bytes');
}
