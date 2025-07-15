# Deploy script for Language Learning App (Windows PowerShell)
# Khắc phục các lỗi Firebase và rebuild ứng dụng

Write-Host "🚀 Bắt đầu quá trình deploy và fix bugs..." -ForegroundColor Green

# 1. Deploy Firestore Rules
Write-Host "📋 Deploying Firestore security rules..." -ForegroundColor Yellow
firebase deploy --only firestore:rules

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Firestore rules deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy Firestore rules!" -ForegroundColor Red
    exit 1
}

# 2. Clean and rebuild Flutter app
Write-Host "🧹 Cleaning Flutter project..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# 3. Build for Android
Write-Host "🔨 Building Android APK..." -ForegroundColor Yellow
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Android build successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Android build failed!" -ForegroundColor Red
    exit 1
}

# 4. Summary
Write-Host ""
Write-Host "🎯 Lỗi đã được khắc phục!" -ForegroundColor Green
Write-Host ""
Write-Host "Các thay đổi:" -ForegroundColor Cyan
Write-Host "✅ Firestore security rules updated" -ForegroundColor Green
Write-Host "✅ Android manifest fixed (enableOnBackInvokedCallback)" -ForegroundColor Green
Write-Host "✅ AuthService uses consistent userProgress collection" -ForegroundColor Green
Write-Host "✅ App rebuilt successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Để chạy app:" -ForegroundColor Yellow
Write-Host "flutter run" -ForegroundColor White

# Optional: Run the app if -Run flag is provided
param([switch]$Run)

if ($Run) {
    Write-Host "🏃 Starting the app..." -ForegroundColor Yellow
    flutter run
} 