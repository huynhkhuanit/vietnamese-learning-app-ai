# 🔧 HƯỚNG DẪN SETUP DỰ ÁN

## Yêu cầu hệ thống

- **Flutter SDK**: >= 3.0.0
- **Dart SDK**: >= 3.0.0
- **Android Studio** hoặc **VS Code**
- **Xcode** (cho iOS - chỉ trên macOS)
- **Git**

## Bước 1: Clone và setup dự án

```bash
git clone [YOUR_REPO_URL]
cd vietnamese-language-learning-app
flutter pub get
```

## Bước 2: Cấu hình Firebase

### 2.1 Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới với tên: `vietnamese-learning-app`
3. Enable Google Analytics (tùy chọn)

### 2.2 Thêm Android App
1. Click "Add app" → chọn Android
2. Package name: `com.hungvuong.vietnamese_learning_app`
3. Download `google-services.json`
4. Copy vào: `android/app/google-services.json`

### 2.3 Thêm iOS App
1. Click "Add app" → chọn iOS  
2. Bundle ID: `com.hungvuong.vietnameseLearningApp`
3. Download `GoogleService-Info.plist`
4. Copy vào: `ios/Runner/GoogleService-Info.plist`

### 2.4 Enable Firebase Services
1. **Authentication**: Enable Email/Password, Google, Facebook, Apple
2. **Firestore Database**: Create database (Start in test mode)
3. **Storage**: Create default bucket

### 2.5 Cập nhật Firebase Options
1. Copy `lib/firebase_options.dart.template` thành `lib/firebase_options.dart`
2. Thay thế các giá trị `YOUR_*` bằng thông tin từ Firebase Console

## Bước 3: Cấu hình AI API

### 3.1 OpenAI Setup (Recommended)
1. Đăng ký tại [OpenAI Platform](https://platform.openai.com/)
2. Tạo API key tại [API Keys](https://platform.openai.com/api-keys)
3. Copy `lib/config/api_config.dart.template` thành `lib/config/api_config.dart`
4. Thay thế `YOUR_OPENAI_API_KEY_HERE` bằng API key thực

### 3.2 Google Gemini Setup (Alternative)
1. Truy cập [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Tạo API key
3. Thay thế `YOUR_GEMINI_API_KEY_HERE` bằng API key thực

## Bước 4: Chạy ứng dụng

```bash
# Kiểm tra devices
flutter devices

# Chạy trên Android
flutter run

# Chạy trên iOS (chỉ macOS)
flutter run -d ios

# Chạy debug mode
flutter run --debug

# Chạy release mode  
flutter run --release
```

## Bước 5: Build APK (Production)

```bash
# Clean project
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# APK sẽ được tạo tại: build/app/outputs/flutter-apk/app-release.apk
```

## Bước 6: Test các chức năng

### 6.1 Test Authentication
- Đăng ký tài khoản mới
- Đăng nhập với email/password
- Test Google/Facebook sign-in

### 6.2 Test AI Chatbot
- Mở chatbot screen
- Gửi tin nhắn test
- Kiểm tra response từ AI

### 6.3 Test Pronunciation
- Mở pronunciation screen
- Test record audio
- Test text-to-speech

## Troubleshooting

### Lỗi Firebase
```bash
# Nếu gặp lỗi Firebase
flutter clean
cd ios && pod install && cd ..
flutter pub get
```

### Lỗi API
- Kiểm tra API key đã đúng format
- Kiểm tra quota API còn đủ
- Kiểm tra network connection

### Lỗi Build
```bash  
# Android build issues
cd android && ./gradlew clean && cd ..

# iOS build issues (macOS only)
cd ios && pod deintegrate && pod install && cd ..
```

## Support

- **Email**: support@hungvuong.edu.vn
- **Documentation**: [Flutter Docs](https://flutter.dev/docs)
- **Firebase Docs**: [Firebase Flutter](https://firebase.flutter.dev/)

---
**Trường Đại học Hùng Vương - TP. Hồ Chí Minh**  
*Đồ án cơ sở - Ngành Công nghệ Thông tin* 