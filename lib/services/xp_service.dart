import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_experience.dart';
import '../models/achievement.dart';
import 'notification_service.dart';

class XPService {
  static final XPService _instance = XPService._internal();
  factory XPService() => _instance;
  XPService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserExperience? _currentUserExperience;
  List<Achievement> _userAchievements = [];

  // Getters
  UserExperience? get currentUserExperience => _currentUserExperience;
  List<Achievement> get userAchievements => _userAchievements;
  int get currentXP => _currentUserExperience?.totalXP ?? 0;
  int get currentLevel => _currentUserExperience?.currentLevel ?? 1;
  int get currentStreak => _currentUserExperience?.currentStreak ?? 0;

  // Initialize user experience data
  Future<void> initializeUserExperience() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('XPService: User not authenticated, cannot initialize experience');
      return;
    }

    print('XPService: Initializing for user ${user.uid}');

    try {
      // Check if user is still authenticated
      await user.reload();

      // Get or create user experience document
      final docRef = _firestore.collection('userExperience').doc(user.uid);
      print('XPService: Attempting to read userExperience/${user.uid}');

      final doc = await docRef.get();

      if (doc.exists) {
        _currentUserExperience = UserExperience.fromFirestore(doc);
        print(
            'XPService: Loaded user experience - Level ${_currentUserExperience!.currentLevel}, XP: ${_currentUserExperience!.totalXP}');
      } else {
        print('XPService: Creating new user experience document');
        // Create new user experience
        _currentUserExperience = UserExperience(
          userId: user.uid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await docRef.set(_currentUserExperience!.toFirestore());
        print('XPService: Created new user experience for ${user.uid}');

        // Grant first login achievement
        await awardAchievement('first_login');
      }

      // Load user achievements
      print('XPService: Loading user achievements...');
      await _loadUserAchievements();

      // Update daily/weekly/monthly counters
      print('XPService: Updating time-based counters...');
      await _updateTimeBasedCounters();

      print('XPService: Initialization completed successfully');
    } catch (e) {
      print('XPService: Error initializing user experience: $e');

      // More detailed error logging
      if (e.toString().contains('permission-denied')) {
        print(
            'XPService: Permission denied - check Firestore rules for userExperience collection');
      } else if (e.toString().contains('network')) {
        print('XPService: Network error - check internet connection');
      } else if (e.toString().contains('unauthenticated')) {
        print('XPService: User unauthenticated - check Firebase Auth state');
      }

      // Set default empty state on error
      _currentUserExperience = UserExperience(
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Load user achievements from Firebase
  Future<void> _loadUserAchievements() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('XPService: User not authenticated, cannot load achievements');
      return;
    }

    try {
      print(
          'XPService: Attempting to read userAchievements/${user.uid}/achievements');
      final snapshot = await _firestore
          .collection('userAchievements')
          .doc(user.uid)
          .collection('achievements')
          .get();

      _userAchievements =
          snapshot.docs.map((doc) => Achievement.fromFirestore(doc)).toList();

      print('XPService: Loaded ${_userAchievements.length} user achievements');
    } catch (e) {
      print('XPService: Error loading user achievements: $e');

      // More detailed error logging
      if (e.toString().contains('permission-denied')) {
        print(
            'XPService: Permission denied - check Firestore rules for userAchievements collection');
      }

      // Initialize empty achievements list on error
      _userAchievements = [];
    }
  }

  // Award XP for specific activity
  Future<int> awardXP(XPActivityType activityType,
      {Map<String, dynamic>? extraData}) async {
    final user = _auth.currentUser;
    if (user == null || _currentUserExperience == null) return 0;

    try {
      int baseXP = activityType.baseXP;
      int multiplier = 1;

      // Apply streak multiplier
      if (_currentUserExperience!.currentStreak >= 7) {
        multiplier = 2; // Double XP for 7+ day streak
      } else if (_currentUserExperience!.currentStreak >= 3) {
        multiplier = 1.5.round(); // 1.5x XP for 3+ day streak
      }

      final awardedXP = (baseXP * multiplier);
      final newTotalXP = _currentUserExperience!.totalXP + awardedXP;
      final newLevel = UserExperience.calculateLevel(newTotalXP);
      final newXPToNext = UserExperience.calculateXPToNextLevel(newTotalXP);

      // Check for level up
      final oldLevel = _currentUserExperience!.currentLevel;
      final leveledUp = newLevel > oldLevel;

      // Update experience
      _currentUserExperience = _currentUserExperience!.copyWith(
        totalXP: newTotalXP,
        currentLevel: newLevel,
        xpToNextLevel: newXPToNext,
        dailyXP: _currentUserExperience!.dailyXP + awardedXP,
        weeklyXP: _currentUserExperience!.weeklyXP + awardedXP,
        monthlyXP: _currentUserExperience!.monthlyXP + awardedXP,
        updatedAt: DateTime.now(),
      );

      // Update activity stats
      final newStats =
          Map<String, int>.from(_currentUserExperience!.activityStats);
      newStats[activityType.name] = (newStats[activityType.name] ?? 0) + 1;

      _currentUserExperience = _currentUserExperience!.copyWith(
        activityStats: newStats,
      );

      // Save to Firebase
      await _firestore
          .collection('userExperience')
          .doc(user.uid)
          .update(_currentUserExperience!.toFirestore());

      // Send level up notification
      if (leveledUp) {
        await _handleLevelUp(oldLevel, newLevel);
      }

      // Check for achievements
      await _checkAndAwardAchievements(activityType, extraData);

      print(
          'Awarded $awardedXP XP for ${activityType.description} (multiplier: ${multiplier}x)');
      print('Total XP: $newTotalXP, Level: $newLevel');

      return awardedXP;
    } catch (e) {
      print('Error awarding XP: $e');
      return 0;
    }
  }

  // Handle level up
  Future<void> _handleLevelUp(int oldLevel, int newLevel) async {
    try {
      // Send notification
      await NotificationService().sendAchievementNotification('Level Up! 🎉',
          'Chúc mừng! Bạn đã lên Level $newLevel - ${_currentUserExperience!.levelTitle}!');

      // Award level achievements
      if (newLevel == 5) {
        await awardAchievement('level_5');
      } else if (newLevel == 10) {
        await awardAchievement('level_10');
      }

      print('Level up: $oldLevel → $newLevel');
    } catch (e) {
      print('Error handling level up: $e');
    }
  }

  // Update daily streak
  Future<void> updateDailyStreak() async {
    final user = _auth.currentUser;
    if (user == null || _currentUserExperience == null) return;

    try {
      final now = DateTime.now();
      final lastStudyDate = _currentUserExperience!.lastStudyDate;

      int newStreak = _currentUserExperience!.currentStreak;

      if (lastStudyDate == null) {
        // First time studying
        newStreak = 1;
      } else {
        final daysDifference = now.difference(lastStudyDate).inDays;

        if (daysDifference == 0) {
          // Already studied today, no change to streak
          return;
        } else if (daysDifference == 1) {
          // Studied yesterday, continue streak
          newStreak += 1;
        } else {
          // Missed days, reset streak
          newStreak = 1;
        }
      }

      // Update longest streak
      final newLongestStreak = newStreak > _currentUserExperience!.longestStreak
          ? newStreak
          : _currentUserExperience!.longestStreak;

      _currentUserExperience = _currentUserExperience!.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastStudyDate: now,
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await _firestore
          .collection('userExperience')
          .doc(user.uid)
          .update(_currentUserExperience!.toFirestore());

      // Award streak XP and check achievements
      if (newStreak > 1) {
        await awardXP(XPActivityType.dailyStreak);
      }

      await _checkStreakAchievements(newStreak);

      // Schedule streak reminder for tomorrow
      await NotificationService().scheduleStreakReminderAfterLesson();

      print('Updated streak: $newStreak days');
    } catch (e) {
      print('Error updating daily streak: $e');
    }
  }

  // Check and award streak achievements
  Future<void> _checkStreakAchievements(int streak) async {
    try {
      switch (streak) {
        case 3:
          await awardAchievement('streak_3');
          break;
        case 7:
          await awardAchievement('streak_7');
          await awardXP(XPActivityType.weeklyStreak);
          break;
        case 30:
          await awardAchievement('streak_30');
          await awardXP(XPActivityType.monthlyStreak);
          break;
        case 100:
          await awardAchievement('streak_100');
          break;
      }
    } catch (e) {
      print('Error checking streak achievements: $e');
    }
  }

  // Award achievement
  Future<bool> awardAchievement(String achievementId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check if already unlocked
      if (_userAchievements.any((a) => a.id == achievementId && a.isUnlocked)) {
        return false;
      }

      // Get achievement template
      final achievementTemplate = PredefinedAchievements.getById(achievementId);
      if (achievementTemplate == null) {
        print('Achievement template not found: $achievementId');
        return false;
      }

      // Create unlocked achievement
      final unlockedAchievement = achievementTemplate.copyWith(
        unlockedAt: DateTime.now(),
        progress: achievementTemplate.maxProgress,
      );

      // Save to Firebase
      await _firestore
          .collection('userAchievements')
          .doc(user.uid)
          .collection('achievements')
          .doc(achievementId)
          .set(unlockedAchievement.toFirestore());

      // Update local list
      _userAchievements.removeWhere((a) => a.id == achievementId);
      _userAchievements.add(unlockedAchievement);

      // Update user experience achievements list
      final newUnlockedList =
          List<String>.from(_currentUserExperience!.unlockedAchievements);
      if (!newUnlockedList.contains(achievementId)) {
        newUnlockedList.add(achievementId);
        _currentUserExperience = _currentUserExperience!.copyWith(
          unlockedAchievements: newUnlockedList,
        );

        await _firestore
            .collection('userExperience')
            .doc(user.uid)
            .update({'unlockedAchievements': newUnlockedList});
      }

      // Award XP for achievement
      await awardXP(XPActivityType.achievementUnlocked);
      if (achievementTemplate.xpReward > 0) {
        final bonusXP = achievementTemplate.xpReward;
        final newTotalXP = _currentUserExperience!.totalXP + bonusXP;
        _currentUserExperience = _currentUserExperience!.copyWith(
          totalXP: newTotalXP,
        );

        await _firestore
            .collection('userExperience')
            .doc(user.uid)
            .update({'totalXP': newTotalXP});
      }

      // Send enhanced achievement notification
      await NotificationService()
          .sendEnhancedAchievementNotification(achievementId);

      print(
          'Achievement unlocked: $achievementId - ${achievementTemplate.title}');
      return true;
    } catch (e) {
      print('Error awarding achievement: $e');
      return false;
    }
  }

  // Check and award achievements based on activity
  Future<void> _checkAndAwardAchievements(
      XPActivityType activityType, Map<String, dynamic>? extraData) async {
    if (_currentUserExperience == null) return;

    try {
      // Check lesson completion achievements
      if (activityType == XPActivityType.lessonCompleted) {
        final totalLessons = _currentUserExperience!.totalLessonsCompleted + 1;

        _currentUserExperience = _currentUserExperience!.copyWith(
          totalLessonsCompleted: totalLessons,
        );

        // Check for first lesson
        if (totalLessons == 1) {
          await awardAchievement('first_lesson');
        }

        // Check lesson milestones
        if (totalLessons == 10) {
          await awardAchievement('lessons_10');
        } else if (totalLessons == 50) {
          await awardAchievement('lessons_50');
        } else if (totalLessons == 100) {
          await awardAchievement('lessons_100');
        }

        // Check DHV Core progress
        if (extraData != null && extraData['isDHVLesson'] == true) {
          final dhvLessons =
              (_currentUserExperience!.activityStats['dhvLessonsCompleted'] ??
                      0) +
                  1;
          final newStats =
              Map<String, int>.from(_currentUserExperience!.activityStats);
          newStats['dhvLessonsCompleted'] = dhvLessons;

          _currentUserExperience = _currentUserExperience!.copyWith(
            activityStats: newStats,
          );

          if (dhvLessons == 5) {
            await awardAchievement('dhv_lesson_5');
          } else if (dhvLessons == 16) {
            await awardAchievement('dhv_graduate');
            await awardXP(XPActivityType.dhvCoreCompleted);
          }
        }

        // Check Life Theme progress
        if (extraData != null && extraData['isLifeTheme'] == true) {
          if ((_currentUserExperience!.activityStats['lifeThemeLessons'] ??
                  0) ==
              0) {
            await awardAchievement('life_started');
            await awardXP(XPActivityType.lifeThemeStarted);
          }

          // Unit completion
          if (extraData['unitCompleted'] != null) {
            final unitNumber = extraData['unitCompleted'] as int;
            if (unitNumber == 1) {
              await awardAchievement('life_unit_1');
            } else if (unitNumber == 2) {
              await awardAchievement('life_unit_2');
            }
          }
        }
      }

      // Check XP achievements
      final totalXP = _currentUserExperience!.totalXP;
      if (totalXP >= 1000 &&
          !_userAchievements.any((a) => a.id == 'xp_1000' && a.isUnlocked)) {
        await awardAchievement('xp_1000');
      } else if (totalXP >= 5000 &&
          !_userAchievements.any((a) => a.id == 'xp_5000' && a.isUnlocked)) {
        await awardAchievement('xp_5000');
      }

      // Check quiz achievements
      if (activityType == XPActivityType.quizPerfect) {
        final perfectQuizzes =
            (_currentUserExperience!.activityStats['perfectQuizzes'] ?? 0) + 1;
        final newStats =
            Map<String, int>.from(_currentUserExperience!.activityStats);
        newStats['perfectQuizzes'] = perfectQuizzes;

        _currentUserExperience = _currentUserExperience!.copyWith(
          activityStats: newStats,
        );

        if (perfectQuizzes == 5) {
          await awardAchievement('quiz_perfect_5');
        }
      }

      // Save updated stats
      await _firestore
          .collection('userExperience')
          .doc(_auth.currentUser!.uid)
          .update(_currentUserExperience!.toFirestore());
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  // Update time-based counters (daily/weekly/monthly)
  Future<void> _updateTimeBasedCounters() async {
    final user = _auth.currentUser;
    if (user == null || _currentUserExperience == null) return;

    try {
      final now = DateTime.now();
      final lastUpdate = _currentUserExperience!.updatedAt;

      bool needsUpdate = false;
      int newDailyXP = _currentUserExperience!.dailyXP;
      int newWeeklyXP = _currentUserExperience!.weeklyXP;
      int newMonthlyXP = _currentUserExperience!.monthlyXP;

      // Reset daily XP if new day
      if (now.day != lastUpdate.day ||
          now.month != lastUpdate.month ||
          now.year != lastUpdate.year) {
        newDailyXP = 0;
        needsUpdate = true;
      }

      // Reset weekly XP if new week
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final lastUpdateStartOfWeek =
          lastUpdate.subtract(Duration(days: lastUpdate.weekday - 1));
      if (startOfWeek.day != lastUpdateStartOfWeek.day ||
          startOfWeek.month != lastUpdateStartOfWeek.month ||
          startOfWeek.year != lastUpdateStartOfWeek.year) {
        newWeeklyXP = 0;
        needsUpdate = true;
      }

      // Reset monthly XP if new month
      if (now.month != lastUpdate.month || now.year != lastUpdate.year) {
        newMonthlyXP = 0;
        needsUpdate = true;
      }

      if (needsUpdate) {
        _currentUserExperience = _currentUserExperience!.copyWith(
          dailyXP: newDailyXP,
          weeklyXP: newWeeklyXP,
          monthlyXP: newMonthlyXP,
          updatedAt: now,
        );

        await _firestore
            .collection('userExperience')
            .doc(user.uid)
            .update(_currentUserExperience!.toFirestore());

        print('Updated time-based counters');
      }
    } catch (e) {
      print('Error updating time-based counters: $e');
    }
  }

  // Use streak freeze
  Future<bool> useStreakFreeze() async {
    final user = _auth.currentUser;
    if (user == null || _currentUserExperience == null) return false;

    try {
      if (!_currentUserExperience!.canUseStreakFreeze()) {
        return false;
      }

      _currentUserExperience = _currentUserExperience!.copyWith(
        streakFreezeUsed: true,
        streakFreezeCount: _currentUserExperience!.streakFreezeCount + 1,
        lastStreakFreezeDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('userExperience')
          .doc(user.uid)
          .update(_currentUserExperience!.toFirestore());

      print('Streak freeze used');
      return true;
    } catch (e) {
      print('Error using streak freeze: $e');
      return false;
    }
  }

  // Get user statistics
  Map<String, dynamic> getUserStats() {
    if (_currentUserExperience == null) return {};

    return {
      'totalXP': _currentUserExperience!.totalXP,
      'currentLevel': _currentUserExperience!.currentLevel,
      'levelTitle': _currentUserExperience!.levelTitle,
      'xpToNextLevel': _currentUserExperience!.xpToNextLevel,
      'currentStreak': _currentUserExperience!.currentStreak,
      'longestStreak': _currentUserExperience!.longestStreak,
      'dailyXP': _currentUserExperience!.dailyXP,
      'weeklyXP': _currentUserExperience!.weeklyXP,
      'monthlyXP': _currentUserExperience!.monthlyXP,
      'totalLessonsCompleted': _currentUserExperience!.totalLessonsCompleted,
      'totalAchievements': _userAchievements.where((a) => a.isUnlocked).length,
      'activityStats': _currentUserExperience!.activityStats,
    };
  }

  // Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return PredefinedAchievements.getByCategory(category).map((template) {
      // Find user progress for this achievement
      final userAchievement = _userAchievements.firstWhere(
        (a) => a.id == template.id,
        orElse: () => template,
      );
      return userAchievement;
    }).toList();
  }

  // Calculate progress for progressive achievements
  void updateAchievementProgress(String achievementId, int progress) {
    final index = _userAchievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      _userAchievements[index] = _userAchievements[index].copyWith(
        progress: progress,
      );
    }
  }

  // Verify user access to Firestore collections
  Future<bool> verifyUserAccess() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('XPService: No authenticated user');
      return false;
    }

    try {
      print('XPService: Verifying access for user ${user.uid}');

      // Try to read user experience document
      final userExpRef = _firestore.collection('userExperience').doc(user.uid);
      await userExpRef.get();
      print('XPService: ✅ userExperience access OK');

      // Try to read user achievements
      final userAchievementsRef = _firestore
          .collection('userAchievements')
          .doc(user.uid)
          .collection('achievements');
      await userAchievementsRef.limit(1).get();
      print('XPService: ✅ userAchievements access OK');

      return true;
    } catch (e) {
      print('XPService: ❌ Access verification failed: $e');

      if (e.toString().contains('permission-denied')) {
        print('XPService: 🔐 Permission denied - check Firestore rules');
        print('XPService: Required rules:');
        print(
            '  - userExperience/{userId} - allow read, write: if request.auth.uid == userId');
        print(
            '  - userAchievements/{userId}/achievements/{achievementId} - allow read, write: if request.auth.uid == userId');
      }

      return false;
    }
  }

  // Reset all data (for testing or account reset)
  Future<void> resetUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Reset experience
      _currentUserExperience = UserExperience(
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('userExperience')
          .doc(user.uid)
          .set(_currentUserExperience!.toFirestore());

      // Clear achievements
      final batch = _firestore.batch();
      final achievementsSnapshot = await _firestore
          .collection('userAchievements')
          .doc(user.uid)
          .collection('achievements')
          .get();

      for (final doc in achievementsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _userAchievements.clear();

      print('User data reset successfully');
    } catch (e) {
      print('Error resetting user data: $e');
    }
  }
}
