import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/life_theme_exercises.dart';
import '../services/universal_tts_service.dart';

class LifeThemeLessonWidget extends StatefulWidget {
  final int unitNumber;
  final int lessonNumber;
  final String unitTitle;
  final Color unitColor;
  final VoidCallback? onCompleted;
  final VoidCallback? onExit;

  const LifeThemeLessonWidget({
    super.key,
    required this.unitNumber,
    required this.lessonNumber,
    required this.unitTitle,
    required this.unitColor,
    this.onCompleted,
    this.onExit,
  });

  @override
  State<LifeThemeLessonWidget> createState() => _LifeThemeLessonWidgetState();
}

class _LifeThemeLessonWidgetState extends State<LifeThemeLessonWidget>
    with TickerProviderStateMixin {
  late List<LifeThemeExercise> exercises;
  int currentExerciseIndex = 0;
  int lives = 3;
  int xp = 0;
  int streak = 0;
  bool isAnswered = false;
  bool isCorrect = false;
  String? selectedAnswer;

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _progressAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;

  // TTS Service
  final UniversalTtsService _ttsService = UniversalTtsService();

  @override
  void initState() {
    super.initState();
    _initializeExercises();
    _initializeAnimations();
  }

  void _initializeExercises() {
    exercises = LifeThemeExerciseProvider.getLessonExercises(
      widget.unitNumber,
      widget.lessonNumber,
    );

    if (exercises.isEmpty) {
      // Fallback exercises if none available
      exercises = [
        LifeThemeExercise(
          type: LifeThemeExerciseType.multipleChoice,
          instruction: 'Bài học này đang được phát triển',
          questionText: 'Vui lòng thử lại sau',
          exerciseData: {},
          correctAnswer: 'OK',
          options: ['OK'],
          explanation: 'Cảm ơn bạn đã kiên nhẫn!',
          difficulty: 1,
          tags: ['placeholder'],
        ),
      ];
    }
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Start progress animation
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _playQuestionAudio() async {
    final exercise = exercises[currentExerciseIndex];
    if (exercise.audioUrl != null) {
      // In real app, would play audio file
      await _ttsService.speak(exercise.questionText ?? '', language: 'vi-VN');
    }
  }

  void _submitAnswer(String answer) async {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
      selectedAnswer = answer;
      isCorrect = answer == exercises[currentExerciseIndex].correctAnswer;
    });

    if (isCorrect) {
      // Correct answer feedback
      _bounceController.forward().then((_) => _bounceController.reverse());
      SystemSound.play(SystemSoundType.click);
      await _ttsService.speak('Chính xác! Rất tốt!', language: 'vi-VN');

      setState(() {
        xp += 10;
        streak++;
      });

      // Auto advance after 2 seconds
      Future.delayed(const Duration(seconds: 2), _nextExercise);
    } else {
      // Wrong answer feedback
      _shakeController.forward().then((_) => _shakeController.reverse());
      SystemSound.play(SystemSoundType.alert);
      await _ttsService.speak('Không đúng rồi. Hãy thử lại!',
          language: 'vi-VN');

      setState(() {
        lives--;
        streak = 0;
      });

      if (lives <= 0) {
        _showGameOverDialog();
      } else {
        // Allow retry after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            isAnswered = false;
            selectedAnswer = null;
          });
        });
      }
    }
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        isAnswered = false;
        selectedAnswer = null;
        isCorrect = false;
      });

      // Update progress animation
      final progress = (currentExerciseIndex + 1) / exercises.length;
      _progressController.animateTo(progress);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: widget.unitColor, size: 30),
            const SizedBox(width: 10),
            const Text('Xuất sắc!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn đã hoàn thành bài học ${widget.lessonNumber + 1}!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.unitColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('XP thu được:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$xp XP',
                          style: TextStyle(
                              color: widget.unitColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Streak tối đa:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$streak',
                          style: TextStyle(
                              color: widget.unitColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onExit?.call();
            },
            child: const Text('Tiếp tục'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Hết lượt rồi!'),
          ],
        ),
        content: const Text('Bạn đã hết tim. Hãy thử lại sau để tiếp tục học!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onExit?.call();
            },
            child: const Text('Thoát'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                lives = 3;
                currentExerciseIndex = 0;
                isAnswered = false;
                selectedAnswer = null;
                xp = 0;
                streak = 0;
              });
              _progressController.reset();
              _progressController.forward();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lives
              Row(
                children: List.generate(
                    3,
                    (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            index < lives
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 24,
                          ),
                        )),
              ),
              // XP
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$xp XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value *
                    (currentExerciseIndex + 1) /
                    exercises.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(widget.unitColor),
                minHeight: 8,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${currentExerciseIndex + 1} / ${exercises.length}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent() {
    final exercise = exercises[currentExerciseIndex];

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeAnimation.value *
            5 *
            (currentExerciseIndex % 2 == 0 ? 1 : -1);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instruction
                Text(
                  exercise.instruction,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Question content
                if (exercise.questionText != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.unitColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.questionText!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (exercise.audioUrl != null)
                          IconButton(
                            onPressed: _playQuestionAudio,
                            icon: Icon(
                              Icons.volume_up,
                              color: widget.unitColor,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Exercise-specific content
                _buildExerciseTypeContent(exercise),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseTypeContent(LifeThemeExercise exercise) {
    switch (exercise.type) {
      case LifeThemeExerciseType.multipleChoice:
        return _buildMultipleChoiceOptions(exercise);
      case LifeThemeExerciseType.wordBuilding:
        return _buildWordBuildingContent(exercise);
      case LifeThemeExerciseType.dragAndDrop:
        return _buildDragDropContent(exercise);
      case LifeThemeExerciseType.listening:
        return _buildListeningContent(exercise);
      case LifeThemeExerciseType.matchPairs:
        return _buildMatchPairsContent(exercise);
      default:
        return _buildMultipleChoiceOptions(exercise);
    }
  }

  Widget _buildMultipleChoiceOptions(LifeThemeExercise exercise) {
    return Column(
      children: exercise.options.map((option) {
        final isSelected = selectedAnswer == option;
        final isCorrectOption = option == exercise.correctAnswer;

        Color? backgroundColor;
        Color? borderColor;

        if (isAnswered) {
          if (isSelected) {
            backgroundColor = isCorrect
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2);
            borderColor = isCorrect ? Colors.green : Colors.red;
          } else if (isCorrectOption && !isCorrect) {
            backgroundColor = Colors.green.withOpacity(0.2);
            borderColor = Colors.green;
          }
        }

        return AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            final scale = isAnswered && isSelected && isCorrect
                ? _bounceAnimation.value
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: isAnswered ? null : () => _submitAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor ?? Colors.grey[100],
                    foregroundColor: Colors.black,
                    side: borderColor != null
                        ? BorderSide(color: borderColor, width: 2)
                        : null,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isSelected ? 4 : 1,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildWordBuildingContent(LifeThemeExercise exercise) {
    final scrambledLetters =
        exercise.exerciseData['scrambledLetters'] as List<String>? ?? [];

    return Column(
      children: [
        const Text(
          'Sắp xếp các chữ cái:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: scrambledLetters
              .map(
                (letter) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.unitColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              isAnswered ? null : () => _submitAnswer(exercise.correctAnswer),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }

  Widget _buildDragDropContent(LifeThemeExercise exercise) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            exercise.questionText ?? '',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          children: exercise.options
              .map(
                (option) => Draggable<String>(
                  data: option,
                  feedback: Material(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.unitColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.unitColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildListeningContent(LifeThemeExercise exercise) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.unitColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _playQuestionAudio,
            icon: Icon(
              Icons.play_arrow,
              size: 48,
              color: widget.unitColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Nhấn để nghe lại',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _buildMultipleChoiceOptions(exercise),
      ],
    );
  }

  Widget _buildMatchPairsContent(LifeThemeExercise exercise) {
    final pairs = exercise.exerciseData['pairs'] as Map<String, String>? ?? {};

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: pairs.keys
                    .map(
                      (vietnameseWord) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.unitColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vietnameseWord,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: pairs.values
                    .map(
                      (englishWord) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          englishWord,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isAnswered ? null : () => _submitAnswer('all_matched'),
          child: const Text('Hoàn thành'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: widget.unitColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onExit,
        ),
        title: Text(
          widget.unitTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildExerciseContent(),
            ),
          ),
          // Feedback area
          if (isAnswered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: isCorrect ? Colors.green[50] : Colors.red[50],
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.error,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercises[currentExerciseIndex].explanation,
                      style: TextStyle(
                        color: isCorrect ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w500,
                      ),
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
