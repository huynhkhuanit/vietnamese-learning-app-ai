import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'chatbot_screen.dart';
import 'user_onboarding_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/user_avatar_with_hat.dart';
import '../services/user_progress_service.dart';
import '../services/notification_service.dart';
import '../services/xp_service.dart';
import '../widgets/xp_progress_widget.dart';
import '../widgets/achievements_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user from Firebase
  User? currentUser;
  Map<String, dynamic>? userProgressData;
  bool isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Initialize UserProgressService and get progress data
        await UserProgressService.initializeUserProgress();
        final progressDoc =
            await UserProgressService.getUserProgressStream().first;
        if (progressDoc.exists) {
          userProgressData = progressDoc.data() as Map<String, dynamic>?;
        }

        // Record app activity for smart notifications
        final notificationService = NotificationService();
        await notificationService.recordAppActivity();
        print('App activity recorded for smart notifications');

        // Initialize XP Service - FIXED: Ensure proper initialization
        final xpService = XPService();

        // Verify Firestore access first
        print('Dashboard: Verifying Firestore access...');
        final hasAccess = await xpService.verifyUserAccess();
        if (!hasAccess) {
          print('Dashboard: ❌ Firestore access verification failed');
          // Continue anyway to show app, but with limited functionality
        } else {
          print('Dashboard: ✅ Firestore access verified');
        }

        await xpService.initializeUserExperience();

        // Force refresh of user experience data
        await Future.delayed(const Duration(milliseconds: 500));

        print('XP Service initialized with user: ${currentUser!.uid}');
        print('Current XP: ${xpService.currentXP}');
        print('Current Level: ${xpService.currentLevel}');
        print('Current Streak: ${xpService.currentStreak}');
      }
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingUserData = false;
        });
      }
    }
  }

  // Helper methods to get user data
  String _getDisplayName() {
    if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@')[0];
    }
    return 'Người dùng';
  }

  String _getEmail() {
    return currentUser?.email ?? 'Chưa có email';
  }

  String _getPhotoUrl() {
    return currentUser?.photoURL ?? '';
  }

  String _getJoinDate() {
    if (currentUser?.metadata.creationTime != null) {
      final date = currentUser!.metadata.creationTime!;
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Hôm nay';
  }

  int _getExperience() {
    return userProgressData?['totalXP'] ?? 0;
  }

  int _getUserLevel() {
    final totalXP = _getExperience();
    return (totalXP / 100).floor() + 1; // Simple level calculation
  }

  int _getExperienceToNextLevel() {
    final currentLevel = _getUserLevel();
    final currentXP = _getExperience();
    final xpForNextLevel = currentLevel * 100;
    return xpForNextLevel - currentXP;
  }

  String? _getAuthProvider() {
    if (currentUser == null) return null;

    // Check provider data to determine OAuth provider
    for (final providerInfo in currentUser!.providerData) {
      if (providerInfo.providerId == 'google.com') {
        return 'Google';
      } else if (providerInfo.providerId == 'facebook.com') {
        return 'Facebook';
      } else if (providerInfo.providerId == 'apple.com') {
        return 'Apple';
      }
    }
    return null;
  }

  Color _getProviderColor() {
    final provider = _getAuthProvider();
    switch (provider) {
      case 'Google':
        return const Color(0xFF4285F4);
      case 'Facebook':
        return const Color(0xFF1877F2);
      case 'Apple':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Show loading indicator while fetching user data
    if (isLoadingUserData) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CustomAppBar(title: 'Việt Ngữ Thông Minh'),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
          ),
        ),
      );
    }

    // Show login prompt if user is not logged in
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CustomAppBar(title: 'Việt Ngữ Thông Minh'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa đăng nhập',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng đăng nhập để sử dụng ứng dụng',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<_Feature> features = [
      _Feature(
        icon: Icons.play_circle_fill,
        label: 'Hôm nay học gì?',
        gradient: [const Color(0xFF58CC02), const Color(0xFF1CB0F6)],
        onTap: () {
          // Navigate to lesson screen (index 1 in bottom navigation)
          MainNavigation.navigateToTab(context, 1);
        },
      ),
      _Feature(
        icon: Icons.flash_on,
        label: 'Luyện tập nhanh',
        gradient: [const Color(0xFF1CB0F6), const Color(0xFFFFC93C)],
        onTap: () {
          // Navigate to lesson screen
          MainNavigation.navigateToTab(context, 1);
        },
      ),
      _Feature(
        icon: Icons.chat_bubble,
        label: 'Giao tiếp với AI',
        gradient: [const Color(0xFFFFC93C), const Color(0xFF58CC02)],
        onTap: () {
          // Navigate to chatbot screen
          MainNavigation.navigateToTab(
            context,
            3,
          ); // Index 3 is for ChatbotScreen
        },
      ),
      _Feature(
        icon: Icons.record_voice_over,
        label: 'Luyện phát âm',
        gradient: [const Color(0xFF1CB0F6), const Color(0xFF58CC02)],
        onTap: () {
          // Navigate to pronunciation screen
          MainNavigation.navigateToTab(
            context,
            2,
          ); // Index 2 is for PronunciationScreen
        },
      ),
      _Feature(
        icon: Icons.lightbulb,
        label: 'AI gợi ý',
        gradient: [const Color(0xFF58CC02), const Color(0xFFFFC93C)],
        onTap: () {
          // Navigate to chatbot screen with AI suggestions
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
      ),
      _Feature(
        icon: Icons.emoji_events,
        label: 'Thành tựu',
        gradient: [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
        onTap: () {
          // Navigate to achievements screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementsWidget()),
          );
        },
      ),
      _Feature(
        icon: Icons.psychology,
        label: 'Thiết lập hồ sơ AI',
        gradient: [const Color(0xFF9B59B6), const Color(0xFFE67E22)],
        onTap: () {
          // Navigate to user onboarding screen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserOnboardingScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Việt Ngữ Thông Minh',
        actions: [
          const Icon(Icons.notifications_none, color: Colors.white),
          const SizedBox(width: 8),
          // Use UserAvatarWithHat with Firebase User
          UserAvatarWithHat(
            user: currentUser,
            size: 40,
            showHat: true,
            onTap: () => _showUserProfileMenu(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic greeting with user's name
            Text(
              'Xin chào, ${_getDisplayName()}!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            // Enhanced XP progress with beautiful UI
            const CompactXPWidget(),
            const SizedBox(height: 20),
            // Các tính năng chính
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _FeatureCard(
                  feature: features[index],
                  isDarkMode: isDarkMode,
                );
              },
            ),
            const SizedBox(height: 20),
            // Mini-game hoặc thử thách trong ngày
            Card(
              color: const Color(0xFF1CB0F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.sports_esports,
                  color: Colors.white,
                  size: 36,
                ),
                title: const Text(
                  'Thử thách hôm nay',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Hoàn thành 3 bài luyện nghe để nhận huy hiệu!',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const NextScreen(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show user profile menu when avatar is tapped
  void _showUserProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info header
            Row(
              children: [
                UserAvatarWithHat(
                  user: currentUser,
                  size: 60,
                  showHat: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getEmail(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_getAuthProvider() != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getProviderColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Đăng nhập qua ${_getAuthProvider()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Menu options
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Hồ sơ cá nhân'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _auth.signOut();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;
  _Feature({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
  });
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  final bool isDarkMode;

  const _FeatureCard({
    required this.feature,
    required this.isDarkMode,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    final borderGradient = LinearGradient(
      colors: widget.feature.gradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.feature.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: borderGradient,
            boxShadow: [
              BoxShadow(
                color: (_hovering
                    ? (widget.isDarkMode ? Colors.black45 : Colors.black26)
                    : (widget.isDarkMode ? Colors.black38 : Colors.black12)),
                blurRadius: _hovering ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.feature.icon,
                  color: widget.feature.gradient.first,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.feature.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Image.asset('assets/logo.png', width: 64, height: 64),
    );
  }
}

class AnimatedFeatureCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const AnimatedFeatureCard({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
    super.key,
  });

  @override
  State<AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<AnimatedFeatureCard> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.97 : (_hovering ? 1.04 : 1.0)),
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (_hovering || _pressed) ? Colors.black26 : Colors.black12,
                blurRadius: (_hovering || _pressed) ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.gradient.first, size: 40),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF222222),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedGradientButton extends StatefulWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AnimatedGradientButton({
    required this.label,
    required this.gradient,
    this.onPressed,
    this.icon,
    super.key,
  });

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.97 : (_hovering ? 1.03 : 1.0)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (_hovering || _pressed) ? Colors.black26 : Colors.black12,
                blurRadius: (_hovering || _pressed) ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                Icon(widget.icon, color: Colors.white, size: 22),
              if (widget.icon != null) const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thử thách hôm nay'),
        backgroundColor: const Color(0xFF1CB0F6),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng đến với thử thách hôm nay!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
