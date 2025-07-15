
/// Mức độ khó của lesson
enum LessonDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// Loại lesson phát âm
enum LessonType {
  word, // Từ đơn
  phrase, // Cụm từ
  sentence, // Câu
  paragraph, // Đoạn văn
  conversation, // Hội thoại
}

/// Mô hình lesson phát âm
class PronunciationLesson {
  final String id;
  final String title;
  final String description;
  final LessonDifficulty difficulty;
  final LessonType type;
  final List<PronunciationExercise> exercises;
  final String category;
  final int estimatedDuration; // phút
  final List<String> tags;
  final String? imageUrl;
  final bool isLocked;
  final int requiredScore; // Điểm tối thiểu để mở khóa

  PronunciationLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.type,
    required this.exercises,
    required this.category,
    required this.estimatedDuration,
    this.tags = const [],
    this.imageUrl,
    this.isLocked = false,
    this.requiredScore = 0,
  });

  /// Tạo từ JSON
  factory PronunciationLesson.fromJson(Map<String, dynamic> json) {
    return PronunciationLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: LessonDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => LessonDifficulty.beginner,
      ),
      type: LessonType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonType.word,
      ),
      exercises: (json['exercises'] as List?)
              ?.map((e) => PronunciationExercise.fromJson(e))
              .toList() ??
          [],
      category: json['category'] ?? '',
      estimatedDuration: json['estimatedDuration'] ?? 5,
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      isLocked: json['isLocked'] ?? false,
      requiredScore: json['requiredScore'] ?? 0,
    );
  }

  /// Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty.name,
      'type': type.name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'category': category,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'imageUrl': imageUrl,
      'isLocked': isLocked,
      'requiredScore': requiredScore,
    };
  }

  /// Copy với một số thay đổi
  PronunciationLesson copyWith({
    String? id,
    String? title,
    String? description,
    LessonDifficulty? difficulty,
    LessonType? type,
    List<PronunciationExercise>? exercises,
    String? category,
    int? estimatedDuration,
    List<String>? tags,
    String? imageUrl,
    bool? isLocked,
    int? requiredScore,
  }) {
    return PronunciationLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      exercises: exercises ?? this.exercises,
      category: category ?? this.category,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      isLocked: isLocked ?? this.isLocked,
      requiredScore: requiredScore ?? this.requiredScore,
    );
  }
}

/// Bài tập phát âm
class PronunciationExercise {
  final String id;
  final String text;
  final String? phonetic; // Phiên âm IPA
  final String? audioUrl; // URL âm thanh mẫu
  final String? meaning; // Nghĩa
  final String? exampleSentence; // Câu ví dụ
  final List<String> tips; // Mẹo phát âm
  final Map<String, dynamic>? metadata; // Thông tin thêm

  PronunciationExercise({
    required this.id,
    required this.text,
    this.phonetic,
    this.audioUrl,
    this.meaning,
    this.exampleSentence,
    this.tips = const [],
    this.metadata,
  });

  factory PronunciationExercise.fromJson(Map<String, dynamic> json) {
    return PronunciationExercise(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      phonetic: json['phonetic'],
      audioUrl: json['audioUrl'],
      meaning: json['meaning'],
      exampleSentence: json['exampleSentence'],
      tips: List<String>.from(json['tips'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'phonetic': phonetic,
      'audioUrl': audioUrl,
      'meaning': meaning,
      'exampleSentence': exampleSentence,
      'tips': tips,
      'metadata': metadata,
    };
  }
}

/// Dữ liệu lesson mẫu
class PronunciationLessonsData {
  static List<PronunciationLesson> getSampleLessons() {
    return [
      // Lesson cơ bản - Từ đơn
      PronunciationLesson(
        id: 'basic_words_1',
        title: 'Basic English Words',
        description: 'Luyện phát âm các từ cơ bản trong tiếng Anh',
        difficulty: LessonDifficulty.beginner,
        type: LessonType.word,
        category: 'Basic Vocabulary',
        estimatedDuration: 5,
        tags: ['vocabulary', 'basic'],
        exercises: [
          PronunciationExercise(
            id: 'word_hello',
            text: 'hello',
            phonetic: '/həˈloʊ/',
            meaning: 'xin chào',
            tips: [
              'Âm "h" được phát âm nhẹ',
              'Nhấn mạnh vào âm tiết thứ hai',
              'Kết thúc bằng âm "loʊ" dài',
            ],
          ),
          PronunciationExercise(
            id: 'word_thank',
            text: 'thank',
            phonetic: '/θæŋk/',
            meaning: 'cảm ơn',
            tips: [
              'Âm "th" phải để lưỡi chạm răng',
              'Âm "æ" giống như "a" trong "cat"',
              'Kết thúc bằng âm "k" rõ ràng',
            ],
          ),
          PronunciationExercise(
            id: 'word_water',
            text: 'water',
            phonetic: '/ˈwɔːtər/',
            meaning: 'nước',
            tips: [
              'Âm "w" tròn môi',
              'Âm "a" dài như trong "saw"',
              'Âm "t" nhẹ, gần như "d"',
            ],
          ),
        ],
      ),

      // Lesson trung cấp - Cụm từ
      PronunciationLesson(
        id: 'phrases_1',
        title: 'Common Phrases',
        description: 'Luyện phát âm các cụm từ thông dụng',
        difficulty: LessonDifficulty.intermediate,
        type: LessonType.phrase,
        category: 'Daily Conversation',
        estimatedDuration: 8,
        tags: ['phrases', 'conversation'],
        exercises: [
          PronunciationExercise(
            id: 'phrase_good_morning',
            text: 'good morning',
            phonetic: '/ɡʊd ˈmɔːrnɪŋ/',
            meaning: 'chào buổi sáng',
            tips: [
              'Liên kết âm giữa "good" và "morning"',
              'Nhấn mạnh vào "mor" của morning',
              'Âm cuối "ing" nhẹ',
            ],
          ),
          PronunciationExercise(
            id: 'phrase_how_are_you',
            text: 'how are you',
            phonetic: '/haʊ ər ju/',
            meaning: 'bạn có khỏe không',
            tips: [
              '"How" phát âm như "cow"',
              '"Are" rút gọn thành "ər"',
              'Cả cụm từ nói nhanh và liền mạch',
            ],
          ),
        ],
      ),

      // Lesson nâng cao - Câu phức tạp
      PronunciationLesson(
        id: 'sentences_1',
        title: 'Complex Sentences',
        description: 'Luyện phát âm câu phức tạp với nhiều âm khó',
        difficulty: LessonDifficulty.advanced,
        type: LessonType.sentence,
        category: 'Advanced Practice',
        estimatedDuration: 12,
        tags: ['sentences', 'advanced', 'difficult-sounds'],
        exercises: [
          PronunciationExercise(
            id: 'sentence_tongue_twister',
            text: 'The quick brown fox jumps over the lazy dog',
            phonetic: '/ðə kwɪk braʊn fɑks dʒʌmps ˈoʊvər ðə ˈleɪzi dɔɡ/',
            meaning: 'Con cáo nâu nhanh nhẹn nhảy qua con chó lười biếng',
            tips: [
              'Tập trung vào âm "th" trong "the"',
              'Phân biệt âm "qu" và "br"',
              'Liên kết âm giữa các từ',
              'Nhấn nhịp đều đặn',
            ],
          ),
        ],
      ),

      // Lesson về âm khó
      PronunciationLesson(
        id: 'difficult_sounds_th',
        title: 'The "TH" Sound',
        description: 'Chuyên luyện âm "th" - một trong những âm khó nhất',
        difficulty: LessonDifficulty.intermediate,
        type: LessonType.word,
        category: 'Difficult Sounds',
        estimatedDuration: 10,
        tags: ['th-sound', 'difficult'],
        exercises: [
          PronunciationExercise(
            id: 'th_think',
            text: 'think',
            phonetic: '/θɪŋk/',
            meaning: 'nghĩ',
            tips: [
              'Đặt lưỡi giữa răng trên và dưới',
              'Thổi khí nhẹ qua lưỡi',
              'Không dùng âm "s" hay "f"',
            ],
          ),
          PronunciationExercise(
            id: 'th_this',
            text: 'this',
            phonetic: '/ðɪs/',
            meaning: 'cái này',
            tips: [
              'Giống như âm "th" trong think nhưng có rung',
              'Lưỡi vẫn ở vị trí giữa răng',
              'Có âm rung trong cổ họng',
            ],
          ),
        ],
      ),

      // Lesson về rhythm và intonation
      PronunciationLesson(
        id: 'rhythm_intonation_1',
        title: 'English Rhythm & Intonation',
        description: 'Luyện nhịp điệu và ngữ điệu tiếng Anh',
        difficulty: LessonDifficulty.advanced,
        type: LessonType.sentence,
        category: 'Rhythm & Intonation',
        estimatedDuration: 15,
        tags: ['rhythm', 'intonation', 'stress'],
        exercises: [
          PronunciationExercise(
            id: 'question_intonation',
            text: 'Are you coming to the party tonight?',
            phonetic: '/ər ju ˈkʌmɪŋ tə ðə ˈpɑrti təˈnaɪt/',
            meaning: 'Bạn có đến bữa tiệc tối nay không?',
            tips: [
              'Tăng giọng ở cuối câu hỏi',
              'Nhấn mạnh "coming", "party", "tonight"',
              'Các từ nhỏ như "to", "the" không nhấn',
              'Rhythm đều đặn giữa các stress',
            ],
          ),
        ],
      ),
    ];
  }

  /// Lấy lesson theo difficulty
  static List<PronunciationLesson> getLessonsByDifficulty(
      LessonDifficulty difficulty) {
    return getSampleLessons()
        .where((lesson) => lesson.difficulty == difficulty)
        .toList();
  }

  /// Lấy lesson theo type
  static List<PronunciationLesson> getLessonsByType(LessonType type) {
    return getSampleLessons().where((lesson) => lesson.type == type).toList();
  }

  /// Lấy lesson theo category
  static List<PronunciationLesson> getLessonsByCategory(String category) {
    return getSampleLessons()
        .where((lesson) => lesson.category == category)
        .toList();
  }
}
