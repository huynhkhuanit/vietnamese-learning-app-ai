enum GoalType {
  casual(5, 'Thoải mái', 'Học 5 phút mỗi ngày', '🌱'),
  regular(10, 'Thường xuyên', 'Học 10 phút mỗi ngày', '⚡'),
  serious(15, 'Nghiêm túc', 'Học 15 phút mỗi ngày', '🔥'),
  intense(20, 'Chuyên cần', 'Học 20 phút mỗi ngày', '💪');

  const GoalType(this.dailyMinutes, this.title, this.description, this.emoji);

  final int dailyMinutes;
  final String title;
  final String description;
  final String emoji;
}

class LearningGoal {
  final String id;
  final String userId;
  final GoalType goalType;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final int todayXP;
  final int todayMinutes;
  final bool streakFreezeUsed;
  final int streakFreezeCount;
  final Map<String, int> weeklyProgress; // day -> minutes
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reminderEnabled;
  final DateTime? reminderTime;
  final List<String> achievements;

  const LearningGoal({
    required this.id,
    required this.userId,
    required this.goalType,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivityDate,
    this.todayXP = 0,
    this.todayMinutes = 0,
    this.streakFreezeUsed = false,
    this.streakFreezeCount = 0,
    this.weeklyProgress = const {},
    required this.createdAt,
    required this.updatedAt,
    this.reminderEnabled = true,
    this.reminderTime,
    this.achievements = const [],
  });

  factory LearningGoal.fromMap(Map<String, dynamic> map) {
    return LearningGoal(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      goalType: GoalType.values.firstWhere(
        (e) => e.name == map['goalType'],
        orElse: () => GoalType.regular,
      ),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActivityDate: DateTime.fromMillisecondsSinceEpoch(
        map['lastActivityDate'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      todayXP: map['todayXP'] ?? 0,
      todayMinutes: map['todayMinutes'] ?? 0,
      streakFreezeUsed: map['streakFreezeUsed'] ?? false,
      streakFreezeCount: map['streakFreezeCount'] ?? 0,
      weeklyProgress: Map<String, int>.from(map['weeklyProgress'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      reminderEnabled: map['reminderEnabled'] ?? true,
      reminderTime: map['reminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime'])
          : null,
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'goalType': goalType.name,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate.millisecondsSinceEpoch,
      'todayXP': todayXP,
      'todayMinutes': todayMinutes,
      'streakFreezeUsed': streakFreezeUsed,
      'streakFreezeCount': streakFreezeCount,
      'weeklyProgress': weeklyProgress,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'achievements': achievements,
    };
  }

  LearningGoal copyWith({
    String? id,
    String? userId,
    GoalType? goalType,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    int? todayXP,
    int? todayMinutes,
    bool? streakFreezeUsed,
    int? streakFreezeCount,
    Map<String, int>? weeklyProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? reminderEnabled,
    DateTime? reminderTime,
    List<String>? achievements,
  }) {
    return LearningGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      todayXP: todayXP ?? this.todayXP,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      streakFreezeUsed: streakFreezeUsed ?? this.streakFreezeUsed,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      achievements: achievements ?? this.achievements,
    );
  }

  // Helper methods
  bool get hasMetDailyGoal => todayMinutes >= goalType.dailyMinutes;

  double get dailyProgress =>
      (todayMinutes / goalType.dailyMinutes).clamp(0.0, 1.0);

  bool get isOnStreak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );

    return today.difference(lastActivity).inDays <= 1;
  }

  bool get streakInDanger {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );

    return today.difference(lastActivity).inDays == 0 && !hasMetDailyGoal;
  }

  int get streakFreezesRemaining => 3 - streakFreezeCount;

  bool get canUseStreakFreeze =>
      streakFreezesRemaining > 0 && !streakFreezeUsed && streakInDanger;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requirement;
  final AchievementType type;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requirement,
    required this.type,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;
}

enum AchievementType {
  streak,
  xp,
  lessons,
  perfect,
}
