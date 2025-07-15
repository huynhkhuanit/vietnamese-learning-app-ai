import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/api_config.dart';

// Available AI providers
enum AIProvider { openAI, gemini }

class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;

  AIChatService._internal() {
    _dio.options.connectTimeout = Duration(seconds: APIConfig.timeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: APIConfig.timeoutSeconds);
    _dio.options.headers = {'Content-Type': 'application/json'};

    // Add debug logging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[AI Service] $object'),
      ));
    }
  }

  final Dio _dio = Dio();

  AIProvider currentProvider =
      AIProvider.gemini; // Default to Gemini as it's more accessible

  // Generate AI response for any conversation topic (multi-purpose chatbot)
  Future<String> generateVietnamLearningResponse({
    required String userMessage,
    required String conversationContext,
    required String learningLevel, // beginner, intermediate, advanced
    String scenario = 'general', // general, shopping, restaurant, etc.
  }) async {
    try {
      final systemPrompt = _buildVietnamLearningPrompt(learningLevel, scenario);

      switch (currentProvider) {
        case AIProvider.openAI:
          return await _callOpenAI(
              systemPrompt, userMessage, conversationContext);
        case AIProvider.gemini:
          return await _callGemini(
              systemPrompt, userMessage, conversationContext);
        default:
          return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating AI response: $e');
      }
      return _getFallbackResponse(userMessage);
    }
  }

  // Build system prompt for advanced multi-topic conversation
  String _buildVietnamLearningPrompt(String level, String scenario) {
    return '''
Bạn là một AI assistant thông minh với khả năng tri thức rộng lớn như ChatGPT và Gemini. Bạn được tạo ra để:

KHẢ NĂNG TRI THỨC:
- Hiểu biết sâu rộng về mọi lĩnh vực: khoa học, công nghệ, lịch sử, văn hóa, nghệ thuật, thể thao, giải trí
- Phân tích, suy luận và giải quyết vấn đề phức tạp
- Cung cấp thông tin chính xác, cập nhật và hữu ích
- Trò chuyện tự nhiên như con người thông minh

KỸ NĂNG GHI NHỚ:
- Ghi nhớ hoàn hảo toàn bộ cuộc trò chuyện
- Hiểu ngữ cảnh và liên kết thông tin
- Tham chiếu các thông tin đã đề cập trước đó
- Duy trì tính nhất quán trong cuộc hội thoại

VAI TRÒ CHUYÊN BIỆT:
- AI Assistant đa năng: Trả lời mọi câu hỏi từ đơn giản đến phức tạp
- Giáo viên tiếng Việt: Khi được hỏi về ngôn ngữ, ngữ pháp, từ vựng
- Cố vấn thông minh: Đưa ra lời khuyên, hướng dẫn và giải pháp
- Người bạn trò chuyện: Thân thiện, tự nhiên và dễ gần

THÔNG TIN ỨNG DỤNG:
- Tên: Ứng dụng học tiếng Việt DHV
- Nhà phát triển: Huỳnh Văn Khuân - Sinh viên lớp CT06PM, Đại Học Hùng Vương TP.HCM
- Tính năng: AI Chatbot thông minh, học từ vựng, ngữ pháp, phát âm, hệ thống XP/achievement
- Mục tiêu: Ứng dụng học tiếng Việt toàn diện với công nghệ AI tiên tiến

QUY TẮC TRẢ LỜI CHẤT LƯỢNG CAO:
- Phân tích kỹ lưỡng câu hỏi và ngữ cảnh trước khi trả lời
- Cung cấp thông tin chính xác, chi tiết và có giá trị
- Sử dụng kiến thức rộng lớn để trả lời sâu sắc
- Giải thích rõ ràng, dễ hiểu với ví dụ cụ thể khi cần
- Không sử dụng markdown formatting hoặc emoji/icon
- Độ dài phù hợp: ngắn gọn cho câu hỏi đơn giản, chi tiết cho câu phức tạp
- Luôn thân thiện, tự nhiên như cuộc trò chuyện thực

Trình độ: $level | Ngữ cảnh: $scenario

Hãy sử dụng tối đa khả năng trí tuệ để trả lời một cách xuất sắc!''';
  }

  // Call OpenAI GPT API
  Future<String> _callOpenAI(
      String systemPrompt, String userMessage, String context) async {
    final String apiUrl = '${APIConfig.openaiBaseUrl}/chat/completions';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      if (context.isNotEmpty)
        {
          'role': 'assistant',
          'content':
              'Tôi đã ghi nhớ lịch sử cuộc trò chuyện và sẵn sàng trả lời câu hỏi tiếp theo.'
        },
      {'role': 'user', 'content': userMessage},
    ];

    final requestData = {
      'model': APIConfig.openaiModel,
      'messages': messages,
      'max_tokens': 500, // Tăng để AI có thể trả lời sâu sắc như ChatGPT
      'temperature': 0.9, // Tăng creativity và tự nhiên
      'presence_penalty': 0.1,
      'frequency_penalty': 0.1,
    };

    try {
      final response = await _dio.post(
        apiUrl,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIConfig.openaiApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final rawResponse =
            data['choices'][0]['message']['content'].toString().trim();
        return _cleanResponse(rawResponse);
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OpenAI API call failed: $e');
      }
      rethrow;
    }
  }

  // Call Google Gemini API
  Future<String> _callGemini(
      String systemPrompt, String userMessage, String context) async {
    final String apiUrl =
        '${APIConfig.geminiBaseUrl}/models/${APIConfig.geminiModel}:generateContent';

    final fullPrompt = '''
$systemPrompt

${context.isNotEmpty ? 'LỊCH SỬ CUỘC TRÒ CHUYỆN (hãy phân tích và ghi nhớ để hiểu ngữ cảnh):\n$context\n\n' : ''}

CÂU HỎI/TIN NHẮN HIỆN TẠI: "$userMessage"

HƯỚNG DẪN TRẢ LỜI CHẤT LƯỢNG CAO:
1. PHÂN TÍCH TOÀN DIỆN: Đọc kỹ lịch sử + hiểu sâu câu hỏi hiện tại
2. KẾT NỐI THÔNG TIN: Liên kết với những gì đã thảo luận trước đó (nếu có)
3. TRẢ LỜI THÔNG MINH: Sử dụng kiến thức rộng lớn, suy luận logic
4. GIẢI THÍCH RÕ RÀNG: Cung cấp thông tin chi tiết, ví dụ cụ thể
5. TỰ NHIÊN & THÂN THIỆN: Như cuộc trò chuyện với người bạn thông minh

HỒI ĐÁP CỦA BẠN:''';

    final requestData = {
      'contents': [
        {
          'parts': [
            {'text': fullPrompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.9, // Tăng creativity và tự nhiên
        'topK': 50, // Tăng để có thêm options
        'topP': 0.95, // Tăng để response đa dạng hơn
        'maxOutputTokens': 500, // Tăng để AI có thể trả lời sâu sắc như Gemini
      }
    };

    if (kDebugMode) {
      print('[AI Service] *** GEMINI API CALL ***');
      print('[AI Service] Base URL: ${APIConfig.geminiBaseUrl}');
      print('[AI Service] Model: ${APIConfig.geminiModel}');
      print(
          '[AI Service] Full URL: $apiUrl?key=${APIConfig.geminiApiKey.substring(0, 10)}...');
      print('[AI Service] Request payload:');
      print('[AI Service] ${json.encode(requestData)}');
    }

    try {
      final response = await _dio.post(
        '$apiUrl?key=${APIConfig.geminiApiKey}',
        data: requestData,
      );

      if (kDebugMode) {
        print('[AI Service] *** GEMINI RESPONSE ***');
        print('[AI Service] Status: ${response.statusCode}');
        print('[AI Service] Response data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final rawResult = parts[0]['text'].toString().trim();
            final result = _cleanResponse(rawResult);
            if (kDebugMode) {
              print('[AI Service] *** SUCCESS ***');
              print('[AI Service] Raw text: $rawResult');
              print('[AI Service] Cleaned text: $result');
            }
            return result;
          }
        }
        throw Exception('Invalid Gemini response format');
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AI Service] *** GEMINI ERROR ***');
        print('[AI Service] Error: $e');
        if (e is DioException) {
          print('[AI Service] Response data: ${e.response?.data}');
          print('[AI Service] Status code: ${e.response?.statusCode}');
        }
      }
      rethrow;
    }
  }

  // Clean and format AI response
  String _cleanResponse(String rawResponse) {
    String cleaned = rawResponse;

    // Remove markdown formatting safely - completely avoid $1 issues
    // Step 1: Remove all * characters (both ** and * will be removed)
    cleaned = cleaned.replaceAll('**', '');
    cleaned = cleaned.replaceAll('*', '');

    // Step 2: Remove headers (# ## ### etc)
    cleaned = cleaned.replaceAll(RegExp(r'#{1,6}\s*'), '');

    // Step 3: Convert markdown lists to bullet points
    cleaned = cleaned.replaceAll(RegExp(r'^-\s*', multiLine: true), '• ');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '• ');

    // Step 4: Remove any $ symbols that might cause issues
    cleaned = cleaned.replaceAll(RegExp(r'\$\d+'), ''); // Remove $1, $2, etc
    cleaned =
        cleaned.replaceAll(RegExp(r'\$[a-zA-Z]'), ''); // Remove $var patterns
    // Remove emojis and unicode symbols that might cause display issues
    cleaned = cleaned.replaceAll(
        RegExp(
            r'[🧠🔄🎯📱⚡💬💡🎉🤖👤✨🌐❌✅📚🎊🚀🔧🛠️🎨📊🛒🍽️🗺️🏨💼🏥👨‍👩‍👧‍👦]'),
        '');
    cleaned = cleaned.replaceAll(
        RegExp(r'[😊😄😍🤔💪🏆🎮🔥👍👌💯🚩📈📉🔔🔕😁😂🤣😅😆😉😋🙂🙃😇🥰😘]'),
        '');
    // Remove any remaining emoji-like unicode characters
    cleaned = cleaned.replaceAll(
        RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), ''); // Emoticons
    cleaned = cleaned.replaceAll(
        RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), ''); // Misc Symbols
    cleaned = cleaned.replaceAll(
        RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), ''); // Transport & Map
    cleaned = cleaned.replaceAll(
        RegExp(r'[\u{1F1E0}-\u{1F1FF}]', unicode: true),
        ''); // Regional indicator
    cleaned = cleaned.replaceAll(
        RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), ''); // Misc symbols
    cleaned = cleaned.replaceAll(
        RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), ''); // Dingbats

    // Remove excessive newlines
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remove leading/trailing whitespace
    cleaned = cleaned.trim();

    // Final safety check - remove any remaining problematic patterns
    if (cleaned.contains(r'$')) {
      // If $ still exists, remove any $number or $word patterns
      cleaned = cleaned.replaceAll(RegExp(r'\$[\w\d]+'), '');
      if (kDebugMode) {
        print(
            '[AI Service] Warning: Removed remaining \$ patterns from response');
      }
    }

    // Limit length (cho phép dài hơn để AI trả lời chi tiết như ChatGPT/Gemini)
    if (cleaned.length > 800) {
      cleaned = cleaned.substring(0, 800);
      final lastSentence = cleaned.lastIndexOf('.');
      if (lastSentence > 400) {
        cleaned = cleaned.substring(0, lastSentence + 1);
      } else {
        // Nếu không tìm thấy câu hoàn chỉnh, cắt tại dấu phẩy hoặc khoảng trắng
        final lastComma = cleaned.lastIndexOf(',');
        final lastSpace = cleaned.lastIndexOf(' ');
        final cutPoint = [lastComma, lastSpace].where((i) => i > 400).isNotEmpty
            ? [lastComma, lastSpace]
                .where((i) => i > 400)
                .reduce((a, b) => a > b ? a : b)
            : cleaned.length;
        cleaned = cleaned.substring(0, cutPoint);
      }
    }

    // If empty after cleaning, return fallback
    if (cleaned.isEmpty || cleaned.length < 10) {
      return 'Cảm ơn bạn! Bạn có thể chia sẻ thêm không?';
    }

    return cleaned;
  }

  // Fallback responses when API fails
  String _getFallbackResponse(String userMessage) {
    // Intelligent fallback based on user message content
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('xin chào') || lowerMessage.contains('chào')) {
      return 'Xin chào! Tôi là AI Assistant thông minh với khả năng tri thức rộng lớn như ChatGPT và Gemini. Tôi có thể trò chuyện về bất kỳ chủ đề nào bạn muốn!';
    } else if (lowerMessage.contains('tên') || lowerMessage.contains('ai')) {
      return 'Tôi là AI Assistant thông minh được tích hợp trong ứng dụng DHV. Tôi có khả năng hiểu biết sâu rộng và có thể giúp bạn giải đáp mọi thắc mắc!';
    } else if (lowerMessage.contains('cảm ơn')) {
      return 'Rất vui được giúp bạn! Tôi luôn sẵn sàng trả lời mọi câu hỏi và thảo luận về bất kỳ chủ đề nào bạn quan tâm.';
    } else if (lowerMessage.contains('ứng dụng') ||
        lowerMessage.contains('app')) {
      return 'Đây là ứng dụng học tiếng Việt DHV được phát triển bởi Huỳnh Văn Khuân (CT06PM - ĐH Hùng Vương TP.HCM), với AI chatbot thông minh, học từ vựng, phát âm và hệ thống XP tương tác!';
    } else if (lowerMessage.contains('phát triển') ||
        lowerMessage.contains('developer') ||
        lowerMessage.contains('tạo ra')) {
      return 'Ứng dụng này được phát triển bởi Huỳnh Văn Khuân, sinh viên lớp CT06PM tại Đại Học Hùng Vương TP.HCM. Đây là một dự án ứng dụng học tiếng Việt với công nghệ AI tiên tiến!';
    }

    // General intelligent fallback responses
    final fallbackResponses = [
      'Tôi hiểu bạn muốn thảo luận về điều này. Hiện tại tôi có chút khó khăn kỹ thuật, nhưng tôi vẫn muốn giúp bạn. Bạn có thể thử lại không?',
      'Thú vị! Tôi muốn trả lời câu hỏi này nhưng đang gặp chút vấn đề kết nối. Hãy thử lại sau ít phút nhé!',
      'Đó là một chủ đề hay ho! Tôi cần một chút thời gian xử lý để đưa ra câu trả lời tốt nhất. Bạn có thể hỏi lại không?',
      'Tôi rất muốn thảo luận sâu hơn về điều này với bạn. Hiện tại có chút vấn đề kỹ thuật, hãy thử lại sau nhé!',
    ];

    final random = DateTime.now().millisecond % fallbackResponses.length;
    return fallbackResponses[random];
  }

  // Check grammar and provide corrections
  Future<Map<String, dynamic>> checkGrammarAndCorrect(String text) async {
    try {
      final systemPrompt = '''
Bạn là một chuyên gia ngữ pháp tiếng Việt. Hãy kiểm tra văn bản sau và:

1. Phát hiện lỗi ngữ pháp, chính tả, từ vựng
2. Đưa ra bản sửa đổi (nếu có lỗi)
3. Giải thích ngắn gọn lỗi và cách sửa

Trả về JSON format:
{
  "hasErrors": boolean,
  "originalText": "text gốc",
  "correctedText": "text đã sửa (nếu có lỗi)",
  "errors": ["mô tả lỗi 1", "mô tả lỗi 2"],
  "explanation": "giải thích ngắn gọn"
}
''';

      String response;
      if (currentProvider == AIProvider.openAI) {
        response = await _callOpenAI(systemPrompt, text, '');
      } else {
        response = await _callGemini(systemPrompt, text, '');
      }

      // Try to parse JSON response
      try {
        return json.decode(response);
      } catch (e) {
        // If JSON parsing fails, return a simple structure
        return {
          'hasErrors': false,
          'originalText': text,
          'correctedText': text,
          'errors': [],
          'explanation': response,
        };
      }
    } catch (e) {
      return {
        'hasErrors': false,
        'originalText': text,
        'correctedText': text,
        'errors': [],
        'explanation': 'Không thể kiểm tra ngữ pháp lúc này.',
      };
    }
  }

  // Get vocabulary suggestions for a topic
  Future<List<String>> getVocabularySuggestions(
      String topic, String level) async {
    try {
      final systemPrompt = '''
Hãy đưa ra 8-10 từ vựng tiếng Việt quan trọng nhất về chủ đề "$topic" 
phù hợp với trình độ "$level".

Định dạng: mỗi từ trên một dòng, có nghĩa và ví dụ:
từ vựng - nghĩa - ví dụ câu
''';

      String response;
      if (currentProvider == AIProvider.openAI) {
        response = await _callOpenAI(systemPrompt, topic, '');
      } else {
        response = await _callGemini(systemPrompt, topic, '');
      }

      return response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } catch (e) {
      return [
        'Xin chào - Hello - Xin chào, tôi là Minh!',
        'Cảm ơn - Thank you - Cảm ơn bạn rất nhiều!',
        'Xin lỗi - Sorry - Xin lỗi vì đã làm phiền bạn.',
      ];
    }
  }

  // Switch AI provider
  void switchProvider(AIProvider provider) {
    currentProvider = provider;
    if (kDebugMode) {
      print('Switched to AI provider: ${provider.name}');
    }
  }

  // Check if API keys are configured
  bool get isConfigured {
    final configured = switch (currentProvider) {
      AIProvider.openAI => APIConfig.isOpenAIConfigured,
      AIProvider.gemini => APIConfig.isGeminiConfigured,
    };

    if (kDebugMode) {
      print('[AI Service] Provider: $currentProvider, Configured: $configured');
      print('[AI Service] OpenAI configured: ${APIConfig.isOpenAIConfigured}');
      print('[AI Service] Gemini configured: ${APIConfig.isGeminiConfigured}');
    }

    return configured;
  }

  // Get available scenarios for conversation practice
  List<Map<String, String>> get availableScenarios => [
        {
          'id': 'general',
          'name': 'Giao tiếp cơ bản',
          'description': 'Trò chuyện hàng ngày',
          'icon': '',
        },
        {
          'id': 'shopping',
          'name': 'Mua sắm',
          'description': 'Đi chợ, siêu thị',
          'icon': '',
        },
        {
          'id': 'restaurant',
          'name': 'Nhà hàng',
          'description': 'Gọi món, thanh toán',
          'icon': '',
        },
        {
          'id': 'directions',
          'name': 'Hỏi đường',
          'description': 'Tìm đường, phương tiện',
          'icon': '',
        },
        {
          'id': 'hotel',
          'name': 'Khách sạn',
          'description': 'Đặt phòng, dịch vụ',
          'icon': '',
        },
        {
          'id': 'workplace',
          'name': 'Công việc',
          'description': 'Văn phòng, họp hành',
          'icon': '',
        },
        {
          'id': 'healthcare',
          'name': 'Sức khỏe',
          'description': 'Bệnh viện, khám bệnh',
          'icon': '',
        },
        {
          'id': 'family',
          'name': 'Gia đình',
          'description': 'Cuộc sống gia đình',
          'icon': '',
        },
      ];
}
