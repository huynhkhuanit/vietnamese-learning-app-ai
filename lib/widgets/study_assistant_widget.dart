import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/universal_tts_service.dart';

// ===============================================
// STUDY ASSISTANT WIDGET - TRỢ LÝ HỌC TẬP THÔNG MINH
// ===============================================

class DHVStudyAssistantWidget extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  final VoidCallback? onHintRequest;
  final VoidCallback? onExplanationRequest;

  const DHVStudyAssistantWidget({
    super.key,
    required this.lessonData,
    this.onHintRequest,
    this.onExplanationRequest,
  });

  @override
  State<DHVStudyAssistantWidget> createState() =>
      _DHVStudyAssistantWidgetState();
}

class _DHVStudyAssistantWidgetState extends State<DHVStudyAssistantWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  final UniversalTtsService _tts = UniversalTtsService();
  bool _isExpanded = false;
  bool _isAssistantActive = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeTTS() async {
    await _tts.initialize();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: _buildAssistantButton(),
          );
        },
      ),
    );
  }

  Widget _buildAssistantButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expanded panel
        if (_isExpanded) _buildAssistantPanel(),

        const SizedBox(height: 12),

        // Main floating button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: GestureDetector(
                onTap: _toggleAssistant,
                onLongPress: _speakWelcome,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B73FF),
                        const Color(0xFF9C27B0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B73FF).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _isExpanded ? Icons.close : Icons.psychology,
                        color: Colors.white,
                        size: 28,
                      ),
                      if (_isAssistantActive)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssistantPanel() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6B73FF).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF6B73FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Trợ lý DHV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B73FF),
                  ),
                ),
              ),
              Icon(
                Icons.smart_toy,
                color: Colors.amber,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick actions
          _buildQuickAction(
            icon: Icons.lightbulb_outline,
            title: 'Gợi ý câu trả lời',
            subtitle: 'Nhận gợi ý thông minh',
            color: Colors.orange,
            onTap: () {
              _provideLearningHint();
              widget.onHintRequest?.call();
            },
          ),

          const SizedBox(height: 8),

          _buildQuickAction(
            icon: Icons.volume_up,
            title: 'Đọc câu hỏi',
            subtitle: 'Nghe phát âm rõ ràng',
            color: Colors.blue,
            onTap: _speakCurrentQuestion,
          ),

          const SizedBox(height: 8),

          _buildQuickAction(
            icon: Icons.school,
            title: 'Giải thích chi tiết',
            subtitle: 'Hiểu sâu kiến thức DHV',
            color: Colors.green,
            onTap: () {
              _provideDetailedExplanation();
              widget.onExplanationRequest?.call();
            },
          ),

          const SizedBox(height: 12),

          // Study tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B73FF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Color(0xFF6B73FF),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Mẹo học tập',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B73FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getRandomStudyTip(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAssistant() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      _isAssistantActive = _isExpanded;
    });

    if (_isExpanded) {
      _speakWelcome();
    }
  }

  void _speakWelcome() {
    _tts.quickSpeak(
      'Xin chào! Tôi là trợ lý DHV, sẵn sàng hỗ trợ bạn học tập. Hãy nhấn vào các tính năng để được giúp đỡ.',
    );
  }

  void _speakCurrentQuestion() {
    final lessonTitle = widget.lessonData['title'] ?? 'Bài học DHV';
    _tts.quickSpeak(
      'Bài học hiện tại: $lessonTitle. Hãy đọc kỹ câu hỏi và suy nghĩ trước khi trả lời.',
    );
  }

  void _provideLearningHint() {
    final hints = [
      'Hãy nhớ rằng DHV được thành lập năm 1995 tại TP.HCM',
      'Ba giá trị cốt lõi của DHV là 3R: Responsibility, Respect, Readiness',
      'DHV có 7 khoa đào tạo chính với nhiều ngành học đa dạng',
      'Trường có phòng VR/Metaverse hiện đại phục vụ học tập',
      'Chuẩn đầu ra ngoại ngữ của DHV là bậc 5/6 khung năng lực',
    ];

    final randomHint = hints[DateTime.now().millisecond % hints.length];
    _tts.quickSpeak('Gợi ý: $randomHint');

    // Show hint visually
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(randomHint)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _provideDetailedExplanation() {
    final explanations = [
      'DHV là viết tắt của Đại học Hùng Vương, được đặt tên theo vua Hùng Vương - quốc tổ dân tộc Việt Nam',
      'Khoa Kỹ thuật Công nghệ có các chuyên ngành CNTT hiện đại như AI, IoT và Metaverse',
      'Trường áp dụng mô hình đại học khởi nghiệp, kết hợp lý thuyết và thực hành',
      'DHV có vườn ươm khởi nghiệp hỗ trợ sinh viên phát triển ý tưởng kinh doanh',
      'Học phí tính theo tín chỉ, linh hoạt cho sinh viên lựa chọn môn học',
    ];

    final randomExplanation =
        explanations[DateTime.now().millisecond % explanations.length];
    _tts.quickSpeak('Giải thích: $randomExplanation');

    // Show explanation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.school, color: Color(0xFF6B73FF)),
            const SizedBox(width: 8),
            const Text('Giải thích chi tiết'),
          ],
        ),
        content: Text(randomExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hiểu rồi'),
          ),
        ],
      ),
    );
  }

  String _getRandomStudyTip() {
    final tips = [
      'Đọc kỹ câu hỏi 2-3 lần trước khi chọn đáp án',
      'Loại trừ các đáp án rõ ràng sai trước',
      'Chú ý từ khóa quan trọng trong câu hỏi',
      'Nhớ lại kiến thức đã học về lịch sử DHV',
      'Thực hành thường xuyên để ghi nhớ tốt hơn',
      'Sử dụng phương pháp liên kết để nhớ thông tin',
    ];

    return tips[DateTime.now().millisecond % tips.length];
  }
}

// ===============================================
// SMART HINT SYSTEM - HỆ THỐNG GỢI Ý THÔNG MINH
// ===============================================

class SmartHintProvider {
  static String getHintForQuestion(String question, List<String> options) {
    // AI-like hint generation based on question content
    if (question.contains('thành lập')) {
      return 'Gợi ý: Tìm kiếm thông tin về năm thành lập trường DHV';
    } else if (question.contains('giá trị cốt lõi')) {
      return 'Gợi ý: Nhớ về 3R - ba giá trị cốt lõi của DHV';
    } else if (question.contains('khoa')) {
      return 'Gợi ý: DHV có 7 khoa đào tạo chính';
    } else if (question.contains('địa chỉ')) {
      return 'Gợi ý: Chú ý số nhà trên đường Nguyễn Trãi';
    } else if (question.contains('ngành')) {
      return 'Gợi ý: Liên quan đến mã ngành và chuyên ngành đào tạo';
    }

    return 'Gợi ý: Đọc kỹ câu hỏi và suy nghĩ về kiến thức DHV đã học';
  }

  static String getExplanationForAnswer(String question, String correctAnswer) {
    // Generate detailed explanation based on question type
    if (question.contains('1995')) {
      return 'DHV được thành lập theo Quyết định số 470/TTg ngày 14/08/1995 của Thủ tướng Chính phủ';
    } else if (question.contains('giá trị cốt lõi')) {
      return 'Ba giá trị cốt lõi: Trách nhiệm (Responsibility), Trung nghĩa (Respect), Tự tin (Readiness)';
    } else if (question.contains('736')) {
      return 'Trụ sở chính DHV tại 736 Nguyễn Trãi, Phường 11, Quận 5, TP.HCM';
    }

    return 'Đáp án đúng là: $correctAnswer. Hãy ôn lại kiến thức này để nhớ lâu hơn.';
  }
}
