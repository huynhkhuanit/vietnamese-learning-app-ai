import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/learning_goal.dart';

class LearningGoalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'learning_goals';

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get learning goal for current user
  static Future<LearningGoal?> getUserLearningGoal() async {
    if (currentUser == null) return null;

    try {
      final doc =
          await _firestore.collection(_collection).doc(currentUser!.uid).get();

      if (doc.exists && doc.data() != null) {
        return LearningGoal.fromMap(doc.data()!);
      }

      // Create default goal if none exists
      return await _createDefaultGoal();
    } catch (e) {
      print('Error getting learning goal: $e');
      return null;
    }
  }

  // Stream learning goal
  static Stream<LearningGoal?> getUserLearningGoalStream() {
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection(_collection)
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return LearningGoal.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Create default goal
  static Future<LearningGoal?> _createDefaultGoal() async {
    if (currentUser == null) return null;

    final now = DateTime.now();
    final goal = LearningGoal(
      id: currentUser!.uid,
      userId: currentUser!.uid,
      goalType: GoalType.regular,
      lastActivityDate: now,
      createdAt: now,
      updatedAt: now,
    );

    await saveLearningGoal(goal);
    return goal;
  }

  // Save/Update learning goal
  static Future<void> saveLearningGoal(LearningGoal goal) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection(_collection)
          .doc(currentUser!.uid)
          .set(goal.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving learning goal: $e');
      rethrow;
    }
  }

  // Update goal type
  static Future<void> updateGoalType(GoalType newGoalType) async {
    final currentGoal = await getUserLearningGoal();
    if (currentGoal == null) return;

    final updatedGoal = currentGoal.copyWith(
      goalType: newGoalType,
      updatedAt: DateTime.now(),
    );

    await saveLearningGoal(updatedGoal);
  }

  // Record study session
  static Future<void> recordStudySession(int minutes, int xp) async {
    final currentGoal = await getUserLearningGoal();
    if (currentGoal == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      currentGoal.lastActivityDate.year,
      currentGoal.lastActivityDate.month,
      currentGoal.lastActivityDate.day,
    );

    // Check if it's a new day
    final isNewDay = today.isAfter(lastActivity);
    final daysDifference = today.difference(lastActivity).inDays;

    // Calculate new streak
    int newStreak = currentGoal.currentStreak;
    if (isNewDay) {
      if (daysDifference == 1 && currentGoal.hasMetDailyGoal) {
        // Continue streak if previous day goal was met
        newStreak += 1;
      } else if (daysDifference > 1) {
        // Reset streak if more than 1 day gap
        newStreak = 1;
      }
    }

    // Update weekly progress
    final weekDay = _getWeekDay(now);
    final newWeeklyProgress = Map<String, int>.from(currentGoal.weeklyProgress);
    newWeeklyProgress[weekDay] = (newWeeklyProgress[weekDay] ?? 0) + minutes;

    final updatedGoal = currentGoal.copyWith(
      todayXP: isNewDay ? xp : currentGoal.todayXP + xp,
      todayMinutes: isNewDay ? minutes : currentGoal.todayMinutes + minutes,
      currentStreak: newStreak,
      longestStreak: newStreak > currentGoal.longestStreak
          ? newStreak
          : currentGoal.longestStreak,
      lastActivityDate: now,
      weeklyProgress: newWeeklyProgress,
      updatedAt: now,
      streakFreezeUsed: false, // Reset daily
    );

    await saveLearningGoal(updatedGoal);

    // Check for achievements
    await _checkAchievements(updatedGoal);
  }

  // Use streak freeze
  static Future<bool> useStreakFreeze() async {
    final currentGoal = await getUserLearningGoal();
    if (currentGoal == null || !currentGoal.canUseStreakFreeze) {
      return false;
    }

    final updatedGoal = currentGoal.copyWith(
      streakFreezeUsed: true,
      streakFreezeCount: currentGoal.streakFreezeCount + 1,
      updatedAt: DateTime.now(),
    );

    await saveLearningGoal(updatedGoal);
    return true;
  }

  // Update reminder settings
  static Future<void> updateReminderSettings({
    required bool enabled,
    DateTime? time,
  }) async {
    final currentGoal = await getUserLearningGoal();
    if (currentGoal == null) return;

    final updatedGoal = currentGoal.copyWith(
      reminderEnabled: enabled,
      reminderTime: time,
      updatedAt: DateTime.now(),
    );

    await saveLearningGoal(updatedGoal);
  }

  // Get weekly stats
  static Future<Map<String, int>> getWeeklyStats() async {
    final goal = await getUserLearningGoal();
    if (goal == null) return {};

    return goal.weeklyProgress;
  }

  // Check achievements
  static Future<void> _checkAchievements(LearningGoal goal) async {
    final newAchievements = <String>[];

    // Streak achievements
    if (goal.currentStreak >= 7 && !goal.achievements.contains('streak_7')) {
      newAchievements.add('streak_7');
    }
    if (goal.currentStreak >= 30 && !goal.achievements.contains('streak_30')) {
      newAchievements.add('streak_30');
    }
    if (goal.currentStreak >= 100 &&
        !goal.achievements.contains('streak_100')) {
      newAchievements.add('streak_100');
    }

    // XP achievements
    if (goal.todayXP >= 100 && !goal.achievements.contains('xp_100_day')) {
      newAchievements.add('xp_100_day');
    }

    // Goal completion achievements
    if (goal.hasMetDailyGoal && !goal.achievements.contains('first_goal')) {
      newAchievements.add('first_goal');
    }

    if (newAchievements.isNotEmpty) {
      final updatedGoal = goal.copyWith(
        achievements: [...goal.achievements, ...newAchievements],
        updatedAt: DateTime.now(),
      );

      await saveLearningGoal(updatedGoal);
    }
  }

  // Get available achievements
  static List<Achievement> getAvailableAchievements() {
    return [
      Achievement(
        id: 'streak_7',
        title: 'Tuần đầu tiên',
        description: 'Học liên tục 7 ngày',
        emoji: '🔥',
        requirement: 7,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Kiên trì tháng đầu',
        description: 'Học liên tục 30 ngày',
        emoji: '💪',
        requirement: 30,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Bậc thầy kiên trì',
        description: 'Học liên tục 100 ngày',
        emoji: '👑',
        requirement: 100,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'xp_100_day',
        title: 'Ngày năng suất',
        description: 'Đạt 100 XP trong một ngày',
        emoji: '⭐',
        requirement: 100,
        type: AchievementType.xp,
      ),
      Achievement(
        id: 'first_goal',
        title: 'Mục tiêu đầu tiên',
        description: 'Hoàn thành mục tiêu hàng ngày lần đầu',
        emoji: '🎯',
        requirement: 1,
        type: AchievementType.perfect,
      ),
    ];
  }

  // Helper method to get weekday string
  static String _getWeekDay(DateTime date) {
    const weekDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return weekDays[date.weekday - 1];
  }

  // Reset daily progress (for testing)
  static Future<void> resetDailyProgress() async {
    final currentGoal = await getUserLearningGoal();
    if (currentGoal == null) return;

    final updatedGoal = currentGoal.copyWith(
      todayXP: 0,
      todayMinutes: 0,
      streakFreezeUsed: false,
      updatedAt: DateTime.now(),
    );

    await saveLearningGoal(updatedGoal);
  }

  // Get streak status message
  static String getStreakStatusMessage(LearningGoal goal) {
    if (goal.streakInDanger) {
      return 'Chuỗi ngày học của bạn đang gặp nguy hiểm! Hãy học thêm ${goal.goalType.dailyMinutes - goal.todayMinutes} phút để duy trì chuỗi.';
    } else if (goal.hasMetDailyGoal) {
      return 'Tuyệt vời! Bạn đã hoàn thành mục tiêu hôm nay.';
    } else if (goal.isOnStreak) {
      return 'Hãy tiếp tục duy trì chuỗi ${goal.currentStreak} ngày!';
    } else {
      return 'Bắt đầu chuỗi ngày học mới ngay hôm nay!';
    }
  }
}
