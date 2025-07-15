import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int dailyReminderId = 1;
  static const int streakReminderId = 2;
  static const int lessonReminderId = 3;
  static const int motivationalId = 4;
  static const int achievementId = 5;

  // SharedPreferences keys
  static const String _keyDailyReminder = 'daily_reminder_enabled';
  static const String _keyLearningStreak = 'learning_streak_enabled';
  static const String _keyAchievements = 'achievement_notifications_enabled';
  static const String _keyLessonReminders = 'lesson_reminders_enabled';
  static const String _keyWeekendFreeze = 'weekend_freeze_enabled';
  static const String _keyMotivational = 'motivational_notifications_enabled';
  static const String _keyReminderTime = 'reminder_time';
  static const String _keyNotificationFrequency = 'notification_frequency';
  static const String _keyQuietStartTime = 'quiet_start_time';
  static const String _keyQuietEndTime = 'quiet_end_time';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;

      // Schedule initial notifications based on current settings
      await _scheduleAllNotifications();
    } catch (e) {
      print('Failed to initialize NotificationService: $e');
      _isInitialized = false;

      // Even if exact alarms fail, mark as initialized for basic functionality
      if (e.toString().contains('exact_alarms_not_permitted')) {
        print('Continuing with inexact notifications...');
        _isInitialized = true;
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();

      // Request exact alarm permission on Android 12+
      try {
        final androidInfo = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();
        print('Exact alarms permission: $androidInfo');
      } catch (e) {
        print('Exact alarms not supported or permission denied: $e');
      }
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  // Check if app can schedule exact alarms
  Future<bool> _canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      try {
        final androidImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final canSchedule =
            await androidImplementation?.canScheduleExactNotifications();
        return canSchedule ?? false;
      } catch (e) {
        print('Error checking exact alarm permission: $e');
        return false;
      }
    }
    return true; // iOS doesn't have this restriction
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    // Handle notification tap
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      } else if (Platform.isIOS) {
        final status = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return status?.isEnabled ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  // Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'dailyReminder': prefs.getBool(_keyDailyReminder) ?? true,
        'learningStreak': prefs.getBool(_keyLearningStreak) ?? true,
        'achievements': prefs.getBool(_keyAchievements) ?? true,
        'lessonReminders': prefs.getBool(_keyLessonReminders) ?? true,
        'weekendFreeze': prefs.getBool(_keyWeekendFreeze) ?? false,
        'motivational': prefs.getBool(_keyMotivational) ?? true,
        'reminderTime': prefs.getString(_keyReminderTime) ?? '19:00',
        'frequency': prefs.getInt(_keyNotificationFrequency) ?? 1,
        'quietStartTime': prefs.getString(_keyQuietStartTime) ?? '22:00',
        'quietEndTime': prefs.getString(_keyQuietEndTime) ?? '08:00',
      };
    } catch (e) {
      print('Error getting notification settings: $e');
      // Return default settings if error occurs
      return {
        'dailyReminder': true,
        'learningStreak': true,
        'achievements': true,
        'lessonReminders': true,
        'weekendFreeze': false,
        'motivational': true,
        'reminderTime': '19:00',
        'frequency': 1,
        'quietStartTime': '22:00',
        'quietEndTime': '08:00',
      };
    }
  }

  // Save notification settings
  Future<void> saveNotificationSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (value.runtimeType) {
      case bool:
        await prefs.setBool(key, value);
        break;
      case int:
        await prefs.setInt(key, value);
        break;
      case String:
        await prefs.setString(key, value);
        break;
    }

    // Re-schedule notifications when settings change
    await _scheduleAllNotifications();
  }

  // Schedule all notifications based on current settings
  Future<void> _scheduleAllNotifications() async {
    final settings = await getNotificationSettings();

    // Cancel all existing notifications
    await _flutterLocalNotificationsPlugin.cancelAll();

    if (!await areNotificationsEnabled()) return;

    final reminderTime = settings['reminderTime'] as String;
    final frequency = settings['frequency'] as int;

    // Schedule daily reminders
    if (settings['dailyReminder'] as bool) {
      await _scheduleDailyReminders(reminderTime, frequency);
    }

    // Schedule streak reminders
    if (settings['learningStreak'] as bool) {
      await _scheduleStreakReminders();
    }

    // Schedule lesson reminders
    if (settings['lessonReminders'] as bool) {
      await _scheduleLessonReminders(reminderTime);
    }

    // Schedule motivational notifications
    if (settings['motivational'] as bool) {
      await _scheduleMotivationalNotifications();
    }
  }

  Future<void> _scheduleDailyReminders(String time, int frequency) async {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final messages = [
      'Đã đến giờ học tiếng Anh! 📚 Hãy duy trì streak của bạn!',
      'Thời gian luyện tập! 🎯 Chỉ 15 phút thôi!',
      'Đừng quên mục tiêu học tập hôm nay! 🌟',
      'Học một chút mỗi ngày sẽ tạo nên kết quả lớn! 💪',
      'Streak của bạn đang chờ đó! Hãy tiếp tục! 🔥',
    ];

    switch (frequency) {
      case 1: // Once daily
        await _scheduleRepeatingNotification(
          dailyReminderId,
          'Nhắc nhở học tập',
          messages[0],
          hour,
          minute,
        );
        break;
      case 2: // Twice daily
        await _scheduleRepeatingNotification(
          dailyReminderId,
          'Nhắc nhở học tập',
          messages[0],
          hour,
          minute,
        );
        await _scheduleRepeatingNotification(
          dailyReminderId + 100,
          'Nhắc nhở học tập',
          messages[1],
          (hour + 8) % 24,
          minute,
        );
        break;
      case 3: // Three times daily
        await _scheduleRepeatingNotification(
          dailyReminderId,
          'Nhắc nhở học tập',
          messages[0],
          9,
          0,
        );
        await _scheduleRepeatingNotification(
          dailyReminderId + 100,
          'Nhắc nhở học tập',
          messages[1],
          15,
          0,
        );
        await _scheduleRepeatingNotification(
          dailyReminderId + 200,
          'Nhắc nhở học tập',
          messages[2],
          hour,
          minute,
        );
        break;
    }
  }

  Future<void> _scheduleStreakReminders() async {
    // This method is called when settings change
    // The actual streak reminder should be scheduled when user completes a lesson
    // For now, we'll just ensure the feature is enabled in settings
    // The actual scheduling should happen in lesson completion logic
  }

  // Call this method when user completes a lesson to schedule streak reminder
  Future<void> scheduleStreakReminderAfterLesson() async {
    final settings = await getNotificationSettings();
    if (!(settings['learningStreak'] as bool)) return;

    // Cancel any existing streak reminder
    await _flutterLocalNotificationsPlugin.cancel(streakReminderId);

    // Schedule notification for 20 hours from now
    final now = DateTime.now();
    final reminderTime = now.add(const Duration(hours: 20));

    await _scheduleOneTimeNotification(
      streakReminderId,
      'Streak của bạn có nguy cơ mất! 🔥',
      'Hãy học ít nhất 1 bài để duy trì streak!',
      reminderTime,
    );
  }

  Future<void> _scheduleLessonReminders(String time) async {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    await _scheduleRepeatingNotification(
      lessonReminderId,
      'Hoàn thành bài học',
      'Bạn đã hoàn thành bài học hôm nay chưa? 📖',
      hour,
      minute,
    );
  }

  Future<void> _scheduleMotivationalNotifications() async {
    final motivationalMessages = [
      'Bạn đang làm rất tốt! Tiếp tục phát huy! 🌟',
      'Mỗi ngày học một chút, thành công sẽ đến! 💫',
      'Hành trình 1000 dặm bắt đầu từ bước chân đầu tiên! 👣',
      'Khôn khéo hơn mỗi ngày với PolyglotAI! 🧠',
      'Học tập chính là đầu tư tốt nhất cho bản thân! 💎',
    ];

    // Send motivational notifications randomly throughout the week
    for (int i = 0; i < motivationalMessages.length; i++) {
      final randomHour = 10 + (i * 2); // Spread throughout the day
      await _scheduleRepeatingNotification(
        motivationalId + i,
        'Động viên từ PolyglotAI',
        motivationalMessages[i],
        randomHour,
        0,
      );
    }
  }

  Future<void> _scheduleRepeatingNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    try {
      // Try exact scheduling first, fallback to inexact if permission denied
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminders',
            channelDescription: 'Daily learning reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: await _canScheduleExactAlarms()
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling repeating notification: $e');
      // Fallback to simple show notification
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminders',
            channelDescription: 'Daily learning reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  Future<void> _scheduleOneTimeNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_reminder',
            'Streak Reminders',
            channelDescription: 'Learning streak reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: await _canScheduleExactAlarms()
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling one-time notification: $e');
      // Show immediate notification instead
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_reminder',
            'Streak Reminders',
            channelDescription: 'Learning streak reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        999,
        'Thông báo thử nghiệm',
        'Tuyệt vời! Thông báo đang hoạt động bình thường! 🎉',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      print('Error sending test notification: $e');
      rethrow;
    }
  }

  // Send achievement notification
  Future<void> sendAchievementNotification(String title, String message) async {
    final settings = await getNotificationSettings();
    if (!(settings['achievements'] as bool)) return;

    await _flutterLocalNotificationsPlugin.show(
      achievementId,
      '🏆 $title',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Achievement notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Check if in quiet hours
  Future<bool> isInQuietHours() async {
    final settings = await getNotificationSettings();
    final quietStart = settings['quietStartTime'] as String;
    final quietEnd = settings['quietEndTime'] as String;

    final now = DateTime.now();
    final startParts = quietStart.split(':');
    final endParts = quietEnd.split(':');

    final startTime = DateTime(now.year, now.month, now.day,
        int.parse(startParts[0]), int.parse(startParts[1]));
    final endTime = DateTime(now.year, now.month, now.day,
        int.parse(endParts[0]), int.parse(endParts[1]));

    if (startTime.isAfter(endTime)) {
      // Quiet hours cross midnight
      return now.isAfter(startTime) || now.isBefore(endTime);
    } else {
      return now.isAfter(startTime) && now.isBefore(endTime);
    }
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Expose keys for use in UI
  static String get keyDailyReminder => _keyDailyReminder;
  static String get keyLearningStreak => _keyLearningStreak;
  static String get keyAchievements => _keyAchievements;
  static String get keyLessonReminders => _keyLessonReminders;
  static String get keyWeekendFreeze => _keyWeekendFreeze;
  static String get keyMotivational => _keyMotivational;
  static String get keyReminderTime => _keyReminderTime;
  static String get keyNotificationFrequency => _keyNotificationFrequency;
  static String get keyQuietStartTime => _keyQuietStartTime;
  static String get keyQuietEndTime => _keyQuietEndTime;

  // ===============================================
  // ENHANCED DUOLINGO-STYLE FEATURES
  // ===============================================

  // Check and schedule comeback notifications based on user inactivity
  Future<void> checkAndScheduleComebackNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final lastActivity = await _getLastActivityDate(user.uid);
    if (lastActivity == null) return;

    final daysSinceActivity = DateTime.now().difference(lastActivity).inDays;

    if (daysSinceActivity >= 1) {
      await _scheduleComebackNotification(daysSinceActivity);
    }
  }

  Future<DateTime?> _getLastActivityDate(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('userProgress')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['lastStudyDate'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      print('Error getting last activity: $e');
    }
    return null;
  }

  Future<void> _scheduleComebackNotification(int daysAway) async {
    final template = _getComebackTemplate(daysAway);

    // Cancel any existing comeback notification
    await _flutterLocalNotificationsPlugin.cancel(6000 + daysAway);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        6000 + daysAway,
        template.title,
        template.body,
        tz.TZDateTime.now(tz.local).add(const Duration(hours: 2)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'comeback_notifications',
            'Comeback Notifications',
            channelDescription: 'Notifications to bring users back to learning',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: await _canScheduleExactAlarms()
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling comeback notification: $e');
    }
  }

  NotificationTemplate _getComebackTemplate(int daysAway) {
    switch (daysAway) {
      case 1:
        return NotificationTemplate(
          title: 'Bạn đã nghỉ 1 ngày rồi đấy! 😊',
          body: 'Chỉ cần 5 phút để duy trì chuỗi học tập. Cùng quay lại nhé!',
          mood: NotificationMood.gentle,
        );

      case 2:
        return NotificationTemplate(
          title: 'Tiếng Việt nhớ bạn lắm! 🥺',
          body: 'Đã 2 ngày rồi đấy! Streak của bạn đang chờ được cứu!',
          mood: NotificationMood.encouraging,
        );

      case 3:
        return NotificationTemplate(
          title: 'Ủa, bạn đi đâu vậy? 😟',
          body: 'Từ vựng tiếng Việt đang từ từ... quên bạn đấy! Nhanh về thôi!',
          mood: NotificationMood.concerned,
        );

      case 5:
        return NotificationTemplate(
          title: 'Thầy Owl lo lắng quá! 😰',
          body: 'Đã 5 ngày! Anh em DHV đang tìm kiếm bạn khắp nơi!',
          mood: NotificationMood.worried,
        );

      case 7:
        return NotificationTemplate(
          title: 'HELP! Tìm kiếm học viên mất tích! 😱',
          body:
              'Chúng tôi đã báo cáo lên Bộ Giáo dục! Nhanh quay lại cứu streak!',
          mood: NotificationMood.desperate,
        );

      case 14:
        return NotificationTemplate(
          title: 'Plot twist: Owl học tiếng Việt thay bạn! 🤪',
          body:
              'Thầy Owl đã thuộc lòng cả từ điển rồi! Bạn có muốn thua không?',
          mood: NotificationMood.funny,
        );

      default:
        return NotificationTemplate(
          title: 'Huyền thoại đã trở lại! 🔥',
          body:
              'Sau $daysAway ngày vắng mặt, đã đến lúc viết nên câu chuyện mới!',
          mood: NotificationMood.motivational,
        );
    }
  }

  // Enhanced achievement notifications
  Future<void> sendEnhancedAchievementNotification(String achievementId) async {
    final settings = await getNotificationSettings();
    if (!(settings['achievements'] as bool)) return;

    final template = _getAchievementTemplate(achievementId);

    await _flutterLocalNotificationsPlugin.show(
      7000 + achievementId.hashCode,
      template.title,
      template.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'enhanced_achievements',
          'Enhanced Achievements',
          channelDescription: 'Detailed achievement notifications',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  NotificationTemplate _getAchievementTemplate(String achievementId) {
    switch (achievementId) {
      case 'streak_7':
        return NotificationTemplate(
          title: 'Tuần đầu hoàn thành! 🔥',
          body: 'Bạn đã học liên tục 7 ngày! Thầy Owl tự hào về bạn!',
          mood: NotificationMood.encouraging,
        );

      case 'streak_30':
        return NotificationTemplate(
          title: 'Tháng đầu chinh phục! 💪',
          body: '30 ngày kiên trì! Bạn đã là warrior tiếng Việt thực thụ!',
          mood: NotificationMood.motivational,
        );

      case 'dhv_graduate':
        return NotificationTemplate(
          title: 'Tốt nghiệp DHV Core! 🎓',
          body: 'Chúc mừng! Bạn đã hiểu rõ về trường DHV. Giờ đến Life Theme!',
          mood: NotificationMood.encouraging,
        );

      case 'life_unit1_complete':
        return NotificationTemplate(
          title: 'Master Gia đình! 👨‍👩‍👧‍👦',
          body:
              'Unit "Gia đình & Mối quan hệ" hoàn thành! Từ vựng gia đình đã thuộc lòng!',
          mood: NotificationMood.encouraging,
        );

      default:
        return NotificationTemplate(
          title: 'Achievement Unlocked! 🏆',
          body: 'Bạn vừa đạt được thành tựu mới! Tiếp tục phát huy nhé!',
          mood: NotificationMood.encouraging,
        );
    }
  }

  // Schedule cultural tip notifications
  Future<void> scheduleCulturalTipNotification() async {
    final tips = [
      'Mẹo văn hóa: "Xin chào" có thể nói thành "Chào anh/chị" tùy độ tuổi! 🇻🇳',
      'Có biết không: "Cơm" không chỉ là gạo mà còn có nghĩa là "bữa ăn"! 🍚',
      'Văn hóa Việt: Gọi "anh/chị/em" thể hiện sự tôn trọng trong giao tiếp! 🙏',
      'Phát âm hay: "Phở" đọc là "Fuh" chứ không phải "Fo"! 🍜',
      'Nghe nói rằng: Người Việt có thể ăn phở cả sáng, trưa, tối! 😄',
      'Fun fact: "Dương vật" nghĩa là calendar trong tiếng Việt cổ! 📅',
      'Thú vị: Tiếng Việt có 6 thanh điệu khác nhau! 🎵',
      'Biết chưa: "Em" có thể dùng cho cả nam và nữ! 👫',
    ];

    final randomTip = tips[Random().nextInt(tips.length)];
    final randomHour = 10 + Random().nextInt(8); // Between 10 AM - 6 PM

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        8000 + Random().nextInt(1000),
        'Mẹo nhỏ hôm nay! 💡',
        randomTip,
        tz.TZDateTime.now(tz.local).add(Duration(hours: randomHour)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'cultural_tips',
            'Cultural Tips',
            channelDescription:
                'Vietnamese cultural tips and interesting facts',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: await _canScheduleExactAlarms()
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling cultural tip notification: $e');
    }
  }

  // Schedule smart reminders based on user behavior
  Future<void> scheduleSmartReminders() async {
    // Check for comeback notifications
    await checkAndScheduleComebackNotifications();

    // Schedule cultural tips (2-3 times per week)
    if (Random().nextBool()) {
      await scheduleCulturalTipNotification();
    }

    // Schedule weekly progress review (every Sunday)
    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    if (daysUntilSunday == 0) {
      await _scheduleWeeklyProgressNotification();
    }
  }

  Future<void> _scheduleWeeklyProgressNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        9000,
        'Báo cáo tuần! 📊',
        'Xem lại thành tích học tập tuần này và lên kế hoạch tuần tới!',
        tz.TZDateTime.now(tz.local).add(const Duration(days: 7)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_progress',
            'Weekly Progress',
            channelDescription: 'Weekly learning progress reports',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: await _canScheduleExactAlarms()
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling weekly progress notification: $e');
    }
  }

  // Record app activity for comeback notification logic
  Future<void> recordAppActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('userProgress')
          .doc(user.uid)
          .update({
        'lastAppActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording app activity: $e');
    }
  }
}

// ===============================================
// ENHANCED FEATURES - DUOLINGO STYLE NOTIFICATIONS
// ===============================================

enum NotificationMood {
  gentle('🌸', 'Nhẹ nhàng'),
  encouraging('💪', 'Động viên'),
  concerned('😟', 'Lo lắng'),
  worried('😰', 'Băn khoăn'),
  desperate('😱', 'Tuyệt vọng'),
  funny('🤪', 'Hài hước'),
  motivational('🔥', 'Thúc đẩy');

  const NotificationMood(this.emoji, this.description);
  final String emoji;
  final String description;
}

enum SmartNotificationType {
  dailyReminder,
  streakWarning,
  comeback,
  achievement,
  lessonSuggestion,
  streakCelebration,
  unitCompletion,
  weeklyProgress,
  culturalTip,
  pronunciationChallenge
}

class NotificationTemplate {
  final String title;
  final String body;
  final NotificationMood mood;
  final String? imageUrl;
  final Map<String, String>? actionButtons;

  NotificationTemplate({
    required this.title,
    required this.body,
    required this.mood,
    this.imageUrl,
    this.actionButtons,
  });
}
