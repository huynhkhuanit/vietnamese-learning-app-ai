# Run Language Learning App with Pronunciation Feature
# Script chạy ứng dụng với tính năng phát âm AI đã hoàn thiện

Write-Host "🎤 Khởi động Language Learning App với tính năng Pronunciation AI..." -ForegroundColor Green

# Kiểm tra Flutter
Write-Host "📋 Kiểm tra Flutter..." -ForegroundColor Yellow
flutter --version

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter không được cài đặt hoặc không có trong PATH!" -ForegroundColor Red
    exit 1
}

# Lấy dependencies
Write-Host "📦 Lấy dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Lỗi khi lấy dependencies!" -ForegroundColor Red
    exit 1
}

# Kiểm tra device
Write-Host "📱 Kiểm tra devices..." -ForegroundColor Yellow
flutter devices

# Clean build (optional)
$clean = Read-Host "Bạn có muốn clean build không? (y/N)"
if ($clean -eq "y" -or $clean -eq "Y") {
    Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
}

Write-Host ""
Write-Host "🚀 Tính năng Pronunciation AI bao gồm:" -ForegroundColor Cyan
Write-Host "   ✓ Speech-to-Text với đánh giá AI" -ForegroundColor Green
Write-Host "   ✓ Text-to-Speech với âm thanh mẫu" -ForegroundColor Green
Write-Host "   ✓ Phân tích phát âm chi tiết theo từng từ" -ForegroundColor Green
Write-Host "   ✓ Điểm số chính xác, trôi chảy, hoàn thành" -ForegroundColor Green
Write-Host "   ✓ Nhiều lesson với độ khó khác nhau" -ForegroundColor Green
Write-Host "   ✓ Phản hồi AI và gợi ý cải thiện" -ForegroundColor Green
Write-Host "   ✓ Animations và UI hiện đại" -ForegroundColor Green
Write-Host "   ✓ Tích hợp sẵn cho Speechace/SpeechSuper API" -ForegroundColor Green
Write-Host ""

# Chạy app
Write-Host "🎯 Khởi động ứng dụng..." -ForegroundColor Green
flutter run --debug

Write-Host ""
Write-Host "📘 Hướng dẫn sử dụng tính năng Pronunciation:" -ForegroundColor Cyan
Write-Host "1. Mở app và đi tới màn hình Pronunciation" -ForegroundColor White
Write-Host "2. Chọn lesson phù hợp với trình độ" -ForegroundColor White
Write-Host "3. Nghe âm thanh mẫu bằng nút 'Nghe mẫu'" -ForegroundColor White
Write-Host "4. Nhấn nút mic để ghi âm phát âm của bạn" -ForegroundColor White
Write-Host "5. Xem kết quả đánh giá chi tiết từ AI" -ForegroundColor White
Write-Host "6. Áp dụng các gợi ý để cải thiện" -ForegroundColor White
Write-Host ""
Write-Host "✨ Chúc bạn học tập hiệu quả!" -ForegroundColor Magenta 