import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int xpReward;
  final Map<String, dynamic> requirements;
  final bool isSecret;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    this.xpReward = 0,
    this.requirements = const {},
    this.isSecret = false,
    this.unlockedAt,
    this.progress = 0,
    this.maxProgress = 1,
  });

  bool get isUnlocked => unlockedAt != null;
  bool get isCompleted => progress >= maxProgress;
  double get progressPercentage =>
      maxProgress > 0 ? progress / maxProgress : 0.0;

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Achievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🏆',
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => AchievementCategory.general,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == data['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      xpReward: data['xpReward'] ?? 0,
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
      isSecret: data['isSecret'] ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      progress: data['progress'] ?? 0,
      maxProgress: data['maxProgress'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'category': category.name,
      'rarity': rarity.name,
      'xpReward': xpReward,
      'requirements': requirements,
      'isSecret': isSecret,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'progress': progress,
      'maxProgress': maxProgress,
    };
  }

  Achievement copyWith({
    String? title,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementRarity? rarity,
    int? xpReward,
    Map<String, dynamic>? requirements,
    bool? isSecret,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) {
    return Achievement(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      xpReward: xpReward ?? this.xpReward,
      requirements: requirements ?? this.requirements,
      isSecret: isSecret ?? this.isSecret,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }
}

enum AchievementCategory {
  general('Tổng quát', '⭐'),
  streaks('Streak', '🔥'),
  lessons('Bài học', '📚'),
  quiz('Quiz', '🧠'),
  experience('Kinh nghiệm', '💎'),
  social('Xã hội', '👥'),
  special('Đặc biệt', '🌟'),
  dhv('DHV Core', '🏫'),
  lifeTheme('Life Theme', '🌱');

  const AchievementCategory(this.displayName, this.icon);
  final String displayName;
  final String icon;
}

enum AchievementRarity {
  common('Phổ thong', '#999999', 10),
  uncommon('Không phổ biến', '#00ff00', 25),
  rare('Hiếm', '#0099ff', 50),
  epic('Huyền thoại', '#cc00ff', 100),
  legendary('Truyền thuyết', '#ff6600', 250);

  const AchievementRarity(this.displayName, this.color, this.baseXP);
  final String displayName;
  final String color;
  final int baseXP;
}

// Predefined achievements
class PredefinedAchievements {
  static List<Achievement> get allAchievements => [
        // General & First Steps
        Achievement(
          id: 'first_login',
          title: 'Chào mừng đến DHV!',
          description: 'Đăng nhập lần đầu tiên vào ứng dụng',
          icon: '👋',
          category: AchievementCategory.general,
          rarity: AchievementRarity.common,
          xpReward: 25,
        ),

        Achievement(
          id: 'profile_completed',
          title: 'Hoàn thiện bản thân',
          description: 'Hoàn thành profile cá nhân',
          icon: '👤',
          category: AchievementCategory.general,
          rarity: AchievementRarity.common,
          xpReward: 30,
        ),

        Achievement(
          id: 'first_lesson',
          title: 'Bước đầu tiên',
          description: 'Hoàn thành bài học đầu tiên',
          icon: '🚀',
          category: AchievementCategory.lessons,
          rarity: AchievementRarity.common,
          xpReward: 50,
        ),

        // Streak Achievements
        Achievement(
          id: 'streak_3',
          title: 'Khởi đầu tốt!',
          description: 'Học liên tục 3 ngày',
          icon: '🔥',
          category: AchievementCategory.streaks,
          rarity: AchievementRarity.common,
          xpReward: 50,
          requirements: {'streakDays': 3},
          maxProgress: 3,
        ),

        Achievement(
          id: 'streak_7',
          title: 'Tuần hoàn hảo',
          description: 'Học liên tục 7 ngày - Một tuần kiên trì!',
          icon: '🔥',
          category: AchievementCategory.streaks,
          rarity: AchievementRarity.uncommon,
          xpReward: 100,
          requirements: {'streakDays': 7},
          maxProgress: 7,
        ),

        Achievement(
          id: 'streak_30',
          title: 'Tháng Warrior',
          description: 'Học liên tục 30 ngày - Bạn là chiến binh thực thụ!',
          icon: '💪',
          category: AchievementCategory.streaks,
          rarity: AchievementRarity.rare,
          xpReward: 300,
          requirements: {'streakDays': 30},
          maxProgress: 30,
        ),

        Achievement(
          id: 'streak_100',
          title: 'Huyền thoại trăm ngày',
          description: 'Học liên tục 100 ngày - Bạn đã trở thành huyền thoại!',
          icon: '👑',
          category: AchievementCategory.streaks,
          rarity: AchievementRarity.legendary,
          xpReward: 1000,
          requirements: {'streakDays': 100},
          maxProgress: 100,
        ),

        // Lesson Achievements
        Achievement(
          id: 'lessons_10',
          title: 'Học sinh cần cù',
          description: 'Hoàn thành 10 bài học',
          icon: '📖',
          category: AchievementCategory.lessons,
          rarity: AchievementRarity.common,
          xpReward: 75,
          requirements: {'lessonsCompleted': 10},
          maxProgress: 10,
        ),

        Achievement(
          id: 'lessons_50',
          title: 'Học giả trẻ',
          description: 'Hoàn thành 50 bài học',
          icon: '🎓',
          category: AchievementCategory.lessons,
          rarity: AchievementRarity.uncommon,
          xpReward: 200,
          requirements: {'lessonsCompleted': 50},
          maxProgress: 50,
        ),

        Achievement(
          id: 'lessons_100',
          title: 'Bậc thầy học tập',
          description: 'Hoàn thành 100 bài học',
          icon: '🏆',
          category: AchievementCategory.lessons,
          rarity: AchievementRarity.rare,
          xpReward: 500,
          requirements: {'lessonsCompleted': 100},
          maxProgress: 100,
        ),

        // DHV Core Achievements
        Achievement(
          id: 'dhv_lesson_5',
          title: 'Biết về DHV',
          description: 'Hoàn thành 5 bài học DHV Core',
          icon: '🏫',
          category: AchievementCategory.dhv,
          rarity: AchievementRarity.common,
          xpReward: 100,
          requirements: {'dhvLessonsCompleted': 5},
          maxProgress: 5,
        ),

        Achievement(
          id: 'dhv_graduate',
          title: 'Tốt nghiệp DHV!',
          description: 'Hoàn thành toàn bộ DHV Core (Lesson 1-16)',
          icon: '🎓',
          category: AchievementCategory.dhv,
          rarity: AchievementRarity.epic,
          xpReward: 400,
          requirements: {'dhvLessonsCompleted': 16},
          maxProgress: 16,
        ),

        // Life Theme Achievements
        Achievement(
          id: 'life_started',
          title: 'Cuộc sống mới bắt đầu',
          description: 'Bắt đầu Life Theme journey',
          icon: '🌱',
          category: AchievementCategory.lifeTheme,
          rarity: AchievementRarity.uncommon,
          xpReward: 75,
        ),

        Achievement(
          id: 'life_unit_1',
          title: 'Master Gia đình',
          description: 'Hoàn thành Unit 1: Gia đình & Mối quan hệ',
          icon: '👨‍👩‍👧‍👦',
          category: AchievementCategory.lifeTheme,
          rarity: AchievementRarity.rare,
          xpReward: 300,
          requirements: {'unitCompleted': 1},
        ),

        Achievement(
          id: 'life_unit_2',
          title: 'Nghề nghiệp Pro',
          description: 'Hoàn thành Unit 2: Công việc & Nghề nghiệp',
          icon: '💼',
          category: AchievementCategory.lifeTheme,
          rarity: AchievementRarity.rare,
          xpReward: 300,
          requirements: {'unitCompleted': 2},
        ),

        // Quiz Achievements
        Achievement(
          id: 'quiz_perfect_5',
          title: 'Quiz Master',
          description: 'Đạt điểm tuyệt đối 5 lần quiz',
          icon: '🎯',
          category: AchievementCategory.quiz,
          rarity: AchievementRarity.uncommon,
          xpReward: 150,
          requirements: {'perfectQuizzes': 5},
          maxProgress: 5,
        ),

        Achievement(
          id: 'quiz_streak_10',
          title: 'Trí tuệ vô địch',
          description: 'Trả lời đúng 10 câu quiz liên tiếp',
          icon: '🧠',
          category: AchievementCategory.quiz,
          rarity: AchievementRarity.rare,
          xpReward: 250,
          requirements: {'correctAnswersStreak': 10},
          maxProgress: 10,
        ),

        // Experience Achievements
        Achievement(
          id: 'level_5',
          title: 'Lên Level 5',
          description: 'Đạt level 5 - Học giả trẻ',
          icon: '⭐',
          category: AchievementCategory.experience,
          rarity: AchievementRarity.uncommon,
          xpReward: 100,
          requirements: {'level': 5},
        ),

        Achievement(
          id: 'level_10',
          title: 'Huyền thoại Level 10',
          description: 'Đạt level 10 - Trở thành huyền thoại!',
          icon: '👑',
          category: AchievementCategory.experience,
          rarity: AchievementRarity.epic,
          xpReward: 500,
          requirements: {'level': 10},
        ),

        Achievement(
          id: 'xp_1000',
          title: '1000 XP Club',
          description: 'Tích lũy 1000 XP',
          icon: '💎',
          category: AchievementCategory.experience,
          rarity: AchievementRarity.rare,
          xpReward: 200,
          requirements: {'totalXP': 1000},
          maxProgress: 1000,
        ),

        Achievement(
          id: 'xp_5000',
          title: 'XP Millionaire',
          description: 'Tích lũy 5000 XP - Bạn là triệu phú XP!',
          icon: '💰',
          category: AchievementCategory.experience,
          rarity: AchievementRarity.legendary,
          xpReward: 1000,
          requirements: {'totalXP': 5000},
          maxProgress: 5000,
        ),

        // Special Achievements
        Achievement(
          id: 'weekend_warrior',
          title: 'Weekend Warrior',
          description: 'Học vào cuối tuần 4 tuần liên tiếp',
          icon: '⚔️',
          category: AchievementCategory.special,
          rarity: AchievementRarity.epic,
          xpReward: 400,
          requirements: {'weekendStreaks': 4},
          maxProgress: 4,
        ),

        Achievement(
          id: 'night_owl',
          title: 'Cú đêm học tập',
          description: 'Học sau 22:00 trong 7 ngày',
          icon: '🦉',
          category: AchievementCategory.special,
          rarity: AchievementRarity.rare,
          xpReward: 200,
          requirements: {'lateNightSessions': 7},
          maxProgress: 7,
          isSecret: true,
        ),

        Achievement(
          id: 'early_bird',
          title: 'Chim sớm bắt sâu',
          description: 'Học trước 6:00 sáng trong 7 ngày',
          icon: '🐦',
          category: AchievementCategory.special,
          rarity: AchievementRarity.rare,
          xpReward: 200,
          requirements: {'earlyMorningSessions': 7},
          maxProgress: 7,
          isSecret: true,
        ),

        Achievement(
          id: 'pronunciation_master',
          title: 'Phát âm chuẩn',
          description: 'Luyện phát âm 50 lần',
          icon: '🎤',
          category: AchievementCategory.special,
          rarity: AchievementRarity.uncommon,
          xpReward: 150,
          requirements: {'pronunciationPractices': 50},
          maxProgress: 50,
        ),
      ];

  // Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return allAchievements
        .where((achievement) => achievement.category == category)
        .toList();
  }

  // Get achievements by rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return allAchievements
        .where((achievement) => achievement.rarity == rarity)
        .toList();
  }
}
