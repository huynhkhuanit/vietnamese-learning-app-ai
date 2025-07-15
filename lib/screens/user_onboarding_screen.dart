import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/user_avatar_with_hat.dart';
import '../services/xp_service.dart';
import '../models/user_experience.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen>
    with TickerProviderStateMixin {
  int currentStep = 0;
  final int totalSteps = 8;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final XPService _xpService = XPService();

  // Current user from Firebase
  User? currentUser;
  Map<String, dynamic>? userFirestoreData;
  bool isLoadingUserData = true;

  // User data collection for onboarding
  Map<String, dynamic> userData = {
    'learningGoal': null,
    'currentLevel': null,
    'dailyTime': null,
    'motivation': null,
    'focusAreas': <String>[],
    'preferredStyle': null,
    'ageGroup': null,
    'background': null,
  };

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _initializeUser() async {
    try {
      currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Get additional user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          userFirestoreData = userDoc.data();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingUserData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      setState(() {
        currentStep++;
      });
      _animationController.forward();
    } else {
      _completeOnboarding();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      setState(() {
        currentStep--;
      });
      _animationController.forward();
    }
  }

  void _completeOnboarding() async {
    try {
      // Save onboarding data to Firestore
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'onboardingData': userData,
          'onboardingCompleted': true,
          'onboardingCompletedAt': FieldValue.serverTimestamp(),
        });
      }

      // Award XP for completing profile
      int awardedXP = 0;
      try {
        awardedXP = await _xpService.awardXP(XPActivityType.profileCompleted);
        print('Awarded $awardedXP XP for completing profile');
      } catch (e) {
        print('Error awarding XP for profile completion: $e');
      }

      // Show completion dialog with XP info
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '🎉',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chào mừng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (awardedXP > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+$awardedXP XP',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: const Text(
                'Cảm ơn bạn đã chia sẻ thông tin! AI sẽ tạo lộ trình học tập phù hợp với bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to main app
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Bắt đầu học',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error saving onboarding data: $e');
      // Still show success dialog even if saving fails
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hoàn thành!'),
            content: const Text(
              'Cảm ơn bạn đã chia sẻ thông tin! AI sẽ tạo lộ trình học tập phù hợp với bạn.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bắt đầu học'),
              ),
            ],
          ),
        );
      }
    }
  }

  String _getDisplayName() {
    if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@')[0];
    }
    return 'Bạn';
  }

  String _getEmail() {
    return currentUser?.email ?? 'Chưa có email';
  }

  String _getPhotoUrl() {
    return currentUser?.photoURL ?? '';
  }

  String _getJoinDate() {
    if (userFirestoreData?['createdAt'] != null) {
      final createdAt = userFirestoreData!['createdAt'] as Timestamp;
      final date = createdAt.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    if (currentUser?.metadata.creationTime != null) {
      final date = currentUser!.metadata.creationTime!;
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Hôm nay';
  }

  bool canProceed() {
    switch (currentStep) {
      case 0:
        return userData['learningGoal'] != null;
      case 1:
        return userData['currentLevel'] != null;
      case 2:
        return userData['dailyTime'] != null;
      case 3:
        return userData['motivation'] != null;
      case 4:
        return userData['focusAreas'].isNotEmpty;
      case 5:
        return userData['preferredStyle'] != null;
      case 6:
        return userData['ageGroup'] != null;
      case 7:
        return userData['background'] != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progress = (currentStep + 1) / totalSteps;

    // Show loading indicator while fetching user data
    if (isLoadingUserData) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        appBar: const CustomAppBar(title: 'Thiết lập hồ sơ'),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
          ),
        ),
      );
    }

    // Show error if user is not logged in
    if (currentUser == null) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        appBar: const CustomAppBar(title: 'Thiết lập hồ sơ'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn cần đăng nhập để tiếp tục',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: 'Thiết lập hồ sơ',
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: previousStep,
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value * 50, 0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Welcome header with user info
                    if (currentStep == 0) _buildWelcomeHeader(isDarkMode),
                    Expanded(
                      child: _buildCurrentStep(),
                    ),
                    const SizedBox(height: 24),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF1CB0F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // User avatar with hat
          UserAvatarWithHat(
            user: currentUser,
            size: 60,
            showHat: true,
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Xin chào, ${_getDisplayName()}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    _getEmail(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    'Thành viên từ ${_getJoinDate()}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildLearningGoalStep();
      case 1:
        return _buildCurrentLevelStep();
      case 2:
        return _buildDailyTimeStep();
      case 3:
        return _buildMotivationStep();
      case 4:
        return _buildFocusAreasStep();
      case 5:
        return _buildPreferredStyleStep();
      case 6:
        return _buildAgeGroupStep();
      case 7:
        return _buildBackgroundStep();
      default:
        return Container();
    }
  }

  Widget _buildStepContainer({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 24),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildLearningGoalStep() {
    final goals = [
      {
        'id': 'communication',
        'title': 'Giao tiếp hàng ngày',
        'subtitle': 'Tôi muốn nói chuyện với người Việt',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'travel',
        'title': 'Du lịch Việt Nam',
        'subtitle': 'Tôi sắp đi du lịch và cần tiếng Việt cơ bản',
        'icon': Icons.flight_takeoff,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'business',
        'title': 'Công việc',
        'subtitle': 'Tôi cần tiếng Việt cho công việc',
        'icon': Icons.business_center,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'culture',
        'title': 'Văn hóa & gia đình',
        'subtitle': 'Tôi muốn hiểu văn hóa và kết nối với gia đình',
        'icon': Icons.favorite,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'id': 'academic',
        'title': 'Học thuật',
        'subtitle': 'Tôi học tiếng Việt ở trường/đại học',
        'icon': Icons.school,
        'color': const Color(0xFF9B59B6),
      },
    ];

    return _buildStepContainer(
      title: 'Mục tiêu học tập của bạn?',
      subtitle: 'Chọn lý do chính bạn muốn học tiếng Việt',
      child: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final isSelected = userData['learningGoal'] == goal['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: goal['color'] as Color,
            icon: goal['icon'] as IconData,
            title: goal['title'] as String,
            subtitle: goal['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['learningGoal'] = goal['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentLevelStep() {
    final levels = [
      {
        'id': 'beginner',
        'title': 'Người mới bắt đầu',
        'subtitle': 'Tôi chưa biết gì về tiếng Việt',
        'icon': Icons.looks_one,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'elementary',
        'title': 'Sơ cấp',
        'subtitle': 'Tôi biết một vài từ cơ bản',
        'icon': Icons.looks_two,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'intermediate',
        'title': 'Trung cấp',
        'subtitle': 'Tôi có thể nói những câu đơn giản',
        'icon': Icons.looks_3,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'advanced',
        'title': 'Cao cấp',
        'subtitle': 'Tôi có thể trò chuyện nhưng cần cải thiện',
        'icon': Icons.looks_4,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'id': 'fluent',
        'title': 'Thành thạo',
        'subtitle': 'Tôi nói tốt nhưng muốn hoàn thiện',
        'icon': Icons.looks_5,
        'color': const Color(0xFF9B59B6),
      },
    ];

    return _buildStepContainer(
      title: 'Trình độ hiện tại?',
      subtitle: 'Đánh giá thật về khả năng tiếng Việt của bạn',
      child: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isSelected = userData['currentLevel'] == level['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: level['color'] as Color,
            icon: level['icon'] as IconData,
            title: level['title'] as String,
            subtitle: level['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['currentLevel'] = level['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildDailyTimeStep() {
    final timeOptions = [
      {
        'id': '5-10',
        'title': '5-10 phút',
        'subtitle': 'Thời gian rảnh rỗi ít',
        'icon': Icons.timer,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': '10-20',
        'title': '10-20 phút',
        'subtitle': 'Học đều đặn mỗi ngày',
        'icon': Icons.schedule,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': '20-30',
        'title': '20-30 phút',
        'subtitle': 'Có thời gian tập trung',
        'icon': Icons.access_time,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': '30+',
        'title': '30+ phút',
        'subtitle': 'Muốn học nhanh và sâu',
        'icon': Icons.hourglass_full,
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return _buildStepContainer(
      title: 'Bạn có bao nhiêu thời gian mỗi ngày?',
      subtitle: 'Chúng tôi sẽ tạo lộ trình phù hợp với thời gian của bạn',
      child: ListView.builder(
        itemCount: timeOptions.length,
        itemBuilder: (context, index) {
          final option = timeOptions[index];
          final isSelected = userData['dailyTime'] == option['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: option['color'] as Color,
            icon: option['icon'] as IconData,
            title: option['title'] as String,
            subtitle: option['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['dailyTime'] = option['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildMotivationStep() {
    final motivations = [
      {
        'id': 'curious',
        'title': 'Tò mò về ngôn ngữ',
        'subtitle': 'Tôi thích học ngôn ngữ mới',
        'icon': Icons.psychology,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'necessity',
        'title': 'Cần thiết cho cuộc sống',
        'subtitle': 'Tôi cần tiếng Việt để sinh sống ở Việt Nam',
        'icon': Icons.home,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'relationship',
        'title': 'Mối quan hệ',
        'subtitle': 'Để giao tiếp với bạn bè, người yêu, gia đình',
        'icon': Icons.people,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'achievement',
        'title': 'Thành tựu cá nhân',
        'subtitle': 'Tôi muốn thách thức bản thân',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return _buildStepContainer(
      title: 'Động lực học tập?',
      subtitle: 'Điều gì thúc đẩy bạn học tiếng Việt?',
      child: ListView.builder(
        itemCount: motivations.length,
        itemBuilder: (context, index) {
          final motivation = motivations[index];
          final isSelected = userData['motivation'] == motivation['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: motivation['color'] as Color,
            icon: motivation['icon'] as IconData,
            title: motivation['title'] as String,
            subtitle: motivation['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['motivation'] = motivation['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFocusAreasStep() {
    final areas = [
      {
        'id': 'speaking',
        'title': 'Nói',
        'icon': Icons.record_voice_over,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'listening',
        'title': 'Nghe',
        'icon': Icons.hearing,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'reading',
        'title': 'Đọc',
        'icon': Icons.menu_book,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'writing',
        'title': 'Viết',
        'icon': Icons.edit,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'id': 'vocabulary',
        'title': 'Từ vựng',
        'icon': Icons.abc,
        'color': const Color(0xFF9B59B6),
      },
      {
        'id': 'grammar',
        'title': 'Ngữ pháp',
        'icon': Icons.school,
        'color': const Color(0xFFE67E22),
      },
    ];

    return _buildStepContainer(
      title: 'Kỹ năng muốn tập trung?',
      subtitle:
          'Chọn những kỹ năng bạn muốn cải thiện nhất (có thể chọn nhiều)',
      child: Row(
        children: [
          // Cột trái
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < areas.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMultiSelectCard(
                      isSelected:
                          userData['focusAreas'].contains(areas[i]['id']),
                      color: areas[i]['color'] as Color,
                      icon: areas[i]['icon'] as IconData,
                      title: areas[i]['title'] as String,
                      onTap: () {
                        setState(() {
                          if (userData['focusAreas'].contains(areas[i]['id'])) {
                            userData['focusAreas'].remove(areas[i]['id']);
                          } else {
                            userData['focusAreas'].add(areas[i]['id']);
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Đường ngăn cách
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomPaint(
              painter: DashedLinePainter(),
              child: Container(height: double.infinity),
            ),
          ),
          // Cột phải
          Expanded(
            child: Column(
              children: [
                for (int i = 1; i < areas.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMultiSelectCard(
                      isSelected:
                          userData['focusAreas'].contains(areas[i]['id']),
                      color: areas[i]['color'] as Color,
                      icon: areas[i]['icon'] as IconData,
                      title: areas[i]['title'] as String,
                      onTap: () {
                        setState(() {
                          if (userData['focusAreas'].contains(areas[i]['id'])) {
                            userData['focusAreas'].remove(areas[i]['id']);
                          } else {
                            userData['focusAreas'].add(areas[i]['id']);
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferredStyleStep() {
    final styles = [
      {
        'id': 'visual',
        'title': 'Trực quan',
        'subtitle': 'Học qua hình ảnh, biểu đồ, màu sắc',
        'icon': Icons.image,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'auditory',
        'title': 'Thính giác',
        'subtitle': 'Học qua âm thanh, nhạc, phát âm',
        'icon': Icons.headphones,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'interactive',
        'title': 'Tương tác',
        'subtitle': 'Học qua trò chơi, hoạt động',
        'icon': Icons.games,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'reading',
        'title': 'Đọc viết',
        'subtitle': 'Học qua văn bản, ghi chú',
        'icon': Icons.article,
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return _buildStepContainer(
      title: 'Phong cách học tập?',
      subtitle: 'Bạn học hiệu quả nhất theo cách nào?',
      child: ListView.builder(
        itemCount: styles.length,
        itemBuilder: (context, index) {
          final style = styles[index];
          final isSelected = userData['preferredStyle'] == style['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: style['color'] as Color,
            icon: style['icon'] as IconData,
            title: style['title'] as String,
            subtitle: style['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['preferredStyle'] = style['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildAgeGroupStep() {
    final ageGroups = [
      {
        'id': 'teen',
        'title': '13-17 tuổi',
        'subtitle': 'Học sinh trung học',
        'icon': Icons.school,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'young-adult',
        'title': '18-25 tuổi',
        'subtitle': 'Sinh viên đại học',
        'icon': Icons.person,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'adult',
        'title': '26-40 tuổi',
        'subtitle': 'Người đi làm',
        'icon': Icons.business_center,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'middle-age',
        'title': '41-60 tuổi',
        'subtitle': 'Trung niên',
        'icon': Icons.family_restroom,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'id': 'senior',
        'title': '60+ tuổi',
        'subtitle': 'Cao niên',
        'icon': Icons.elderly,
        'color': const Color(0xFF9B59B6),
      },
    ];

    return _buildStepContainer(
      title: 'Độ tuổi của bạn?',
      subtitle: 'Giúp chúng tôi tùy chỉnh nội dung phù hợp',
      child: ListView.builder(
        itemCount: ageGroups.length,
        itemBuilder: (context, index) {
          final group = ageGroups[index];
          final isSelected = userData['ageGroup'] == group['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: group['color'] as Color,
            icon: group['icon'] as IconData,
            title: group['title'] as String,
            subtitle: group['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['ageGroup'] = group['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBackgroundStep() {
    final backgrounds = [
      {
        'id': 'no-experience',
        'title': 'Chưa từng học tiếng Việt',
        'subtitle': 'Đây là lần đầu tiên tôi học',
        'icon': Icons.fiber_new,
        'color': const Color(0xFF58CC02),
      },
      {
        'id': 'some-exposure',
        'title': 'Có tiếp xúc ít',
        'subtitle': 'Nghe qua từ phim, nhạc, bạn bè',
        'icon': Icons.hearing,
        'color': const Color(0xFF1CB0F6),
      },
      {
        'id': 'formal-learning',
        'title': 'Đã học chính thức',
        'subtitle': 'Học ở trường hoặc khóa học',
        'icon': Icons.school,
        'color': const Color(0xFFFFC93C),
      },
      {
        'id': 'heritage',
        'title': 'Gốc Việt',
        'subtitle': 'Gia đình có người Việt nhưng tôi không nói được',
        'icon': Icons.family_restroom,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'id': 'lived-vietnam',
        'title': 'Đã sống ở Việt Nam',
        'subtitle': 'Đã từng hoặc đang sống ở Việt Nam',
        'icon': Icons.home,
        'color': const Color(0xFF9B59B6),
      },
    ];

    return _buildStepContainer(
      title: 'Kinh nghiệm với tiếng Việt?',
      subtitle: 'Cho chúng tôi biết về nền tảng của bạn',
      child: ListView.builder(
        itemCount: backgrounds.length,
        itemBuilder: (context, index) {
          final background = backgrounds[index];
          final isSelected = userData['background'] == background['id'];

          return _buildSelectionCard(
            isSelected: isSelected,
            color: background['color'] as Color,
            icon: background['icon'] as IconData,
            title: background['title'] as String,
            subtitle: background['subtitle'] as String,
            onTap: () {
              setState(() {
                userData['background'] = background['id'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectionCard({
    required bool isSelected,
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectCard({
    required bool isSelected,
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.black87,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: previousStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF58CC02)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Quay lại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 16),
        Expanded(
          flex: currentStep == 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed: canProceed() ? nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: canProceed() ? 4 : 0,
            ),
            child: Text(
              currentStep == totalSteps - 1 ? 'Hoàn thành' : 'Tiếp tục',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter cho đường kẻ đứt nét
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashHeight = 8.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
