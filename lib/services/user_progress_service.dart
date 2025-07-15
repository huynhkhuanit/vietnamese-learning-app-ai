import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

// ===============================================
// USER PROGRESS SERVICE - FIREBASE INTEGRATION
// ===============================================
class UserProgressService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get user progress document reference
  static DocumentReference get userProgressDoc {
    if (currentUser == null) throw Exception('User not logged in');
    return _firestore.collection('userProgress').doc(currentUser!.uid);
  }

  // Initialize user progress for new users
  static Future<void> initializeUserProgress() async {
    if (currentUser == null) return;

    final docSnapshot = await userProgressDoc.get();
    if (!docSnapshot.exists) {
      await userProgressDoc.set({
        'userId': currentUser!.uid,
        'email': currentUser!.email,
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
      });
    }
  }

  // Get user progress stream
  static Stream<DocumentSnapshot> getUserProgressStream() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    return userProgressDoc.snapshots();
  }

  // Mark lesson as completed
  static Future<void> markLessonCompleted(
      int lessonId, bool isCore, int xpGained) async {
    if (currentUser == null) return;

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';

    await userProgressDoc.update({
      '$sectionKey.completedLessons': FieldValue.arrayUnion([lessonId]),
      '$sectionKey.totalXP': FieldValue.increment(xpGained),
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastStudyDate': FieldValue.serverTimestamp(),
    });

    // Update current lesson to next available
    await _updateCurrentLesson(isCore, lessonId);

    // Check for achievements
    await _checkAchievements(lessonId, isCore);
  }

  // Update current lesson pointer
  static Future<void> _updateCurrentLesson(
      bool isCore, int completedLessonId) async {
    if (currentUser == null) return;

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';

    // Get current progress
    final snapshot = await userProgressDoc.get();
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data != null && data[sectionKey] != null) {
      final sectionData = data[sectionKey] as Map<String, dynamic>;
      final currentLesson = sectionData['currentLesson'] ?? (isCore ? 1 : 100);

      // Only update if the completed lesson is the current lesson
      if (completedLessonId == currentLesson) {
        // Find next lesson to unlock
        int nextLessonId = _getNextLessonId(completedLessonId, isCore);

        print(
            'DEBUG: Updating currentLesson from $currentLesson to $nextLessonId');

        if (nextLessonId != -1) {
          await userProgressDoc.update({
            '$sectionKey.currentLesson': nextLessonId,
          });
          print('DEBUG: CurrentLesson updated successfully to $nextLessonId');
        } else {
          print('DEBUG: No next lesson available after $completedLessonId');
        }
      } else {
        print(
            'DEBUG: Not updating currentLesson - completed lesson $completedLessonId is not current lesson $currentLesson');
      }
    }
  }

  // Get next lesson ID based on current lesson and type
  static int _getNextLessonId(int currentLessonId, bool isCore) {
    if (isCore) {
      // DHV Core lessons: 1-16
      if (currentLessonId < 16) {
        return currentLessonId + 1;
      }
    } else {
      // Life Theme lessons: 100-107, 200-207, etc.
      if (currentLessonId >= 100 && currentLessonId < 607) {
        // Kiểm tra nếu là bài cuối của unit (107, 207, 307, etc.)
        if (currentLessonId % 100 == 7) {
          // Chuyển sang unit tiếp theo - bài đầu tiên của unit mới
          int currentUnit = currentLessonId ~/ 100;
          int nextUnit = currentUnit + 1;
          if (nextUnit <= 6) {
            // Chỉ có 6 units - bài đầu của unit tiếp theo
            return nextUnit * 100; // Ví dụ: từ 107 → 200, từ 207 → 300
          }
        } else {
          // Bài tiếp theo trong cùng unit
          return currentLessonId + 1;
        }
      }
    }
    return -1; // No more lessons
  }

  // Check for achievements
  static Future<void> _checkAchievements(int lessonId, bool isCore) async {
    if (currentUser == null) return;

    List<String> newAchievements = [];

    // Get current progress
    final snapshot = await userProgressDoc.get();
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      final List<dynamic> currentAchievements = data['achievements'] ?? [];

      // DHV Core completion achievements
      if (isCore) {
        if (lessonId == 8 &&
            !currentAchievements.contains('dhv_unit1_complete')) {
          newAchievements.add('dhv_unit1_complete');
        }
        if (lessonId == 16 && !currentAchievements.contains('dhv_graduate')) {
          newAchievements.add('dhv_graduate');
        }
      }

      // Life Theme achievements
      if (!isCore) {
        int unitNumber = lessonId ~/ 100;
        String achievementKey = 'life_unit${unitNumber}_complete';

        if (lessonId % 100 == 7 &&
            !currentAchievements.contains(achievementKey)) {
          newAchievements.add(achievementKey);
        }
      }

      // Add new achievements
      if (newAchievements.isNotEmpty) {
        await userProgressDoc.update({
          'achievements': FieldValue.arrayUnion(newAchievements),
        });

        // Send enhanced achievement notifications
        final notificationService = NotificationService();
        for (final achievementId in newAchievements) {
          await notificationService
              .sendEnhancedAchievementNotification(achievementId);
          print('Achievement notification sent for: $achievementId');
        }
      }
    }
  }

  // Check if lesson is unlocked - ENHANCED: Improved logic for Life Theme
  static bool isLessonUnlocked(
      int lessonId, bool isCore, Map<String, dynamic>? progressData) {
    if (progressData == null) {
      return lessonId == 1 || lessonId == 100; // First lessons always unlocked
    }

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';
    final sectionData = progressData[sectionKey] as Map<String, dynamic>?;

    if (sectionData == null) return lessonId == 1 || lessonId == 100;

    final List<dynamic> completedLessons =
        sectionData['completedLessons'] ?? [];
    final int currentLesson =
        sectionData['currentLesson'] ?? (isCore ? 1 : 100);

    // Bài học được mở khóa nếu:
    // 1. Đã hoàn thành rồi
    if (completedLessons.contains(lessonId)) {
      return true;
    }

    // 2. Là bài học hiện tại (currentLesson)
    if (lessonId == currentLesson) {
      return true;
    }

    // 3. FIXED: Allow next lesson unlock immediately for Life Theme
    if (!isCore && lessonId >= 100) {
      // Kiểm tra xem có phải bài đầu tiên của một unit mới không
      if (lessonId % 100 == 0) {
        // Đây là bài đầu tiên của unit (100, 200, 300, etc.)
        int unitNumber = lessonId ~/ 100;

        if (unitNumber == 1) {
          return true; // Unit 1 luôn unlock
        }

        // Kiểm tra xem unit trước đó đã hoàn thành chưa
        int previousUnitLastLesson = (unitNumber - 1) * 100 + 7;
        return completedLessons.contains(previousUnitLastLesson);
      }

      // Đối với các bài khác, cho phép unlock nếu:
      // 1. Bài trước đã completed, HOẶC
      // 2. Là bài tiếp theo ngay sau current lesson
      int previousLessonId = lessonId - 1;

      // Nếu là bài đầu tiên trong unit (101, 201, etc.) thì check bài 100, 200, etc.
      if (lessonId % 100 == 1) {
        previousLessonId = lessonId - 1; // 101 -> 100, 201 -> 200
      }

      return completedLessons.contains(previousLessonId) ||
          (lessonId == currentLesson + 1);
    }

    // 4. For DHV Core, use similar logic
    if (isCore) {
      if (lessonId == 1) return true; // First lesson always unlocked
      return completedLessons.contains(lessonId - 1) ||
          (lessonId == currentLesson + 1);
    }

    return false;
  }

  // Check if lesson is completed
  static bool isLessonCompleted(
      int lessonId, bool isCore, Map<String, dynamic>? progressData) {
    if (progressData == null) return false;

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';
    final sectionData = progressData[sectionKey] as Map<String, dynamic>?;

    if (sectionData == null) return false;

    final List<dynamic> completedLessons =
        sectionData['completedLessons'] ?? [];
    return completedLessons.contains(lessonId);
  }

  // Get total XP for section
  static int getTotalXP(bool isCore, Map<String, dynamic>? progressData) {
    if (progressData == null) return 0;

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';
    final sectionData = progressData[sectionKey] as Map<String, dynamic>?;

    if (sectionData == null) return 0;

    return (sectionData['totalXP'] ?? 0) as int;
  }

  // Get completion percentage for a unit
  static double getUnitProgress(
      int unitNumber, bool isCore, Map<String, dynamic>? progressData) {
    if (progressData == null) return 0.0;

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';
    final sectionData = progressData[sectionKey] as Map<String, dynamic>?;

    if (sectionData == null) return 0.0;

    final List<dynamic> completedLessons =
        sectionData['completedLessons'] ?? [];

    int totalLessonsInUnit = 8; // Each unit has 8 lessons
    int completedInUnit = 0;

    if (isCore) {
      // DHV Core: Unit 1 (1-8), Unit 2 (9-16)
      int startLesson = (unitNumber - 1) * 8 + 1;
      int endLesson = unitNumber * 8;

      for (int i = startLesson; i <= endLesson; i++) {
        if (completedLessons.contains(i)) {
          completedInUnit++;
        }
      }
    } else {
      // Life Theme: Unit 1 (100-107), Unit 2 (200-207), etc.
      int baseId = unitNumber * 100;

      for (int i = 0; i < 8; i++) {
        if (completedLessons.contains(baseId + i)) {
          completedInUnit++;
        }
      }
    }

    return completedInUnit / totalLessonsInUnit;
  }

  // Get user statistics
  static Map<String, dynamic> getUserStats(Map<String, dynamic>? progressData) {
    if (progressData == null) {
      return {
        'dhvCoreXP': 0,
        'lifeThemeXP': 0,
        'totalXP': 0,
        'completedCoreUnits': 0,
        'completedLifeUnits': 0,
        'achievements': [],
        'streakDays': 0,
      };
    }

    final dhvCoreXP = getTotalXP(true, progressData);
    final lifeThemeXP = getTotalXP(false, progressData);
    final achievements = progressData['achievements'] ?? [];
    final streakDays = progressData['streakDays'] ?? 0;

    return {
      'dhvCoreXP': dhvCoreXP,
      'lifeThemeXP': lifeThemeXP,
      'totalXP': dhvCoreXP + lifeThemeXP,
      'completedCoreUnits':
          achievements.where((a) => a.toString().startsWith('dhv_unit')).length,
      'completedLifeUnits': achievements
          .where((a) => a.toString().startsWith('life_unit'))
          .length,
      'achievements': achievements,
      'streakDays': streakDays,
    };
  }

  // ===============================================
  // DEBUGGING AND TESTING METHODS
  // ===============================================

  // Debug method to test unlock logic for a range of lessons
  static void debugUnlockLogic(Map<String, dynamic>? progressData,
      {bool isCore = false}) {
    if (progressData == null) {
      print('DEBUG: No progress data available');
      return;
    }

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';
    final sectionData = progressData[sectionKey] as Map<String, dynamic>?;

    if (sectionData == null) {
      print('DEBUG: No $sectionKey data available');
      return;
    }

    final List<dynamic> completedLessons =
        sectionData['completedLessons'] ?? [];
    final int currentLesson =
        sectionData['currentLesson'] ?? (isCore ? 1 : 100);

    print(
        '\n=== DEBUG UNLOCK LOGIC for ${isCore ? 'DHV Core' : 'Life Theme'} ===');
    print('Completed lessons: $completedLessons');
    print('Current lesson: $currentLesson');
    print('');

    if (isCore) {
      // Test DHV Core lessons 1-16
      for (int i = 1; i <= 16; i++) {
        final unlocked = isLessonUnlocked(i, true, progressData);
        final completed = isLessonCompleted(i, true, progressData);
        print('Lesson $i: unlocked=$unlocked, completed=$completed');
      }
    } else {
      // Test Life Theme lessons 100-107, 200-207
      for (int unit = 1; unit <= 2; unit++) {
        print('--- Unit $unit ---');
        for (int lesson = 0; lesson <= 7; lesson++) {
          final lessonId = unit * 100 + lesson;
          final unlocked = isLessonUnlocked(lessonId, false, progressData);
          final completed = isLessonCompleted(lessonId, false, progressData);
          final nextId = _getNextLessonId(lessonId, false);
          print(
              'Lesson $lessonId: unlocked=$unlocked, completed=$completed, nextId=$nextId');
        }
        print('');
      }
    }
    print('=== END DEBUG ===\n');
  }

  // Method to simulate lesson completion for testing
  static Future<void> debugCompleteLesson(int lessonId, bool isCore) async {
    print('DEBUG: Simulating completion of lesson $lessonId (isCore: $isCore)');

    try {
      await markLessonCompleted(lessonId, isCore, 30);
      print('DEBUG: Lesson $lessonId marked as completed successfully');

      // Get updated progress
      final snapshot = await userProgressDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        debugUnlockLogic(data, isCore: isCore);
      }
    } catch (e) {
      print('DEBUG ERROR: Failed to complete lesson $lessonId: $e');
    }
  }

  // Get next available lesson for user
  static int getNextAvailableLesson(
      bool isCore, Map<String, dynamic>? progressData) {
    if (progressData == null) {
      return isCore ? 1 : 100;
    }

    final String sectionKey = isCore ? 'dhvCore' : 'lifeTheme';
    final sectionData = progressData[sectionKey] as Map<String, dynamic>?;

    if (sectionData == null) {
      return isCore ? 1 : 100;
    }

    final int currentLesson =
        sectionData['currentLesson'] ?? (isCore ? 1 : 100);
    return currentLesson;
  }

  // Quick test for current user's Life Theme progress
  static Future<void> testCurrentProgress() async {
    try {
      final snapshot = await userProgressDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        print('\n=== TESTING CURRENT PROGRESS ===');
        debugUnlockLogic(data, isCore: false);

        // Test specific lessons 103-106
        for (int i = 103; i <= 106; i++) {
          final unlocked = isLessonUnlocked(i, false, data);
          final completed = isLessonCompleted(i, false, data);
          print(
              'SPECIFIC TEST - Lesson $i: unlocked=$unlocked, completed=$completed');
        }
        print('=== END TEST ===\n');
      }
    } catch (e) {
      print('ERROR testing progress: $e');
    }
  }
}
