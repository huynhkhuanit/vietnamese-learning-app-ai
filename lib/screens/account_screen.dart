import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/user_avatar_with_hat.dart';
import '../services/user_progress_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
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

  int _getStreak() {
    return userProgressData?['streak'] ?? 0;
  }

  int _getTotalXP() {
    return userProgressData?['totalXP'] ?? 0;
  }

  int _getLevel() {
    final totalXP = _getTotalXP();
    return (totalXP / 100).floor() + 1; // Simple level calculation
  }

  int _getLessonsCompleted() {
    final dhvCore = userProgressData?['dhvCore'] as Map<String, dynamic>?;
    final lifeTheme = userProgressData?['lifeTheme'] as Map<String, dynamic>?;

    int count = 0;
    dhvCore?.forEach((key, value) {
      if (value is Map && value['completed'] == true) count++;
    });
    lifeTheme?.forEach((key, value) {
      if (value is Map && value['completed'] == true) count++;
    });

    return count;
  }

  int _getMinutesLearned() {
    return userProgressData?['minutesLearned'] ?? 0;
  }

  String _getRank() {
    final level = _getLevel();
    if (level >= 10) return 'Diamond';
    if (level >= 7) return 'Gold';
    if (level >= 4) return 'Silver';
    return 'Bronze';
  }

  List<Map<String, dynamic>> _getAchievements() {
    // Static achievements based on real progress
    return [
      {
        'name': 'Học viên mới',
        'icon': Icons.school,
        'color': const Color(0xFF58CC02),
        'completed': true
      },
      {
        'name': 'Streak 7 ngày',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFFF6B6B),
        'completed': _getStreak() >= 7
      },
      {
        'name': 'Bài học đầu tiên',
        'icon': Icons.play_arrow,
        'color': const Color(0xFF1CB0F6),
        'completed': _getLessonsCompleted() > 0
      },
      {
        'name': 'Phát âm chuẩn',
        'icon': Icons.mic,
        'color': const Color(0xFF9B59B6),
        'completed': false
      },
      {
        'name': 'Master từ vựng',
        'icon': Icons.library_books,
        'color': const Color(0xFFFFC93C),
        'completed': _getTotalXP() >= 1000
      },
      {
        'name': 'Streak 30 ngày',
        'icon': Icons.whatshot,
        'color': const Color(0xFFFF9500),
        'completed': _getStreak() >= 30
      },
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Show loading indicator
    if (isLoadingUserData) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        appBar: const CustomAppBar(title: 'Tài khoản'),
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
        appBar: const CustomAppBar(title: 'Tài khoản'),
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
                'Bạn cần đăng nhập để xem thông tin tài khoản',
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
      appBar: const CustomAppBar(
        title: 'Tài khoản',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(isDarkMode),
              const SizedBox(height: 24),
              _buildStatsGrid(isDarkMode),
              const SizedBox(height: 24),
              _buildProgressSection(isDarkMode),
              const SizedBox(height: 24),
              _buildAchievementsSection(isDarkMode),
              const SizedBox(height: 24),
              _buildAccountActions(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF1CB0F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // User avatar with hat
              UserAvatarWithHat(
                user: currentUser,
                size: 100,
                showHat: true,
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC93C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${_getLevel()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getDisplayName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getEmail(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Thành viên từ ${_getJoinDate()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDarkMode) {
    final stats = [
      {
        'title': 'ngày',
        'subtitle': 'Streak hiện tại',
        'value': '${_getStreak()}',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'title': 'điểm',
        'subtitle': 'Tổng XP',
        'value': '${_getTotalXP()}',
        'icon': Icons.star,
        'color': const Color(0xFFFFC93C),
      },
      {
        'title': 'hoàn thành',
        'subtitle': 'Bài học',
        'value': '${_getLessonsCompleted()}',
        'icon': Icons.school,
        'color': const Color(0xFF58CC02),
      },
      {
        'title': 'phút',
        'subtitle': 'Thời gian học',
        'value': '${_getMinutesLearned()}',
        'icon': Icons.access_time,
        'color': const Color(0xFF1CB0F6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(stat, isDarkMode);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat['icon'],
              color: stat['color'],
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: stat['color'],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat['title'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.87)
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  stat['subtitle'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.6)
                        : Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isDarkMode) {
    final currentLevelXP = _getTotalXP() % 300;
    const nextLevelXP = 300;
    final progress = currentLevelXP / nextLevelXP;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ Level ${_getLevel()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC93C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRank(),
                  style: const TextStyle(
                    color: Color(0xFFFFC93C),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_getLevel()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currentLevelXP XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          '$nextLevelXP XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF58CC02)),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1CB0F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_getLevel() + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Còn ${nextLevelXP - currentLevelXP} XP để lên level ${_getLevel() + 1}',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(bool isDarkMode) {
    final achievements = _getAchievements();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành tích',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to full achievements screen
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFF58CC02),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85, // Tối ưu tỷ lệ cho icon + text
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementItem(achievement, isDarkMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
      Map<String, dynamic> achievement, bool isDarkMode) {
    final isCompleted = achievement['completed'];
    final achievementColor = achievement['color'] as Color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAchievementDetail(achievement);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCompleted
              ? achievementColor.withOpacity(0.12)
              : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: achievementColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: achievementColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? achievementColor.withOpacity(0.15)
                    : (isDarkMode ? Colors.grey[700] : Colors.grey[200]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement['icon'],
                size: 20,
                color: isCompleted
                    ? achievementColor
                    : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                achievement['name'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? achievementColor
                      : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(bool isDarkMode) {
    final actions = [
      {
        'title': 'Chỉnh sửa hồ sơ',
        'icon': Icons.edit,
        'color': const Color(0xFF1CB0F6),
        'onTap': () => _editProfile(),
      },
      {
        'title': 'Thống kê chi tiết',
        'icon': Icons.analytics,
        'color': const Color(0xFF9B59B6),
        'onTap': () => _showDetailedStats(),
      },
      {
        'title': 'Thiết lập mục tiêu',
        'icon': Icons.flag,
        'color': const Color(0xFFFFC93C),
        'onTap': () => _setGoals(),
      },
      {
        'title': 'Đăng xuất',
        'icon': Icons.logout,
        'color': const Color(0xFFFF6B6B),
        'onTap': () => _logout(),
      },
    ];

    return Column(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildActionCard(action, isDarkMode),
        );
      }).toList(),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action, bool isDarkMode) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        action['onTap']();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action['icon'],
                color: action['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                action['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(Map<String, dynamic> achievement) {
    final isCompleted = achievement['completed'];
    final achievementColor = achievement['color'] as Color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCompleted
                    ? achievementColor.withOpacity(0.15)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement['icon'],
                size: 48,
                color: isCompleted ? achievementColor : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              achievement['name'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCompleted ? achievementColor : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              achievement['completed']
                  ? 'Bạn đã đạt được thành tích này!'
                  : 'Tiếp tục học để mở khóa thành tích này.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: achievement['completed']
                    ? achievementColor
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: achievementColor,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: const Text(
            'Tính năng chỉnh sửa hồ sơ sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDetailedStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê chi tiết'),
        content: const Text(
            'Tính năng thống kê chi tiết sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _setGoals() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thiết lập mục tiêu'),
        content: const Text(
            'Tính năng thiết lập mục tiêu sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to settings
              // In real app, implement logout logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
