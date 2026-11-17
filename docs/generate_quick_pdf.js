const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const brainDir = 'C:\\Users\\Lenovo\\.gemini\\antigravity\\brain\\2568ef0c-ce92-41da-9431-bd2fcb556405';

function getBase64(fileName) {
  const filePath = path.join(brainDir, fileName);
  if (fs.existsSync(filePath)) {
    const data = fs.readFileSync(filePath);
    return `data:image/png;base64,${data.toString('base64')}`;
  }
  return '';
}

const imgMain = getBase64('emulator_screen_final_main.png');
const imgDetail = getBase64('emulator_screen_detail.png');
const imgStats = getBase64('emulator_screen_stats_loaded.png');
const imgOtp = getBase64('emulator_screen_otp_removed.png');

const htmlContent = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Tóm Tắt Tính Năng Task Manager - Huỳnh Đăng Khoa</title>
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
      font-size: 12.5px;
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
      padding-bottom: 8px;
      border-bottom: 1.5px solid #2C2C2C;
      margin-bottom: 12px;
    }

    .header-title {
      font-size: 15px;
      font-weight: 800;
      color: #2C2C2C;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .badge-pill {
      background: #FEE07C;
      border: 1.2px solid #2C2C2C;
      padding: 3px 10px;
      border-radius: 999px;
      font-weight: 700;
      font-size: 11px;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
    }

    .badge-blue { background: #D0EBFF; }
    .badge-green { background: #D3F9D8; }

    .card {
      background: #FFFFFF;
      border: 1.4px solid #2C2C2C;
      border-radius: 12px;
      padding: 10px 12px;
      box-shadow: 2px 2px 0px #2C2C2C;
      margin-bottom: 10px;
    }

    .card-yellow { background: #FFF9E6; }
    .card-blue { background: #F0F7FF; }
    .card-green { background: #F2FAF3; }

    h2 {
      font-size: 14.5px;
      font-weight: 800;
      color: #2C2C2C;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .feature-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin-bottom: 10px;
    }

    .feature-item {
      background: #FFFFFF;
      border: 1.2px solid #2C2C2C;
      border-radius: 10px;
      padding: 9px 11px;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
    }

    .feature-item h3 {
      font-size: 12.5px;
      font-weight: 800;
      color: #111;
      margin-bottom: 3px;
    }

    .feature-item p {
      font-size: 11.5px;
      color: #444;
      line-height: 1.35;
    }

    .footer-bar {
      display: flex;
      justify-content: space-between;
      border-top: 1.2px solid #D0C4B4;
      padding-top: 6px;
      font-size: 11px;
      color: #666;
      font-weight: 600;
      margin-top: auto;
    }

    .img-box {
      width: 100%;
      height: 128mm;
      border: 1.5px solid #2C2C2C;
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 3px 3px 0px #2C2C2C;
      background: #2C2C2C;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .img-box img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      background: #FFFDF8;
    }

    .demo-step {
      display: flex;
      gap: 8px;
      margin-bottom: 7px;
      align-items: flex-start;
      font-size: 12px;
    }

    .demo-num {
      background: #FEE07C;
      border: 1.2px solid #2C2C2C;
      border-radius: 50%;
      width: 20px;
      height: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 800;
      font-size: 11px;
      flex-shrink: 0;
    }
  </style>
</head>
<body>

  <!-- ================= TRANG 1: APP CÓ NHỮNG GÌ? ================= -->
  <div class="page">
    <div>
      <div class="header-bar">
        <div class="header-title">
          <span>📋 TASK MANAGER — TỔNG QUAN TÍNH NĂNG (CASE STUDY 2)</span>
        </div>
        <div class="badge-pill">Huỳnh Đăng Khoa • KHMT2411074</div>
      </div>

      <!-- Mục tiêu 1 dòng -->
      <div class="card card-yellow" style="margin-bottom: 10px; padding: 8px 12px;">
        <p style="font-size: 12px; font-weight: 700; color: #7A4100;">
          🎯 <strong>Mục tiêu:</strong> Ứng dụng giải quyết triệt để tình trạng trôi deadline, phân công mập mờ và thiếu số liệu báo cáo thông qua 6 module tính năng hoàn chỉnh:
        </p>
      </div>

      <div style="display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 12px; align-items: start;">
        
        <!-- Cột trái: 6 Tính năng cốt lõi -->
        <div>
          <h2>⚡ 6 Chức Năng Cốt Lõi Của Ứng Dụng</h2>
          
          <div class="feature-item" style="margin-bottom: 7px;">
            <h3>1. Quản lý & Lọc Đa Chiều (3 Tầng)</h3>
            <p>• <strong>3 Tầng lọc:</strong> Phạm vi (Tất cả / Tôi tạo / Được giao / Chia sẻ) — Trạng thái (Chờ / Đang làm / Xong) — Độ ưu tiên.<br>
            • <strong>Tìm kiếm tức thì:</strong> Gõ từ khóa tự động lọc danh sách không cần reload.</p>
          </div>

          <div class="feature-item" style="margin-bottom: 7px;">
            <h3>2. Tạo Mới & Phân Bổ Nguồn Lực</h3>
            <p>• Đặt tiêu đề, mô tả bàn giao, chọn hạn chót (Deadline Picker).<br>
            • <strong>Phân quyền giao việc:</strong> Gán đích danh Người phụ trách (Assignee) và Người theo dõi (Collaborators).</p>
          </div>

          <div class="feature-item" style="margin-bottom: 7px;">
            <h3>3. Phân Quyền Vai Trò (RBAC)</h3>
            <p>• <strong>Owner:</strong> Toàn quyền sửa nội dung, đổi hạn chót hoặc xóa task.<br>
            • <strong>Assignee:</strong> Chỉ được bấm đổi trạng thái tiến độ.<br>
            • <strong>Viewer:</strong> Chỉ xem thông tin, không được sửa trái phép.</p>
          </div>

          <div class="feature-item" style="margin-bottom: 7px;">
            <h3>4. Nhật Ký Hoạt Động (Audit Trail)</h3>
            <p>• Ghi vết thời gian thực mọi thay đổi: Ai tạo task lúc mấy giờ? Ai nhận việc chuyển sang "Đang làm"? Ai chốt hoàn thành? Minh bạch 100%.</p>
          </div>

          <div class="feature-item" style="margin-bottom: 7px;">
            <h3>5. Đo Lường KPI & Xuất Báo Cáo</h3>
            <p>• Tự động tính % hoàn thành, đếm số việc quá hạn (Overdue).<br>
            • <strong>Xuất báo cáo 1 chạm:</strong> Xuất bản tổng hợp tiến độ phục vụ quản lý.</p>
          </div>

          <div class="feature-item" style="margin-bottom: 0;">
            <h3>6. Nhắc Việc & Bảo Mật OTP Email Thật</h3>
            <p>• Chuông thông báo In-App nhắc deadline và khi có người giao task.<br>
            • Đổi mật khẩu an toàn với <strong>Google SMTP gửi mã OTP 6 số thật</strong> về Gmail.</p>
          </div>
        </div>

        <!-- Cột phải: 2 Ảnh mockup -->
        <div>
          <h2 style="font-size: 13.5px;">📱 Màn Hình Chính & Chi Tiết</h2>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
            <div class="img-box" style="height: 185mm;">
              <img src="${imgMain}" alt="Màn hình chính">
            </div>
            <div class="img-box" style="height: 185mm;">
              <img src="${imgDetail}" alt="Chi tiết công việc">
            </div>
          </div>
        </div>

      </div>
    </div>

    <div class="footer-bar">
      <span>Task Manager — Tóm tắt tính năng dành cho buổi báo cáo</span>
      <span>Trang 1 / 2</span>
    </div>
  </div>

  <!-- ================= TRANG 2: CÁCH NÓI & DEMO NHANH ================= -->
  <div class="page">
    <div>
      <div class="header-bar">
        <div class="header-title">
          <span>🎤 KỊCH BẢN NÓI & LIVE DEMO NHANH (1 - 2 PHÚT)</span>
        </div>
        <div class="badge-pill badge-green">Hội Đồng Đánh Giá Case Study 2</div>
      </div>

      <div style="display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 12px; align-items: start;">
        
        <!-- Cột trái: Kịch bản nói -->
        <div>
          <h2>🗣️ Giảng Viên Hỏi "App Em Có Gì?": Nói Thế Nào?</h2>
          
          <div class="card card-blue" style="margin-bottom: 9px; padding: 10px;">
            <p style="font-size: 12px; font-weight: 700; color: #1864AB; margin-bottom: 4px;">
              Câu mở đầu tóm tắt nhanh (15 giây):
            </p>
            <p style="font-size: 12px; font-style: italic; color: #222; margin-bottom: 0;">
              "Dạ thưa Thầy/Cô, ứng dụng Task Manager của em giải quyết bài toán quản lý và phối hợp công việc với <strong>giao diện Soft Neo-Brutalism</strong>. Hệ thống tập trung vào 3 điểm mấu chốt: <strong>Bộ lọc 3 tầng thông minh</strong>, <strong>Phân quyền RBAC kết hợp Nhật ký Audit Trail</strong> để không ai đổ lỗi cho nhau, và <strong>Tự động đo lường KPI kèm xuất báo cáo</strong>."
            </p>
          </div>

          <h2>🎬 4 Bước Demo Trên Điện Thoại (Thao Tác Thực Tế)</h2>

          <div class="card" style="margin-bottom: 8px; padding: 8px 10px;">
            <div class="demo-step">
              <span class="demo-num">1</span>
              <div>
                <strong>Lọc việc nhanh:</strong> Bấm nút <em>"Được giao"</em>, chọn trạng thái <em>"Đang làm"</em>, gõ thử vài chữ vào ô tìm kiếm ➔ <em>"Hệ thống lọc tức thì không giật lag."</em>
              </div>
            </div>
            <div class="demo-step">
              <span class="demo-num">2</span>
              <div>
                <strong>Tạo việc & Phân công:</strong> Bấm nút tròn (+), nhập tên việc, chọn hạn chót, gán tên bạn làm ➔ <em>"Gán đích danh người chịu trách nhiệm."</em>
              </div>
            </div>
            <div class="demo-step">
              <span class="demo-num">3</span>
              <div>
                <strong>Đổi trạng thái & Xem Audit Trail:</strong> Mở task vừa tạo, bấm chuyển sang <em>"Hoàn thành"</em>, cuộn xuống phần Lịch sử hoạt động ➔ <em>"Hệ thống ghi nhận chính xác từng giây ai đã hoàn thành."</em>
              </div>
            </div>
            <div class="demo-step" style="margin-bottom: 0;">
              <span class="demo-num">4</span>
              <div>
                <strong>Thống kê KPI & Xuất báo cáo:</strong> Bấm icon Biểu đồ ➔ chỉ vào tỷ lệ %, bấm nút <em>"Xuất báo cáo"</em> ➔ <em>"Tự động tính năng suất, xuất bản tóm tắt cho quản lý."</em>
              </div>
            </div>
          </div>

          <h2>🛠️ Kiến Trúc Công Nghệ Triển Khai</h2>
          <div class="feature-item" style="background: #FFF9E6; border: 1.2px solid #2C2C2C;">
            <p style="font-size: 11.5px; color: #333; line-height: 1.4;">
              • <strong>Mobile App:</strong> Flutter, giao diện Soft Neo-Brutalism bo tròn, font Plus Jakarta Sans.<br>
              • <strong>Backend:</strong> Node.js / Express REST API, xác thực bảo mật JWT Token.<br>
              • <strong>Database:</strong> MongoDB Cloud lưu trữ dữ liệu thời gian thực.<br>
              • <strong>Dịch vụ Mail:</strong> Google SMTP Server gửi mã OTP khôi phục mật khẩu thật.
            </p>
          </div>
        </div>

        <!-- Cột phải: 2 Ảnh mockup bổ trợ -->
        <div>
          <h2 style="font-size: 13.5px;">📊 Thống Kê & Bảo Mật OTP</h2>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
            <div class="img-box" style="height: 185mm;">
              <img src="${imgStats}" alt="Thống kê KPI">
            </div>
            <div class="img-box" style="height: 185mm;">
              <img src="${imgOtp}" alt="Xác thực OTP">
            </div>
          </div>
        </div>

      </div>
    </div>

    <div class="footer-bar">
      <span>Task Manager — Tóm tắt tính năng dành cho buổi báo cáo</span>
      <span>Trang 2 / 2</span>
    </div>
  </div>

</body>
</html>
`;

const htmlPath = path.join('D:\\casestudy2', 'docs', 'report_quick_2pages.html');
const pdfPath = path.join('D:\\casestudy2', 'Tong_Quan_Chuc_Nang_Task_Manager.pdf');

fs.writeFileSync(htmlPath, htmlContent, 'utf8');
console.log('HTML written to:', htmlPath);

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const cmd = `"${edgePath}" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="${pdfPath}" "file:///${htmlPath.replace(/\\\\/g, '/')}"`;

console.log('Running 2-page PDF export...');
execSync(cmd);
console.log('2-Page PDF generated at:', pdfPath);

if (fs.existsSync(pdfPath)) {
  const stats = fs.statSync(pdfPath);
  console.log('PDF File size:', stats.size, 'bytes');
}
