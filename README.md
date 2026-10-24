# Flutter Isolate Demo — So sánh Main Isolate và `compute()`

Ứng dụng Flutter minh họa tác động của tác vụ tính toán nặng đến độ mượt của giao diện, đồng thời so sánh hai cách thực hiện cùng một phép tính.

## Yêu cầu trước khi chạy

Cần cài đặt:

1. **Flutter SDK và Dart SDK** (Dart đã đi kèm Flutter).
2. **Git** nếu muốn tải mã nguồn bằng Git.
3. **Visual Studio trên Windows**, có workload **Desktop development with C++**, để biên dịch và chạy ứng dụng Windows desktop. VS Code chỉ là trình soạn thảo và không thay thế workload này.

Kiểm tra môi trường bằng PowerShell hoặc terminal:

```powershell
flutter --version
flutter doctor
```

Nếu `flutter doctor` báo thiếu công cụ dành cho Windows desktop, hãy cài workload **Desktop development with C++** trong Visual Studio Installer, sau đó mở lại terminal và chạy `flutter doctor` lần nữa.

## Tải mã nguồn

Repository GitHub: [https://github.com/w2303/isolate-compute](https://github.com/w2303/isolate-compute)

Có thể tải mã nguồn bằng Git:

```powershell
git clone https://github.com/w2303/isolate-compute.git
cd isolate-compute
```

Hoặc vào repository trên GitHub, chọn **Code → Download ZIP**, rồi giải nén dự án.

> Các lệnh tiếp theo cần được thực hiện tại thư mục gốc của dự án — thư mục có tệp `pubspec.yaml`.

## Cài đặt dependencies

Tại thư mục dự án, chạy:

```powershell
flutter pub get
```

Lệnh này tải và giải quyết các package mà dự án khai báo trong `pubspec.yaml`.

## Chạy ứng dụng

Chạy ứng dụng trên Windows desktop:

```powershell
flutter run -d windows
```

Nếu Flutter chưa bật hỗ trợ Windows desktop, chạy:

```powershell
flutter config --enable-windows-desktop
flutter doctor
```

Sau đó kiểm tra lại yêu cầu cài đặt Visual Studio và workload **Desktop development with C++**, rồi chạy lại:

```powershell
flutter devices
flutter run -d windows
```

## Cấu trúc thư mục quan trọng

```text
isolate-compute/
├── lib/
│   └── main.dart              # Giao diện và logic demo Isolate / compute()
├── test/                      # Vị trí dành cho các bài kiểm thử
├── windows/                   # Cấu hình ứng dụng Windows desktop
├── android/                   # Cấu hình ứng dụng Android
├── web/                       # Cấu hình ứng dụng web
├── pubspec.yaml               # Khai báo package và cấu hình Flutter
├── pubspec.lock               # Phiên bản package đã được giải quyết
├── analysis_options.yaml       # Quy tắc phân tích mã Dart
└── README.md                  # Tài liệu dự án
```

Các thư mục nền tảng `ios/`, `linux/` và `macos/` cũng được tạo trong dự án Flutter.
