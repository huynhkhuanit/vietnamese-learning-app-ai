import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/services/firebase_service.dart';
import 'lib/services/xp_service.dart';
import 'lib/models/user_experience.dart';

/// Debug script để test XP System và Firestore permissions
///
/// Sử dụng:
/// ```bash
/// flutter run debug_xp_system.dart
/// ```

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 XP System Debug Script Starting...');

  try {
    // Initialize Firebase
    print('📱 Initializing Firebase...');
    await FirebaseService.initialize();
    print('✅ Firebase initialized');

    // Check authentication
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      print('❌ No authenticated user found');
      print('💡 Please login to the app first, then run this script');
      return;
    }

    print('👤 Authenticated user: ${user.uid}');
    print('📧 Email: ${user.email}');

    // Test XP Service
    print('\n🧪 Testing XP Service...');
    final xpService = XPService();

    // Verify access
    print('🔐 Verifying Firestore access...');
    final hasAccess = await xpService.verifyUserAccess();

    if (!hasAccess) {
      print('❌ Firestore access failed');
      print('🔧 Check Firestore rules:');
      print('   - userExperience/{userId}');
      print('   - userAchievements/{userId}/achievements/{achievementId}');
      return;
    }

    print('✅ Firestore access verified');

    // Initialize XP Service
    print('⚙️ Initializing XP Service...');
    await xpService.initializeUserExperience();

    // Display current state
    final userExp = xpService.currentUserExperience;
    if (userExp != null) {
      print('✅ XP Service initialized successfully');
      print('📊 Current Stats:');
      print('   - Level: ${userExp.currentLevel} (${userExp.levelTitle})');
      print('   - Total XP: ${userExp.totalXP}');
      print('   - XP to next level: ${userExp.xpToNextLevel}');
      print('   - Current streak: ${userExp.currentStreak} days');
      print('   - Daily XP: ${userExp.dailyXP}');
      print('   - Weekly XP: ${userExp.weeklyXP}');
      print(
          '   - Achievements unlocked: ${userExp.unlockedAchievements.length}');
    } else {
      print('❌ XP Service initialization failed');
      return;
    }

    // Test XP awarding
    print('\n🏆 Testing XP Award System...');

    print('💫 Awarding test XP (lesson completed)...');
    final awardedXP = await xpService.awardXP(XPActivityType.lessonCompleted);
    print('✅ Awarded $awardedXP XP');

    print('💫 Awarding test XP (quiz perfect)...');
    final quizXP = await xpService.awardXP(XPActivityType.quizPerfect);
    print('✅ Awarded $quizXP XP');

    // Display updated state
    final updatedExp = xpService.currentUserExperience;
    if (updatedExp != null) {
      print('📊 Updated Stats:');
      print(
          '   - Level: ${updatedExp.currentLevel} (${updatedExp.levelTitle})');
      print('   - Total XP: ${updatedExp.totalXP}');
      print('   - Daily XP: ${updatedExp.dailyXP}');
    }

    // Test achievements
    print('\n🏅 Testing Achievement System...');
    final achievements = xpService.userAchievements;
    print(
        '🎯 User has ${achievements.where((a) => a.isUnlocked).length} unlocked achievements');

    if (achievements.isNotEmpty) {
      print('📜 Recent achievements:');
      for (final achievement
          in achievements.where((a) => a.isUnlocked).take(3)) {
        print('   - ${achievement.icon} ${achievement.title}');
      }
    }

    // Test streak system
    print('\n🔥 Testing Streak System...');
    await xpService.updateDailyStreak();
    final finalExp = xpService.currentUserExperience;
    if (finalExp != null) {
      print('✅ Current streak: ${finalExp.currentStreak} days');
      print('🏆 Longest streak: ${finalExp.longestStreak} days');
    }

    print('\n🎉 All tests completed successfully!');
    print('✅ XP System is working correctly');
  } catch (e, stackTrace) {
    print('❌ Error during testing: $e');
    print('📄 Stack trace: $stackTrace');

    if (e.toString().contains('permission-denied')) {
      print('\n🔧 Fix: Update Firestore rules with:');
      print('''
// Add these rules to firestore.rules
match /userExperience/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /userAchievements/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  
  match /achievements/{achievementId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
}
''');
      print('\nThen run: firebase deploy --only firestore:rules');
    }
  }
}
