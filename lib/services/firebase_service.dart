import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) print('Firebase đã được khởi tạo rồi');
      return;
    }

    try {
      // Kiểm tra xem có app Firebase nào đã được khởi tạo chưa
      if (Firebase.apps.isNotEmpty) {
        await _initializeAppCheck();
        _isInitialized = true;
        if (kDebugMode) print('Firebase app đã tồn tại');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await _initializeAppCheck();

      _isInitialized = true;
      if (kDebugMode) print('Firebase khởi tạo thành công');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khởi tạo Firebase:');
        print('- Error type: ${e.runtimeType}');
        print('- Error message: $e');
      }
      rethrow;
    }
  }

  static Future<void> _initializeAppCheck() async {
    try {
      // Trong môi trường debug, sử dụng debug provider
      if (kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        print('Firebase App Check đã được khởi tạo trong chế độ debug');
      } else {
        // Trong môi trường production, sử dụng Play Integrity
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
        );
        print('Firebase App Check đã được khởi tạo trong chế độ production');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khởi tạo Firebase App Check:');
        print('- Error type: ${e.runtimeType}');
        print('- Error message: $e');
      }
      rethrow;
    }
  }

  static bool get isInitialized => _isInitialized;

  // Reset method for testing
  static void reset() {
    _isInitialized = false;
  }
}
