import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/models/user_experience.dart';
import 'package:language_learning_app/models/achievement.dart';

void main() {
  group('XP System Tests', () {
    test('Level calculation should work correctly', () {
      expect(UserExperience.calculateLevel(0), 1);
      expect(UserExperience.calculateLevel(50), 1);
      expect(UserExperience.calculateLevel(100), 2);
      expect(UserExperience.calculateLevel(300), 3);
      expect(UserExperience.calculateLevel(1000), 5);
      expect(UserExperience.calculateLevel(5500), 10);
      expect(UserExperience.calculateLevel(6500), 11);
    });

    test('XP to next level should be calculated correctly', () {
      expect(UserExperience.calculateXPToNextLevel(0), 100);
      expect(UserExperience.calculateXPToNextLevel(50), 50);
      expect(UserExperience.calculateXPToNextLevel(100), 200);
      expect(UserExperience.calculateXPToNextLevel(250), 50);
    });

    test('XP Activity Types should have correct base XP', () {
      expect(XPActivityType.lessonCompleted.baseXP, 25);
      expect(XPActivityType.quizPerfect.baseXP, 50);
      expect(XPActivityType.quizGood.baseXP, 30);
      expect(XPActivityType.pronunciationPractice.baseXP, 15);
      expect(XPActivityType.chatbotInteraction.baseXP, 10);
      expect(XPActivityType.profileCompleted.baseXP, 25);
    });

    test('Achievement system should have predefined achievements', () {
      final achievements = PredefinedAchievements.allAchievements;

      expect(achievements.isNotEmpty, true);

      // Check for key achievements
      final firstLogin = PredefinedAchievements.getById('first_login');
      expect(firstLogin, isNotNull);
      expect(firstLogin!.title, 'Chào mừng đến DHV!');
      expect(firstLogin.xpReward, 25);

      final streak7 = PredefinedAchievements.getById('streak_7');
      expect(streak7, isNotNull);
      expect(streak7!.title, 'Tuần hoàn hảo');
      expect(streak7.xpReward, 100);

      final dhvGraduate = PredefinedAchievements.getById('dhv_graduate');
      expect(dhvGraduate, isNotNull);
      expect(dhvGraduate!.title, 'Tốt nghiệp DHV!');
      expect(dhvGraduate.xpReward, 400);
    });

    test('Achievement categories should be properly grouped', () {
      final generalAchievements =
          PredefinedAchievements.getByCategory(AchievementCategory.general);
      final streakAchievements =
          PredefinedAchievements.getByCategory(AchievementCategory.streaks);
      final dhvAchievements =
          PredefinedAchievements.getByCategory(AchievementCategory.dhv);

      expect(generalAchievements.isNotEmpty, true);
      expect(streakAchievements.isNotEmpty, true);
      expect(dhvAchievements.isNotEmpty, true);

      // Check that achievements are in correct categories
      expect(generalAchievements.any((a) => a.id == 'first_login'), true);
      expect(streakAchievements.any((a) => a.id == 'streak_7'), true);
      expect(dhvAchievements.any((a) => a.id == 'dhv_graduate'), true);
    });

    test('Achievement rarity should have correct XP values', () {
      expect(AchievementRarity.common.baseXP, 10);
      expect(AchievementRarity.uncommon.baseXP, 25);
      expect(AchievementRarity.rare.baseXP, 50);
      expect(AchievementRarity.epic.baseXP, 100);
      expect(AchievementRarity.legendary.baseXP, 250);
    });

    test('UserExperience level titles should be correct', () {
      final userExp = UserExperience(
        userId: 'test',
        currentLevel: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(userExp.levelTitle, 'Học viên mới');

      final userExp5 = userExp.copyWith(currentLevel: 5);
      expect(userExp5.levelTitle, 'Học giả trẻ');

      final userExp10 = userExp.copyWith(currentLevel: 10);
      expect(userExp10.levelTitle, 'Huyền thoại');
    });

    test('XP Required for levels should be calculated correctly', () {
      expect(UserExperience.getXPRequiredForLevel(1), 0);
      expect(UserExperience.getXPRequiredForLevel(2), 100);
      expect(UserExperience.getXPRequiredForLevel(5), 1000);
      expect(UserExperience.getXPRequiredForLevel(10), 4500);
      expect(UserExperience.getXPRequiredForLevel(11), 5500);
      expect(UserExperience.getXPRequiredForLevel(12), 6500);
    });

    test('Achievement progress calculation should work correctly', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test Achievement',
        description: 'Test Description',
        icon: '🏆',
        category: AchievementCategory.general,
        rarity: AchievementRarity.common,
        progress: 5,
        maxProgress: 10,
      );

      expect(achievement.progressPercentage, 0.5);
      expect(achievement.isCompleted, false);
      expect(achievement.isUnlocked, false);

      final completedAchievement = achievement.copyWith(
        progress: 10,
        unlockedAt: DateTime.now(),
      );

      expect(completedAchievement.progressPercentage, 1.0);
      expect(completedAchievement.isCompleted, true);
      expect(completedAchievement.isUnlocked, true);
    });
  });
}
