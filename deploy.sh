#!/bin/bash

# Deploy script for Language Learning App
# Khắc phục các lỗi Firebase và rebuild ứng dụng

echo "🚀 Bắt đầu quá trình deploy và fix bugs..."

# 1. Deploy Firestore Rules
echo "📋 Deploying Firestore security rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo "✅ Firestore rules deployed successfully!"
else
    echo "❌ Failed to deploy Firestore rules!"
    exit 1
fi

# 2. Clean and rebuild Flutter app
echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# 3. Build for Android
echo "🔨 Building Android APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Android build successful!"
else
    echo "❌ Android build failed!"
    exit 1
fi

# 4. Run the app (optional)
echo "🎯 Lỗi đã được khắc phục!"
echo ""
echo "Các thay đổi:"
echo "✅ Firestore security rules updated"
echo "✅ Android manifest fixed (enableOnBackInvokedCallback)"
echo "✅ AuthService uses consistent userProgress collection"
echo "✅ App rebuilt successfully"
echo ""
echo "Để chạy app:"
echo "flutter run"

# Optional: Run the app if --run flag is provided
if [ "$1" = "--run" ]; then
    echo "🏃 Starting the app..."
    flutter run
fi 