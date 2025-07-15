# 🇻🇳 Việt Ngữ Thông Minh - Smart Vietnamese Learning App

<div align="center">

![Vietnamese Learning](https://img.shields.io/badge/Vietnamese-Learning-red?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![AI Powered](https://img.shields.io/badge/AI-Powered-green?style=for-the-badge)

**Ứng dụng học tiếng Việt thông minh tích hợp trí tuệ nhân tạo**

*Đồ án cơ sở - Trường Đại học Hùng Vương TP. Hồ Chí Minh*

</div>

---

## 📋 Thông tin đồ án

- **Tên đồ án**: Ứng dụng học ngôn ngữ tiếng Việt tích hợp AI
- **Sinh viên thực hiện**: [Huỳnh Văn Khuân]
- **MSSV**: [2205CT0035]
- **Lớp**: [CT06PM]
- **Khoa**: Kỹ Thuật Công Nghệ
- **Trường**: Đại học Hùng Vương TP. Hồ Chí Minh
- **Năm học**: 2024-2025

## 🎯 Mục tiêu dự án

Xây dựng ứng dụng di động hỗ trợ học tiếng Việt cho người nước ngoài với các tính năng:
- Tích hợp AI chatbot để luyện tập hội thoại
- Hệ thống phát âm và nhận dạng giọng nói
- Theo dõi tiến độ học tập thông minh
- Giao diện thân thiện, dễ sử dụng

## ✨ Tính năng chính

### 🔐 Xác thực người dùng
- Đăng ký/Đăng nhập bằng email
- Đăng nhập xã hội (Google, Facebook, Apple)
- Quản lý hồ sơ cá nhân
- Bảo mật thông tin người dùng

### 📚 Học tập thông minh
- **Bài học tương tác**: Học từ vựng, ngữ pháp theo chủ đề
- **Luyện phát âm**: Nhận dạng giọng nói và feedback AI
- **Chatbot AI**: Luyện tập hội thoại thực tế
- **Hệ thống XP**: Tích điểm và cấp độ
- **Streak**: Theo dõi chuỗi ngày học liên tiếp

### 🤖 Tích hợp AI
- **OpenAI GPT**: Chatbot thông minh cho hội thoại
- **Google Gemini**: AI assistant hỗ trợ học tập
- **Text-to-Speech**: Phát âm chuẩn tiếng Việt
- **Speech-to-Text**: Nhận dạng giọng nói

### 🎨 Giao diện & Trải nghiệm
- Material Design 3
- Dark/Light mode
- Hoạt ảnh mượt mà
- Responsive design
- Hỗ trợ đa ngôn ngữ

## 🛠️ Công nghệ sử dụng

### Frontend
- **Flutter 3.x**: Framework đa nền tảng
- **Dart**: Ngôn ngữ lập trình
- **Provider/Riverpod**: Quản lý state
- **Material Design 3**: UI framework

### Backend & Services  
- **Firebase Auth**: Xác thực người dùng
- **Cloud Firestore**: Cơ sở dữ liệu NoSQL
- **Firebase Storage**: Lưu trữ file media
- **OpenAI API**: GPT cho chatbot
- **Google Gemini API**: AI assistance

### Dependencies chính
```yaml
dependencies:
  flutter: sdk
  firebase_core: ^3.14.0
  firebase_auth: ^5.6.0  
  cloud_firestore: ^5.6.9
  provider: ^6.1.1
  flutter_tts: ^4.2.3
  speech_to_text: ^7.0.0
  http: ^1.1.0
  lottie: ^3.3.1
```

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                    # Entry point
├── firebase_options.dart        # Firebase config
├── config/
│   └── api_config.dart         # API configurations
├── models/                     # Data models
│   ├── user_model.dart
│   ├── achievement.dart
│   └── learning_goal.dart
├── screens/                    # UI screens
│   ├── auth/                   # Authentication
│   ├── dashboard_screen.dart   # Main dashboard
│   ├── chatbot_screen.dart     # AI chatbot
│   ├── pronunciation_screen.dart
│   └── lesson_screen.dart
├── services/                   # Business logic
│   ├── auth_service.dart
│   ├── ai_chat_service.dart
│   ├── firebase_service.dart
│   └── xp_service.dart
├── widgets/                    # Reusable components
└── utils/                      # Utilities
```

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0  
- Android Studio hoặc VS Code
- Git

### Cài đặt nhanh
```bash
# Clone repository
git clone https://github.com/[username]/vietnamese-language-learning-app.git
cd vietnamese-language-learning-app

# Install dependencies  
flutter pub get

# Run app
flutter run
```

**📖 Xem [SETUP.md](SETUP.md) để hướng dẫn setup chi tiết**

## 📱 Screenshots

<!-- Thêm screenshots của app ở đây -->
| Dashboard | Chatbot | Pronunciation | Lessons |
|-----------|---------|---------------|---------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Chatbot](assets/screenshots/chatbot.png) | ![Pronunciation](assets/screenshots/pronunciation.png) | ![Lessons](assets/screenshots/lessons.png) |

## 🏗️ Build APK

```bash
# Build production APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 📊 Tính năng nổi bật

### 🎯 Hệ thống học tập thông minh
- Phân tích tiến độ người dùng
- Đề xuất bài học phù hợp  
- Hệ thống nhắc nhở thông minh

### 🤖 AI Chatbot tiên tiến
- Hỗ trợ đa ngữ cảnh (mua sắm, nhà hàng, công việc...)
- Phản hồi thông minh và tự nhiên
- Học từ lịch sử hội thoại

### 📈 Gamification
- Hệ thống điểm XP và cấp độ
- Thành tựu và huy hiệu
- Bảng xếp hạng

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests  
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📝 Báo cáo đồ án

Dự án bao gồm các tài liệu báo cáo:
- **Thuyết minh đồ án** (PDF)
- **Slide thuyết trình** (PowerPoint)
- **Video demo** ứng dụng
- **Source code** đầy đủ

## 🤝 Contributing

Đây là đồ án cơ sở cá nhân. Mọi góp ý và đề xuất xin gửi qua:
- Email: [email@student.hungvuong.edu.vn]
- Issues: [GitHub Issues](../../issues)

## 📄 License

```
MIT License - Dự án được phát triển cho mục đích học tập
Copyright (c) 2024 [Tên sinh viên] - Trường ĐH Hùng Vương
```

## 🙏 Lời cảm ơn

- **Thầy/Cô hướng dẫn**: [TS. Nguyễn Văn Dũng]
- **Khoa Công nghệ Thông tin** - Trường ĐH Hùng Vương
- **Flutter Community** và **Firebase Team**
- **OpenAI** và **Google AI** cho API services

---

<div align="center">

**🏫 TRƯỜNG ĐẠI HỌC HÙNG VƯƠNG TP. HỒ CHÍ MINH**

*Khoa Công nghệ Thông tin - Đồ án cơ sở*

**⭐ Nếu dự án hữu ích, hãy cho một Star! ⭐**

</div>
