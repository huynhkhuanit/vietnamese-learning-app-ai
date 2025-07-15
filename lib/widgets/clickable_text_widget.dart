import 'package:flutter/material.dart';
import '../services/universal_tts_service.dart';

/// Widget cho phép click vào text để nghe TTS
/// Hỗ trợ người dùng nước ngoài học tiếng Việt
class ClickableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool enabled;
  final Color? highlightColor;
  final Duration highlightDuration;
  final VoidCallback? onTap;
  final String? englishTranslation;
  final bool showSpeakIcon;
  final bool autoDetectLanguage;

  const ClickableTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.enabled = true,
    this.highlightColor,
    this.highlightDuration = const Duration(milliseconds: 300),
    this.onTap,
    this.englishTranslation,
    this.showSpeakIcon = true,
    this.autoDetectLanguage = true,
  });

  @override
  State<ClickableTextWidget> createState() => _ClickableTextWidgetState();
}

class _ClickableTextWidgetState extends State<ClickableTextWidget>
    with SingleTickerProviderStateMixin {
  final UniversalTtsService _ttsService = UniversalTtsService();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isHighlighted = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimation();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    _ttsService.setCallbacks(
      onSpeechStart: () {
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      },
      onSpeechComplete: () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      },
      onSpeechError: (error) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      },
    );
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: widget.highlightDuration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.highlightColor ?? Colors.blue.withOpacity(0.3),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled || _isPlaying) return;

    // Gọi callback nếu có
    widget.onTap?.call();

    // Highlight animation
    setState(() {
      _isHighlighted = true;
    });
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isHighlighted = false;
          });
        }
      });
    });

    // Speak text
    if (widget.text.trim().isNotEmpty) {
      if (widget.autoDetectLanguage) {
        await _ttsService.quickSpeak(widget.text);
      } else {
        await _ttsService.speakVietnamese(widget.text);
      }

      // Nếu có bản dịch tiếng Anh và người dùng muốn nghe
      if (widget.englishTranslation != null &&
          widget.englishTranslation!.isNotEmpty) {
        // Đợi một chút rồi đọc bản dịch
        await Future.delayed(const Duration(milliseconds: 800));
        await _ttsService.speakEnglish(widget.englishTranslation!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color:
                  _isHighlighted ? _colorAnimation.value : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child:
                widget.showSpeakIcon ? _buildTextWithIcon() : _buildTextOnly(),
          );
        },
      ),
    );
  }

  Widget _buildTextOnly() {
    return Text(
      widget.text,
      style: widget.style?.copyWith(
        color:
            widget.enabled ? (widget.style?.color ?? Colors.blue) : Colors.grey,
        decoration: widget.enabled ? TextDecoration.underline : null,
        decorationStyle: TextDecorationStyle.dotted,
      ),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  Widget _buildTextWithIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.text,
            style: widget.style?.copyWith(
              color: widget.enabled
                  ? (widget.style?.color ?? Colors.blue)
                  : Colors.grey,
            ),
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            overflow: widget.overflow,
          ),
        ),
        const SizedBox(width: 4),
        _buildSpeakIcon(),
      ],
    );
  }

  Widget _buildSpeakIcon() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _isPlaying ? Colors.green : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
        size: 16,
        color: _isPlaying ? Colors.white : Colors.blue,
      ),
    );
  }
}

/// Phiên bản đơn giản của ClickableTextWidget chỉ để đọc text
class SimpleClickableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final UniversalTtsService _ttsService = UniversalTtsService();

  SimpleClickableText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _ttsService.initialize();
        await _ttsService.quickSpeak(text);
      },
      child: Text(
        text,
        style: style?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ) ??
            const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
      ),
    );
  }
}

/// Widget để tạo ra một paragraph với nhiều đoạn text clickable
class ClickableParagraph extends StatefulWidget {
  final List<ClickableTextSegment> segments;
  final TextStyle? defaultStyle;
  final TextAlign? textAlign;
  final double spacing;

  const ClickableParagraph({
    super.key,
    required this.segments,
    this.defaultStyle,
    this.textAlign,
    this.spacing = 4.0,
  });

  @override
  State<ClickableParagraph> createState() => _ClickableParagraphState();
}

class _ClickableParagraphState extends State<ClickableParagraph> {
  final UniversalTtsService _ttsService = UniversalTtsService();

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: widget.textAlign == TextAlign.center
          ? WrapAlignment.center
          : WrapAlignment.start,
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: widget.segments.map((segment) {
        return ClickableTextWidget(
          text: segment.text,
          style: segment.style ?? widget.defaultStyle,
          englishTranslation: segment.englishTranslation,
          showSpeakIcon: segment.showSpeakIcon,
          enabled: segment.enabled,
          onTap: segment.onTap,
        );
      }).toList(),
    );
  }
}

/// Model cho một đoạn text trong paragraph
class ClickableTextSegment {
  final String text;
  final TextStyle? style;
  final String? englishTranslation;
  final bool showSpeakIcon;
  final bool enabled;
  final VoidCallback? onTap;

  const ClickableTextSegment({
    required this.text,
    this.style,
    this.englishTranslation,
    this.showSpeakIcon = false,
    this.enabled = true,
    this.onTap,
  });
}

/// Mixin để thêm tính năng TTS vào bất kỳ widget nào
mixin TTSCapability {
  final UniversalTtsService ttsService = UniversalTtsService();

  Future<void> initializeTTS() async {
    await ttsService.initialize();
  }

  Future<void> speakText(String text, {bool vietnamese = true}) async {
    if (vietnamese) {
      await ttsService.speakVietnamese(text);
    } else {
      await ttsService.speakEnglish(text);
    }
  }

  Future<void> speakWithTranslation(String vietnamese, String english) async {
    await ttsService.speakWithExplanation(vietnamese, english);
  }

  Future<void> stopSpeaking() async {
    await ttsService.stop();
  }
}

/// Widget chuyên biệt cho danh sách nội dung có thể click-to-speak
/// Hỗ trợ nhiều tính năng TTS nâng cao
class ClickableContentListWidget extends StatefulWidget {
  final List<String> contentList;
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final Color? highlightColor;
  final bool showPlayAllButton;
  final bool showRepeatButton;
  final bool showSlowModeButton;
  final bool autoNumbering;
  final EdgeInsets? padding;
  final double spacing;
  final VoidCallback? onPlayAllComplete;
  final Function(int index, String content)? onItemSpeak;

  const ClickableContentListWidget({
    super.key,
    required this.contentList,
    this.title,
    this.titleStyle,
    this.contentStyle,
    this.highlightColor,
    this.showPlayAllButton = true,
    this.showRepeatButton = true,
    this.showSlowModeButton = true,
    this.autoNumbering = true,
    this.padding,
    this.spacing = 12.0,
    this.onPlayAllComplete,
    this.onItemSpeak,
  });

  @override
  State<ClickableContentListWidget> createState() =>
      _ClickableContentListWidgetState();
}

class _ClickableContentListWidgetState
    extends State<ClickableContentListWidget> {
  final UniversalTtsService _ttsService = UniversalTtsService();
  bool _isPlayingAll = false;
  bool _isSlowMode = false;
  int _currentPlayingIndex = -1;
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    _ttsService.setCallbacks(
      onSpeechStart: () {
        if (mounted) {
          setState(() {});
        }
      },
      onSpeechComplete: () {
        if (mounted) {
          setState(() {
            _currentPlayingIndex = -1;
            _highlightedIndex = -1;
          });
        }
      },
      onSpeechError: (error) {
        if (mounted) {
          setState(() {
            _isPlayingAll = false;
            _currentPlayingIndex = -1;
            _highlightedIndex = -1;
          });
        }
      },
    );
  }

  Future<void> _playAllContent() async {
    if (_isPlayingAll) {
      await _ttsService.stop();
      setState(() {
        _isPlayingAll = false;
        _currentPlayingIndex = -1;
        _highlightedIndex = -1;
      });
      return;
    }

    setState(() {
      _isPlayingAll = true;
    });

    for (int i = 0; i < widget.contentList.length; i++) {
      if (!_isPlayingAll) break; // Người dùng đã dừng

      setState(() {
        _currentPlayingIndex = i;
        _highlightedIndex = i;
      });

      await _ttsService.speakVietnamese(
        widget.contentList[i],
        slow: _isSlowMode,
      );

      widget.onItemSpeak?.call(i, widget.contentList[i]);

      // Nghỉ một chút giữa các câu
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isPlayingAll = false;
      _currentPlayingIndex = -1;
      _highlightedIndex = -1;
    });

    widget.onPlayAllComplete?.call();
  }

  Future<void> _speakItem(int index) async {
    if (_isPlayingAll) return;

    setState(() {
      _currentPlayingIndex = index;
      _highlightedIndex = index;
    });

    await _ttsService.speakVietnamese(
      widget.contentList[index],
      slow: _isSlowMode,
    );

    widget.onItemSpeak?.call(index, widget.contentList[index]);
  }

  void _toggleSlowMode() {
    setState(() {
      _isSlowMode = !_isSlowMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title với control buttons
          if (widget.title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title!,
                    style: widget.titleStyle ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Control buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showSlowModeButton)
                      IconButton(
                        onPressed: _toggleSlowMode,
                        icon: Icon(
                          _isSlowMode ? Icons.speed : Icons.slow_motion_video,
                          color: _isSlowMode ? Colors.orange : Colors.grey,
                        ),
                        tooltip:
                            _isSlowMode ? 'Tốc độ bình thường' : 'Chế độ chậm',
                      ),
                    if (widget.showRepeatButton)
                      IconButton(
                        onPressed: _isPlayingAll
                            ? null
                            : () async {
                                if (_currentPlayingIndex >= 0) {
                                  await _speakItem(_currentPlayingIndex);
                                }
                              },
                        icon: Icon(
                          Icons.repeat,
                          color: _currentPlayingIndex >= 0
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        tooltip: 'Lặp lại',
                      ),
                    if (widget.showPlayAllButton)
                      IconButton(
                        onPressed: _playAllContent,
                        icon: Icon(
                          _isPlayingAll ? Icons.stop : Icons.play_arrow,
                          color: _isPlayingAll ? Colors.red : Colors.green,
                        ),
                        tooltip: _isPlayingAll ? 'Dừng' : 'Phát tất cả',
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: widget.spacing),
          ],

          // Content list
          ...widget.contentList.asMap().entries.map((entry) {
            int index = entry.key;
            String content = entry.value;
            bool isCurrentlyPlaying = _currentPlayingIndex == index;
            bool isHighlighted = _highlightedIndex == index;

            return Container(
              margin: EdgeInsets.only(bottom: widget.spacing),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? (widget.highlightColor ?? Colors.blue.withOpacity(0.1))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrentlyPlaying
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.2),
                  width: isCurrentlyPlaying ? 2 : 1,
                ),
              ),
              child: GestureDetector(
                onTap: () => _speakItem(index),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numbering
                    if (widget.autoNumbering)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrentlyPlaying
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrentlyPlaying
                                ? Colors.white
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),

                    // Content
                    Expanded(
                      child: Text(
                        content,
                        style: widget.contentStyle?.copyWith(
                              color: isCurrentlyPlaying ? Colors.blue : null,
                              fontWeight:
                                  isCurrentlyPlaying ? FontWeight.w600 : null,
                            ) ??
                            TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isCurrentlyPlaying
                                  ? Colors.blue
                                  : Colors.black87,
                              fontWeight: isCurrentlyPlaying
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),

                    // Play icon
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isCurrentlyPlaying
                            ? Colors.green
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isCurrentlyPlaying
                            ? Icons.volume_up
                            : Icons.volume_up_outlined,
                        size: 16,
                        color: isCurrentlyPlaying ? Colors.white : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}

/// Widget hỗ trợ học tập toàn diện với nhiều tính năng TTS
class StudyAssistantWidget extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  final bool showFloatingControls;
  final EdgeInsets? padding;

  const StudyAssistantWidget({
    super.key,
    required this.lessonData,
    this.showFloatingControls = true,
    this.padding,
  });

  @override
  State<StudyAssistantWidget> createState() => _StudyAssistantWidgetState();
}

class _StudyAssistantWidgetState extends State<StudyAssistantWidget>
    with TickerProviderStateMixin {
  final UniversalTtsService _ttsService = UniversalTtsService();
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;

  bool _isExpanded = false;
  bool _isReading = false;
  bool _autoMode = false;
  double _currentSpeed = 0.6;
  int _currentSection = 0;

  final List<String> _speedLabels = ['Chậm', 'Bình thường', 'Nhanh'];
  final List<double> _speedValues = [0.4, 0.6, 1.0];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimations();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    _ttsService.setCallbacks(
      onSpeechStart: () {
        if (mounted) {
          setState(() {
            _isReading = true;
          });
          debugPrint(
              'StudyAssistant: Speech started for section $_currentSection');
        }
      },
      onSpeechComplete: () {
        if (mounted) {
          setState(() {
            _isReading = false;
          });
          debugPrint(
              'StudyAssistant: Speech completed for section $_currentSection');

          // Only continue auto reading if still in auto mode and not at the end
          if (_autoMode) {
            _continueAutoReading();
          }
        }
      },
      onSpeechError: (error) {
        if (mounted) {
          setState(() {
            _isReading = false;
            _autoMode = false;
          });
          debugPrint('StudyAssistant: Speech error: $error');
        }
      },
    );
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  List<String> _getAllContent() {
    List<String> content = [];

    try {
      // Debug: In ra toàn bộ cấu trúc lessonData
      debugPrint('=== StudyAssistant: DEBUG lessonData structure ===');
      widget.lessonData.forEach((key, value) {
        debugPrint('Key: $key, Type: ${value.runtimeType}');
        if (value is Map) {
          debugPrint('  Map keys: ${value.keys.toList()}');
        } else if (value is List) {
          debugPrint('  List length: ${value.length}');
          if (value.isNotEmpty) {
            debugPrint('  First item type: ${value.first.runtimeType}');
          }
        } else {
          final str = value.toString();
          debugPrint(
              '  Value: ${str.length > 100 ? '${str.substring(0, 100)}...' : str}');
        }
      });
      debugPrint('=== END DEBUG ===');

      // 1. Title (luôn thêm đầu tiên)
      if (widget.lessonData['title'] != null &&
          widget.lessonData['title'].toString().trim().isNotEmpty) {
        content.add(widget.lessonData['title'].toString().trim());
        debugPrint('Added title: ${widget.lessonData['title']}');
      }

      // 2. Description/subtitle
      if (widget.lessonData['description'] != null &&
          widget.lessonData['description'].toString().trim().isNotEmpty) {
        content.add(widget.lessonData['description'].toString().trim());
        debugPrint('Added description');
      }

      // 3. Main content
      if (widget.lessonData['content'] != null &&
          widget.lessonData['content'].toString().trim().isNotEmpty) {
        content.add(widget.lessonData['content'].toString().trim());
        debugPrint('Added main content');
      }

      // 4. Key points (quan trọng!)
      if (widget.lessonData['keyPoints'] != null) {
        final keyPoints = widget.lessonData['keyPoints'];
        debugPrint('Processing keyPoints: ${keyPoints.runtimeType}');

        if (keyPoints is List) {
          debugPrint('KeyPoints is List with ${keyPoints.length} items');
          for (int i = 0; i < keyPoints.length; i++) {
            final point = keyPoints[i];
            final pointStr = point.toString().trim();
            if (pointStr.isNotEmpty) {
              content.add(pointStr);
              debugPrint(
                  'Added keyPoint $i: ${pointStr.substring(0, pointStr.length > 50 ? 50 : pointStr.length)}...');
            }
          }
        } else if (keyPoints is String && keyPoints.trim().isNotEmpty) {
          content.add(keyPoints.trim());
          debugPrint('Added keyPoints as string');
        }
      }

      // 5. Card content từ DHVCardDataProvider
      debugPrint('Processing card data...');
      for (var cardType in ['visual', 'audio', 'interactive', 'info']) {
        if (widget.lessonData[cardType] != null) {
          final cardData = widget.lessonData[cardType];
          debugPrint('Processing $cardType card: ${cardData.runtimeType}');

          if (cardData is Map<String, dynamic>) {
            // Card title
            if (cardData['title'] != null &&
                cardData['title'].toString().trim().isNotEmpty) {
              content.add(cardData['title'].toString().trim());
              debugPrint('Added $cardType title: ${cardData['title']}');
            }

            // Card subtitle
            if (cardData['subtitle'] != null &&
                cardData['subtitle'].toString().trim().isNotEmpty) {
              content.add(cardData['subtitle'].toString().trim());
              debugPrint('Added $cardType subtitle');
            }

            // Card content
            if (cardData['content'] != null &&
                cardData['content'].toString().trim().isNotEmpty) {
              content.add(cardData['content'].toString().trim());
              debugPrint('Added $cardType content');
            }

            // Card text
            if (cardData['text'] != null &&
                cardData['text'].toString().trim().isNotEmpty) {
              content.add(cardData['text'].toString().trim());
              debugPrint('Added $cardType text');
            }

            // Card audioText (for audio cards)
            if (cardData['audioText'] != null &&
                cardData['audioText'].toString().trim().isNotEmpty) {
              content.add(cardData['audioText'].toString().trim());
              debugPrint('Added $cardType audioText');
            }

            // Card highlights
            if (cardData['highlights'] != null &&
                cardData['highlights'] is List) {
              final highlights = cardData['highlights'] as List<dynamic>;
              debugPrint(
                  'Processing $cardType highlights: ${highlights.length} items');

              for (int i = 0; i < highlights.length; i++) {
                final highlight = highlights[i];
                final highlightStr = highlight.toString().trim();
                if (highlightStr.isNotEmpty) {
                  content.add(highlightStr);
                  debugPrint(
                      'Added $cardType highlight $i: ${highlightStr.substring(0, highlightStr.length > 30 ? 30 : highlightStr.length)}...');
                }
              }
            }

            // Card keyPoints (nếu có)
            if (cardData['keyPoints'] != null &&
                cardData['keyPoints'] is List) {
              final cardKeyPoints = cardData['keyPoints'] as List<dynamic>;
              debugPrint(
                  'Processing $cardType keyPoints: ${cardKeyPoints.length} items');

              for (int i = 0; i < cardKeyPoints.length; i++) {
                final keyPoint = cardKeyPoints[i];
                final keyPointStr = keyPoint.toString().trim();
                if (keyPointStr.isNotEmpty) {
                  content.add(keyPointStr);
                  debugPrint('Added $cardType keyPoint $i');
                }
              }
            }

            // Card features (cho interactive cards)
            if (cardData['features'] != null && cardData['features'] is List) {
              final features = cardData['features'] as List<dynamic>;
              for (var feature in features) {
                if (feature is Map && feature['description'] != null) {
                  final featureDesc = feature['description'].toString().trim();
                  if (featureDesc.isNotEmpty) {
                    content.add(featureDesc);
                    debugPrint('Added $cardType feature description');
                  }
                }
              }
            }

            // Card info points (cho info cards)
            if (cardData['infoPoints'] != null &&
                cardData['infoPoints'] is List) {
              final infoPoints = cardData['infoPoints'] as List<dynamic>;
              for (var point in infoPoints) {
                if (point is Map && point['detail'] != null) {
                  final detail = point['detail'].toString().trim();
                  if (detail.isNotEmpty) {
                    content.add(detail);
                    debugPrint('Added $cardType info detail');
                  }
                }
              }
            }
          }
        }
      }

      // 6. Additional sections
      if (widget.lessonData['sections'] != null &&
          widget.lessonData['sections'] is List) {
        final sections = widget.lessonData['sections'] as List<dynamic>;
        debugPrint('Processing sections: ${sections.length} items');

        for (int i = 0; i < sections.length; i++) {
          final section = sections[i];
          if (section is Map) {
            if (section['content'] != null) {
              final sectionContent = section['content'].toString().trim();
              if (sectionContent.isNotEmpty) {
                content.add(sectionContent);
                debugPrint('Added section $i content');
              }
            }
            if (section['title'] != null) {
              final sectionTitle = section['title'].toString().trim();
              if (sectionTitle.isNotEmpty) {
                content.add(sectionTitle);
                debugPrint('Added section $i title');
              }
            }
          }
        }
      }

      // 7. Remove duplicates và empty strings
      final uniqueContent = <String>[];
      final seen = <String>{};

      for (String item in content) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty && !seen.contains(trimmed)) {
          uniqueContent.add(trimmed);
          seen.add(trimmed);
        }
      }

      content = uniqueContent;

      debugPrint('=== StudyAssistant: FINAL CONTENT ===');
      debugPrint('Total content items: ${content.length}');
      for (int i = 0; i < content.length; i++) {
        final preview = content[i].length > 80
            ? '${content[i].substring(0, 80)}...'
            : content[i];
        debugPrint('[$i] $preview');
      }
      debugPrint('=== END FINAL CONTENT ===');
    } catch (e, stackTrace) {
      debugPrint('Error in _getAllContent: $e');
      debugPrint('StackTrace: $stackTrace');
    }

    // Fallback: nếu không có content nào, ít nhất trả về title
    if (content.isEmpty && widget.lessonData['title'] != null) {
      content.add(widget.lessonData['title'].toString());
      debugPrint('Fallback: Added only title');
    }

    return content;
  }

  Future<void> _speakCurrentSection() async {
    final allContent = _getAllContent();

    debugPrint(
        'StudyAssistant: _speakCurrentSection called - currentSection: $_currentSection, totalContent: ${allContent.length}');

    if (allContent.isEmpty) {
      debugPrint('StudyAssistant: No content available to speak');
      setState(() {
        _isReading = false;
        _autoMode = false;
      });
      return;
    }

    if (_currentSection < 0 || _currentSection >= allContent.length) {
      debugPrint(
          'StudyAssistant: Invalid section index $_currentSection (total: ${allContent.length})');
      setState(() {
        _isReading = false;
        _autoMode = false;
      });
      return;
    }

    final contentToSpeak = allContent[_currentSection];
    if (contentToSpeak.trim().isEmpty) {
      debugPrint('StudyAssistant: Section $_currentSection is empty, skipping');
      // Auto skip to next section if in auto mode
      if (_autoMode) {
        _continueAutoReading();
      }
      return;
    }

    final preview = contentToSpeak.length > 50
        ? '${contentToSpeak.substring(0, 50)}...'
        : contentToSpeak;
    debugPrint('StudyAssistant: Speaking section $_currentSection: $preview');

    try {
      setState(() {
        _isReading = true;
      });

      await _ttsService.speakVietnamese(
        contentToSpeak,
        slow: _currentSpeed < 0.6,
      );

      debugPrint('StudyAssistant: Successfully spoke section $_currentSection');
    } catch (e) {
      debugPrint('StudyAssistant: Error speaking section $_currentSection: $e');
      setState(() {
        _isReading = false;
        _autoMode = false;
      });
    }
  }

  Future<void> _continueAutoReading() async {
    debugPrint(
        'StudyAssistant: _continueAutoReading called - autoMode: $_autoMode, isReading: $_isReading');

    if (!_autoMode) {
      debugPrint('StudyAssistant: Auto mode disabled, stopping auto reading');
      return;
    }

    if (_isReading) {
      debugPrint('StudyAssistant: Still reading, waiting...');
      return;
    }

    final allContent = _getAllContent();
    debugPrint(
        'StudyAssistant: Current section $_currentSection of ${allContent.length}');

    if (allContent.isEmpty) {
      debugPrint('StudyAssistant: No content available, stopping auto reading');
      setState(() {
        _autoMode = false;
        _isReading = false;
      });
      return;
    }

    if (_currentSection < allContent.length - 1) {
      // Move to next section
      final nextSection = _currentSection + 1;
      setState(() {
        _currentSection = nextSection;
      });

      debugPrint(
          'StudyAssistant: Auto reading - moving to section $nextSection');

      // Add a delay before speaking next section
      await Future.delayed(const Duration(milliseconds: 1200));

      // Double check state before continuing
      if (_autoMode &&
          mounted &&
          !_isReading &&
          _currentSection < allContent.length) {
        debugPrint(
            'StudyAssistant: Continuing auto reading with section $_currentSection');
        await _speakCurrentSection();
      } else {
        debugPrint(
            'StudyAssistant: State changed during delay, stopping auto reading');
        debugPrint(
            '  autoMode: $_autoMode, mounted: $mounted, isReading: $_isReading');
      }
    } else {
      // Reached the end, stop auto mode
      debugPrint('StudyAssistant: Auto reading completed - reached end');
      setState(() {
        _autoMode = false;
        _isReading = false;
      });

      // Show completion message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã đọc xong toàn bộ nội dung'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _startAutoReading() async {
    final allContent = _getAllContent();

    if (allContent.isEmpty) {
      debugPrint(
          'StudyAssistant: No content to read - lessonData may be empty or malformed');
      _showNoContentMessage();
      return;
    }

    // Stop any current speech
    if (_isReading) {
      debugPrint(
          'StudyAssistant: Stopping current speech before starting auto reading');
      await _ttsService.stop();
    }

    setState(() {
      _autoMode = true;
      _currentSection = 0;
      _isReading = false;
    });

    debugPrint(
        'StudyAssistant: Starting auto reading with ${allContent.length} sections');
    debugPrint('Content preview:');
    for (int i = 0; i < allContent.length && i < 5; i++) {
      final preview = allContent[i].length > 60
          ? '${allContent[i].substring(0, 60)}...'
          : allContent[i];
      debugPrint('  [$i] $preview');
    }

    // Wait a bit to ensure state is updated
    await Future.delayed(const Duration(milliseconds: 300));

    if (_autoMode && mounted && allContent.isNotEmpty) {
      debugPrint('StudyAssistant: Starting with section 0');
      await _speakCurrentSection();
    }
  }

  void _showNoContentMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy nội dung để đọc'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _stopReading() async {
    debugPrint('StudyAssistant: Stopping reading');

    // Stop TTS service
    await _ttsService.stop();

    // Wait a bit to ensure TTS stops completely
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _isReading = false;
        _autoMode = false;
      });
    }

    debugPrint('StudyAssistant: Reading stopped successfully');
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _floatingController.forward();
    } else {
      _floatingController.reverse();
    }
  }

  void _changeSpeed() {
    setState(() {
      final currentIndex = _speedValues.indexOf(_currentSpeed);
      final nextIndex = (currentIndex + 1) % _speedValues.length;
      _currentSpeed = _speedValues[nextIndex];
    });
  }

  Future<void> _previousSection() async {
    final allContent = _getAllContent();

    if (_currentSection > 0) {
      // Stop current speech if playing
      if (_isReading) {
        await _ttsService.stop();
      }

      setState(() {
        _currentSection--;
        _autoMode = false; // Disable auto mode when manually navigating
      });

      debugPrint('StudyAssistant: Moving to previous section $_currentSection');
      await _speakCurrentSection();
    }
  }

  Future<void> _nextSection() async {
    final allContent = _getAllContent();

    if (_currentSection < allContent.length - 1) {
      // Stop current speech if playing
      if (_isReading) {
        await _ttsService.stop();
      }

      setState(() {
        _currentSection++;
        _autoMode = false; // Disable auto mode when manually navigating
      });

      debugPrint('StudyAssistant: Moving to next section $_currentSection');
      await _speakCurrentSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showFloatingControls) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      right: 16,
      child: SlideTransition(
        position: _floatingAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(24),
          color: Colors.blue.shade600,
          child:
              _isExpanded ? _buildExpandedControls() : _buildCollapsedButton(),
        ),
      ),
    );
  }

  Widget _buildCollapsedButton() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isReading ? Icons.volume_up : Icons.school,
              color: Colors.white,
              size: 24,
            ),
            if (_isReading) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedControls() {
    final allContent = _getAllContent();
    final currentSpeedIndex = _speedValues.indexOf(_currentSpeed);

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.assistant, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Trợ lý học tập',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleExpanded,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress indicator
          if (allContent.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phần ${_currentSection + 1}/${allContent.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentSection + 1) / allContent.length,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 12),
          ],

          // Speed control
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tốc độ: ${_speedLabels[currentSpeedIndex]}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: _changeSpeed,
                icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous
              IconButton(
                onPressed:
                    _currentSection > 0 ? () => _previousSection() : null,
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),

              // Play/Stop
              IconButton(
                onPressed: _isReading
                    ? () => _stopReading()
                    : () => _speakCurrentSection(),
                icon: Icon(
                  _isReading ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),

              // Next
              IconButton(
                onPressed: _currentSection < allContent.length - 1
                    ? () => _nextSection()
                    : null,
                icon: const Icon(Icons.skip_next, color: Colors.white),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Auto mode toggle
          Row(
            children: [
              Checkbox(
                value: _autoMode,
                onChanged: (value) {
                  setState(() {
                    _autoMode = value ?? false;
                  });
                  if (_autoMode && !_isReading) {
                    _startAutoReading();
                  }
                },
                checkColor: Colors.blue.shade600,
                fillColor: WidgetStateProperty.all(Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Tự động đọc toàn bộ',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _ttsService.stop();
    super.dispose();
  }
}
