import 'life_theme_content.dart';

// ===============================================
// LIFE THEME EXERCISES - DUOLINGO STYLE
// ===============================================

enum LifeThemeExerciseType {
  multipleChoice,
  wordBuilding,
  dragAndDrop,
  fillBlank,
  listening,
  speaking,
  matchPairs,
  translate,
  pictureChoice,
  sentenceOrder
}

class LifeThemeExercise {
  final LifeThemeExerciseType type;
  final String instruction;
  final String? questionText;
  final String? audioUrl;
  final String? imageUrl;
  final Map<String, dynamic> exerciseData;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
  final int difficulty; // 1=beginner, 2=intermediate, 3=advanced
  final List<String> tags;

  LifeThemeExercise({
    required this.type,
    required this.instruction,
    this.questionText,
    this.audioUrl,
    this.imageUrl,
    required this.exerciseData,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
    required this.difficulty,
    required this.tags,
  });
}

class LifeThemeExerciseProvider {
  // Sample exercises for Unit 1 - Family & Relations
  static final List<LifeThemeExercise> unit1Exercises = [
    // Lesson 0: Basic family terms
    LifeThemeExercise(
      type: LifeThemeExerciseType.multipleChoice,
      instruction: 'Từ "bố" có nghĩa là gì?',
      questionText: 'bố',
      audioUrl: 'audio/lifetheme/bo.mp3',
      exerciseData: {'word': 'bố', 'meaning': 'father'},
      correctAnswer: 'father',
      options: ['father', 'mother', 'brother', 'sister'],
      explanation: 'Đúng rồi! "bố" có nghĩa là father',
      difficulty: 1,
      tags: ['vocabulary', 'family', 'unit1'],
    ),

    LifeThemeExercise(
      type: LifeThemeExerciseType.wordBuilding,
      instruction: 'Sắp xếp các chữ cái để tạo thành từ "mẹ":',
      questionText: 'mother',
      exerciseData: {
        'scrambledLetters': ['ẹ', 'm'],
        'correctWord': 'mẹ'
      },
      correctAnswer: 'mẹ',
      options: [],
      explanation: 'Từ đúng là "mẹ" (mother)',
      difficulty: 1,
      tags: ['vocabulary', 'spelling', 'unit1'],
    ),

    LifeThemeExercise(
      type: LifeThemeExerciseType.listening,
      instruction: 'Nghe và chọn từ bạn vừa nghe:',
      audioUrl: 'audio/lifetheme/anh.mp3',
      exerciseData: {'targetWord': 'anh', 'playCount': 0},
      correctAnswer: 'anh',
      options: ['anh', 'em', 'chị', 'bà'],
      explanation: 'Từ bạn vừa nghe là "anh" (older brother)',
      difficulty: 2,
      tags: ['listening', 'family', 'unit1'],
    ),

    LifeThemeExercise(
      type: LifeThemeExerciseType.dragAndDrop,
      instruction: 'Kéo từ phù hợp vào chỗ trống:',
      questionText: 'Đây là ____ của tôi (This is my sister)',
      exerciseData: {
        'sentence': 'Đây là ____ của tôi',
        'options': ['chị', 'anh', 'bố', 'mẹ'],
        'correctAnswer': 'chị'
      },
      correctAnswer: 'chị',
      options: ['chị', 'anh', 'bố', 'mẹ'],
      explanation: 'Từ đúng là "chị" (sister)',
      difficulty: 2,
      tags: ['grammar', 'family', 'unit1'],
    ),

    LifeThemeExercise(
      type: LifeThemeExerciseType.matchPairs,
      instruction: 'Ghép từ tiếng Việt với nghĩa tiếng Anh:',
      exerciseData: {
        'pairs': {
          'bố': 'father',
          'mẹ': 'mother',
          'anh': 'older brother',
          'chị': 'older sister'
        }
      },
      correctAnswer: 'all_matched',
      options: [],
      explanation: 'Tất cả các cặp đã ghép đúng!',
      difficulty: 2,
      tags: ['vocabulary', 'matching', 'unit1'],
    ),
  ];

  // Sample exercises for Unit 2 - Food & Drinks
  static final List<LifeThemeExercise> unit2Exercises = [
    LifeThemeExercise(
      type: LifeThemeExerciseType.pictureChoice,
      instruction: 'Chọn hình ảnh đúng cho từ "phở":',
      questionText: 'phở',
      audioUrl: 'audio/lifetheme/pho.mp3',
      exerciseData: {
        'correctImage': 'pho.jpg',
        'distractors': ['com.jpg', 'bun.jpg', 'banh_mi.jpg']
      },
      correctAnswer: 'pho.jpg',
      options: ['pho.jpg', 'com.jpg', 'bun.jpg', 'banh_mi.jpg'],
      explanation: '"phở" là món ăn truyền thống Việt Nam',
      difficulty: 1,
      tags: ['vocabulary', 'food', 'unit2'],
    ),
    LifeThemeExercise(
      type: LifeThemeExerciseType.fillBlank,
      instruction: 'Điền từ thích hợp vào chỗ trống:',
      questionText: 'Tôi muốn ăn ____',
      exerciseData: {'context': 'ordering_food', 'correctWord': 'cơm'},
      correctAnswer: 'cơm',
      options: ['cơm', 'nước', 'phở', 'bánh'],
      explanation: 'Câu hoàn chỉnh: "Tôi muốn ăn cơm"',
      difficulty: 2,
      tags: ['grammar', 'food', 'unit2'],
    ),
  ];

  // Generate exercises for a specific lesson
  static List<LifeThemeExercise> generateLessonExercises(
      int unitNumber, int lessonNumber) {
    final exercises = <LifeThemeExercise>[];

    // Try to get vocabulary for this unit, fallback to sample data
    List<Map<String, dynamic>> allWords = [];
    List<Map<String, dynamic>> grammarPatterns = [];

    try {
      allWords = LifeThemeContentProvider.getAllVocabularyWords(unitNumber);
      grammarPatterns = LifeThemeContentProvider.getGrammarPatterns(unitNumber);
    } catch (e) {
      // Fallback to sample data if LifeThemeContentProvider is not available
      print('LifeThemeContentProvider not available, using sample data');
    }

    if (allWords.isEmpty) {
      // Use predefined exercises for the requested unit
      return _getUnit1LessonExercises(lessonNumber);
    }

    // Lesson structure: 8 lessons per unit, each with different focus
    switch (lessonNumber) {
      case 0: // Introduction lesson - Basic vocabulary
        exercises.addAll(_generateIntroductionExercises(unitNumber, allWords));
        break;
      case 1: // Core vocabulary practice
        exercises.addAll(_generateVocabularyExercises(unitNumber, allWords));
        break;
      case 2: // Listening and pronunciation
        exercises.addAll(_generateListeningExercises(unitNumber, allWords));
        break;
      case 3: // Grammar patterns
        exercises.addAll(
            _generateGrammarExercises(unitNumber, grammarPatterns, allWords));
        break;
      case 4: // Mixed practice with review
        exercises.addAll(_generateMixedExercises(unitNumber, allWords));
        break;
      case 5: // Advanced combinations
        exercises.addAll(
            _generateAdvancedExercises(unitNumber, allWords, grammarPatterns));
        break;
      case 6: // Review and reinforcement
        exercises.addAll(_generateReviewExercises(unitNumber, allWords));
        break;
      case 7: // Unit test
        exercises.addAll(
            _generateTestExercises(unitNumber, allWords, grammarPatterns));
        break;
    }

    return exercises;
  }

  // Introduction lesson - Basic vocabulary with pictures
  static List<LifeThemeExercise> _generateIntroductionExercises(
      int unitNumber, List<Map<String, dynamic>> words) {
    final exercises = <LifeThemeExercise>[];
    final selectedWords = words.take(6).toList();

    for (int i = 0; i < selectedWords.length; i++) {
      final word = selectedWords[i];
      final otherWords = words.where((w) => w != word).take(3).toList();

      // Picture choice exercise
      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.pictureChoice,
        instruction: 'Chọn hình ảnh đúng cho từ này:',
        questionText: word['vn'],
        audioUrl: 'audio/lifetheme/${word['audio']}',
        exerciseData: {
          'correctWord': word,
          'distractors': otherWords,
          'showAudio': true,
        },
        correctAnswer: word['en'],
        options: [word['en'], ...otherWords.map((w) => w['en']).take(3)],
        explanation:
            '${word['vn']} nghĩa là ${word['en']}. Phát âm: ${word['ipa']}',
        difficulty: 1,
        tags: ['vocabulary', 'introduction', 'unit$unitNumber'],
      ));

      // Basic multiple choice
      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.multipleChoice,
        instruction: 'Từ "${word['vn']}" có nghĩa là gì?',
        questionText: word['vn'],
        audioUrl: 'audio/lifetheme/${word['audio']}',
        exerciseData: {
          'word': word,
          'showIPA': true,
        },
        correctAnswer: word['en'],
        options: [word['en'], ...otherWords.map((w) => w['en']).take(3)],
        explanation: 'Đúng rồi! ${word['vn']} = ${word['en']}',
        difficulty: 1,
        tags: ['vocabulary', 'meaning', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Core vocabulary with word building
  static List<LifeThemeExercise> _generateVocabularyExercises(
      int unitNumber, List<Map<String, dynamic>> words) {
    final exercises = <LifeThemeExercise>[];
    final selectedWords = words.take(8).toList();

    for (final word in selectedWords) {
      // Word building exercise
      final letters = word['vn'].split('');
      letters.shuffle();

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.wordBuilding,
        instruction: 'Sắp xếp các chữ cái để tạo thành từ đúng:',
        questionText: word['en'],
        audioUrl: 'audio/lifetheme/${word['audio']}',
        imageUrl: 'images/lifetheme/unit$unitNumber/${word['vn']}.jpg',
        exerciseData: {
          'scrambledLetters': letters,
          'correctWord': word['vn'],
          'hint': word['en'],
          'ipa': word['ipa'],
        },
        correctAnswer: word['vn'],
        options: [], // No options for word building
        explanation: 'Từ đúng là "${word['vn']}" (${word['en']})',
        difficulty: 2,
        tags: ['vocabulary', 'spelling', 'unit$unitNumber'],
      ));

      // Drag and drop exercise
      final otherWords = words.where((w) => w != word).take(3).toList();
      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.dragAndDrop,
        instruction: 'Kéo từ tiếng Việt phù hợp vào ô trống:',
        questionText: 'This is ${word['en']} in Vietnamese: ____',
        exerciseData: {
          'targetWord': word,
          'distractors': otherWords,
          'sentence': 'Đây là ____ (${word['en']})',
          'correctPosition': 2, // Position in sentence
        },
        correctAnswer: word['vn'],
        options: [word['vn'], ...otherWords.map((w) => w['vn']).take(3)],
        explanation: 'Từ tiếng Việt cho "${word['en']}" là "${word['vn']}"',
        difficulty: 2,
        tags: ['vocabulary', 'dragdrop', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Listening and pronunciation exercises
  static List<LifeThemeExercise> _generateListeningExercises(
      int unitNumber, List<Map<String, dynamic>> words) {
    final exercises = <LifeThemeExercise>[];
    final selectedWords = words.take(6).toList();

    for (final word in selectedWords) {
      // Listening exercise
      final similarSoundWords = words
          .where((w) => w != word && w['vn'].length == word['vn'].length)
          .take(3)
          .toList();

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.listening,
        instruction: 'Nghe và chọn từ bạn vừa nghe:',
        audioUrl: 'audio/lifetheme/${word['audio']}',
        exerciseData: {
          'targetWord': word,
          'playCount': 0, // Track how many times played
          'showIPA': false, // Don't show IPA initially
        },
        correctAnswer: word['vn'],
        options: [word['vn'], ...similarSoundWords.map((w) => w['vn']).take(3)],
        explanation:
            'Từ bạn vừa nghe là "${word['vn']}" (${word['en']}). Phát âm: ${word['ipa']}',
        difficulty: 2,
        tags: ['listening', 'pronunciation', 'unit$unitNumber'],
      ));

      // Speaking exercise
      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.speaking,
        instruction: 'Nhìn hình và nói từ tiếng Việt:',
        questionText: word['en'],
        imageUrl: 'images/lifetheme/unit$unitNumber/${word['vn']}.jpg',
        exerciseData: {
          'targetWord': word,
          'showHint': false,
          'maxAttempts': 3,
        },
        correctAnswer: word['vn'],
        options: [], // Speaking doesn't need options
        explanation: 'Cách phát âm đúng: ${word['vn']} ${word['ipa']}',
        difficulty: 3,
        tags: ['speaking', 'pronunciation', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Grammar pattern exercises
  static List<LifeThemeExercise> _generateGrammarExercises(int unitNumber,
      List<Map<String, dynamic>> patterns, List<Map<String, dynamic>> words) {
    final exercises = <LifeThemeExercise>[];

    for (final pattern in patterns) {
      final examples = List<String>.from(pattern['examples'] ?? []);

      for (final example in examples.take(2)) {
        // Fill in the blank with grammar pattern
        final blankPosition = example.indexOf(' ') + 1;
        final beforeBlank = example.substring(0, blankPosition);
        final afterBlank =
            example.substring(example.indexOf(' ', blankPosition));
        final correctWord = example.split(' ')[1];

        final otherWords = words
            .map((w) => w['vn'])
            .where((w) => w != correctWord)
            .take(3)
            .toList();

        exercises.add(LifeThemeExercise(
          type: LifeThemeExerciseType.fillBlank,
          instruction: 'Điền từ thích hợp vào chỗ trống:',
          questionText: '$beforeBlank ____$afterBlank',
          exerciseData: {
            'pattern': pattern['pattern'],
            'meaning': pattern['meaning'],
            'fullSentence': example,
            'blankPosition': 1,
          },
          correctAnswer: correctWord,
          options: [correctWord, ...otherWords],
          explanation:
              'Câu đúng: "$example". Mẫu câu: ${pattern['pattern']} = ${pattern['meaning']}',
          difficulty: 2,
          tags: ['grammar', 'fillblank', 'unit$unitNumber'],
        ));

        // Translation exercise
        exercises.add(LifeThemeExercise(
          type: LifeThemeExerciseType.translate,
          instruction: 'Dịch câu sau sang tiếng Việt:',
          questionText: pattern['meaning']
              .toString()
              .replaceFirst('[person]', 'my father')
              .replaceFirst('[food]', 'pho')
              .replaceFirst('[activity]', 'football'),
          exerciseData: {
            'sourceLanguage': 'en',
            'targetLanguage': 'vn',
            'pattern': pattern,
            'context': 'unit$unitNumber',
          },
          correctAnswer: example,
          options: [example, ...examples.where((e) => e != example).take(3)],
          explanation: 'Bản dịch đúng: "$example"',
          difficulty: 3,
          tags: ['translation', 'grammar', 'unit$unitNumber'],
        ));
      }
    }

    return exercises;
  }

  // Mixed practice exercises
  static List<LifeThemeExercise> _generateMixedExercises(
      int unitNumber, List<Map<String, dynamic>> words) {
    final exercises = <LifeThemeExercise>[];
    final selectedWords = words.take(8).toList();

    // Match pairs exercise
    final firstHalf = selectedWords.take(4).toList();
    final secondHalf = firstHalf.map((w) => w['en']).toList()..shuffle();

    exercises.add(LifeThemeExercise(
      type: LifeThemeExerciseType.matchPairs,
      instruction: 'Ghép từ tiếng Việt với nghĩa tiếng Anh:',
      exerciseData: {
        'leftColumn': firstHalf.map((w) => w['vn']).toList(),
        'rightColumn': secondHalf,
        'correctPairs': {for (var w in firstHalf) w['vn']: w['en']},
      },
      correctAnswer: 'all_matched',
      options: [], // Matching doesn't use options
      explanation:
          'Các cặp đúng: ${firstHalf.map((w) => '${w['vn']} = ${w['en']}').join(', ')}',
      difficulty: 2,
      tags: ['vocabulary', 'matching', 'unit$unitNumber'],
    ));

    // Sentence order exercise
    for (final word in selectedWords.take(3)) {
      final sentence = _createSentenceWithWord(unitNumber, word);
      final words = sentence.split(' ')..shuffle();

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.sentenceOrder,
        instruction: 'Sắp xếp các từ để tạo thành câu đúng:',
        exerciseData: {
          'scrambledWords': words,
          'correctSentence': sentence,
          'keyWord': word['vn'],
          'meaning': _translateSentence(sentence),
        },
        correctAnswer: sentence,
        options: words,
        explanation: 'Câu đúng: "$sentence" = ${_translateSentence(sentence)}',
        difficulty: 3,
        tags: ['grammar', 'sentence', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Advanced exercises with complex patterns
  static List<LifeThemeExercise> _generateAdvancedExercises(int unitNumber,
      List<Map<String, dynamic>> words, List<Map<String, dynamic>> patterns) {
    final exercises = <LifeThemeExercise>[];

    // Advanced listening with context
    final selectedWords = words.take(4).toList();
    for (final word in selectedWords) {
      final contextSentence = _createContextSentence(unitNumber, word);

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.listening,
        instruction: 'Nghe câu và chọn từ khóa:',
        questionText: contextSentence,
        audioUrl:
            'audio/lifetheme/sentences/unit${unitNumber}_${word['vn']}.mp3',
        exerciseData: {
          'fullSentence': contextSentence,
          'keyWord': word['vn'],
          'context': true,
          'difficulty': 'advanced',
        },
        correctAnswer: word['vn'],
        options: [
          word['vn'],
          ...words.where((w) => w != word).take(3).map((w) => w['vn'])
        ],
        explanation: 'Từ khóa trong câu là "${word['vn']}" (${word['en']})',
        difficulty: 3,
        tags: ['listening', 'context', 'advanced', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Review exercises with spaced repetition
  static List<LifeThemeExercise> _generateReviewExercises(
      int unitNumber, List<Map<String, dynamic>> words) {
    final exercises = <LifeThemeExercise>[];

    // Quick review multiple choice
    final reviewWords = words.take(10).toList()..shuffle();

    for (int i = 0; i < reviewWords.length; i += 2) {
      final word = reviewWords[i];
      final others = reviewWords.where((w) => w != word).take(3).toList();

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.multipleChoice,
        instruction: 'Ôn tập: Từ này có nghĩa là gì?',
        questionText: word['vn'],
        audioUrl: 'audio/lifetheme/${word['audio']}',
        exerciseData: {
          'reviewMode': true,
          'fastPaced': true,
          'showTimer': true,
        },
        correctAnswer: word['en'],
        options: [word['en'], ...others.map((w) => w['en'])],
        explanation: '${word['vn']} = ${word['en']}',
        difficulty: 1,
        tags: ['review', 'vocabulary', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Test exercises for unit completion
  static List<LifeThemeExercise> _generateTestExercises(int unitNumber,
      List<Map<String, dynamic>> words, List<Map<String, dynamic>> patterns) {
    final exercises = <LifeThemeExercise>[];

    // Comprehensive test with mixed types
    final testWords = words.take(12).toList();

    // Vocabulary test
    for (int i = 0; i < 5; i++) {
      final word = testWords[i];
      final others = testWords.where((w) => w != word).take(3).toList();

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.multipleChoice,
        instruction: 'Kiểm tra: Chọn nghĩa đúng',
        questionText: word['vn'],
        exerciseData: {
          'testMode': true,
          'unitTest': true,
        },
        correctAnswer: word['en'],
        options: [word['en'], ...others.map((w) => w['en'])],
        explanation: 'Đáp án: ${word['vn']} = ${word['en']}',
        difficulty: 2,
        tags: ['test', 'vocabulary', 'unit$unitNumber'],
      ));
    }

    // Grammar test
    for (final pattern in patterns.take(2)) {
      final examples = List<String>.from(pattern['examples'] ?? []);
      final example = examples.first;

      exercises.add(LifeThemeExercise(
        type: LifeThemeExerciseType.translate,
        instruction: 'Kiểm tra ngữ pháp: Dịch câu sau',
        questionText: pattern['meaning'].toString(),
        exerciseData: {
          'testMode': true,
          'grammarTest': true,
          'pattern': pattern['pattern'],
        },
        correctAnswer: example,
        options: [example, ...examples.skip(1).take(3)],
        explanation: 'Mẫu câu: ${pattern['pattern']} → "$example"',
        difficulty: 3,
        tags: ['test', 'grammar', 'unit$unitNumber'],
      ));
    }

    return exercises;
  }

  // Helper methods
  static String _createSentenceWithWord(
      int unitNumber, Map<String, dynamic> word) {
    final patterns = {
      1: 'Đây là ${word['vn']} của tôi',
      2: 'Tôi muốn ăn ${word['vn']}',
      3: 'Tôi làm ${word['vn']}',
      4: 'Tôi thích ${word['vn']}',
      5: 'Tôi bị đau ${word['vn']}',
      6: 'Tôi muốn mua ${word['vn']}'
    };
    return patterns[unitNumber] ?? 'Đây là ${word['vn']}';
  }

  static String _createContextSentence(
      int unitNumber, Map<String, dynamic> word) {
    final contexts = {
      1: 'Gia đình tôi có ${word['vn']} rất tốt',
      2: '${word['vn']} này rất ngon',
      3: '${word['vn']} làm việc ở công ty',
      4: 'Tôi chơi ${word['vn']} vào cuối tuần',
      5: 'Bác sĩ kiểm tra ${word['vn']} của tôi',
      6: 'Tôi mua ${word['vn']} ở chợ'
    };
    return contexts[unitNumber] ?? '${word['vn']} rất quan trọng';
  }

  static String _translateSentence(String sentence) {
    // Simple translation mapping - in real app would use proper translation service
    final translations = {
      'Đây là': 'This is',
      'của tôi': 'my',
      'Tôi muốn': 'I want',
      'ăn': 'to eat',
      'làm': 'work as',
      'thích': 'like',
      'bị đau': 'have pain in',
      'mua': 'to buy',
    };

    String translated = sentence;
    translations.forEach((vn, en) {
      translated = translated.replaceAll(vn, en);
    });

    return translated;
  }

  // Get exercises for specific lesson (0-7 in each unit)
  static List<LifeThemeExercise> getLessonExercises(
      int unitNumber, int lessonInUnit) {
    return generateLessonExercises(unitNumber, lessonInUnit);
  }

  // Get mixed review exercises across multiple lessons
  static List<LifeThemeExercise> getReviewExercises(
      int unitNumber, List<int> completedLessons) {
    final exercises = <LifeThemeExercise>[];

    try {
      final allWords =
          LifeThemeContentProvider.getAllVocabularyWords(unitNumber);
      exercises.addAll(_generateReviewExercises(unitNumber, allWords));
    } catch (e) {
      // Fallback to predefined exercises
      exercises.addAll(_getUnit1LessonExercises(0));
    }

    return exercises;
  }

  // Get adaptive exercises based on user performance
  static List<LifeThemeExercise> getAdaptiveExercises(int unitNumber,
      Map<String, double> wordDifficulties, List<String> weakWords) {
    final exercises = <LifeThemeExercise>[];

    try {
      final allWords =
          LifeThemeContentProvider.getAllVocabularyWords(unitNumber);

      // Focus on weak words
      final focusWords = allWords
          .where((w) =>
              weakWords.contains(w['vn']) ||
              (wordDifficulties[w['vn']] ?? 0.5) > 0.7)
          .toList();

      if (focusWords.isNotEmpty) {
        exercises.addAll(_generateVocabularyExercises(unitNumber, focusWords));
        exercises.addAll(_generateListeningExercises(unitNumber, focusWords));
      }
    } catch (e) {
      // Fallback to predefined exercises
      exercises.addAll(_getUnit1LessonExercises(0));
    }

    return exercises;
  }

  // Helper methods for fallback data
  static List<LifeThemeExercise> _getUnit1LessonExercises(int lessonNumber) {
    final baseExercises = unit1Exercises;
    final exercisesPerLesson = 2;
    final startIndex = lessonNumber * exercisesPerLesson;
    final endIndex =
        (startIndex + exercisesPerLesson).clamp(0, baseExercises.length);

    if (startIndex >= baseExercises.length) {
      return unit1Exercises.take(2).toList();
    }

    return baseExercises.sublist(startIndex, endIndex);
  }

  static List<LifeThemeExercise> _getUnit2LessonExercises(int lessonNumber) {
    final baseExercises = unit2Exercises;
    final exercisesPerLesson = 1;
    final startIndex = lessonNumber * exercisesPerLesson;
    final endIndex =
        (startIndex + exercisesPerLesson).clamp(0, baseExercises.length);

    if (startIndex >= baseExercises.length) {
      return unit2Exercises;
    }

    return baseExercises.sublist(startIndex, endIndex);
  }
}
