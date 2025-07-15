import 'package:flutter/material.dart';
import '../models/user_experience.dart';
import '../services/xp_service.dart';

class XPProgressWidget extends StatefulWidget {
  final bool showDetailed;
  final bool showStreak;

  const XPProgressWidget({
    super.key,
    this.showDetailed = true,
    this.showStreak = true,
  });

  @override
  State<XPProgressWidget> createState() => _XPProgressWidgetState();
}

class _XPProgressWidgetState extends State<XPProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _streakController;
  late Animation<double> _progressAnimation;
  late Animation<double> _streakAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _streakAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _streakController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
      _streakController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _streakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpService = XPService();
    final userExperience = xpService.currentUserExperience;

    if (userExperience == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade100,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (widget.showDetailed) _buildLevelHeader(userExperience),
          const SizedBox(height: 12),
          _buildXPProgressBar(userExperience),
          if (widget.showDetailed) ...[
            const SizedBox(height: 16),
            _buildStatsRow(userExperience),
          ],
          if (widget.showStreak) ...[
            const SizedBox(height: 12),
            _buildStreakDisplay(userExperience),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelHeader(UserExperience userExperience) {
    return Row(
      children: [
        // Level Badge
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.blue.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${userExperience.currentLevel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Level Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userExperience.levelTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${userExperience.totalXP} XP tổng cộng',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Daily XP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.today,
                size: 16,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                '${userExperience.dailyXP} XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildXPProgressBar(UserExperience userExperience) {
    final currentLevelXP =
        UserExperience.getXPRequiredForLevel(userExperience.currentLevel);
    final nextLevelXP =
        UserExperience.getXPRequiredForLevel(userExperience.currentLevel + 1);
    final levelProgress = nextLevelXP > currentLevelXP
        ? (userExperience.totalXP - currentLevelXP) /
            (nextLevelXP - currentLevelXP)
        : 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${userExperience.currentLevel}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              'Level ${userExperience.currentLevel + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.shade200,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade200,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: levelProgress * _progressAnimation.value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.blue.shade400,
                            Colors.purple.shade300,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),
        Text(
          '${userExperience.xpToNextLevel} XP nữa để lên level',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserExperience userExperience) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.trending_up,
            label: 'Tuần này',
            value: '${userExperience.weeklyXP} XP',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.calendar_month,
            label: 'Tháng này',
            value: '${userExperience.monthlyXP} XP',
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.school,
            label: 'Bài học',
            value: '${userExperience.totalLessonsCompleted}',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDisplay(UserExperience userExperience) {
    return AnimatedBuilder(
      animation: _streakAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _streakAnimation.value),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.red.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Flame icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      '🔥',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Streak info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userExperience.currentStreak} ngày streak!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Kỷ lục: ${userExperience.longestStreak} ngày',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Streak freeze
                if (userExperience.canUseStreakFreeze())
                  IconButton(
                    onPressed: () => _showStreakFreezeDialog(),
                    icon: const Icon(
                      Icons.ac_unit,
                      color: Colors.white,
                    ),
                    tooltip: 'Streak Freeze',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStreakFreezeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.ac_unit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Streak Freeze'),
          ],
        ),
        content: const Text(
          'Sử dụng Streak Freeze để bảo vệ chuỗi học tập của bạn trong 1 ngày. '
          'Bạn có thể sử dụng tối đa 3 lần và mỗi lần cách nhau ít nhất 7 ngày.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final xpService = XPService();
              final success = await xpService.useStreakFreeze();
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🧊 Streak Freeze đã được kích hoạt!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Không thể sử dụng Streak Freeze lúc này'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sử dụng'),
          ),
        ],
      ),
    );
  }
}

// Compact version for dashboard
class CompactXPWidget extends StatefulWidget {
  const CompactXPWidget({super.key});

  @override
  State<CompactXPWidget> createState() => _CompactXPWidgetState();
}

class _CompactXPWidgetState extends State<CompactXPWidget> {
  @override
  void initState() {
    super.initState();
    // Refresh every 30 seconds to ensure data is current
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshXPData();
    });
  }

  Future<void> _refreshXPData() async {
    try {
      final xpService = XPService();
      if (xpService.currentUserExperience == null) {
        await xpService.initializeUserExperience();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing XP data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final xpService = XPService();
    final userExperience = xpService.currentUserExperience;

    if (userExperience == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Level badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Học viên mới',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '0 XP • Chưa có streak',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            // Refresh button
            IconButton(
              onPressed: _refreshXPData,
              icon: const Icon(Icons.refresh, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      );
    }

    final currentLevelXP =
        UserExperience.getXPRequiredForLevel(userExperience.currentLevel);
    final nextLevelXP =
        UserExperience.getXPRequiredForLevel(userExperience.currentLevel + 1);
    final levelProgress = nextLevelXP > currentLevelXP
        ? (userExperience.totalXP - currentLevelXP) /
            (nextLevelXP - currentLevelXP)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${userExperience.currentLevel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userExperience.levelTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${userExperience.totalXP} XP • ${userExperience.currentStreak} ngày streak',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ],
            ),
          ),

          // Flame icon for streak
          if (userExperience.currentStreak > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  Text(
                    '${userExperience.currentStreak}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
