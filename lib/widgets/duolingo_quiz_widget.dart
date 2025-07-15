import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/universal_tts_service.dart';
import '../services/xp_service.dart';
import '../models/user_experience.dart';

/// Duolingo-style Quiz Widget cho DHV Learning App
/// Với animation, progress bar, và interactive feedback
class DuolingoQuizWidget extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final Color unitColor;
  final String lessonTitle;
  final VoidCallback? onCompleted;
  final VoidCallback? onExit;

  const DuolingoQuizWidget({
    super.key,
    required this.quizData,
    required this.unitColor,
    required this.lessonTitle,
    this.onCompleted,
    this.onExit,
  });

  @override
  State<DuolingoQuizWidget> createState() => _DuolingoQuizWidgetState();
}

class _DuolingoQuizWidgetState extends State<DuolingoQuizWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _progressAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;

  final UniversalTtsService _tts = UniversalTtsService();

  int currentQuestionIndex = 0;
  int? selectedAnswer;
  bool showFeedback = false;
  bool isCorrect = false;
  int score = 0;
  int streak = 0;
  int lives = 3;
  bool quizCompleted = false;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _loadQuestions();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initializeTTS() async {
    await _tts.initialize();
  }

  void _loadQuestions() {
    questions = List<Map<String, dynamic>>.from(
        widget.quizData['questions'] as List<dynamic>? ?? []);
    if (questions.isNotEmpty) {
      _progressController
          .animateTo((currentQuestionIndex + 1) / questions.length);
    }
  }

  // Phát âm thanh phản hồi với TTS
  Future<void> _playFeedbackSound(bool correct) async {
    try {
      if (correct) {
        // Âm thanh + TTS cho trả lời đúng
        await SystemSound.play(SystemSoundType.alert);
        Future.delayed(const Duration(milliseconds: 100), () {
          SystemSound.play(SystemSoundType.click);
        });
        // TTS thông báo đúng
        await _tts.quickSpeak("Chính xác! Rất tốt!");
      } else {
        // Âm thanh + TTS cho trả lời sai
        await SystemSound.play(SystemSoundType.alert);
        // TTS thông báo sai
        await _tts.quickSpeak("Không đúng rồi. Hãy thử lại!");
      }
    } catch (e) {
      print('Error playing feedback sound: $e');
    }
  }

  // Phát âm thanh celebration
  Future<void> _playCelebrationSound() async {
    try {
      for (int i = 0; i < 3; i++) {
        await SystemSound.play(SystemSoundType.click);
        await Future.delayed(const Duration(milliseconds: 150));
      }
      // TTS thông báo hoàn thành
      await _tts.quickSpeak("Xuất sắc! Bạn đã hoàn thành bài kiểm tra!");
    } catch (e) {
      print('Error playing celebration sound: $e');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    if (quizCompleted) {
      return _buildCompletionScreen();
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header với progress và lives
            _buildHeader(),

            // Nội dung câu hỏi - Loại bỏ shake animation ở đây
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Câu hỏi
                    _buildQuestionCard(currentQuestion),

                    const SizedBox(height: 24),

                    // Lựa chọn
                    _buildAnswerOptions(currentQuestion),

                    const SizedBox(height: 24),

                    // Feedback area
                    if (showFeedback) _buildFeedbackArea(currentQuestion),
                  ],
                ),
              ),
            ),

            // Bottom action area
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: widget.unitColor,
        boxShadow: [
          BoxShadow(
            color: widget.unitColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Exit button
              IconButton(
                onPressed: () {
                  _showExitDialog();
                },
                icon: const Icon(Icons.close, color: Colors.white),
              ),

              // Progress bar
              Expanded(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      );
                    },
                  ),
                ),
              ),

              // Lives
              Row(
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: Icon(
                      index < lives ? Icons.favorite : Icons.favorite_border,
                      color: index < lives ? Colors.red : Colors.white54,
                      size: 20,
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Question counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$score XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.unitColor.withOpacity(0.1),
            widget.unitColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.unitColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.unitColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getQuestionTypeText(question['type'] ?? 'multiple_choice'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question text
          Text(
            question['question']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          // Audio button nếu có - Chỉ đọc câu hỏi
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Chỉ đọc câu hỏi, không đọc câu trả lời
                  final questionText = question['question']?.toString() ?? '';
                  _tts.quickSpeak(questionText);
                },
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.unitColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Nghe câu hỏi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Map<String, dynamic> question) {
    final options = question['options'] as List<dynamic>? ?? [];

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value.toString();
        final isSelected = selectedAnswer == index;
        final correctAnswer = question['correct'] as int? ?? -1;
        final isCorrect = index == correctAnswer;

        Color? backgroundColor;
        Color? borderColor;
        Color? textColor;

        if (showFeedback) {
          if (isCorrect) {
            backgroundColor = Colors.green.withOpacity(0.1);
            borderColor = Colors.green;
            textColor = Colors.green;
          } else if (isSelected && !isCorrect) {
            backgroundColor = Colors.red.withOpacity(0.1);
            borderColor = Colors.red;
            textColor = Colors.red;
          } else {
            backgroundColor = Colors.grey.withOpacity(0.1);
            borderColor = Colors.grey.withOpacity(0.3);
          }
        } else if (isSelected) {
          backgroundColor = widget.unitColor.withOpacity(0.1);
          borderColor = widget.unitColor;
          textColor = widget.unitColor;
        }

        // Chỉ áp dụng animation cho từng option riêng lẻ, không cho toàn bộ list
        return AnimatedBuilder(
          animation: showFeedback && isCorrect
              ? _bounceAnimation
              : showFeedback && isSelected && !isCorrect
                  ? _shakeAnimation
                  : const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            // Chỉ shake riêng option được chọn sai, không làm xô lệch giao diện
            final shakeOffset = showFeedback && isSelected && !isCorrect
                ? _shakeAnimation.value * 3.0 * (index.isEven ? 1 : -1)
                : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Transform.scale(
                  scale:
                      showFeedback && isCorrect ? _bounceAnimation.value : 1.0,
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: showFeedback
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                selectedAnswer = index;
                              });
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor ?? Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: isSelected && !showFeedback
                              ? [
                                  BoxShadow(
                                    color: widget.unitColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : showFeedback && isCorrect
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : null,
                        ),
                        child: Row(
                          children: [
                            // Option letter
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    borderColor ?? Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Option text
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),

                            // Feedback icon với animation
                            if (showFeedback && isCorrect)
                              AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(Icons.check_circle,
                                    color: Colors.green, size: 24),
                              ),
                            if (showFeedback && isSelected && !isCorrect)
                              AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(Icons.cancel,
                                    color: Colors.red, size: 24),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackArea(Map<String, dynamic> question) {
    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _feedbackAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
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
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCorrect ? 'Chính xác!' : 'Không chính xác',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (question['explanation'] != null) ...[
                  const Text(
                    'Giải thích:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question['explanation'].toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (!isCorrect && question['correctAnswer'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Đáp án đúng: ${question['correctAnswer']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showFeedback) ...[
            // Check answer button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? _checkAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.unitColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: selectedAnswer != null ? 4 : 0,
                ),
                child: Text(
                  'KIỂM TRA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedAnswer != null ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? Colors.green : widget.unitColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  currentQuestionIndex < questions.length - 1
                      ? 'TIẾP TỤC'
                      : 'HOÀN THÀNH',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 64,
              color: widget.unitColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có câu hỏi nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quiz đang được cập nhật',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final percentage = (score / (questions.length * 10) * 100).round();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.unitColor,
              widget.unitColor.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    percentage >= 80 ? Icons.emoji_events : Icons.star,
                    size: 64,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Xuất sắc!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Bạn đã hoàn thành bài kiểm tra\nvới $percentage% độ chính xác',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Stats
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Điểm số:', '$score XP'),
                      _buildStatRow('Tỷ lệ đúng:', '$percentage%'),
                      _buildStatRow('Streak:', '$streak câu'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onCompleted?.call();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: widget.unitColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'HOÀN THÀNH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _restartQuiz,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'LÀM LẠI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getQuestionTypeText(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'TRẮC NGHIỆM';
      case 'true_false':
        return 'ĐÚNG/SAI';
      case 'fill_blank':
        return 'ĐIỀN KHUYẾT';
      default:
        return 'CÂU HỎI';
    }
  }

  void _checkAnswer() {
    if (selectedAnswer == null) return;

    final currentQuestion = questions[currentQuestionIndex];
    final correctAnswer = currentQuestion['correct'] as int? ?? -1;
    isCorrect = selectedAnswer == correctAnswer;

    // Phát âm thanh phản hồi ngay lập tức
    _playFeedbackSound(isCorrect);

    if (isCorrect) {
      score += 10;
      streak++;
      HapticFeedback.heavyImpact();
      // Animation bounce cho câu trả lời đúng
      _bounceController.reset();
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    } else {
      lives--;
      streak = 0;
      // Animation shake cho câu trả lời sai
      _shakeController.reset();
      _shakeController.forward();
      HapticFeedback.mediumImpact();
    }

    setState(() {
      showFeedback = true;
    });

    _feedbackController.reset();
    _feedbackController.forward();

    // Check game over
    if (lives <= 0 && !isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        _showGameOverDialog();
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showFeedback = false;
      });

      _progressController
          .animateTo((currentQuestionIndex + 1) / questions.length);
    } else {
      // Quiz completed - Award XP based on performance
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    // Phát âm thanh celebration khi hoàn thành
    _playCelebrationSound();

    // Award XP based on performance
    final xpService = XPService();
    final percentage = (score / (questions.length * 10) * 100).round();

    try {
      int awardedXP = 0;

      if (percentage >= 95) {
        // Perfect or near perfect score
        awardedXP = await xpService.awardXP(XPActivityType.quizPerfect);
      } else if (percentage >= 80) {
        // Good score
        awardedXP = await xpService.awardXP(XPActivityType.quizGood);
      } else if (percentage >= 60) {
        // Average score
        awardedXP = await xpService.awardXP(XPActivityType.quizAverage);
      }

      // Update daily streak
      await xpService.updateDailyStreak();

      // Store awarded XP for display
      score += awardedXP;

      print('Quiz completed: $percentage% accuracy, awarded $awardedXP XP');
    } catch (e) {
      print('Error awarding XP for quiz: $e');
    }

    setState(() {
      quizCompleted = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = null;
      showFeedback = false;
      isCorrect = false;
      score = 0;
      streak = 0;
      lives = 3;
      quizCompleted = false;
    });

    _progressController.reset();
    _progressController.animateTo(1 / questions.length);
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát bài kiểm tra?'),
        content: const Text('Tiến độ của bạn sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz
              widget.onExit?.call();
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hết mạng!'),
        content:
            const Text('Bạn đã trả lời sai quá nhiều. Hãy thử lại từ đầu.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartQuiz();
            },
            child: const Text('Thử lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }
}

/// Quiz launcher button với animation đẹp mắt
class QuizLauncherButton extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final Color unitColor;
  final String lessonTitle;
  final VoidCallback? onCompleted;

  const QuizLauncherButton({
    super.key,
    required this.quizData,
    required this.unitColor,
    required this.lessonTitle,
    this.onCompleted,
  });

  @override
  State<QuizLauncherButton> createState() => _QuizLauncherButtonState();
}

class _QuizLauncherButtonState extends State<QuizLauncherButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    setState(() {
      _isHovered = true;
    });
    _hoverController.forward();
  }

  void _onHoverEnd() {
    setState(() {
      _isHovered = false;
    });
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quizData['questions'] as List<dynamic>? ?? [];

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 8 + (_glowAnimation.value * 4),
              shadowColor: widget.unitColor.withOpacity(0.3),
              child: InkWell(
                onTap: _launchQuiz,
                onTapDown: (_) => _onHoverStart(),
                onTapUp: (_) => _onHoverEnd(),
                onTapCancel: () => _onHoverEnd(),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.unitColor,
                        widget.unitColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (_isHovered)
                        BoxShadow(
                          color: widget.unitColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(_isHovered ? 0.3 : 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bài kiểm tra DHV',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${questions.length} câu hỏi • ~${questions.length * 2} phút',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isHovered ? 0.05 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(_isHovered ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuizStat(Icons.help_outline, 'Câu hỏi',
                                '${questions.length}'),
                            _buildQuizStat(Icons.star, 'Điểm tối đa',
                                '${questions.length * 10} XP'),
                            _buildQuizStat(Icons.timer, 'Thời gian',
                                '${questions.length * 2}\''),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _launchQuiz() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuolingoQuizWidget(
          quizData: widget.quizData,
          unitColor: widget.unitColor,
          lessonTitle: widget.lessonTitle,
          onCompleted: widget.onCompleted,
        ),
      ),
    );
  }
}
