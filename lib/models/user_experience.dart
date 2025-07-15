import 'package:cloud_firestore/cloud_firestore.dart';

class UserExperience {
  final String userId;
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final int dailyXP;
  final int weeklyXP;
  final int monthlyXP;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final List<String> unlockedAchievements;
  final Map<String, int> activityStats;
  final bool streakFreezeUsed;
  final int streakFreezeCount;
  final DateTime? lastStreakFreezeDate;
  final Map<String, dynamic> weeklyGoals;
  final int totalLessonsCompleted;
  final int totalQuizScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserExperience({
    required this.userId,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.xpToNextLevel = 100,
    this.dailyXP = 0,
    this.weeklyXP = 0,
    this.monthlyXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.unlockedAchievements = const [],
    this.activityStats = const {},
    this.streakFreezeUsed = false,
    this.streakFreezeCount = 0,
    this.lastStreakFreezeDate,
    this.weeklyGoals = const {},
    this.totalLessonsCompleted = 0,
    this.totalQuizScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate level from total XP
  static int calculateLevel(int totalXP) {
    if (totalXP < 100) return 1;
    if (totalXP < 300) return 2;
    if (totalXP < 600) return 3;
    if (totalXP < 1000) return 4;
    if (totalXP < 1500) return 5;
    if (totalXP < 2100) return 6;
    if (totalXP < 2800) return 7;
    if (totalXP < 3600) return 8;
    if (totalXP < 4500) return 9;
    if (totalXP < 5500) return 10;

    // After level 10, each level requires 1000 XP more
    return 10 + ((totalXP - 5500) ~/ 1000);
  }

  // Calculate XP needed for next level
  static int calculateXPToNextLevel(int totalXP) {
    final currentLevel = calculateLevel(totalXP);
    final nextLevelXP = getXPRequiredForLevel(currentLevel + 1);
    return nextLevelXP - totalXP;
  }

  // Get XP required for specific level
  static int getXPRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 300;
    if (level == 4) return 600;
    if (level == 5) return 1000;
    if (level == 6) return 1500;
    if (level == 7) return 2100;
    if (level == 8) return 2800;
    if (level == 9) return 3600;
    if (level == 10) return 4500;
    if (level == 11) return 5500;

    // After level 11, each level requires 1000 XP more
    return 5500 + ((level - 11) * 1000);
  }

  // Get level title/name
  String get levelTitle {
    switch (currentLevel) {
      case 1:
        return 'Học viên mới';
      case 2:
        return 'Người mới bắt đầu';
      case 3:
        return 'Học sinh cần cù';
      case 4:
        return 'Người học nghiêm túc';
      case 5:
        return 'Học giả trẻ';
      case 6:
        return 'Chuyên gia ngôn ngữ';
      case 7:
        return 'Bậc thầy từ vựng';
      case 8:
        return 'Cao thủ tiếng Việt';
      case 9:
        return 'Siêu sao DHV';
      case 10:
        return 'Huyền thoại';
      default:
        return 'Thần thoại cấp ${currentLevel - 10}';
    }
  }

  // Check if user can use streak freeze
  bool canUseStreakFreeze() {
    if (streakFreezeCount >= 3) return false;
    if (lastStreakFreezeDate != null) {
      final daysSinceLastFreeze =
          DateTime.now().difference(lastStreakFreezeDate!).inDays;
      return daysSinceLastFreeze >= 7; // Can only use once per week
    }
    return true;
  }

  // Factory method from Firestore
  factory UserExperience.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserExperience(
      userId: doc.id,
      totalXP: data['totalXP'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      xpToNextLevel: data['xpToNextLevel'] ?? 100,
      dailyXP: data['dailyXP'] ?? 0,
      weeklyXP: data['weeklyXP'] ?? 0,
      monthlyXP: data['monthlyXP'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastStudyDate: (data['lastStudyDate'] as Timestamp?)?.toDate(),
      unlockedAchievements:
          List<String>.from(data['unlockedAchievements'] ?? []),
      activityStats: Map<String, int>.from(data['activityStats'] ?? {}),
      streakFreezeUsed: data['streakFreezeUsed'] ?? false,
      streakFreezeCount: data['streakFreezeCount'] ?? 0,
      lastStreakFreezeDate:
          (data['lastStreakFreezeDate'] as Timestamp?)?.toDate(),
      weeklyGoals: Map<String, dynamic>.from(data['weeklyGoals'] ?? {}),
      totalLessonsCompleted: data['totalLessonsCompleted'] ?? 0,
      totalQuizScore: data['totalQuizScore'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'xpToNextLevel': xpToNextLevel,
      'dailyXP': dailyXP,
      'weeklyXP': weeklyXP,
      'monthlyXP': monthlyXP,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate':
          lastStudyDate != null ? Timestamp.fromDate(lastStudyDate!) : null,
      'unlockedAchievements': unlockedAchievements,
      'activityStats': activityStats,
      'streakFreezeUsed': streakFreezeUsed,
      'streakFreezeCount': streakFreezeCount,
      'lastStreakFreezeDate': lastStreakFreezeDate != null
          ? Timestamp.fromDate(lastStreakFreezeDate!)
          : null,
      'weeklyGoals': weeklyGoals,
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalQuizScore': totalQuizScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create copy with updated values
  UserExperience copyWith({
    int? totalXP,
    int? currentLevel,
    int? xpToNextLevel,
    int? dailyXP,
    int? weeklyXP,
    int? monthlyXP,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    List<String>? unlockedAchievements,
    Map<String, int>? activityStats,
    bool? streakFreezeUsed,
    int? streakFreezeCount,
    DateTime? lastStreakFreezeDate,
    Map<String, dynamic>? weeklyGoals,
    int? totalLessonsCompleted,
    int? totalQuizScore,
    DateTime? updatedAt,
  }) {
    return UserExperience(
      userId: userId,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      dailyXP: dailyXP ?? this.dailyXP,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      monthlyXP: monthlyXP ?? this.monthlyXP,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      activityStats: activityStats ?? this.activityStats,
      streakFreezeUsed: streakFreezeUsed ?? this.streakFreezeUsed,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      lastStreakFreezeDate: lastStreakFreezeDate ?? this.lastStreakFreezeDate,
      weeklyGoals: weeklyGoals ?? this.weeklyGoals,
      totalLessonsCompleted:
          totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalQuizScore: totalQuizScore ?? this.totalQuizScore,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// XP Activity Types
enum XPActivityType {
  lessonCompleted(25, 'Hoàn thành bài học'),
  quizPerfect(50, 'Quiz điểm tuyệt đối'),
  quizGood(30, 'Quiz điểm cao'),
  quizAverage(15, 'Quiz điểm trung bình'),
  dailyStreak(10, 'Duy trì streak hàng ngày'),
  weeklyStreak(50, 'Streak 7 ngày'),
  monthlyStreak(200, 'Streak 30 ngày'),
  firstLesson(20, 'Bài học đầu tiên'),
  unitCompleted(100, 'Hoàn thành unit'),
  dhvCoreCompleted(300, 'Hoàn thành DHV Core'),
  lifeThemeStarted(50, 'Bắt đầu Life Theme'),
  pronunciationPractice(15, 'Luyện phát âm'),
  chatbotInteraction(10, 'Tương tác với chatbot'),
  profileCompleted(25, 'Hoàn thiện profile'),
  achievementUnlocked(30, 'Mở khóa thành tựu');

  const XPActivityType(this.baseXP, this.description);
  final int baseXP;
  final String description;
}
