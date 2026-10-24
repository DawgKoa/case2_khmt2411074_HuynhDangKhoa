# CASE STUDY 2: ỨNG DỤNG QUẢN LÝ VÀ GIAO CÔNG VIỆC NHÓM
> **Đồ án môn học / Case Study:** Xây dựng ứng dụng di động và hệ thống backend quản lý công việc, phân công nhiệm vụ nhóm và theo dõi tiến độ thời gian thực.

---

## 👤 THÔNG TIN SINH VIÊN THỰC HIỆN
- **Họ và tên:** Huỳnh Đăng Khoa
- **Mã số sinh viên (MSSV):** KHMT2411074
- **Chuyên ngành:** Khoa học Máy tính (KHMT)
- **Repository GitHub:** [https://github.com/DawgKoa/casestudy2](https://github.com/DawgKoa/casestudy2)

---

## 🎨 THIẾT KẾ GIAO DIỆN: NIVORA BRUTALIST UI SYSTEM
Ứng dụng được thiết kế theo phong cách **Nivora Brutalist (Mobile Neo-Brutalism & Warm Retro-Industrial)** mang lại trải nghiệm thị giác mạnh mẽ, rõ ràng, dứt khoát và đậm chất công nghiệp:
- **Màu nền chủ đạo:** Giấy thô ấm (Warm Paper Cream) `#EFEDE0`.
- **Viền mực đậm:** Pure Black Ink `#050504` với độ dày `2.0px` trên tất cả các Card, Button, Input và Badge.
- **Đổ bóng cứng (Hard Cast Shadows):** Đổ bóng góc cạnh `Offset(3, 3)` và `Offset(4, 4)` với độ mờ bằng không (`blurRadius: 0`), kiên quyết loại bỏ hiệu ứng mờ nhòe mềm mại.
- **Màu điểm nhấn (Accent):** Vàng nghệ (Turmeric Yellow) `#F6B400` cho các nút bấm chính, tiến độ và thẻ nổi bật.
- **Màu cảnh báo & khẩn cấp (Danger):** Đỏ công nghiệp `#F61F01` cho hạn chót quá hạn, mức ưu tiên cao và thao tác xóa.
- **Kiến trúc Font chữ:**
  - **Tiêu đề & Con số lớn:** `Space Grotesk` (Đậm, dứt khoát, `FontWeight.w900`).
  - **Nhãn trạng thái, Mã & Mốc giờ:** `JetBrains Mono` (Monospace, Utilitarian, ALL CAPS).
  - **Nội dung văn bản & Form:** `Inter` (Dễ đọc, trực quan, `FontWeight.w500 - w600`).

---

## 🛠 CÔNG NGHỆ SỬ DỤNG (TECH STACK)

### 1. Frontend (Mobile App - Flutter)
- **Framework:** Flutter SDK (Dart 3.x).
- **Quản lý trạng thái:** Stateful Lifecycle & Reactive UI.
- **Mạng & Lưu trữ:** `package:http`, `shared_preferences` (Lưu trữ JWT & User Session).
- **Phông chữ & Định dạng:** `google_fonts` (Space Grotesk, JetBrains Mono, Inter), `intl` (Định dạng ngày giờ Việt Nam).

### 2. Backend (RESTful API - Node.js)
- **Runtime & Framework:** Node.js, Express.js.
- **Cơ sở dữ liệu:** MongoDB (với thư viện ODM `mongoose`).
- **Xác thực & Bảo mật:** JSON Web Token (`jsonwebtoken`), mã hóa mật khẩu 1 chiều (`bcryptjs`), CORS.
- **Dịch vụ Email & Nhắc nhở:** `nodemailer` với mẫu HTML Neo-Brutalist, Background Cron Job nhắc nhở hạn chót công việc.

---

## 📁 CẤU TRÚC DỰ ÁN

```
casestudy2/
├── README.md                           # Tài liệu tổng quan dự án
├── .gitignore                          # Quy tắc loại trừ tệp git
│
├── api/                                # BACKEND NODE.JS & EXPRESS REST API
│   ├── package.json                    # Cấu hình gói và dependencies backend
│   ├── .env                            # Biến môi trường (PORT, MONGO_URI, JWT_SECRET, EMAIL_...)
│   └── src/
│       ├── server.js                   # Điểm khởi chạy server và background reminder cron
│       ├── app.js                      # Cấu hình Express app, middleware và routes
│       ├── config/
│       │   ├── database.js             # Kết nối MongoDB
│       │   └── email.js                # Cấu hình Nodemailer transporter
│       ├── models/
│       │   ├── User.js                 # Schema Người dùng (fullName, email, passwordHash, avatar)
│       │   ├── Task.js                 # Schema Công việc (title, priority, status, dates, assignees, RBAC sharedWith)
│       │   └── Notification.js         # Schema Thông báo (userId, senderId, taskId, type, isRead)
│       ├── controllers/
│       │   ├── authController.js       # Xử lý Đăng ký, Đăng nhập, Profile, Đổi mật khẩu, Quên mật khẩu OTP
│       │   ├── taskController.js       # CRUD công việc, phân công, RBAC share, thống kê KPI
│       │   ├── userController.js       # Tìm kiếm cộng tác viên theo email / họ tên
│       │   └── notificationController.js # Lấy thông báo, đánh dấu đã đọc, xóa, trigger nhắc nhở
│       ├── routes/
│       │   ├── authRoutes.js           # Định tuyến /api/auth
│       │   ├── taskRoutes.js           # Định tuyến /api/tasks
│       │   ├── userRoutes.js           # Định tuyến /api/users
│       │   └── notificationRoutes.js   # Định tuyến /api/notifications
│       ├── middleware/
│       │   └── authMiddleware.js       # Xác thực JWT Bearer Token & phân quyền
│       ├── services/
│       │   ├── emailService.js         # Dịch vụ gửi email thông báo (Mẫu Brutalist HTML)
│       │   ├── notificationService.js  # Điều phối thông báo In-app và Email đa kênh
│       │   └── reminderService.js      # Tiến trình định kỳ quét và cảnh báo hạn chót
│       └── validators/
│           ├── authValidator.js        # Kiểm tra tính hợp lệ của dữ liệu người dùng
│           └── taskValidator.js        # Kiểm tra tính hợp lệ khi tạo và sửa công việc
│
└── TaskManager/                        # FRONTEND MOBILE APP (FLUTTER)
    ├── pubspec.yaml                    # Cấu hình dependencies Flutter
    └── lib/
        ├── main.dart                   # Điểm khởi chạy Flutter App & Routing
        ├── models/
        │   ├── user.dart               # Data model User
        │   ├── task.dart               # Data model Task & TaskShareMember
        │   ├── notification_model.dart # Data model AppNotification & TaskSummary
        │   └── task_stats.dart         # Data model KPI Summary, Status & Priority Breakdown
        ├── services/
        │   ├── api_client.dart         # HTTP Client tập trung (GET, POST, PUT, PATCH, DELETE)
        │   ├── auth_service.dart       # Quản lý phiên đăng nhập, JWT token, User API
        │   ├── task_service.dart       # Giao tiếp API công việc, lọc, phân công, phân quyền
        │   ├── user_service.dart       # Tìm kiếm người dùng hệ thống
        │   ├── notification_service.dart # Dịch vụ lấy và cập nhật trạng thái thông báo
        │   └── stats_service.dart      # Dịch vụ lấy báo cáo KPI và phân tích công việc
        ├── utils/
        │   ├── app_colors.dart         # Bảng màu Nivora Brutalist UI
        │   ├── app_theme.dart          # Cấu hình ThemeData chuẩn Neo-Brutalism
        │   ├── constants.dart          # Hằng số cấu hình hệ thống và API Base URL
        │   └── validators.dart         # Hàm kiểm tra regex email, độ dài mật khẩu
        ├── widgets/
        │   ├── brutalist_button.dart   # Nút bấm phẳng Neo-Brutalist với hiệu ứng nảy cứng
        │   ├── brutalist_card.dart     # Khung thẻ nền trắng/kem viền mực 2px kèm bóng đổ
        │   ├── brutalist_text_field.dart # Ô nhập liệu viền mực đậm, nhãn chữ kỹ thuật
        │   ├── brutalist_badge.dart    # Huy hiệu trạng thái và tag hệ thống
        │   ├── brutalist_task_card.dart# Thẻ công việc chi tiết với hạn chót và thành viên
        │   ├── brutalist_user_picker.dart # Hộp thoại tìm kiếm và chọn cộng tác viên
        │   ├── brutalist_share_modal.dart # Modal chia sẻ công việc và phân quyền RBAC
        │   ├── brutalist_manage_members_modal.dart # Quản lý vai trò và thu hồi quyền thành viên
        │   └── quick_status_bottom_sheet.dart # Menu trượt đổi trạng thái nhanh
        └── screens/
            ├── auth/
            │   ├── welcome_screen.dart # Màn hình chào đón lựa chọn Đăng nhập / Đăng ký
            │   ├── login_screen.dart   # Màn hình đăng nhập tài khoản
            │   ├── register_screen.dart# Màn hình đăng ký tài khoản mới
            │   └── forgot_password_screen.dart # Quên mật khẩu & xác thực OTP qua email
            ├── profile/
            │   └── profile_screen.dart # Hồ sơ cá nhân & đổi mật khẩu tài khoản
            ├── tasks/
            │   ├── task_list_screen.dart   # Màn hình danh sách công việc chính, tìm kiếm, lọc
            │   ├── task_create_screen.dart # Tạo mới công việc kèm người phụ trách & tham gia
            │   ├── task_detail_screen.dart # Xem chi tiết, lịch sử thời gian, hạn chót, xóa
            │   └── task_edit_screen.dart   # Chỉnh sửa toàn diện nội dung công việc
            ├── notifications/
            │   └── notification_screen.dart# Trung tâm thông báo In-app (Tất cả / Chưa đọc)
            └── stats/
                └── statistics_screen.dart  # Bảng điều khiển KPI, biểu đồ tiến độ & xuất báo cáo
```

---

## 📋 CHECKLIST CHỨC NĂNG ĐÃ TRIỂN KHAI HOÀN THIỆN

### 🟢 GIAI ĐOẠN 1: MODULE A - XÁC THỰC VÀ QUẢN LÝ TÀI KHOẢN (Branch `feature/auth`)
- [x] **A1: Đăng ký tài khoản:** Xác thực họ tên, email hợp lệ, mật khẩu tối thiểu 6 ký tự, mã hóa bcrypt an toàn.
- [x] **A2: Đăng nhập & Lưu JWT Token:** Cấp JWT token thời hạn dài, tự động lưu trữ bảo mật với `SharedPreferences`, tự động điều hướng khi mở app.
- [x] **UX: Màn hình Chào (Welcome Screen):** Giao diện định danh đồ án với lựa chọn Đăng nhập / Đăng ký trực quan.
- [x] **A3: Xem thông tin tài khoản (Profile):** Hiển thị avatar đại diện, họ tên, email, ngày gia nhập hệ thống.
- [x] **A4: Đổi mật khẩu:** Kiểm tra mật khẩu hiện tại, cập nhật mật khẩu mới có xác nhận.
- [x] **Quên mật khẩu & Xác thực OTP qua Email:** Tạo mã OTP ngẫu nhiên 6 chữ số có thời hạn 15 phút, gửi email tự động và xác thực đặt lại mật khẩu mới.

### 🟢 GIAI ĐOẠN 2: MODULE B - QUẢN LÝ CÔNG VIỆC CƠ BẢN (Branch `feature/task-management`)
- [x] **B1: Tạo mới công việc:** Nhập tiêu đề, mô tả chi tiết, ngày bắt đầu, hạn chót hoàn thành, mức độ ưu tiên (Thấp, Trung bình, Cao).
- [x] **B2: Danh sách công việc:** Hiển thị dạng thẻ Brutalist Card sắc nét, hỗ trợ kéo xuống để làm mới (Pull-to-refresh).
- [x] **B3: Xem chi tiết công việc:** Xem đầy đủ thông tin, thời gian tạo, cập nhật, hạn chót, cảnh báo trễ hạn.
- [x] **B4: Cập nhật & Đổi trạng thái nhanh:** Menu trượt Bottom Sheet đổi trạng thái tức thì giữa `TODO`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`.
- [x] **B5: Xóa công việc:** Hộp thoại xác nhận phong cách Neo-Brutalist, kiểm tra phân quyền người tạo/quản trị trước khi xóa.
- [x] **B6: Tìm kiếm, Lọc và Sắp xếp:** Thanh tìm kiếm tức thời theo từ khóa tiêu đề/mô tả; chip lọc theo trạng thái, mức ưu tiên; sắp xếp theo ngày tạo, hạn chót, mức ưu tiên.

### 🟢 GIAI ĐOẠN 3: MODULE C - PHÂN CÔNG & CHIA SẺ VỚI PHÂN QUYỀN RBAC (Branch `feature/task-assignment-sharing`)
- [x] **C1: Tìm kiếm người dùng:** Tìm kiếm nhanh theo email hoặc họ tên qua modal `BrutalistUserPicker`.
- [x] **C2: Phân công người thực hiện chính & người tham gia:** Chỉ định 1 người chịu trách nhiệm chính (`primaryAssigneeId`) và nhiều thành viên cùng tham gia (`assigneeIds`).
- [x] **C3: Chia sẻ công việc & Phân quyền RBAC:** Phân cấp 3 vai trò rõ rệt:
  - `Viewer` (Người xem): Chỉ có quyền đọc thông tin, không sửa hay đổi trạng thái.
  - `Editor` (Người chỉnh sửa): Có quyền cập nhật tiến độ, nội dung công việc.
  - `Admin` (Quản trị viên): Toàn quyền thêm bớt thành viên, chia sẻ quyền và xóa công việc.
- [x] **C4: Quản lý thành viên & Thu hồi quyền:** Modal `BrutalistManageMembersModal` cho phép đổi vai trò hoặc thu hồi quyền truy cập của bất kỳ thành viên nào.
- [x] **C5: Phân loại phạm vi công việc (Scope Tabs):** Lọc theo 4 phạm vi: *Tất cả*, *Tôi tạo*, *Giao cho tôi*, *Được chia sẻ*.

### 🟢 GIAI ĐOẠN 4: MODULE D - THÔNG BÁO VÀ NHẮC NHỞ EMAIL (Branch `feature/notification-email`)
- [x] **D1: Hệ thống Thông báo In-App (Model & APIs):** Lưu trữ thông báo trong CSDL MongoDB, hỗ trợ đánh dấu đã đọc từng thông báo hoặc toàn bộ, đếm số lượng chưa đọc.
- [x] **D2: Màn hình Trung tâm Thông báo (Notification Center):**
  - Biểu tượng chuông thông báo trên thanh tiêu đề kèm huy hiệu số lượng chưa đọc.
  - Giao diện danh sách thông báo phong cách Brutalist với nhãn phân loại: `PHÂN CÔNG`, `CHIA SẺ`, `TRẠNG THÁI`, `HẠN CHÓT`.
  - Bấm vào thông báo tự động mở chi tiết công việc liên quan.
- [x] **D3: Gửi Email Thông báo Tự động (Automated Email Notifications):** Tự động gửi email qua Nodemailer với định dạng HTML phong cách Neo-Brutalist khi:
  - Được phân công vào công việc mới.
  - Được chia sẻ quyền truy cập công việc.
  - Trạng thái công việc có sự thay đổi.
- [x] **D4: Tự động Nhắc nhở Hạn chót (Deadline Reminder Job):**
  - Tiến trình nền chạy định kỳ quét các công việc sắp hết hạn trong 24 giờ tới hoặc đã quá hạn mà chưa hoàn thành.
  - Gửi cả thông báo In-app lẫn Email cảnh báo đến người phụ trách và thành viên.
  - Cơ chế chống gửi lặp lại trong vòng 12 giờ.
  - Cung cấp endpoint `POST /api/notifications/reminders/trigger` kích hoạt quét tức thời cho việc kiểm thử và chấm điểm.

### 🟢 GIAI ĐOẠN 5: MODULE E - THỐNG KÊ, BÁO CÁO & TIỆN ÍCH (Branch `feature/statistics-utility`)
- [x] **E1: API Thống kê Công việc & Hiệu suất:** Endpoint `GET /api/tasks/stats/summary` tính toán tổng số việc, tỷ lệ hoàn thành (%), tỷ lệ đúng hạn, phân bổ theo trạng thái và mức độ ưu tiên.
- [x] **E2: Màn hình Dashboard Thống kê & Báo cáo:** Màn hình `StatisticsScreen` hiển thị các thẻ KPI trực quan, thanh tiến độ tỷ lệ hoàn thành dạng biểu đồ thanh ngang, phân bổ mức ưu tiên và trạng thái hạn chót.
- [x] **E3: Thống kê Hiệu suất Cá nhân & Cộng tác Nhóm:**
  - Bảng xếp hạng khối lượng công việc từng thành viên trong nhóm.
  - Modal chi tiết hiệu suất thành viên khi chạm: Tổng việc được giao, việc đã xong, việc quá hạn, xếp loại phong độ (`XUẤT SẮC`, `ĐẠT TIẾN ĐỘ`, `CẦN ĐẨY NHANH`).
- [x] **E4: Tiện ích Lọc theo Thời gian & Xuất Báo cáo Tóm tắt:**
  - Lọc số liệu thống kê linh hoạt: *Tất cả*, *Hôm nay*, *7 ngày qua*, *Tháng này*.
  - Tiện ích **Xuất báo cáo tổng hợp** tự động tạo bản tóm tắt định dạng văn bản có cấu trúc chuẩn, hỗ trợ sao chép vào bộ nhớ tạm (Clipboard) chỉ với một chạm.

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY DỰ ÁN

### 1. Yêu cầu môi trường
- **Node.js:** Phiên bản `>= 18.x` (Đã kiểm thử trên Node v24).
- **MongoDB:** MongoDB Community Server đang chạy trên `mongodb://127.0.0.1:27017` (hoặc MongoDB Atlas).
- **Flutter SDK:** Phiên bản `>= 3.13.x` (Khuyên dùng Flutter 3.29.x).

---

### 2. Khởi chạy Backend (Node.js API)

1. Mở terminal và di chuyển vào thư mục `api/`:
   ```bash
   cd casestudy2/api
   ```
2. Cài đặt các gói phụ thuộc:
   ```bash
   npm install
   ```
3. Cấu hình tệp môi trường `.env`:
   ```env
   PORT=5000
   NODE_ENV=development
   MONGO_URI=mongodb://127.0.0.1:27017/task_manager_db
   JWT_SECRET=super_secret_jwt_key_task_manager_2026
   JWT_EXPIRE=30d
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASS=your_app_password
   EMAIL_FROM="Task Manager App" <noreply@taskmanager.com>
   ```
4. Khởi chạy server API:
   ```bash
   npm start
   # Hoặc chạy chế độ phát triển:
   npm run dev
   ```
   > Máy chủ sẽ hoạt động tại địa chỉ: `http://localhost:5000`

---

### 3. Khởi chạy Ứng dụng Di động (Flutter App)

1. Mở terminal và di chuyển vào thư mục `TaskManager/`:
   ```bash
   cd casestudy2/TaskManager
   ```
2. Tải các dependencies Flutter:
   ```bash
   flutter pub get
   ```
3. Cấu hình IP máy chủ tại `lib/utils/constants.dart`:
   - Nếu chạy trên **Android Emulator**: sử dụng `http://10.0.2.2:5000/api`.
   - Nếu chạy trên **Thiết bị thật / Windows Desktop / Web**: sử dụng `http://localhost:5000/api` hoặc địa chỉ IP LAN máy tính của bạn (VD: `http://192.168.1.x:5000/api`).
4. Kiểm tra mã nguồn với công cụ phân tích tĩnh:
   ```bash
   flutter analyze
   ```
5. Chạy ứng dụng trên thiết bị / máy ảo mong muốn:
   ```bash
   flutter run
   ```

---

## 📡 DANH SÁCH RESTful API ENDPOINTS

| Phương thức | Đường dẫn API | Mô tả chức năng | Yêu cầu JWT |
| :--- | :--- | :--- | :---: |
| **POST** | `/api/auth/register` | Đăng ký tài khoản mới bằng họ tên, email, mật khẩu | ❌ |
| **POST** | `/api/auth/login` | Đăng nhập tài khoản & nhận JWT token | ❌ |
| **GET** | `/api/auth/profile` | Lấy thông tin hồ sơ người dùng hiện tại | ✅ |
| **PUT** | `/api/auth/profile` | Cập nhật họ tên, avatar người dùng | ✅ |
| **PUT** | `/api/auth/change-password` | Đổi mật khẩu tài khoản | ✅ |
| **POST** | `/api/auth/forgot-password` | Yêu cầu gửi mã OTP đặt lại mật khẩu qua email | ❌ |
| **POST** | `/api/auth/reset-password` | Đặt lại mật khẩu mới bằng mã OTP xác thực | ❌ |
| **GET** | `/api/users/search` | Tìm kiếm người dùng theo email hoặc họ tên | ✅ |
| **GET** | `/api/tasks` | Lấy danh sách công việc (hỗ trợ search, filter, sort, scope) | ✅ |
| **POST** | `/api/tasks` | Tạo mới công việc (assignees, dates, priority) | ✅ |
| **GET** | `/api/tasks/stats/summary` | Lấy số liệu thống kê KPI, biểu đồ tiến độ & hiệu suất | ✅ |
| **GET** | `/api/tasks/:id` | Xem thông tin chi tiết một công việc | ✅ |
| **PUT** | `/api/tasks/:id` | Cập nhật thông tin công việc | ✅ |
| **PATCH** | `/api/tasks/:id/status` | Đổi trạng thái nhanh công việc (`todo`, `in_progress`, ...) | ✅ |
| **DELETE** | `/api/tasks/:id` | Xóa công việc (yêu cầu quyền Creator hoặc Admin) | ✅ |
| **PUT** | `/api/tasks/:id/assign` | Phân công người thực hiện chính & danh sách tham gia | ✅ |
| **POST** | `/api/tasks/:id/share` | Chia sẻ công việc và phân quyền RBAC (`viewer`, `editor`, `admin`) | ✅ |
| **PATCH** | `/api/tasks/:id/members/:memberId`| Cập nhật vai trò thành viên trong công việc | ✅ |
| **DELETE** | `/api/tasks/:id/members/:memberId`| Thu hồi quyền truy cập / Xóa thành viên khỏi công việc | ✅ |
| **GET** | `/api/notifications` | Lấy danh sách thông báo In-app (kèm số lượng chưa đọc) | ✅ |
| **PATCH** | `/api/notifications/:id/read` | Đánh dấu 1 thông báo là đã đọc | ✅ |
| **PATCH** | `/api/notifications/read-all` | Đánh dấu tất cả thông báo là đã đọc | ✅ |
| **DELETE** | `/api/notifications/:id` | Xóa một thông báo | ✅ |
| **POST** | `/api/notifications/reminders/trigger` | Kích hoạt quét và gửi nhắc nhở hạn chót tức thời | ✅ |

---

## 🌿 LỊCH SỬ NHÁNH & QUY TRÌNH PHÁT TRIỂN
Dự án tuân thủ nghiêm ngặt quy trình phát triển tính năng theo nhánh chuyên biệt:
- `main`: Nhánh production ổn định, tích hợp tất cả các module đã hoàn thiện và kiểm thử.
- `feature/auth`: Nhánh phát triển Giai đoạn 1 (Module A - Xác thực tài khoản & Profile).
- `feature/task-management`: Nhánh phát triển Giai đoạn 2 (Module B - Quản lý công việc cơ bản).
- `feature/task-assignment-sharing`: Nhánh phát triển Giai đoạn 3 (Module C - Phân công & Phân quyền RBAC).
- `feature/notification-email`: Nhánh phát triển Giai đoạn 4 (Module D - Thông báo & Nhắc nhở Email).
- `feature/statistics-utility`: Nhánh phát triển Giai đoạn 5 (Module E - Thống kê, Báo cáo & Tiện ích).

---
*Bản quyền đồ án © 2026 Huỳnh Đăng Khoa - MSSV: KHMT2411074. Trường Đại học - Khoa học Máy tính.*
