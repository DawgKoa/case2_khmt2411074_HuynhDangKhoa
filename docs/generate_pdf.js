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
  console.warn(`File not found: ${filePath}`);
  return '';
}

const imgMain = getBase64('emulator_screen_final_main.png');
const imgCreate = getBase64('emulator_screen_create.png');
const imgDetail = getBase64('emulator_screen_detail.png');
const imgDetailBottom = getBase64('emulator_screen_detail_bottom.png');
const imgStats = getBase64('emulator_screen_stats_loaded.png');
const imgExport = getBase64('emulator_screen_export.png');
const imgNotif = getBase64('emulator_screen_notifications.png');
const imgOtp = getBase64('emulator_screen_otp_removed.png');

const htmlContent = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Báo Cáo Giới Thiệu Sản Phẩm Task Manager - Huỳnh Đăng Khoa</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');

    @page {
      size: A4 portrait;
      margin: 10mm 12mm 12mm 12mm;
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
      font-size: 13px;
      line-height: 1.5;
    }

    .page {
      width: 100%;
      height: 275mm;
      max-height: 275mm;
      position: relative;
      page-break-after: always;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      overflow: hidden;
      padding: 4mm 0;
    }

    .page:last-child {
      page-break-after: avoid;
    }

    /* Header & Footer */
    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 8px;
      border-bottom: 1.5px solid #E2D9CC;
      margin-bottom: 14px;
    }

    .page-header .brand {
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 800;
      font-size: 13px;
      color: #2C2C2C;
      letter-spacing: -0.2px;
    }

    .page-header .brand-icon {
      width: 24px;
      height: 24px;
      background: #FEE07C;
      border: 1.5px solid #2C2C2C;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
    }

    .page-header .doc-tag {
      font-size: 11px;
      font-weight: 700;
      background: #FFFDF8;
      border: 1.2px solid #2C2C2C;
      padding: 3px 10px;
      border-radius: 999px;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
    }

    .page-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 8px;
      border-top: 1.5px solid #E2D9CC;
      font-size: 11px;
      color: #666;
      font-weight: 600;
      margin-top: auto;
    }

    /* Soft Neo-Brutalism Cards */
    .card {
      background: #FFFFFF;
      border: 1.5px solid #2C2C2C;
      border-radius: 14px;
      padding: 14px;
      box-shadow: 2.5px 2.5px 0px #2C2C2C;
      margin-bottom: 12px;
    }

    .card-yellow {
      background: #FFF9E6;
    }

    .card-blue {
      background: #F0F7FF;
    }

    .card-green {
      background: #F2FAF3;
    }

    .card-orange {
      background: #FFF4EB;
    }

    .card-purple {
      background: #F7F3FF;
    }

    /* Badges */
    .badge {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      font-size: 11px;
      font-weight: 700;
      padding: 3px 10px;
      border-radius: 999px;
      border: 1.2px solid #2C2C2C;
      box-shadow: 1.5px 1.5px 0px #2C2C2C;
    }

    .badge-yellow { background: #FEE07C; }
    .badge-blue { background: #D0EBFF; }
    .badge-green { background: #D3F9D8; }
    .badge-orange { background: #FFD8A8; }
    .badge-white { background: #FFFFFF; }

    /* Typography */
    h1 {
      font-size: 26px;
      font-weight: 800;
      color: #2C2C2C;
      line-height: 1.25;
      letter-spacing: -0.5px;
    }

    h2 {
      font-size: 18px;
      font-weight: 800;
      color: #2C2C2C;
      letter-spacing: -0.3px;
      margin-bottom: 6px;
    }

    h3 {
      font-size: 14px;
      font-weight: 700;
      color: #2C2C2C;
      margin-bottom: 4px;
    }

    p {
      color: #444;
      margin-bottom: 6px;
    }

    /* Grid Layouts */
    .grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px;
    }

    .grid-3 {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 12px;
    }

    /* Feature Showcase Layout */
    .showcase-layout {
      display: grid;
      grid-template-columns: 1fr 1.25fr;
      gap: 16px;
      align-items: start;
      height: 100%;
    }

    .phone-mockup {
      background: #FFFFFF;
      border: 2px solid #2C2C2C;
      border-radius: 20px;
      padding: 6px;
      box-shadow: 4px 4px 0px #2C2C2C;
      display: flex;
      flex-direction: column;
      align-items: center;
      background: #2C2C2C;
    }

    .phone-screen {
      width: 100%;
      border-radius: 14px;
      overflow: hidden;
      border: 1px solid #444;
      display: block;
    }

    .phone-screen img {
      width: 100%;
      height: auto;
      max-height: 205mm;
      object-fit: contain;
      display: block;
      background: #FFFDF8;
    }

    .bullet-list {
      list-style: none;
      padding: 0;
    }

    .bullet-list li {
      position: relative;
      padding-left: 20px;
      margin-bottom: 7px;
      color: #333;
      font-size: 12.5px;
    }

    .bullet-list li::before {
      content: '✓';
      position: absolute;
      left: 0;
      top: 0;
      font-weight: 800;
      color: #2B8A3E;
    }

    .demo-step-box {
      background: #FFFFFF;
      border: 1.5px solid #2C2C2C;
      border-radius: 12px;
      padding: 10px 12px;
      box-shadow: 2px 2px 0px #2C2C2C;
      margin-bottom: 8px;
    }

    .step-number {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 22px;
      height: 22px;
      background: #FEE07C;
      border: 1.2px solid #2C2C2C;
      border-radius: 50%;
      font-weight: 800;
      font-size: 11px;
      margin-right: 6px;
    }

    /* Cover Page Styling */
    .cover-container {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      height: 100%;
      padding: 15mm 8mm 10mm 8mm;
      text-align: center;
    }

    .cover-top {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 10px;
    }

    .cover-logo {
      width: 70px;
      height: 70px;
      background: #FEE07C;
      border: 2px solid #2C2C2C;
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 34px;
      box-shadow: 4px 4px 0px #2C2C2C;
      margin-bottom: 10px;
    }

    .cover-title-box {
      background: #FFFFFF;
      border: 2px solid #2C2C2C;
      border-radius: 20px;
      padding: 22px 26px;
      box-shadow: 4px 4px 0px #2C2C2C;
      margin: 15px 0;
      width: 100%;
    }

    .cover-info-card {
      background: #FFF9E6;
      border: 1.8px solid #2C2C2C;
      border-radius: 16px;
      padding: 18px 24px;
      box-shadow: 3.5px 3.5px 0px #2C2C2C;
      text-align: left;
      width: 100%;
      margin: 15px 0;
    }

    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px dashed #D0C4B4;
      font-size: 13.5px;
    }

    .info-row:last-child {
      border-bottom: none;
    }

    .info-label {
      font-weight: 600;
      color: #666;
    }

    .info-value {
      font-weight: 750;
      color: #2C2C2C;
    }

    .highlight-badge {
      background: #2C2C2C;
      color: #FFF;
      font-weight: 700;
      font-size: 11px;
      padding: 4px 10px;
      border-radius: 999px;
    }

    table {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0;
      border: 1.5px solid #2C2C2C;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 2.5px 2.5px 0px #2C2C2C;
      margin-top: 8px;
      font-size: 12px;
    }

    th {
      background: #FEE07C;
      color: #2C2C2C;
      font-weight: 800;
      padding: 9px 10px;
      text-align: left;
      border-bottom: 1.5px solid #2C2C2C;
      border-right: 1px solid #2C2C2C;
    }

    th:last-child {
      border-right: none;
    }

    td {
      padding: 8px 10px;
      border-bottom: 1px solid #E2D9CC;
      border-right: 1px solid #E2D9CC;
      background: #FFFFFF;
      vertical-align: top;
    }

    td:last-child {
      border-right: none;
    }

    tr:last-child td {
      border-bottom: none;
    }
  </style>
</head>
<body>

  <!-- ==================== TRANG 1: TRANG BÌA ==================== -->
  <div class="page">
    <div class="cover-container">
      <div class="cover-top">
        <span class="badge badge-yellow">BÁO CÁO NGHIỆM THU ĐỀ TÀI // CASE STUDY 2</span>
        <h3 style="text-transform: uppercase; letter-spacing: 1.5px; color: #555; font-size: 13px; margin-top: 4px;">
          BÁO CÁO ĐÁNH GIÁ SẢN PHẨM PHẦN MỀM
        </h3>
        <div class="cover-logo">📋</div>
      </div>

      <div class="cover-title-box">
        <h1 style="font-size: 27px; margin-bottom: 8px;">TASK MANAGER MOBILE SYSTEM</h1>
        <p style="font-size: 15px; font-weight: 700; color: #B26A00; margin-bottom: 10px;">
          Hệ Thống Quản Trị Công Việc Đa Nền Tảng & Phân Quyền Thông Minh
        </p>
        <div style="display: flex; justify-content: center; gap: 8px; flex-wrap: wrap;">
          <span class="badge badge-white">⚡ Soft Neo-Brutalism UI</span>
          <span class="badge badge-blue">🔄 Real-time Cloud Sync</span>
          <span class="badge badge-green">🛡️ Role-Based Access Control</span>
          <span class="badge badge-orange">📧 Google SMTP OTP</span>
        </div>
      </div>

      <div class="cover-info-card">
        <div class="info-row">
          <span class="info-label">Họ và tên sinh viên:</span>
          <span class="info-value" style="font-size: 15px; color: #111;">HUỲNH ĐĂNG KHOA</span>
        </div>
        <div class="info-row">
          <span class="info-label">Mã số sinh viên (MSSV):</span>
          <span class="info-value" style="font-family: monospace; font-size: 14px; background: #FFF; padding: 2px 8px; border-radius: 6px; border: 1px solid #2C2C2C;">KHMT2411074</span>
        </div>
        <div class="info-row">
          <span class="info-label">Chuyên ngành đào tạo:</span>
          <span class="info-value">Khoa Học Máy Tính</span>
        </div>
        <div class="info-row">
          <span class="info-label">Mã học phần:</span>
          <span class="info-value">Case Study 2 - Phát triển Ứng dụng Di động</span>
        </div>
        <div class="info-row">
          <span class="info-label">Kiến trúc triển khai:</span>
          <span class="info-value">Flutter Mobile + Node.js/Express REST API + MongoDB Cloud</span>
        </div>
      </div>

      <div>
        <p style="font-size: 12px; color: #777; font-weight: 600;">
          TP. Hồ Chí Minh — Tháng 11 / 2026
        </p>
      </div>
    </div>
  </div>

  <!-- ==================== TRANG 2: TỔNG QUAN & BÀI TOÁN ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">01</div> TỔNG QUAN DỰ ÁN & ĐẶT VẤN ĐỀ</div>
      <div class="doc-tag">Huỳnh Đăng Khoa • KHMT2411074</div>
    </div>

    <div>
      <div style="margin-bottom: 14px;">
        <h2>1. Đặt Vấn Đề & Bối Cảnh Thực Tiễn</h2>
        <p style="font-size: 13px; color: #444;">
          Trong quản lý công việc và phối hợp đội nhóm hiện đại, các cá nhân và tổ chức thường xuyên gặp phải tình trạng trễ tiến độ, thông tin bị phân mảnh qua nhiều kênh tin nhắn, thiếu cơ chế phân chia quyền hạn minh bạch và không có số liệu đo lường hiệu suất (KPI) trực quan.
        </p>
      </div>

      <div class="grid-2" style="margin-bottom: 14px;">
        <div class="card card-orange" style="margin-bottom: 0;">
          <h3 style="color: #D9480F; display: flex; align-items: center; gap: 6px;">
            ⚠️ Những Bất Cập Thường Gặp
          </h3>
          <ul class="bullet-list" style="margin-top: 8px;">
            <li><strong>Thất lạc thông tin:</strong> Trao đổi task qua chat dẫn đến sót việc, không kiểm soát được hạn chót (Deadline).</li>
            <li><strong>Mập mờ trách nhiệm:</strong> Không phân định rõ vai trò người tạo việc (Owner) và người thực thi (Assignee).</li>
            <li><strong>Thiếu lịch sử truy vết:</strong> Khi có thay đổi trạng thái hoặc chỉnh sửa nội dung, không có nhật ký Audit Trail.</li>
            <li><strong>Báo cáo thủ công:</strong> Cuối tuần/cuối tháng phải tổng hợp số liệu bằng tay, tốn nhiều thời gian.</li>
          </ul>
        </div>

        <div class="card card-green" style="margin-bottom: 0;">
          <h3 style="color: #2B8A3E; display: flex; align-items: center; gap: 6px;">
            💡 Giải Pháp Của Task Manager
          </h3>
          <ul class="bullet-list" style="margin-top: 8px;">
            <li><strong>Tập trung hóa công việc:</strong> Toàn bộ nhiệm vụ được gom vào một hệ thống trực quan, dễ tra cứu và lọc theo nhiều tiêu chí.</li>
            <li><strong>Phân quyền RBAC chuẩn chỉ:</strong> Chỉ người có thẩm quyền mới được sửa/đổi trạng thái, bảo toàn tính toàn vẹn dữ liệu.</li>
            <li><strong>Cảnh báo Deadline tự động:</strong> Hệ thống thông báo In-App và Email nhắc việc thông minh trước hạn chót.</li>
            <li><strong>Thống kê KPI tự động:</strong> Đo lường tức thì tỷ lệ hoàn thành, công việc quá hạn và xuất báo cáo chỉ với 1 chạm.</li>
          </ul>
        </div>
      </div>

      <h2>2. Triết Lý Thiết Kế: Soft Neo-Brutalism</h2>
      <p style="font-size: 13px; color: #444; margin-bottom: 10px;">
        Ứng dụng được thiết kế hoàn toàn theo phong cách <strong>Soft Neo-Brutalism</strong> — sự kết hợp hài hòa giữa nét dứt khoát, hiện đại của phong cách Neo-Brutalism với sự mềm mại, thân thiện của thiết kế di động đương đại:
      </p>

      <div class="grid-3">
        <div class="card card-yellow" style="margin-bottom: 0;">
          <h3 style="font-size: 13px;">🎨 Bảng Màu Pastel Ấm</h3>
          <p style="font-size: 12px; color: #555; margin-bottom: 0;">
            Sử dụng tông nền kem ấm dịu mắt kết hợp vàng pastel (Warm Amber) và xanh phấn, giúp người dùng không bị mỏi mắt khi làm việc thời gian dài.
          </p>
        </div>
        <div class="card card-blue" style="margin-bottom: 0;">
          <h3 style="font-size: 13px;">📐 Bo Góc & Viền Tinh Tế</h3>
          <p style="font-size: 12px; color: #555; margin-bottom: 0;">
            Các thẻ card được bo tròn 16px - 20px, nút bấm dạng viên thuốc (Pill shape), viền màu than chì 1.5px mảnh thanh lịch, bóng đổ nhẹ nhàng.
          </p>
        </div>
        <div class="card card-purple" style="margin-bottom: 0;">
          <h3 style="font-size: 13px;">🔤 Typography Chuẩn Bực</h3>
          <p style="font-size: 12px; color: #555; margin-bottom: 0;">
            Sử dụng font <strong>Plus Jakarta Sans</strong> cao cấp, loại bỏ hoàn toàn các thuật ngữ kỹ thuật thừa thãi, văn bản tiếng Việt tự nhiên và mạch lạc.
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 2 / 8</span>
    </div>
  </div>

  <!-- ==================== TRANG 3: MÀN HÌNH CHÍNH ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">02</div> GIAO DIỆN CHÍNH & QUẢN LÝ CÔNG VIỆC</div>
      <div class="doc-tag">Màn Hình Danh Sách // Task Hub</div>
    </div>

    <div class="showcase-layout">
      <!-- Cột Trái: Ảnh Mockup -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgMain}" alt="Giao diện màn hình chính Task Manager">
        </div>
      </div>

      <!-- Cột Phải: Phân Tích Chức Năng -->
      <div>
        <h2>Màn Hình Trung Tâm Quản Lý</h2>
        <p style="font-size: 13px; color: #444; margin-bottom: 12px;">
          Màn hình chính đóng vai trò là "Cockpit" chỉ huy, cho phép người dùng bao quát toàn bộ khối lượng công việc, lọc nhanh và hành động tức thì.
        </p>

        <div class="card card-yellow">
          <h3>🔍 Bộ Lọc Đa Chiều Thông Minh (3 Tầng)</h3>
          <ul class="bullet-list" style="margin-top: 6px;">
            <li><strong>Tầng 1 - Phạm vi:</strong> <em>Tất cả</em>, <em>Tôi tạo</em>, <em>Được giao</em>, <em>Được chia sẻ</em>. Giúp phân định ngay việc của cá nhân hay việc theo dõi.</li>
            <li><strong>Tầng 2 - Trạng thái:</strong> <em>Tất cả</em>, <em>Chờ xử lý</em>, <em>Đang làm</em>, <em>Hoàn thành</em>. Chuyển đổi trạng thái cực kỳ nhanh.</li>
            <li><strong>Tầng 3 - Mức độ ưu tiên:</strong> Lọc theo <em>Khẩn cấp</em>, <em>Cao</em>, <em>Trung bình</em>, <em>Thấp</em> để tập trung xử lý công việc quan trọng trước.</li>
          </ul>
        </div>

        <div class="card card-blue">
          <h3>⚡ Thẻ Công Việc Trực Quan (Task Card)</h3>
          <ul class="bullet-list" style="margin-top: 6px;">
            <li><strong>Badge Trạng thái:</strong> Phối màu rõ nét (Đang làm - Xanh phấn, Chờ xử lý - Vàng nhạt, Hoàn thành - Xanh lục).</li>
            <li><strong>Thời hạn Deadline:</strong> Hiển thị rõ ràng ngày giờ đến hạn kèm cảnh báo đỏ nếu nhiệm vụ bị trễ hạn.</li>
            <li><strong>Người phụ trách:</strong> Hiển thị tên và avatar thành viên được phân công, dễ dàng nhận diện trách nhiệm.</li>
          </ul>
        </div>

        <div class="card card-green">
          <h3 style="color: #2B8A3E;">🎤 Gợi Ý Thuyết Trình Demo</h3>
          <p style="font-size: 12px; color: #444; margin-bottom: 0;">
            <em>"Thưa thầy/cô, đây là màn hình chính của ứng dụng. Em áp dụng ngôn ngữ Soft Neo-Brutalism với màu kem ấm và các nút lọc bo tròn dạng pill. Điểm mạnh ở đây là bộ lọc 3 tầng hoạt động hoàn toàn mượt mà, người dùng gõ tìm kiếm là danh sách cập nhật ngay lập tức mà không cần bấm nút tìm kiếm."</em>
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 3 / 8</span>
    </div>
  </div>

  <!-- ==================== TRANG 4: TẠO MỚI & PHÂN CÔNG ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">03</div> KHỞI TẠO CÔNG VIỆC & PHÂN BỔ NGUỒN LỰC</div>
      <div class="doc-tag">Khởi Tạo // Task Creation</div>
    </div>

    <div class="showcase-layout">
      <!-- Cột Trái: Ảnh Mockup -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgCreate}" alt="Giao diện tạo mới công việc">
        </div>
      </div>

      <!-- Cột Phải: Phân Tích Chức Năng -->
      <div>
        <h2>Quy Trình Tạo Việc Chuẩn Hóa</h2>
        <p style="font-size: 13px; color: #444; margin-bottom: 12px;">
          Form khởi tạo được tối ưu hóa theo trải nghiệm người dùng di động (Mobile UX), đảm bảo đầy đủ thông tin nghiệp vụ nhưng thao tác chỉ mất dưới 30 giây.
        </p>

        <div class="card">
          <h3>📝 Các Trường Dữ Liệu Nghiệp Vụ</h3>
          <ul class="bullet-list" style="margin-top: 6px;">
            <li><strong>Tiêu đề & Mô tả chi tiết:</strong> Nhập rõ ràng yêu cầu công việc, hỗ trợ nhiều dòng văn bản mô tả cụ thể tiêu chí bàn giao.</li>
            <li><strong>Hạn chót (Deadline Picker):</strong> Hộp thoại chọn ngày giờ trực quan, tự động kiểm tra tính hợp lệ (không cho chọn ngày trong quá khứ).</li>
            <li><strong>Thiết lập độ ưu tiên:</strong> 4 cấp độ trực quan (Khẩn cấp, Cao, Trung bình, Thấp) với màu sắc cảnh báo chuẩn quốc tế.</li>
          </ul>
        </div>

        <div class="card card-purple">
          <h3>👥 Phân Bổ Nguồn Lực & Phối Hợp Nhóm</h3>
          <ul class="bullet-list" style="margin-top: 6px;">
            <li><strong>Người phụ trách chính (Assignee):</strong> Lựa chọn thành viên chịu trách nhiệm chính về kết quả công việc.</li>
            <li><strong>Người theo dõi (Collaborators):</strong> Cho phép thêm nhiều thành viên phối hợp để cùng nhận thông báo và theo dõi tiến độ.</li>
            <li><strong>Tự động gửi thông báo:</strong> Ngay khi bấm "Tạo công việc", hệ thống tự động đẩy thông báo In-App và Email đến người được giao việc.</li>
          </ul>
        </div>

        <div class="card card-green">
          <h3 style="color: #2B8A3E;">🎤 Gợi Ý Thuyết Trình Demo</h3>
          <p style="font-size: 12px; color: #444; margin-bottom: 0;">
            <em>"Khi tạo việc mới, hệ thống đảm bảo tính chặt chẽ về dữ liệu: bắt buộc có tiêu đề, hạn chót rõ ràng và phân công đích danh người chịu trách nhiệm. Ngay sau khi em bấm Lưu, dữ liệu sẽ được đẩy lên MongoDB Cloud và thành viên được phân công sẽ nhận được thông báo tức thì."</em>
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 4 / 8</span>
    </div>
  </div>

  <!-- ==================== TRANG 5: CHI TIẾT & RBAC & AUDIT TRAIL ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">04</div> CHI TIẾT NHIỆM VỤ & PHÂN QUYỀN RBAC</div>
      <div class="doc-tag">Chi Tiết // Audit Trail</div>
    </div>

    <div style="display: grid; grid-template-columns: 0.9fr 0.9fr 1.2fr; gap: 14px; height: 100%;">
      <!-- Cột 1: Ảnh Detail Top -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgDetail}" alt="Chi tiết công việc phần trên">
        </div>
      </div>

      <!-- Cột 2: Ảnh Detail Bottom (Audit Trail) -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgDetailBottom}" alt="Lịch sử hoạt động Audit Trail">
        </div>
      </div>

      <!-- Cột 3: Nội dung phân tích -->
      <div>
        <h2>Cơ Chế Phân Quyền & Minh Bạch</h2>
        <p style="font-size: 12.5px; color: #444; margin-bottom: 10px;">
          Màn hình chi tiết là nơi diễn ra các hoạt động cộng tác hàng ngày, kiểm soát quyền hạn và lưu vết mọi thay đổi.
        </p>

        <div class="card card-yellow" style="padding: 11px;">
          <h3>🛡️ Phân Quyền Theo Vai Trò (RBAC)</h3>
          <ul class="bullet-list" style="margin-top: 4px; font-size: 12px;">
            <li><strong>Chủ sở hữu (Owner/Creator):</strong> Toàn quyền chỉnh sửa nội dung, thay đổi deadline, xóa task hoặc đổi người phụ trách.</li>
            <li><strong>Người thực hiện (Assignee):</strong> Có quyền bấm cập nhật trạng thái tiến độ (Chờ xử lý ➔ Đang làm ➔ Hoàn thành), không được sửa deadline nếu không được phân quyền.</li>
            <li><strong>Người theo dõi (Viewer):</strong> Chỉ xem thông tin, không thể sửa đổi trái phép dữ liệu.</li>
          </ul>
        </div>

        <div class="card card-blue" style="padding: 11px;">
          <h3>📜 Nhật Ký Hoạt Động (Audit Trail)</h3>
          <p style="font-size: 12px; color: #444; margin-bottom: 6px;">
            Mọi thao tác đều được hệ thống backend ghi log thời gian thực với định dạng Timeline chuẩn mực:
          </p>
          <ul class="bullet-list" style="font-size: 12px;">
            <li>Ai là người tạo nhiệm vụ lúc mấy giờ?</li>
            <li>Ai đã nhận việc và chuyển trạng thái sang "Đang làm"?</li>
            <li>Ai là người hoàn thành nhiệm vụ và thời điểm chốt?</li>
          </ul>
        </div>

        <div class="card card-green" style="padding: 11px; margin-bottom: 0;">
          <h3 style="color: #2B8A3E; font-size: 13px;">🎤 Gợi Ý Thuyết Trình Demo</h3>
          <p style="font-size: 11.5px; color: #444; margin-bottom: 0;">
            <em>"Điểm cốt lõi giúp hệ thống của em giải quyết bài toán mập mờ trách nhiệm là phần <strong>Lịch sử hoạt động</strong>. Bất kỳ ai đổi trạng thái hay cập nhật nội dung đều được hệ thống ghi nhận chính xác từng phút, giúp trưởng nhóm quản lý minh bạch 100%."</em>
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 5 / 8</span>
    </div>
  </div>

  <!-- ==================== TRANG 6: THỐNG KÊ KPI & XUẤT BÁO CÁO ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">05</div> THỐNG KÊ KPI & XUẤT BÁO CÁO TỔNG HỢP</div>
      <div class="doc-tag">Thống Kê // Executive Report</div>
    </div>

    <div style="display: grid; grid-template-columns: 0.9fr 0.9fr 1.2fr; gap: 14px; height: 100%;">
      <!-- Cột 1: Ảnh Stats -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgStats}" alt="Thống kê KPI công việc">
        </div>
      </div>

      <!-- Cột 2: Ảnh Export -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgExport}" alt="Xuất báo cáo tổng hợp">
        </div>
      </div>

      <!-- Cột 3: Nội dung phân tích -->
      <div>
        <h2>Đo Lường Hiệu Suất Tức Thì</h2>
        <p style="font-size: 12.5px; color: #444; margin-bottom: 10px;">
          Cung cấp góc nhìn toàn cảnh về năng suất làm việc của cá nhân và đội nhóm thông qua các chỉ số KPI trực quan.
        </p>

        <div class="card card-yellow" style="padding: 11px;">
          <h3>📊 Các Chỉ Số Đo Lường Chính (KPIs)</h3>
          <ul class="bullet-list" style="margin-top: 4px; font-size: 12px;">
            <li><strong>Tỷ lệ hoàn thành (%):</strong> Tính toán tự động theo thời gian thực dựa trên tổng số task đã chốt.</li>
            <li><strong>Cảnh báo Quá hạn (Overdue):</strong> Đánh dấu các công việc chưa xong nhưng đã quá deadline để kịp thời can thiệp.</li>
            <li><strong>Phân bổ trạng thái:</strong> Biểu đồ thanh trực quan thể hiện rõ khối lượng đang chờ, đang xử lý và đã xong.</li>
          </ul>
        </div>

        <div class="card card-orange" style="padding: 11px;">
          <h3>📄 Tính Năng Xuất Báo Cáo Tổng Hợp</h3>
          <p style="font-size: 12px; color: #444; margin-bottom: 6px;">
            Hỗ trợ người quản lý xuất dữ liệu báo cáo chuyên nghiệp chỉ với 1 thao tác:
          </p>
          <ul class="bullet-list" style="font-size: 12px;">
            <li>Tự động tổng hợp số liệu tổng quan, tỷ lệ hoàn thành, danh sách việc ưu tiên cao.</li>
            <li>Định dạng chuẩn để trình bày cho ban giám đốc hoặc lưu trữ hồ sơ dự án.</li>
          </ul>
        </div>

        <div class="card card-green" style="padding: 11px; margin-bottom: 0;">
          <h3 style="color: #2B8A3E; font-size: 13px;">🎤 Gợi Ý Thuyết Trình Demo</h3>
          <p style="font-size: 11.5px; color: #444; margin-bottom: 0;">
            <em>"Màn hình Thống kê giúp người quản trị không cần tính toán thủ công. Chỉ cần mở tab này, hệ thống sẽ tự động tổng hợp tỷ lệ hoàn thành, chỉ ra ngay bao nhiêu việc đang bị chậm tiến độ và cho phép bấm nút Xuất báo cáo để chia sẻ dữ liệu ngay lập tức."</em>
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 6 / 8</span>
    </div>
  </div>

  <!-- ==================== TRANG 7: THÔNG BÁO & BẢO MẬT OTP ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">06</div> THÔNG BÁO THÔNG MINH & BẢO MẬT TÀI KHOẢN</div>
      <div class="doc-tag">Thông Báo // Bảo Mật OTP</div>
    </div>

    <div style="display: grid; grid-template-columns: 0.9fr 0.9fr 1.2fr; gap: 14px; height: 100%;">
      <!-- Cột 1: Ảnh Notifications -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgNotif}" alt="Trung tâm thông báo">
        </div>
      </div>

      <!-- Cột 2: Ảnh Quên MK OTP -->
      <div class="phone-mockup">
        <div class="phone-screen">
          <img src="${imgOtp}" alt="Xác thực OTP Email an toàn">
        </div>
      </div>

      <!-- Cột 3: Nội dung phân tích -->
      <div>
        <h2>Hệ Thống Cảnh Báo & Bảo Mật</h2>
        <p style="font-size: 12.5px; color: #444; margin-bottom: 10px;">
          Đảm bảo người dùng không bao giờ bỏ lỡ nhiệm vụ quan trọng, đồng thời tài khoản được bảo vệ bằng cơ chế xác thực hai lớp qua Email.
        </p>

        <div class="card card-blue" style="padding: 11px;">
          <h3>🔔 Trung Tâm Thông Báo (Notification Hub)</h3>
          <ul class="bullet-list" style="margin-top: 4px; font-size: 12px;">
            <li><strong>Cảnh báo phân công mới:</strong> Nhận thông báo ngay khi được trưởng nhóm giao việc hoặc được thêm vào theo dõi.</li>
            <li><strong>Nhắc nhở hạn chót (Deadline Alert):</strong> Tự động kích hoạt khi công việc sắp đến hạn hoặc rơi vào trạng thái quá hạn.</li>
            <li><strong>Đánh dấu đã đọc:</strong> Badge số lượng thông báo chưa đọc cập nhật tự động.</li>
          </ul>
        </div>

        <div class="card card-yellow" style="padding: 11px;">
          <h3>🔐 Khôi Phục Mật Khẩu Qua Google SMTP OTP</h3>
          <ul class="bullet-list" style="margin-top: 4px; font-size: 12px;">
            <li><strong>Tích hợp Google Mail Server:</strong> Mã OTP 6 chữ số được gửi trực tiếp vào hòm thư Gmail của người dùng qua giao thức SMTP chuẩn.</li>
            <li><strong>Bảo mật thời hạn (Time-to-Live):</strong> Mã OTP chỉ có hiệu lực trong 5 phút và tự hủy sau khi sử dụng một lần.</li>
            <li><strong>Loại bỏ hoàn toàn mã thử nghiệm:</strong> Toàn bộ quy trình chạy thật 100%, không để lộ mã OTP trên giao diện máy khách.</li>
          </ul>
        </div>

        <div class="card card-green" style="padding: 11px; margin-bottom: 0;">
          <h3 style="color: #2B8A3E; font-size: 13px;">🎤 Gợi Ý Thuyết Trình Demo</h3>
          <p style="font-size: 11.5px; color: #444; margin-bottom: 0;">
            <em>"Về mặt an toàn thông tin, em xây dựng tính năng Quên mật khẩu qua OTP Email thật. Khi người dùng yêu cầu, máy chủ Node.js sẽ kết nối với Google SMTP gửi mã bí mật 6 số về hộp thư Gmail. Người dùng nhập đúng mã mới được đổi mật khẩu, đảm bảo an toàn tuyệt đối."</em>
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 7 / 8</span>
    </div>
  </div>

  <!-- ==================== TRANG 8: KỊCH BẢN DEMO & LỜI KẾT ==================== -->
  <div class="page">
    <div class="page-header">
      <div class="brand"><div class="brand-icon">07</div> KỊCH BẢN THUYẾT TRÌNH LIVE DEMO & LỜI KẾT</div>
      <div class="doc-tag">Kịch Bản Trình Chiếu // Demo Script</div>
    </div>

    <div>
      <div style="margin-bottom: 8px;">
        <h2>Kịch Bản Live Demo 6 Bước Dành Cho Buổi Báo Cáo</h2>
        <p style="font-size: 12px; color: #444;">
          Thực hiện tuần tự theo 6 bước dưới đây để bài báo cáo diễn ra mạch lạc, tự tin và phô diễn trọn vẹn giá trị sản phẩm trước hội đồng:
        </p>
      </div>

      <table>
        <thead>
          <tr>
            <th style="width: 12%;">Bước</th>
            <th style="width: 28%;">Thao tác trên ứng dụng</th>
            <th style="width: 42%;">Lời thuyết trình gợi ý</th>
            <th style="width: 18%;">Điểm nhấn ghi điểm</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Bước 1</strong><br><span class="badge badge-white" style="font-size: 10px;">Đăng nhập</span></td>
            <td>Mở app, đăng nhập tài khoản <code>dangkhoa15022006@gmail.com</code>.</td>
            <td><em>"Em xin phép bắt đầu buổi báo cáo với màn hình đăng nhập hệ thống. Ứng dụng hỗ trợ ghi nhớ phiên và khôi phục mật khẩu qua Google SMTP OTP."</em></td>
            <td>Đăng nhập tức thì, bảo mật token an toàn.</td>
          </tr>
          <tr>
            <td><strong>Bước 2</strong><br><span class="badge badge-yellow" style="font-size: 10px;">Lọc việc</span></td>
            <td>Tại màn hình chính, gõ từ khóa tìm kiếm và bấm thử các nút lọc trạng thái/ưu tiên.</td>
            <td><em>"Màn hình chính được thiết kế theo phong cách Soft Neo-Brutalism. Người dùng có thể lọc công việc theo 3 tầng hoặc gõ tìm kiếm với kết quả phản hồi tức thì."</em></td>
            <td>UI Soft Neo-Brutalism mượt mà, bộ lọc 3 tầng.</td>
          </tr>
          <tr>
            <td><strong>Bước 3</strong><br><span class="badge badge-blue" style="font-size: 10px;">Tạo task</span></td>
            <td>Bấm nút tròn (+) góc dưới, tạo task mới, chọn hạn chót và phân công người làm.</td>
            <td><em>"Em xin thao tác tạo nhanh một nhiệm vụ mới với đầy đủ tiêu đề, hạn chót và gán đích danh người phụ trách để minh bạch trách nhiệm."</em></td>
            <td>Validation chuẩn, phân bổ nguồn lực rõ ràng.</td>
          </tr>
          <tr>
            <td><strong>Bước 4</strong><br><span class="badge badge-orange" style="font-size: 10px;">Chi tiết</span></td>
            <td>Bấm vào một công việc, cuộn xem lịch sử hoạt động và bấm đổi trạng thái sang "Đang làm".</td>
            <td><em>"Ở màn hình chi tiết, hệ thống áp dụng phân quyền RBAC và ghi nhận mọi thay đổi vào Nhật ký hoạt động Audit Trail với mốc thời gian chính xác từng giây."</em></td>
            <td>Audit Trail lưu vết minh bạch, RBAC chuẩn.</td>
          </tr>
          <tr>
            <td><strong>Bước 5</strong><br><span class="badge badge-green" style="font-size: 10px;">Thống kê</span></td>
            <td>Bấm icon biểu đồ (Thống kê) trên thanh tiêu đề, bấm nút "Xuất báo cáo".</td>
            <td><em>"Kế tiếp là trung tâm đo lường KPI. Hệ thống tự động tính tỷ lệ hoàn thành, cảnh báo việc trễ hạn và cho phép xuất báo cáo tổng hợp chỉ với 1 chạm."</em></td>
            <td>Tự động hóa KPI, tính năng xuất báo cáo quản trị.</td>
          </tr>
          <tr>
            <td><strong>Bước 6</strong><br><span class="badge badge-white" style="font-size: 10px;">Thông báo</span></td>
            <td>Bấm icon chuông thông báo, điểm qua các tin nhắn nhắc việc và việc mới.</td>
            <td><em>"Cuối cùng là hệ thống thông báo thông minh giúp thành viên không bỏ sót nhiệm vụ, đồng bộ thời gian thực qua Cloud."</em></td>
            <td>Cảnh báo nhắc nhở thông minh, hoàn thiện trọn vẹn.</td>
          </tr>
        </tbody>
      </table>

      <div class="card card-yellow" style="margin-top: 10px; margin-bottom: 0; padding: 12px;">
        <h3 style="font-size: 13px; color: #2C2C2C;">Lời Kết & Cảm Ơn Hội Đồng Đánh Giá</h3>
        <p style="font-size: 12px; color: #444; margin-bottom: 0;">
          Ứng dụng <strong>Task Manager</strong> đã giải quyết trọn vẹn bài toán quản trị và phối hợp công việc thông qua kiến trúc công nghệ hiện đại, cơ chế phân quyền chặt chẽ và trải nghiệm người dùng Soft Neo-Brutalism trực quan. Em xin chân thành cảm ơn quý Thầy/Cô đã lắng nghe và kính mong nhận được những góp ý quý báu để tiếp tục hoàn thiện sản phẩm!
        </p>
      </div>
    </div>

    <div class="page-footer">
      <span>Task Manager Presentation Report</span>
      <span>Trang 8 / 8</span>
    </div>
  </div>

</body>
</html>
`;

const htmlPath = path.join('D:\\casestudy2', 'docs', 'report_presentation.html');
const pdfPath = path.join('D:\\casestudy2', 'Bao_Cao_Gioi_Thieu_Task_Manager.pdf');

fs.writeFileSync(htmlPath, htmlContent, 'utf8');
console.log('HTML written to:', htmlPath);

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const cmd = `"${edgePath}" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="${pdfPath}" "file:///${htmlPath.replace(/\\\\/g, '/')}"`;

console.log('Running PDF export command...');
execSync(cmd);
console.log('PDF generated at:', pdfPath);

if (fs.existsSync(pdfPath)) {
  const stats = fs.statSync(pdfPath);
  console.log('PDF File size:', stats.size, 'bytes');
}
