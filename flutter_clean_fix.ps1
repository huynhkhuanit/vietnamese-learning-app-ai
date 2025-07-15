# Flutter Clean Fix Script
# Chạy script này với quyền Administrator

Write-Host "🚀 Bắt đầu khắc phục lỗi Flutter Clean..." -ForegroundColor Green

# Bước 1: Kill các process có thể đang sử dụng file
Write-Host "📋 Đóng các process Flutter/Dart..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Bước 2: Xóa các thư mục cache/build
Write-Host "🗑️ Xóa các thư mục cache..." -ForegroundColor Yellow

$directories = @(
    "build",
    ".dart_tool", 
    "linux\flutter\ephemeral",
    "ios\Flutter\ephemeral",
    "windows\flutter\ephemeral", 
    "macos\Flutter\ephemeral",
    "android\.gradle",
    "android\app\build",
    "ios\Pods",
    "ios\Podfile.lock"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "  Xóa: $dir" -ForegroundColor Gray
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dir
    }
}

# Bước 3: Chạy Flutter commands
Write-Host "📦 Chạy flutter pub get..." -ForegroundColor Yellow
flutter pub get

Write-Host "🧹 Chạy flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "✅ Hoàn thành! Thử chạy ứng dụng của bạn." -ForegroundColor Green 