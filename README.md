# CASE STUDY 2: ỨNG DỤNG QUẢN LÝ VÀ GIAO CÔNG VIỆC NHÓM

## 👤 Thông tin sinh viên
- **Họ và tên:** Huỳnh Đăng Khoa
- **Mã số sinh viên (MSSV):** KHMT2411074
- **Repository GitHub:** [https://github.com/DawgKoa/casestudy2](https://github.com/DawgKoa/casestudy2)

---

## 🛠 Công nghệ sử dụng
- **Frontend:** Flutter (`TaskManager`)
- **Backend:** Node.js, Express REST API (`api`)
- **Database:** MongoDB
- **Notification:** Email (Nodemailer) & In-App Notification

---

## 📁 Cấu trúc dự án
```
casestudy2/
├── README.md
├── .gitignore
├── api/                  # Node.js Express REST API backend
└── TaskManager/          # Flutter Mobile/Web frontend
```

---

## 📋 Danh sách chức năng triển khai
- [ ] **Nhánh `feature/auth`**: Quản lý tài khoản và xác thực (Đăng ký, Đăng nhập JWT, Profile, Đổi mật khẩu, Đăng xuất)
- [ ] **Nhánh `feature/task-management`**: Quản lý công việc (CRUD công việc, Trạng thái, Ưu tiên, Hạn chót, Lọc & Sắp xếp)
- [ ] **Nhánh `feature/task-assignment-sharing`**: Giao việc & Phân quyền chia sẻ (Viewer / Editor, Giao việc nhiều người)
- [ ] **Nhánh `feature/notification-email`**: Thông báo trong ứng dụng & Gửi email tự động qua Nodemailer
- [ ] **Nhánh `feature/statistics-utility`**: Thống kê số liệu, Lịch sử hoạt động và tiện ích
