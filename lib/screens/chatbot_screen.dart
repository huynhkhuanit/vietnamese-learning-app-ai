import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/custom_app_bar.dart';
import '../services/xp_service.dart';
import '../services/ai_chat_service.dart';
import '../models/user_experience.dart';
import '../models/chat_conversation.dart';
import '../config/api_config.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  // Controllers and Services
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final XPService _xpService = XPService();
  final AIChatService _aiService = AIChatService();
  final SpeechToText _speechToText = SpeechToText();

  // State variables
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isTyping = false;
  bool _speechEnabled = false;
  String _currentScenario = 'general';
  LearningLevel _learningLevel = LearningLevel.beginner;
  int _interactionCount = 0;

  // Animation controllers
  late AnimationController _typingAnimationController;
  late AnimationController _recordingAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeech();
    _addWelcomeMessage();
  }

  void _initializeAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        _speechEnabled = await _speechToText.initialize(
          onError: (error) => print('Speech error: $error'),
          onStatus: (status) => print('Speech status: $status'),
        );
      }
    } catch (e) {
      print('Speech initialization error: $e');
    }
    if (mounted) setState(() {});
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: _getWelcomeMessage(),
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.system,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });

    _scrollToBottom();
  }

  String _getWelcomeMessage() {
    return '''Xin chào! Tôi là AI Assistant thông minh với khả năng tri thức rộng lớn như ChatGPT và Gemini!

Khả năng của tôi:
• Trả lời mọi câu hỏi từ đơn giản đến phức tạp
• Hiểu biết sâu về khoa học, công nghệ, lịch sử, văn hóa, nghệ thuật
• Giải quyết vấn đề, phân tích và suy luận logic
• Dạy tiếng Việt: ngữ pháp, từ vựng, phát âm chuyên nghiệp
• Tư vấn học tập, công việc và cuộc sống

Đặc biệt:
• Ghi nhớ hoàn hảo toàn bộ cuộc trò chuyện
• Hiểu ngữ cảnh và liên kết thông tin thông minh
• Trò chuyện tự nhiên như con người
• Hỗ trợ giọng nói (nhấn mic để nói)

Được phát triển bởi: Huỳnh Văn Khuân - CT06PM, ĐH Hùng Vương TP.HCM

Hãy hỏi tôi bất cứ điều gì bạn tò mò - từ những câu hỏi đời thường đến các vấn đề phức tạp!''';
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messageController.clear();
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _scrollToBottom();
    _awardXPForChatbotInteraction();

    // Get AI response
    await _getAIResponse(text.trim());
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      // Debug: Check API configuration
      print('[Chatbot] Checking API configuration...');
      print('[Chatbot] Current provider: ${_aiService.currentProvider}');
      print('[Chatbot] Is configured: ${_aiService.isConfigured}');

      // Check if API is configured
      if (!_aiService.isConfigured) {
        print('[Chatbot] API not configured, showing setup message');
        _addSystemMessage(
          'Cấu hình cần thiết\n\n'
          'Để sử dụng AI chatbot, bạn cần:\n'
          '1. Lấy API key từ OpenAI hoặc Google Gemini\n'
          '2. Cập nhật trong file lib/config/api_config.dart\n'
          '3. Thay thế YOUR_API_KEY_HERE bằng key thực\n\n'
          'Hiện tại tôi sẽ dùng phản hồi mẫu để demo.',
        );
        await Future.delayed(const Duration(seconds: 1));
        _addFallbackResponse(userMessage);
        return;
      }

      print('[Chatbot] API configured, generating response...');

      // Get conversation context
      final context = _getConversationContext();

      // Debug: Log context để kiểm tra
      if (context.isNotEmpty) {
        print('[Chatbot] Conversation Context:');
        print('[Chatbot] $context');
        print('[Chatbot] Context length: ${context.length} characters');
      }

      // Generate AI response
      final response = await _aiService.generateVietnamLearningResponse(
        userMessage: userMessage,
        conversationContext: context,
        learningLevel: _learningLevel.name,
        scenario: _currentScenario,
      );

      // Parse response for corrections and suggestions
      print(
          '[Chatbot] AI Response received: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');
      await _processAIResponse(response);
    } catch (e) {
      print('[Chatbot] Error getting AI response: $e');
      if (e.toString().contains('ApiException') ||
          e.toString().contains('DioException')) {
        _addSystemMessage('Lỗi kết nối API\n\n'
            'Có thể do:\n'
            '• API key không hợp lệ\n'
            '• Hết quota API\n'
            '• Mạng internet không ổn định\n\n'
            'Hãy kiểm tra lại cấu hình API.');
      } else {
        _addSystemMessage('Lỗi hệ thống\n\n'
            'Chi tiết: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e.toString()}\n\n'
            'Hãy thử lại sau ít phút.');
      }
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  String _getConversationContext() {
    // Get last 7 messages for excellent context (tăng lên 7 để AI hiểu sâu hơn)
    final filteredMessages = _messages
        .where((m) => !m.isSystemMessage && m.type != MessageType.system)
        .toList();

    final recentMessages = filteredMessages.length > 7
        ? filteredMessages.sublist(filteredMessages.length - 7)
        : filteredMessages;

    // Format conversation với chi tiết để AI hiểu rõ ngữ cảnh
    return recentMessages.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final message = entry.value;
      final role = message.isUser ? "User" : "Assistant";
      return '[$index] $role: ${message.text}';
    }).join('\n');
  }

  Future<void> _processAIResponse(String response) async {
    // Check if response contains corrections or suggestions
    if (response.contains('→') || response.contains('sửa')) {
      // Try to extract correction
      await _handleCorrectionResponse(response);
    } else {
      // Regular response
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
      });
    }

    _scrollToBottom();
  }

  Future<void> _handleCorrectionResponse(String response) async {
    // Simple parsing for demo - in real app, this would be more sophisticated
    final lines = response.split('\n');
    String mainResponse = response;
    String? correction;
    String? originalText;

    // Look for correction patterns
    for (final line in lines) {
      if (line.contains('→') || line.contains('sửa')) {
        final parts = line.split('→');
        if (parts.length == 2) {
          originalText = parts[0].trim();
          correction = parts[1].trim();
          mainResponse = response.replaceAll(line, '').trim();
          break;
        }
      }
    }

    final aiMessage = ChatMessage(
      text: mainResponse,
      isUser: false,
      timestamp: DateTime.now(),
      correction: correction,
      originalText: originalText,
      type: correction != null ? MessageType.correction : MessageType.text,
    );

    setState(() {
      _messages.add(aiMessage);
    });

    // Award extra XP for corrections
    if (correction != null) {
      await _xpService.awardXP(XPActivityType.quizGood);
    }
  }

  void _addFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    String response;

    // Intelligent fallback responses
    if (lowerMessage.contains('xin chào') || lowerMessage.contains('chào')) {
      response =
          'Xin chào! Tôi là AI chatbot DHV. Bạn muốn nói chuyện về chủ đề gì?';
    } else if (lowerMessage.contains('tên') || lowerMessage.contains('ai')) {
      response =
          'Tôi là AI chatbot thông minh. Tôi có thể trò chuyện về mọi chủ đề với bạn!';
    } else if (lowerMessage.contains('làm gì') ||
        lowerMessage.contains('chức năng')) {
      response =
          'Tôi có thể trò chuyện về bất cứ gì: khoa học, văn hóa, cuộc sống, học tiếng Việt... Bạn muốn nói về gì?';
    } else if (lowerMessage.contains('ứng dụng') ||
        lowerMessage.contains('app')) {
      response =
          'Đây là ứng dụng học tiếng Việt DHV với chatbot AI, bài học tương tác và nhiều tính năng thú vị!';
    } else if (lowerMessage.contains('cảm ơn')) {
      response = 'Rất vui được giúp bạn! Còn điều gì khác bạn muốn biết không?';
    } else if (lowerMessage.contains('hỏi') ||
        lowerMessage.contains('câu hỏi')) {
      response =
          'Tôi sẵn sàng trả lời mọi câu hỏi của bạn. Hãy hỏi bất cứ điều gì bạn tò mò!';
    } else {
      // Default responses for unknown topics
      final defaultResponses = [
        'Thú vị! Bạn có thể kể thêm về điều đó không?',
        'Tôi hiểu rồi. Bạn muốn nói gì thêm về chủ đề này?',
        'Đó là một chủ đề hay! Bạn có câu hỏi cụ thể nào không?',
        'Cảm ơn bạn đã chia sẻ. Còn gì khác bạn muốn thảo luận?',
      ];
      final random = DateTime.now().millisecond % defaultResponses.length;
      response = defaultResponses[random];
    }

    final aiMessage = ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMessage);
      _isTyping = false;
    });
  }

  void _addSystemMessage(String message) {
    final systemMessage = ChatMessage(
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
      isSystemMessage: true,
      type: MessageType.system,
    );

    setState(() {
      _messages.add(systemMessage);
      _isTyping = false;
    });

    _scrollToBottom();
  }

  Future<void> _awardXPForChatbotInteraction() async {
    _interactionCount++;
    if (_interactionCount % 3 == 0) {
      try {
        final awardedXP =
            await _xpService.awardXP(XPActivityType.chatbotInteraction);

        if (awardedXP > 0 && mounted) {
          _showXPSnackBar(awardedXP);
        }
      } catch (e) {
        print('Error awarding XP: $e');
      }
    }
  }

  void _showXPSnackBar(int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text('+$xp XP • Trò chuyện với AI!',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Speech to text methods
  Future<void> _startListening() async {
    if (!_speechEnabled) return;

    setState(() {
      _isRecording = true;
    });

    HapticFeedback.lightImpact();

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      },
      localeId: 'vi-VN', // Vietnamese locale
    );
  }

  Future<void> _stopListening() async {
    setState(() {
      _isRecording = false;
    });

    await _speechToText.stop();
    HapticFeedback.lightImpact();

    // Auto-send if we have text
    if (_messageController.text.isNotEmpty) {
      _handleSubmitted(_messageController.text);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _recordingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF58CC02);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: CustomAppBar(
        title: 'AI Assistant DHV',
        actions: [
          // Scenario selector
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.translate, color: Colors.white),
            ),
            onSelected: _changeScenario,
            itemBuilder: (context) => ConversationScenario.scenarios
                .map((scenario) => PopupMenuItem<String>(
                      value: scenario.id,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(scenario.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(scenario.description,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          if (_currentScenario == scenario.id)
                            Icon(Icons.check, color: primaryColor, size: 20),
                        ],
                      ),
                    ))
                .toList(),
          ),
          // Learning level selector
          PopupMenuButton<LearningLevel>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white),
            ),
            onSelected: (level) => setState(() => _learningLevel = level),
            itemBuilder: (context) => LearningLevel.values
                .map((level) => PopupMenuItem<LearningLevel>(
                      value: level,
                      child: Row(
                        children: [
                          Text(level.displayName),
                          if (_learningLevel == level) const Spacer(),
                          if (_learningLevel == level)
                            Icon(Icons.check, color: primaryColor, size: 20),
                        ],
                      ),
                    ))
                .toList(),
          ),
          // Debug API config button
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.white),
            onPressed: _debugAPIConfig,
            tooltip: 'Debug API Config',
          ),
        ],
      ),
      body: Column(
        children: [
          // Current scenario display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ConversationScenario.getById(_currentScenario)?.name ??
                            'Giao tiếp cơ bản',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Trình độ: ${_learningLevel.displayName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Trực tuyến',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index], isDarkMode);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice input button
                GestureDetector(
                  onTapDown: (_) => _startListening(),
                  onTapUp: (_) => _stopListening(),
                  onTapCancel: _stopListening,
                  child: AnimatedBuilder(
                    animation: _recordingAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red.withOpacity(0.8 +
                                  0.2 * _recordingAnimationController.value)
                              : (_speechEnabled ? primaryColor : Colors.grey),
                          shape: BoxShape.circle,
                          boxShadow: _isRecording
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 10 *
                                        _recordingAnimationController.value,
                                    spreadRadius:
                                        5 * _recordingAnimationController.value,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Hỏi tôi bất cứ điều gì...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Send button
                GestureDetector(
                  onTap: () => _handleSubmitted(_messageController.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF58CC02),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final animationValue =
                        (_typingAnimationController.value - index * 0.2)
                            .clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[600]
                            ?.withOpacity(0.5 + 0.5 * animationValue),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDarkMode) {
    final isUser = message.isUser;
    final primaryColor = const Color(0xFF58CC02);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: message.isSystemMessage ? Colors.blue : primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.isSystemMessage ? Icons.info : Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getMessageBackgroundColor(message, isDarkMode),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Correction display
                  if (message.hasCorrection) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_fix_high,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Gợi ý sửa lỗi:',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: message.originalText,
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.red,
                                  ),
                                ),
                                const TextSpan(text: ' → '),
                                TextSpan(
                                  text: message.correction,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF58CC02),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Main message text
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getMessageTextColor(message, isDarkMode),
                      height: 1.4,
                    ),
                  ),

                  // Timestamp
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User avatar
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF1CB0F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Color _getMessageBackgroundColor(ChatMessage message, bool isDarkMode) {
    if (message.isUser) {
      return const Color(0xFF1CB0F6);
    } else if (message.isSystemMessage) {
      return isDarkMode ? Colors.grey[700]! : Colors.blue[50]!;
    } else {
      return isDarkMode ? Colors.grey[800]! : Colors.white;
    }
  }

  Color _getMessageTextColor(ChatMessage message, bool isDarkMode) {
    if (message.isUser) {
      return Colors.white;
    } else {
      return isDarkMode ? Colors.white : Colors.black87;
    }
  }

  void _changeScenario(String scenarioId) {
    setState(() {
      _currentScenario = scenarioId;
    });

    final scenario = ConversationScenario.getById(scenarioId);
    if (scenario != null) {
      _addSystemMessage(
        'Đã chuyển sang: ${scenario.name}\n\n'
        '${scenario.description}\n\n'
        'Câu hỏi gợi ý:\n'
        '${scenario.sampleQuestions.map((q) => '• $q').join('\n')}\n\n'
        'Hãy thử trò chuyện về chủ đề này nhé!',
      );
    }
  }

  void _debugAPIConfig() {
    final apiInfo = '''Debug API Configuration

Current Provider: ${_aiService.currentProvider.name}
Is Configured: ${_aiService.isConfigured}

OpenAI Status:
• Configured: ${APIConfig.isOpenAIConfigured}
• Key Length: ${APIConfig.openaiApiKey.length} chars
• Starts with sk-: ${APIConfig.openaiApiKey.startsWith('sk-')}

Gemini Status:
• Configured: ${APIConfig.isGeminiConfigured}  
• Key Length: ${APIConfig.geminiApiKey.length} chars

Available Providers: ${APIConfig.availableProviders.join(', ')}

Kiểm tra console logs để xem chi tiết hơn.''';

    _addSystemMessage(apiInfo);

    // Also print to console
    print('[Debug] =========================');
    print('[Debug] API Configuration Check');
    print('[Debug] =========================');
    print('[Debug] Current Provider: ${_aiService.currentProvider}');
    print('[Debug] Is Configured: ${_aiService.isConfigured}');
    print('[Debug] OpenAI Key: ${APIConfig.openaiApiKey.substring(0, 20)}...');
    print('[Debug] Gemini Key: ${APIConfig.geminiApiKey.substring(0, 20)}...');
    print('[Debug] OpenAI Configured: ${APIConfig.isOpenAIConfigured}');
    print('[Debug] Gemini Configured: ${APIConfig.isGeminiConfigured}');
    print('[Debug] =========================');

    // Test API call
    _testAPICall();
  }

  Future<void> _testAPICall() async {
    try {
      _addSystemMessage(
          'Testing API Call...\n\nĐang thử gọi API để kiểm tra kết nối...');

      final response = await _aiService.generateVietnamLearningResponse(
        userMessage: 'Xin chào, đây là test message',
        conversationContext: '',
        learningLevel: 'beginner',
        scenario: 'general',
      );

      _addSystemMessage(
          'API Test Thành công!\n\nResponse: ${response.substring(0, response.length > 200 ? 200 : response.length)}${response.length > 200 ? '...' : ''}');
    } catch (e) {
      _addSystemMessage('API Test Thất bại!\n\nError: ${e.toString()}');
      print('[Debug] API Test failed: $e');
    }
  }
}
