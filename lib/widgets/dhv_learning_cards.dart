import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Base class for DHV learning cards
abstract class DHVCard extends StatefulWidget {
  final Map<String, dynamic> cardData;
  final Color unitColor;
  final bool isDarkMode;

  const DHVCard({
    super.key,
    required this.cardData,
    required this.unitColor,
    required this.isDarkMode,
  });
}

// ========================================
// VISUAL CARD - Hình ảnh và Video
// ========================================
class DHVVisualCard extends DHVCard {
  const DHVVisualCard({
    super.key,
    required super.cardData,
    required super.unitColor,
    required super.isDarkMode,
  });

  @override
  State<DHVVisualCard> createState() => _DHVVisualCardState();
}

class _DHVVisualCardState extends State<DHVVisualCard> {
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          _buildCardHeader(
            icon: Icons.visibility,
            title: widget.cardData['title'] ?? 'Xem',
            subtitle: widget.cardData['subtitle'] ?? 'Nội dung trực quan',
            color: const Color(0xFF4CAF50),
          ),

          const SizedBox(height: 20),

          // Content based on card data
          if (widget.cardData['type'] == 'timeline') _buildTimelineWidget(),
          if (widget.cardData['type'] == 'gallery') _buildGalleryWidget(),
          if (widget.cardData['type'] == 'default')
            _buildDefaultVisualContent(),

          const SizedBox(height: 20),

          // Highlights section
          if (widget.cardData['highlights'] != null)
            _buildHighlightsSection(widget.cardData['highlights']),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineWidget() {
    final timelineData =
        widget.cardData['timelineData'] as List<Map<String, dynamic>>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dòng thời gian DHV',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...timelineData.map((event) => _buildTimelineItem(
                year: event['year']?.toString() ?? '',
                event: event['event']?.toString() ?? '',
                isLast: timelineData.indexOf(event) == timelineData.length - 1,
              )),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String event,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.unitColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: widget.unitColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.unitColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryWidget() {
    final images =
        widget.cardData['images'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      children: [
        // Main image display
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 64, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // Image thumbnails
        if (images.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: selectedImageIndex == index
                          ? Border.all(color: widget.unitColor, width: 2)
                          : null,
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 32, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultVisualContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            widget.cardData['content']?.toString() ??
                'Nội dung đang được cập nhật',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(List<dynamic> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm nổi bật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...highlights.map((highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: widget.unitColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ========================================
// AUDIO CARD - Âm thanh và Phát âm
// ========================================
class DHVAudioCard extends DHVCard {
  const DHVAudioCard({
    super.key,
    required super.cardData,
    required super.unitColor,
    required super.isDarkMode,
  });

  @override
  State<DHVAudioCard> createState() => _DHVAudioCardState();
}

class _DHVAudioCardState extends State<DHVAudioCard> {
  FlutterTts? flutterTts;
  bool isPlaying = false;
  int? playingWordIndex;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    flutterTts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    try {
      await flutterTts?.setLanguage("vi-VN");
      await flutterTts?.setSpeechRate(0.6);
      await flutterTts?.setVolume(1.0);
      await flutterTts?.setPitch(1.0);
    } catch (e) {
      print('TTS configuration error: $e');
    }
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          _buildCardHeader(
            icon: Icons.headphones,
            title: widget.cardData['title'] ?? 'Nghe',
            subtitle: widget.cardData['subtitle'] ?? 'Luyện nghe và phát âm',
            color: const Color(0xFF2196F3),
          ),

          const SizedBox(height: 20),

          // Content based on card data
          if (widget.cardData['type'] == 'pronunciation')
            _buildPronunciationWidget(),
          if (widget.cardData['type'] == 'vocabulary') _buildVocabularyWidget(),
          if (widget.cardData['type'] == 'default') _buildDefaultAudioContent(),

          const SizedBox(height: 20),

          // Highlights section
          if (widget.cardData['highlights'] != null)
            _buildHighlightsSection(widget.cardData['highlights']),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationWidget() {
    final pronunciationData =
        widget.cardData['pronunciationData'] as List<Map<String, dynamic>>? ??
            [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Luyện phát âm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...pronunciationData.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          return _buildPronunciationItem(
            word: word['word']?.toString() ?? '',
            ipa: word['ipa']?.toString() ?? '',
            meaning: word['meaning']?.toString() ?? '',
            index: index,
          );
        }),
      ],
    );
  }

  Widget _buildPronunciationItem({
    required String word,
    required String ipa,
    required String meaning,
    required int index,
  }) {
    final isPlaying = playingWordIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border:
            isPlaying ? Border.all(color: widget.unitColor, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ipa,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.unitColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  meaning,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _speakWord(word, index),
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: widget.unitColor,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyWidget() {
    final vocabulary =
        widget.cardData['vocabulary'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Từ vựng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...vocabulary.entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _speakWord(entry.key, null),
                    icon: Icon(
                      Icons.volume_up,
                      color: widget.unitColor,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDefaultAudioContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.headphones,
                size: 64,
                color: widget.unitColor,
              ),
              const SizedBox(height: 16),
              Text(
                widget.cardData['content']?.toString() ?? 'Nội dung âm thanh',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    _speakText(widget.cardData['audioText']?.toString() ?? ''),
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPlaying ? 'Dừng' : 'Phát âm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.unitColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection(List<dynamic> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm nổi bật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...highlights.map((highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.volume_up,
                    color: widget.unitColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Future<void> _speakWord(String word, int? index) async {
    try {
      if (isPlaying && playingWordIndex == index) {
        await flutterTts?.stop();
        setState(() {
          isPlaying = false;
          playingWordIndex = null;
        });
      } else {
        setState(() {
          isPlaying = true;
          playingWordIndex = index;
        });
        await flutterTts?.speak(word);
        setState(() {
          isPlaying = false;
          playingWordIndex = null;
        });
      }
    } catch (e) {
      print('TTS error: $e');
      setState(() {
        isPlaying = false;
        playingWordIndex = null;
      });
    }
  }

  Future<void> _speakText(String text) async {
    try {
      if (isPlaying) {
        await flutterTts?.stop();
        setState(() {
          isPlaying = false;
        });
      } else {
        setState(() {
          isPlaying = true;
        });
        await flutterTts?.speak(text);
        setState(() {
          isPlaying = false;
        });
      }
    } catch (e) {
      print('TTS error: $e');
      setState(() {
        isPlaying = false;
      });
    }
  }
}

// ========================================
// INTERACTIVE CARD - Tương tác và Quiz
// ========================================
class DHVInteractiveCard extends DHVCard {
  const DHVInteractiveCard({
    super.key,
    required super.cardData,
    required super.unitColor,
    required super.isDarkMode,
  });

  @override
  State<DHVInteractiveCard> createState() => _DHVInteractiveCardState();
}

class _DHVInteractiveCardState extends State<DHVInteractiveCard> {
  int? selectedAnswer;
  int currentQuestionIndex = 0;
  int score = 0;
  bool showExplanation = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          _buildCardHeader(
            icon: Icons.touch_app,
            title: widget.cardData['title'] ?? 'Tương tác',
            subtitle: widget.cardData['subtitle'] ?? 'Hoạt động tương tác',
            color: const Color(0xFFFF9800),
          ),

          const SizedBox(height: 20),

          // Content based on card data
          if (widget.cardData['type'] == 'quiz') _buildQuizWidget(),
          if (widget.cardData['type'] == 'map') _buildMapWidget(),
          if (widget.cardData['type'] == 'default')
            _buildDefaultInteractiveContent(),

          const SizedBox(height: 20),

          // Highlights section
          if (widget.cardData['highlights'] != null)
            _buildHighlightsSection(widget.cardData['highlights']),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizWidget() {
    final quizData = widget.cardData['quizData'] as Map<String, dynamic>? ?? {};
    final questions = quizData['questions'] as List<dynamic>? ?? [];

    if (questions.isEmpty) {
      return _buildDefaultInteractiveContent();
    }

    final currentQuestion =
        questions[currentQuestionIndex] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          children: [
            Text(
              'Câu ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(
                fontSize: 14,
                color: widget.unitColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Điểm: $score',
              style: TextStyle(
                fontSize: 14,
                color: widget.unitColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Question
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            currentQuestion['question']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Options
        ...((currentQuestion['options'] as List<dynamic>?) ?? [])
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final option = entry.value.toString();
          final isSelected = selectedAnswer == index;
          final correctAnswer = currentQuestion['correct'] as int? ?? -1;
          final isCorrect = index == correctAnswer;

          Color? backgroundColor;
          Color? borderColor;
          if (showExplanation) {
            if (isCorrect) {
              backgroundColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              backgroundColor = Colors.red.withOpacity(0.1);
              borderColor = Colors.red;
            }
          } else if (isSelected) {
            backgroundColor = widget.unitColor.withOpacity(0.1);
            borderColor = widget.unitColor;
          }

          return GestureDetector(
            onTap: showExplanation
                ? null
                : () {
                    setState(() {
                      selectedAnswer = index;
                    });
                  },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor ??
                    (widget.isDarkMode ? Colors.grey[800] : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor ?? Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: borderColor ?? Colors.grey.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (showExplanation && isCorrect)
                    const Icon(Icons.check, color: Colors.green),
                  if (showExplanation && isSelected && !isCorrect)
                    const Icon(Icons.close, color: Colors.red),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Check Answer Button
        if (!showExplanation && selectedAnswer != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final correctAnswer = currentQuestion['correct'] as int? ?? -1;
                if (selectedAnswer == correctAnswer) {
                  setState(() {
                    score += 10;
                  });
                }
                setState(() {
                  showExplanation = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.unitColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kiểm tra đáp án'),
            ),
          ),

        // Explanation
        if (showExplanation)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.unitColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giải thích:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentQuestion['explanation']?.toString() ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                if (currentQuestionIndex < questions.length - 1)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex++;
                          selectedAnswer = null;
                          showExplanation = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.unitColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Câu tiếp theo'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex = 0;
                          selectedAnswer = null;
                          showExplanation = false;
                          score = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Làm lại quiz'),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMapWidget() {
    final mapData = widget.cardData['mapData'] as Map<String, dynamic>? ?? {};
    final locations = mapData['locations'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bản đồ DHV',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.map, size: 64, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        ...locations.map((location) {
          final locationData = location as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: widget.unitColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationData['name']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tầng ${locationData['floor']} - Tòa ${locationData['building']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDefaultInteractiveContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            widget.cardData['content']?.toString() ?? 'Nội dung tương tác',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(List<dynamic> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm nổi bật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...highlights.map((highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star,
                    color: widget.unitColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ========================================
// INFO CARD - Chi tiết và Thống kê
// ========================================
class DHVInfoCard extends DHVCard {
  const DHVInfoCard({
    super.key,
    required super.cardData,
    required super.unitColor,
    required super.isDarkMode,
  });

  @override
  State<DHVInfoCard> createState() => _DHVInfoCardState();
}

class _DHVInfoCardState extends State<DHVInfoCard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          _buildCardHeader(
            icon: Icons.info,
            title: widget.cardData['title'] ?? 'Chi tiết',
            subtitle: widget.cardData['subtitle'] ?? 'Thông tin chi tiết',
            color: const Color(0xFF9C27B0),
          ),

          const SizedBox(height: 20),

          // Content based on card data
          if (widget.cardData['type'] == 'stats') _buildStatsWidget(),
          if (widget.cardData['type'] == 'default') _buildDefaultInfoContent(),

          const SizedBox(height: 20),

          // Highlights section
          if (widget.cardData['highlights'] != null)
            _buildHighlightsSection(widget.cardData['highlights']),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsWidget() {
    final statsData =
        widget.cardData['statsData'] as Map<String, dynamic>? ?? {};
    final stats = statsData['stats'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê DHV',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index] as Map<String, dynamic>;
            return _buildStatCard(
              label: stat['label']?.toString() ?? '',
              value: stat['value']?.toString() ?? '',
              iconName: stat['icon']?.toString() ?? 'info',
              color: Color(stat['color'] as int? ?? 0xFF9C27B0),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String iconName,
    required Color color,
  }) {
    IconData icon;
    switch (iconName) {
      case 'school':
        icon = Icons.school;
        break;
      case 'person':
        icon = Icons.person;
        break;
      case 'work':
        icon = Icons.work;
        break;
      case 'business':
        icon = Icons.business;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultInfoContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            widget.cardData['content']?.toString() ?? 'Thông tin chi tiết',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(List<dynamic> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm nổi bật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...highlights.map((highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.unitColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
