import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/notification_service.dart';
import '../localization/extension.dart';
import '../widgets/custom_app_bar.dart';
import 'dart:io';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _notificationsEnabled = false;
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      // Ensure notification service is initialized
      if (!_notificationService.isInitialized) {
        await _notificationService.initialize();
      }

      final enabled = await _notificationService.areNotificationsEnabled();
      final settings = await _notificationService.getNotificationSettings();

      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
          _settings = settings;
          _isLoading = false;
        });

        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Lỗi khi tải cài đặt: $e');
      }
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      await _notificationService.saveNotificationSetting(key, value);
      setState(() {
        _settings[_getLocalKey(key)] = value;
      });

      // Show success feedback
      _showSuccessSnackBar('Đã lưu cài đặt');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi lưu cài đặt: $e');
    }
  }

  String _getLocalKey(String serviceKey) {
    // Map service keys to local keys
    switch (serviceKey) {
      case 'daily_reminder_enabled':
        return 'dailyReminder';
      case 'learning_streak_enabled':
        return 'learningStreak';
      case 'achievement_notifications_enabled':
        return 'achievements';
      case 'lesson_reminders_enabled':
        return 'lessonReminders';
      case 'weekend_freeze_enabled':
        return 'weekendFreeze';
      case 'motivational_notifications_enabled':
        return 'motivational';
      case 'reminder_time':
        return 'reminderTime';
      case 'notification_frequency':
        return 'frequency';
      case 'quiet_start_time':
        return 'quietStartTime';
      case 'quiet_end_time':
        return 'quietEndTime';
      default:
        return serviceKey;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF58CC02),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      _showSuccessSnackBar('notification_sent'.tr);
    } catch (e) {
      _showErrorSnackBar('Lỗi khi gửi thông báo: $e');
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await _notificationService.initialize();
      final enabled = await _notificationService.areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
      });

      if (enabled) {
        _showSuccessSnackBar('Đã bật thông báo thành công');
      } else {
        _showErrorSnackBar('Vui lòng cấp quyền thông báo trong cài đặt');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi yêu cầu quyền: $e');
    }
  }

  Future<void> _selectTime(String settingKey, String currentTime) async {
    final timeParts = currentTime.split(':');
    final currentTimeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    TimeOfDay? selectedTime;

    if (Platform.isIOS) {
      selectedTime = await _showCupertinoTimePicker(currentTimeOfDay);
    } else {
      selectedTime = await showTimePicker(
        context: context,
        initialTime: currentTimeOfDay,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: const Color(0xFF58CC02),
                  ),
            ),
            child: child!,
          );
        },
      );
    }

    if (selectedTime != null) {
      final timeString =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      await _updateSetting(settingKey, timeString);
    }
  }

  Future<TimeOfDay?> _showCupertinoTimePicker(TimeOfDay initialTime) async {
    TimeOfDay? selectedTime;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime:
                DateTime(2023, 1, 1, initialTime.hour, initialTime.minute),
            onDateTimeChanged: (DateTime newDateTime) {
              selectedTime = TimeOfDay(
                hour: newDateTime.hour,
                minute: newDateTime.minute,
              );
            },
          ),
        );
      },
    );
    return selectedTime ?? initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'notification_settings'.tr,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Permission status card
                  _buildPermissionCard(),
                  const SizedBox(height: 20),

                  // Notification types
                  if (_notificationsEnabled) ...[
                    _buildSectionTitle('Loại thông báo'),
                    const SizedBox(height: 12),
                    _buildNotificationToggle(
                      'daily_reminder'.tr,
                      'daily_reminder_desc'.tr,
                      Icons.schedule,
                      _settings['dailyReminder'] ?? true,
                      NotificationService.keyDailyReminder,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationToggle(
                      'learning_streak'.tr,
                      'learning_streak_desc'.tr,
                      Icons.local_fire_department,
                      _settings['learningStreak'] ?? true,
                      NotificationService.keyLearningStreak,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationToggle(
                      'lesson_reminders'.tr,
                      'lesson_reminders_desc'.tr,
                      Icons.book,
                      _settings['lessonReminders'] ?? true,
                      NotificationService.keyLessonReminders,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationToggle(
                      'achievement_notifications'.tr,
                      'achievement_notifications_desc'.tr,
                      Icons.emoji_events,
                      _settings['achievements'] ?? true,
                      NotificationService.keyAchievements,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationToggle(
                      'motivational_notifications'.tr,
                      'motivational_notifications_desc'.tr,
                      Icons.favorite,
                      _settings['motivational'] ?? true,
                      NotificationService.keyMotivational,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationToggle(
                      'weekend_freeze'.tr,
                      'weekend_freeze_desc'.tr,
                      Icons.weekend,
                      _settings['weekendFreeze'] ?? false,
                      NotificationService.keyWeekendFreeze,
                    ),

                    const SizedBox(height: 32),

                    // Timing settings
                    _buildSectionTitle('Cài đặt thời gian'),
                    const SizedBox(height: 12),
                    _buildTimeSelector(
                      'reminder_time'.tr,
                      _settings['reminderTime'] ?? '19:00',
                      NotificationService.keyReminderTime,
                    ),
                    const SizedBox(height: 12),
                    _buildFrequencySelector(),
                    const SizedBox(height: 12),
                    _buildTimeSelector(
                      'start_quiet_time'.tr,
                      _settings['quietStartTime'] ?? '22:00',
                      NotificationService.keyQuietStartTime,
                    ),
                    const SizedBox(height: 12),
                    _buildTimeSelector(
                      'end_quiet_time'.tr,
                      _settings['quietEndTime'] ?? '08:00',
                      NotificationService.keyQuietEndTime,
                    ),

                    const SizedBox(height: 32),

                    // Test notification
                    _buildTestNotificationCard(),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _notificationsEnabled
            ? const Color(0xFF58CC02).withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _notificationsEnabled ? const Color(0xFF58CC02) : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _notificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off,
            size: 48,
            color:
                _notificationsEnabled ? const Color(0xFF58CC02) : Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            _notificationsEnabled
                ? 'Thông báo đã được bật'
                : 'permission_required'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _notificationsEnabled
                ? 'Bạn sẽ nhận được thông báo theo cài đặt bên dưới'
                : 'notification_permission_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          if (!_notificationsEnabled) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _requestNotificationPermission,
              icon: const Icon(Icons.notifications, color: Colors.white),
              label: Text(
                'enable_notifications'.tr,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String description,
    IconData icon,
    bool value,
    String settingKey,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: (newValue) => _updateSetting(settingKey, newValue),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF58CC02),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        activeColor: const Color(0xFF58CC02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildTimeSelector(
      String title, String currentTime, String settingKey) {
    return GestureDetector(
      onTap: () => _selectTime(settingKey, currentTime),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1CB0F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.access_time,
                color: Color(0xFF1CB0F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1CB0F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1CB0F6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final frequency = _settings['frequency'] ?? 1;
    final frequencies = [
      {'value': 1, 'label': 'once_daily'.tr},
      {'value': 2, 'label': 'twice_daily'.tr},
      {'value': 3, 'label': 'three_times_daily'.tr},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9600).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.repeat,
                  color: Color(0xFFFF9600),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'notification_frequency'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: frequencies.map((freq) {
              final isSelected = frequency == freq['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => _updateSetting(
                    NotificationService.keyNotificationFrequency,
                    freq['value'],
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF9600)
                          : const Color(0xFFFF9600).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF9600),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      freq['label'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFFFF9600),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bug_report,
            size: 48,
            color: Color(0xFF58CC02),
          ),
          const SizedBox(height: 12),
          Text(
            'test_notification'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'test_notification_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _sendTestNotification,
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text(
              'Gửi thử nghiệm',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
