import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/custom_app_bar.dart';
import '../services/pronunciation_service.dart';
import '../services/xp_service.dart';
import '../models/user_experience.dart';
import '../models/pronunciation_lesson.dart';

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen>
    with TickerProviderStateMixin {
  // Service
  final PronunciationService _pronunciationService = PronunciationService();
  final XPService _xpService = XPService();

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resultAnimation;

  // State Variables
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPlaying = false;
  bool _isAnalyzing = false;
  String? _currentAudioPath;
  PronunciationResult? _lastResult;

  // Lesson Data
  List<PronunciationLesson> _lessons = [];
  int _currentLessonIndex = 0;
  int _currentExerciseIndex = 0;

  // Progress
  final Map<String, double> _lessonProgress = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLessons();
    _initializePronunciationService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _loadLessons() {
    setState(() {
      _lessons = PronunciationLessonsData.getSampleLessons();
    });
  }

  Future<void> _initializePronunciationService() async {
    final success = await _pronunciationService.initialize();
    setState(() {
      _isInitialized = success;
    });

    if (!success) {
      _showErrorSnackBar(
          'Không thể khởi tạo dịch vụ phát âm. Vui lòng kiểm tra quyền microphone.');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resultController.dispose();
    _pronunciationService.dispose();
    super.dispose();
  }

  // Getter cho lesson và exercise hiện tại
  PronunciationLesson? get _currentLesson =>
      _currentLessonIndex < _lessons.length
          ? _lessons[_currentLessonIndex]
          : null;

  PronunciationExercise? get _currentExercise => _currentLesson != null &&
          _currentExerciseIndex < _currentLesson!.exercises.length
      ? _currentLesson!.exercises[_currentExerciseIndex]
      : null;

  Future<void> _playAudioSample() async {
    if (_currentExercise == null) return;

    setState(() {
      _isPlaying = true;
    });

    await _pronunciationService.speakSample(_currentExercise!.text);

    // Giả lập thời gian phát
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _isRecording) return;

    try {
      HapticFeedback.lightImpact();
      final audioPath = await _pronunciationService.startRecording();

      if (audioPath != null) {
        setState(() {
          _isRecording = true;
          _hasRecorded = false;
          _lastResult = null;
          _currentAudioPath = audioPath;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi bắt đầu ghi âm: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      HapticFeedback.mediumImpact();
      final audioPath = await _pronunciationService.stopRecording();

      if (audioPath != null) {
        setState(() {
          _isRecording = false;
          _hasRecorded = true;
          _isAnalyzing = true;
          _currentAudioPath = audioPath;
        });

        await _analyzePronunciation();
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi dừng ghi âm: $e');
    }
  }

  Future<void> _analyzePronunciation() async {
    if (_currentExercise == null || _currentAudioPath == null) return;

    try {
      // Sử dụng đánh giá nâng cao với AI
      final result = await _pronunciationService.assessPronunciationAdvanced(
        _currentExercise!.text,
        _currentAudioPath!,
      );

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });

      // Animate kết quả
      _resultController.forward();

      // Haptic feedback dựa trên điểm số
      if (result.overallScore >= 90) {
        HapticFeedback.heavyImpact();
      } else if (result.overallScore >= 70) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      // Award XP for good pronunciation practice
      await _awardXPForPronunciation(result.overallScore);

      // Cập nhật progress
      _updateLessonProgress(result.overallScore);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorSnackBar('Lỗi khi phân tích phát âm: $e');
    }
  }

  Future<void> _awardXPForPronunciation(double score) async {
    try {
      // Award XP only for good pronunciation (score >= 70%)
      if (score >= 70) {
        final awardedXP =
            await _xpService.awardXP(XPActivityType.pronunciationPractice);

        if (awardedXP > 0) {
          // Show XP award notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('+$awardedXP XP - Phát âm tốt!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          print(
              'Awarded $awardedXP XP for pronunciation practice (${score.toInt()}% accuracy)');
        }
      }
    } catch (e) {
      print('Error awarding XP for pronunciation: $e');
    }
  }

  void _updateLessonProgress(double score) {
    if (_currentLesson == null) return;

    setState(() {
      _lessonProgress[_currentLesson!.id] =
          (_lessonProgress[_currentLesson!.id] ?? 0.0).clamp(0.0, score);
    });
  }

  void _nextExercise() {
    if (_currentLesson == null) return;

    setState(() {
      if (_currentExerciseIndex < _currentLesson!.exercises.length - 1) {
        _currentExerciseIndex++;
      } else {
        // Chuyển sang lesson tiếp theo
        if (_currentLessonIndex < _lessons.length - 1) {
          _currentLessonIndex++;
          _currentExerciseIndex = 0;
        }
      }
      _hasRecorded = false;
      _lastResult = null;
      _currentAudioPath = null;
    });

    _resultController.reset();
  }

  void _previousExercise() {
    setState(() {
      if (_currentExerciseIndex > 0) {
        _currentExerciseIndex--;
      } else if (_currentLessonIndex > 0) {
        _currentLessonIndex--;
        _currentExerciseIndex =
            _lessons[_currentLessonIndex].exercises.length - 1;
      }
      _hasRecorded = false;
      _lastResult = null;
      _currentAudioPath = null;
    });

    _resultController.reset();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLessonSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLessonSelector(),
    );
  }

  Widget _buildLessonSelector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Chọn bài học',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Lessons List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                final progress = _lessonProgress[lesson.id] ?? 0.0;
                final isSelected = index == _currentLessonIndex;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getDifficultyColor(lesson.difficulty),
                      child: Icon(
                        _getDifficultyIcon(lesson.difficulty),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      lesson.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.timer,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${lesson.estimatedDuration} phút'),
                            const SizedBox(width: 16),
                            Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${lesson.exercises.length} bài tập'),
                          ],
                        ),
                        if (progress > 0) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getDifficultyColor(lesson.difficulty),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _currentLessonIndex = index;
                        _currentExerciseIndex = 0;
                        _hasRecorded = false;
                        _lastResult = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return Colors.green;
      case LessonDifficulty.intermediate:
        return Colors.orange;
      case LessonDifficulty.advanced:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return Icons.mood;
      case LessonDifficulty.intermediate:
        return Icons.school;
      case LessonDifficulty.advanced:
        return Icons.psychology;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Luyện phát âm'),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang khởi tạo dịch vụ phát âm...'),
            ],
          ),
        ),
      );
    }

    if (_currentLesson == null || _currentExercise == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Luyện phát âm'),
        body: const Center(
          child: Text('Không có bài học nào được tải.'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Luyện phát âm',
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showLessonSelector,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress Bar
            _buildProgressBar(),
            const SizedBox(height: 20),

            // Lesson Info
            _buildLessonInfo(),
            const SizedBox(height: 20),

            // Exercise Card
            _buildExerciseCard(isDarkMode),
            const SizedBox(height: 30),

            // Recording Button
            _buildRecordingButton(),
            const SizedBox(height: 15),

            // Recording Status
            _buildRecordingStatus(),

            // Analysis Progress
            if (_isAnalyzing) _buildAnalysisProgress(),

            // Results
            if (_hasRecorded && _lastResult != null) ...[
              const SizedBox(height: 30),
              _buildResultCard(isDarkMode),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final currentProgress =
        (_currentExerciseIndex + 1) / _currentLesson!.exercises.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentLesson!.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_currentExerciseIndex + 1}/${_currentLesson!.exercises.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentProgress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getDifficultyColor(_currentLesson!.difficulty),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getDifficultyColor(_currentLesson!.difficulty).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDifficultyColor(_currentLesson!.difficulty),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDifficultyIcon(_currentLesson!.difficulty),
                color: _getDifficultyColor(_currentLesson!.difficulty),
              ),
              const SizedBox(width: 8),
              Text(
                _currentLesson!.difficulty.name.toUpperCase(),
                style: TextStyle(
                  color: _getDifficultyColor(_currentLesson!.difficulty),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentLesson!.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
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
            color: isDarkMode ? Colors.black26 : Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Phát âm từ/câu sau:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Main text
          Text(
            _currentExercise!.text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          // Phonetic
          if (_currentExercise!.phonetic != null) ...[
            const SizedBox(height: 12),
            Text(
              _currentExercise!.phonetic!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Meaning
          if (_currentExercise!.meaning != null) ...[
            const SizedBox(height: 8),
            Text(
              '(${_currentExercise!.meaning})',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 20),

          // Play button
          ElevatedButton.icon(
            onPressed: _isPlaying ? null : _playAudioSample,
            icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
            label: Text(_isPlaying ? 'Đang phát...' : 'Nghe mẫu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF58CC02),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red[600] : const Color(0xFF58CC02),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording
                            ? Colors.red[600]!
                            : const Color(0xFF58CC02))
                        .withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: _isRecording ? 8 : 4,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 60,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    ).animate().scale(delay: 300.ms, duration: 600.ms);
  }

  Widget _buildRecordingStatus() {
    String statusText;
    if (_isAnalyzing) {
      statusText = 'Đang phân tích...';
    } else if (_isRecording) {
      statusText = 'Nhấn để dừng ghi âm';
    } else if (_hasRecorded) {
      statusText = 'Đã ghi âm xong';
    } else {
      statusText = 'Nhấn để bắt đầu ghi âm';
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAnalysisProgress() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'AI đang phân tích phát âm của bạn...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildResultCard(bool isDarkMode) {
    if (_lastResult == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _resultAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black26 : Colors.black12,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Overall Score
                _buildScoreCircle(_lastResult!.overallScore),

                const SizedBox(height: 24),

                // Detailed Scores
                _buildDetailedScores(),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Feedback
                _buildFeedback(),

                // Tips
                if (_currentExercise!.tips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildTips(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCircle(double score) {
    final color = _getScoreColor(score);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          children: [
            Text(
              '${score.toInt()}%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              _getScoreText(score),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedScores() {
    return Row(
      children: [
        Expanded(
            child: _buildScoreItem('Chính xác', _lastResult!.accuracyScore)),
        Expanded(
            child: _buildScoreItem('Trôi chảy', _lastResult!.fluencyScore)),
        Expanded(
            child:
                _buildScoreItem('Hoàn thành', _lastResult!.completenessScore)),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score) {
    return Column(
      children: [
        Text(
          '${score.toInt()}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phản hồi:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _lastResult!.feedback,
          style: const TextStyle(fontSize: 15),
        ),
        if (_lastResult!.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Gợi ý cải thiện:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._lastResult!.suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF58CC02),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mẹo phát âm:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._currentExercise!.tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Previous Button
        if (_currentExerciseIndex > 0 || _currentLessonIndex > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousExercise,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Trước'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF58CC02)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

        if (_currentExerciseIndex > 0 || _currentLessonIndex > 0)
          const SizedBox(width: 12),

        // Try Again Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _hasRecorded = false;
                _lastResult = null;
                _currentAudioPath = null;
              });
              _resultController.reset();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF58CC02)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Next Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _nextExercise,
            icon: const Icon(Icons.arrow_forward),
            label: Text(
                _currentExerciseIndex < _currentLesson!.exercises.length - 1
                    ? 'Tiếp tục'
                    : _currentLessonIndex < _lessons.length - 1
                        ? 'Lesson tiếp'
                        : 'Hoàn thành'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF58CC02);
    if (score >= 70) return const Color(0xFFFFC800);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFFF4B4B);
  }

  String _getScoreText(double score) {
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Rất tốt';
    if (score >= 70) return 'Tốt';
    if (score >= 60) return 'Khá';
    return 'Cần cải thiện';
  }
}
