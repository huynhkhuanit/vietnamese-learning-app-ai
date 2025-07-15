import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../firebase_options.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Platform-specific Google Sign In
  static final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId: DefaultFirebaseOptions.web.apiKey,
          scopes: ['email', 'profile'],
        )
      : GoogleSignIn(scopes: ['email', 'profile']);

  // Đăng ký với email và mật khẩu
  static Future<UserCredential> registerWithEmail(
    String displayName,
    String email,
    String password,
  ) async {
    try {
      // Validate input parameters
      if (displayName.trim().isEmpty) {
        throw 'Tên hiển thị không được để trống';
      }
      if (email.trim().isEmpty) {
        throw 'Email không được để trống';
      }
      if (password.trim().isEmpty) {
        throw 'Mật khẩu không được để trống';
      }

      // Additional email validation
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
      );
      if (!emailRegex.hasMatch(email.trim())) {
        throw 'Định dạng email không hợp lệ';
      }

      if (kDebugMode) {
        print('Bắt đầu đăng ký với:');
        print('- Email: $email');
        print('- Display Name: $displayName');
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (kDebugMode) print('Tạo user credential thành công');

      // Create user document in Firestore
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email.trim().toLowerCase(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        preferences: {'theme': 'light', 'language': 'vi'},
        learningProgress: {
          'currentLevel': 1,
          'completedLessons': [],
          'streak': 0,
        },
      );

      if (kDebugMode) print('Tạo user document trong Firestore...');
      await _firestore.collection('users').doc(user.id).set(user.toMap());

      // Update display name
      await userCredential.user!.updateDisplayName(displayName.trim());

      if (kDebugMode) print('Đăng ký thành công hoàn tất');
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi trong registerWithEmail:');
        print('- Error type: ${e.runtimeType}');
        print('- Error message: $e');
      }
      throw _handleAuthError(e);
    }
  }

  // Đăng nhập với email và mật khẩu
  static Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Đăng nhập với Google
  static Future<UserCredential> signInWithGoogle() async {
    try {
      if (kDebugMode) print('Bắt đầu đăng nhập Google...');

      // Ensure Firebase is initialized
      if (!FirebaseService.isInitialized) {
        if (kDebugMode) print('Khởi tạo Firebase...');
        await FirebaseService.initialize();
      }

      // Sign out first to ensure clean state
      try {
        await _googleSignIn.signOut();
        await _auth.signOut();
      } catch (e) {
        if (kDebugMode) print('Lỗi sign out (có thể bỏ qua): $e');
      }

      // Start fresh sign in flow
      if (kDebugMode) print('Bắt đầu luồng đăng nhập mới...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) print('Người dùng hủy đăng nhập Google');
        throw 'Đăng nhập Google bị hủy';
      }

      if (kDebugMode) {
        print('Đã nhận thông tin Google user:');
        print('- Email: ${googleUser.email}');
        print('- Display Name: ${googleUser.displayName}');
        print('- Photo URL: ${googleUser.photoUrl}');
      }

      if (kDebugMode) print('Lấy thông tin xác thực Google...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (kDebugMode) {
        print('Đã nhận Google Auth:');
        print('- Access Token length: ${googleAuth.accessToken?.length ?? 0}');
        print('- ID Token length: ${googleAuth.idToken?.length ?? 0}');
      }

      if (googleAuth.accessToken == null) {
        throw 'Không thể lấy access token từ Google';
      }

      if (kDebugMode) print('Tạo credential từ Google Auth...');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) print('Đăng nhập vào Firebase với Google credential...');

      // Sử dụng try-catch riêng cho signInWithCredential
      try {
        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user == null) {
          throw 'Không thể lấy thông tin user sau khi đăng nhập';
        }

        if (kDebugMode) print('Kiểm tra user trong Firestore...');
        await _createOrUpdateUserInFirestore(user);

        if (kDebugMode) print('Đăng nhập Google thành công!');
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('Lỗi Firebase Auth:');
          print('- Code: ${e.code}');
          print('- Message: ${e.message}');
        }
        throw _handleAuthError(e);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng nhập Google chi tiết:');
        print('- Error type: ${e.runtimeType}');
        print('- Error message: $e');
      }
      rethrow;
    }
  }

  // Helper method to create or update user in Firestore
  static Future<void> _createOrUpdateUserInFirestore(User user) async {
    try {
      // Import UserProgressService for consistent data structure
      final userProgressDoc =
          _firestore.collection('userProgress').doc(user.uid);
      final userDoc = await userProgressDoc.get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          print('Tạo user progress document mới trong Firestore...');
        }

        // Create user progress document with consistent structure
        await userProgressDoc.set({
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'dhvCore': {
            'currentUnit': 1,
            'currentLesson': 1,
            'completedLessons': [],
            'totalXP': 0,
          },
          'lifeTheme': {
            'currentUnit': 1,
            'currentLesson': 100,
            'completedLessons': [],
            'totalXP': 0,
          },
          'achievements': [],
          'streakDays': 0,
          'lastStudyDate': null,
          'totalXP': 0,
          'minutesLearned': 0,
          'streak': 0,
        });

        if (kDebugMode) print('User progress document created successfully');
      } else {
        if (kDebugMode) print('Cập nhật thông tin user...');
        await userProgressDoc.update({
          'lastUpdated': FieldValue.serverTimestamp(),
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi tạo/cập nhật user trong Firestore:');
        print(e);
      }
      // Don't throw here, just log the error
    }
  }

  // Đăng nhập với Facebook
  // static Future<UserCredential> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status != LoginStatus.success) {
  //       throw 'Đăng nhập Facebook thất bại';
  //     }

  //     final AccessToken accessToken = result.accessToken!;
  //     final OAuthCredential credential = FacebookAuthProvider.credential(
  //       accessToken
  //           .tokenString, // Sửa từ accessToken.token thành accessToken.tokenString
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);
  //     final user = userCredential.user!;

  //     // Check if user exists in Firestore
  //     final userDoc = await _firestore.collection('users').doc(user.uid).get();

  //     if (!userDoc.exists) {
  //       // Create new user document
  //       final newUser = UserModel(
  //         id: user.uid,
  //         email: user.email!,
  //         displayName: user.displayName,
  //         photoURL: user.photoURL,
  //         createdAt: DateTime.now(),
  //         lastLogin: DateTime.now(),
  //         preferences: {'theme': 'light', 'language': 'vi'},
  //         learningProgress: {
  //           'currentLevel': 1,
  //           'completedLessons': [],
  //           'streak': 0,
  //         },
  //       );

  //       await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
  //     } else {
  //       // Update last login
  //       await _firestore.collection('users').doc(user.uid).update({
  //         'lastLogin': FieldValue.serverTimestamp(),
  //       });
  //     }

  //     return userCredential;
  //   } catch (e) {
  //     throw _handleAuthError(e);
  //   }
  // }

  // Đăng nhập với Apple
  static Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user!;

      // Use the helper method for consistent user data creation
      await _createOrUpdateUserInFirestore(user);

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Đăng xuất
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Lưu trữ dữ liệu offline
  static Future<void> saveOfflineData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_data', jsonEncode(data));
    } catch (e) {
      print('Error saving offline data: $e');
    }
  }

  // Đọc dữ liệu offline
  static Future<Map<String, dynamic>?> getOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('offline_data');
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error reading offline data: $e');
    }
    return null;
  }

  // Xử lý lỗi xác thực
  static String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này';
        case 'wrong-password':
          return 'Mật khẩu không chính xác';
        case 'email-already-in-use':
          return 'Email này đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu quá yếu';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'operation-not-allowed':
          return 'Phương thức đăng nhập này không được hỗ trợ';
        case 'account-exists-with-different-credential':
          return 'Tài khoản đã tồn tại với phương thức đăng nhập khác';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng';
        default:
          return 'Đã xảy ra lỗi: ${error.message}';
      }
    }
    return error.toString();
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Get from userProgress collection for consistency
    final doc = await _firestore.collection('userProgress').doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data();
  }

  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }

    // Update in userProgress collection for consistency
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoURL != null) updates['photoURL'] = photoURL;
    updates['lastUpdated'] = FieldValue.serverTimestamp();

    await _firestore.collection('userProgress').doc(user.uid).update(updates);
  }

  static Future<void> updateUserPreferences(
    Map<String, dynamic> preferences,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    await _firestore.collection('userProgress').doc(user.uid).update({
      'preferences': preferences,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateLearningProgress(
    Map<String, dynamic> progress,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    await _firestore.collection('userProgress').doc(user.uid).update({
      'learningProgress': progress,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
