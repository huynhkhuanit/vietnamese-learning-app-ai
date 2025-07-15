import 'package:cloud_firestore/cloud_firestore.dart';

// Enhanced Chat Message model for AI conversations
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSystemMessage;
  final String? correction;
  final String? originalText;
  final String? explanation;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystemMessage = false,
    this.correction,
    this.originalText,
    this.explanation,
    this.type = MessageType.text,
    this.metadata,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Copy with method for updates
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isSystemMessage,
    String? correction,
    String? originalText,
    String? explanation,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      correction: correction ?? this.correction,
      originalText: originalText ?? this.originalText,
      explanation: explanation ?? this.explanation,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSystemMessage': isSystemMessage,
      'correction': correction,
      'originalText': originalText,
      'explanation': explanation,
      'type': type.name,
      'metadata': metadata,
    };
  }

  // Create from Firestore
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSystemMessage: map['isSystemMessage'] ?? false,
      correction: map['correction'],
      originalText: map['originalText'],
      explanation: map['explanation'],
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      metadata: map['metadata'],
    );
  }

  // Check if message has corrections
  bool get hasCorrection => correction != null && originalText != null;

  // Check if message has explanation
  bool get hasExplanation => explanation != null && explanation!.isNotEmpty;
}

// Types of messages
enum MessageType {
  text,
  correction,
  vocabulary,
  grammar,
  suggestion,
  achievement,
  system,
}

// Learning levels
enum LearningLevel {
  beginner('Người mới bắt đầu'),
  intermediate('Trung cấp'),
  advanced('Nâng cao');

  const LearningLevel(this.displayName);
  final String displayName;
}

// Conversation scenarios
class ConversationScenario {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> sampleQuestions;
  final List<String> vocabulary;

  const ConversationScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.sampleQuestions,
    required this.vocabulary,
  });

  // Predefined scenarios
  static const List<ConversationScenario> scenarios = [
    ConversationScenario(
      id: 'general',
      name: 'Giao tiếp cơ bản',
      description: 'Trò chuyện hàng ngày',
      icon: '',
      sampleQuestions: [
        'Bạn tên gì?',
        'Hôm nay thế nào?',
        'Bạn thích làm gì?',
        'Cuối tuần bạn có kế hoạch gì không?',
      ],
      vocabulary: ['xin chào', 'cảm ơn', 'tạm biệt', 'làm ơn', 'xin lỗi'],
    ),
    ConversationScenario(
      id: 'shopping',
      name: 'Mua sắm',
      description: 'Đi chợ, siêu thị',
      icon: '',
      sampleQuestions: [
        'Cái này bao nhiều tiền?',
        'Có size khác không?',
        'Tôi có thể thử được không?',
        'Có giảm giá không?',
      ],
      vocabulary: ['tiền', 'mua', 'bán', 'đắt', 'rẻ', 'size', 'màu sắc'],
    ),
    ConversationScenario(
      id: 'restaurant',
      name: 'Nhà hàng',
      description: 'Gọi món, thanh toán',
      icon: '',
      sampleQuestions: [
        'Menu có gì ngon?',
        'Tôi muốn gọi món này',
        'Có thể ít cay không?',
        'Tính tiền giúp tôi',
      ],
      vocabulary: ['thức ăn', 'uống', 'ngon', 'cay', 'ngọt', 'mặn', 'tươi'],
    ),
    ConversationScenario(
      id: 'directions',
      name: 'Hỏi đường',
      description: 'Tìm đường, phương tiện',
      icon: '',
      sampleQuestions: [
        'Đi đâu thế này?',
        'Bưu điện ở đâu?',
        'Đi bằng xe buýt được không?',
        'Còn bao xa nữa?',
      ],
      vocabulary: ['đường', 'gần', 'xa', 'trái', 'phải', 'thẳng', 'rẽ'],
    ),
    ConversationScenario(
      id: 'hotel',
      name: 'Khách sạn',
      description: 'Đặt phòng, dịch vụ',
      icon: '',
      sampleQuestions: [
        'Tôi muốn đặt phòng',
        'Phòng có wifi không?',
        'Bao giờ check-out?',
        'Có dịch vụ giặt ủi không?',
      ],
      vocabulary: ['phòng', 'giường', 'tắm', 'sạch', 'tiện nghi', 'dịch vụ'],
    ),
  ];

  // Get scenario by ID
  static ConversationScenario? getById(String id) {
    try {
      return scenarios.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
