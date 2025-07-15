import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/pronunciation_lesson.dart';
import '../screens/pronunciation_screen.dart';

class PronunciationLessonCard extends StatelessWidget {
  final PronunciationLesson lesson;
  final double? progress;
  final VoidCallback? onTap;
  final bool showProgress;

  const PronunciationLessonCard({
    super.key,
    required this.lesson,
    this.progress,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap ?? () => _navigateToLesson(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gradient background
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getDifficultyGradient(lesson.difficulty),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with difficulty badge
                    Row(
                      children: [
                        _buildDifficultyBadge(),
                        const Spacer(),
                        _buildLessonTypeIcon(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Stats row
                    Row(
                      children: [
                        _buildStatItem(
                          Icons.timer,
                          '${lesson.estimatedDuration} phút',
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          Icons.quiz,
                          '${lesson.exercises.length} bài tập',
                        ),
                      ],
                    ),

                    // Progress bar
                    if (showProgress && progress != null && progress! > 0) ...[
                      const SizedBox(height: 12),
                      _buildProgressBar(),
                    ],
                  ],
                ),
              ),

              // Locked overlay
              if (lesson.isLocked)
                Container(
                  height: 160,
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bài học bị khóa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3, duration: 600.ms);
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDifficultyIcon(lesson.difficulty),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getDifficultyText(lesson.difficulty),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTypeIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getLessonTypeIcon(lesson.type),
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ: ${(progress! * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getDifficultyGradient(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)];
      case LessonDifficulty.intermediate:
        return [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
      case LessonDifficulty.advanced:
        return [const Color(0xFFF44336), const Color(0xFFEF5350)];
    }
  }

  IconData _getDifficultyIcon(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return Icons.sentiment_satisfied;
      case LessonDifficulty.intermediate:
        return Icons.school;
      case LessonDifficulty.advanced:
        return Icons.psychology;
    }
  }

  String _getDifficultyText(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return 'Cơ bản';
      case LessonDifficulty.intermediate:
        return 'Trung cấp';
      case LessonDifficulty.advanced:
        return 'Nâng cao';
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.word:
        return Icons.text_fields;
      case LessonType.phrase:
        return Icons.format_quote;
      case LessonType.sentence:
        return Icons.notes;
      case LessonType.paragraph:
        return Icons.article;
      case LessonType.conversation:
        return Icons.chat;
    }
  }

  void _navigateToLesson(BuildContext context) {
    if (lesson.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cần hoàn thành các bài học trước để mở khóa'),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PronunciationScreen(),
      ),
    );
  }
}

/// Widget hiển thị danh sách pronunciation lessons
class PronunciationLessonsList extends StatelessWidget {
  final List<PronunciationLesson> lessons;
  final Map<String, double> progress;
  final String? title;
  final bool showAll;

  const PronunciationLessonsList({
    super.key,
    required this.lessons,
    this.progress = const {},
    this.title,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayLessons = showAll ? lessons : lessons.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!showAll && lessons.length > 3)
                  TextButton(
                    onPressed: () => _showAllLessons(context),
                    child: const Text('Xem tất cả'),
                  ),
              ],
            ),
          ),
        ],
        ...displayLessons.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          final lessonProgress = progress[lesson.id] ?? 0.0;

          return PronunciationLessonCard(
            lesson: lesson,
            progress: lessonProgress,
          ).animate(delay: (index * 100).ms);
        }),
      ],
    );
  }

  void _showAllLessons(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AllPronunciationLessonsScreen(
          lessons: lessons,
          progress: progress,
        ),
      ),
    );
  }
}

/// Screen hiển thị tất cả pronunciation lessons
class _AllPronunciationLessonsScreen extends StatelessWidget {
  final List<PronunciationLesson> lessons;
  final Map<String, double> progress;

  const _AllPronunciationLessonsScreen({
    required this.lessons,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả bài học phát âm'),
        backgroundColor: const Color(0xFF58CC02),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final lessonProgress = progress[lesson.id] ?? 0.0;

          return PronunciationLessonCard(
            lesson: lesson,
            progress: lessonProgress,
          ).animate(delay: (index * 50).ms);
        },
      ),
    );
  }
}
