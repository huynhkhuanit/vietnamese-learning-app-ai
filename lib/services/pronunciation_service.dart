import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Mô hình kết quả đánh giá phát âm
class PronunciationResult {
  final double overallScore;
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final double pronScore;
  final List<WordResult> words;
  final String recognizedText;
  final String feedback;
  final List<String> suggestions;

  PronunciationResult({
    required this.overallScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.pronScore,
    required this.words,
    required this.recognizedText,
    required this.feedback,
    required this.suggestions,
  });

  factory PronunciationResult.fromJson(Map<String, dynamic> json) {
    return PronunciationResult(
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
      accuracyScore: (json['accuracy_score'] ?? 0.0).toDouble(),
      fluencyScore: (json['fluency_score'] ?? 0.0).toDouble(),
      completenessScore: (json['completeness_score'] ?? 0.0).toDouble(),
      pronScore: (json['pron_score'] ?? 0.0).toDouble(),
      words: (json['words'] as List?)
              ?.map((w) => WordResult.fromJson(w))
              .toList() ??
          [],
      recognizedText: json['recognized_text'] ?? '',
      feedback: json['feedback'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

/// Kết quả đánh giá cho từng từ
class WordResult {
  final String word;
  final double accuracyScore;
  final double errorType;
  final List<PhonemeResult> phonemes;

  WordResult({
    required this.word,
    required this.accuracyScore,
    required this.errorType,
    required this.phonemes,
  });

  factory WordResult.fromJson(Map<String, dynamic> json) {
    return WordResult(
      word: json['word'] ?? '',
      accuracyScore: (json['accuracy_score'] ?? 0.0).toDouble(),
      errorType: (json['error_type'] ?? 0.0).toDouble(),
      phonemes: (json['phonemes'] as List?)
              ?.map((p) => PhonemeResult.fromJson(p))
              .toList() ??
          [],
    );
  }
}

/// Kết quả đánh giá cho từng âm tố
class PhonemeResult {
  final String phoneme;
  final double accuracyScore;

  PhonemeResult({
    required this.phoneme,
    required this.accuracyScore,
  });

  factory PhonemeResult.fromJson(Map<String, dynamic> json) {
    return PhonemeResult(
      phoneme: json['phoneme'] ?? '',
      accuracyScore: (json['accuracy_score'] ?? 0.0).toDouble(),
    );
  }
}

/// Service chính cho đánh giá phát âm
class PronunciationService {
  static final PronunciationService _instance =
      PronunciationService._internal();
  factory PronunciationService() => _instance;
  PronunciationService._internal();

  // Speech Recognition
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;

  // Text to Speech
  final FlutterTts _flutterTts = FlutterTts();

  // Audio Recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get speechEnabled => _speechEnabled;

  /// Khởi tạo service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Yêu cầu quyền
      await _requestPermissions();

      // Khởi tạo Speech to Text
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );

      // Cấu hình TTS
      await _configureTts();

      _isInitialized = true;
      debugPrint('PronunciationService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize PronunciationService: $e');
      return false;
    }
  }

  /// Yêu cầu quyền cần thiết
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.storage,
      Permission.speech,
    ];

    for (final permission in permissions) {
      if (await permission.isDenied) {
        await permission.request();
      }
    }
  }

  /// Cấu hình Text to Speech
  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
      debugPrint('TTS Error: $msg');
    });
  }

  /// Phát âm thanh mẫu
  Future<void> speakSample(String text) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  /// Dừng phát âm thanh
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isPlaying = false;
  }

  /// Bắt đầu ghi âm
  Future<String?> startRecording() async {
    if (!_isInitialized || _isRecording) return null;

    try {
      // Kiểm tra quyền
      if (await Permission.microphone.isDenied) {
        await Permission.microphone.request();
      }

      // Tạo đường dẫn file
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Bắt đầu ghi âm
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;
      debugPrint('Started recording: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return null;
    }
  }

  /// Dừng ghi âm
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      debugPrint('Stopped recording: $path');
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Phát lại bản ghi âm
  Future<void> playRecording(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing recording: $e');
    }
  }

  /// Đánh giá phát âm bằng Speech Recognition cơ bản
  Future<PronunciationResult> assessPronunciationBasic(
    String targetText,
    String? audioFilePath,
  ) async {
    if (!_speechEnabled) {
      return _createErrorResult('Speech recognition not available');
    }

    try {
      // Nếu có file âm thanh, sử dụng nó; nếu không, ghi âm trực tiếp
      String recognizedText = '';

      if (audioFilePath != null) {
        // Sử dụng file đã ghi sẵn (giả lập)
        recognizedText = await _transcribeAudioFile(audioFilePath);
      } else {
        // Ghi âm trực tiếp
        recognizedText = await _recognizeSpeechDirect();
      }

      // So sánh và đánh giá
      final result = _compareTexts(targetText, recognizedText);
      return result;
    } catch (e) {
      debugPrint('Error in basic pronunciation assessment: $e');
      return _createErrorResult('Assessment failed: $e');
    }
  }

  /// Đánh giá phát âm nâng cao với API AI (Speechace hoặc SpeechSuper)
  Future<PronunciationResult> assessPronunciationAdvanced(
    String targetText,
    String audioFilePath,
  ) async {
    try {
      // Đọc file audio
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        return _createErrorResult('Audio file not found');
      }

      final audioBytes = await audioFile.readAsBytes();

      // Gọi API đánh giá (giả lập - thay bằng API thật)
      final result = await _callPronunciationAPI(targetText, audioBytes);
      return result;
    } catch (e) {
      debugPrint('Error in advanced pronunciation assessment: $e');
      return _createErrorResult('Advanced assessment failed: $e');
    }
  }

  /// Transcribe audio file (giả lập)
  Future<String> _transcribeAudioFile(String filePath) async {
    // Trong thực tế, cần convert audio file và gửi đến STT service
    // Hiện tại giả lập bằng cách sử dụng speech recognition trực tiếp
    return await _recognizeSpeechDirect();
  }

  /// Nhận diện giọng nói trực tiếp
  Future<String> _recognizeSpeechDirect() async {
    final completer = Completer<String>();
    String recognizedText = '';

    await _speechToText.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
        if (result.finalResult) {
          completer.complete(recognizedText);
        }
      },
      listenFor: const Duration(seconds: 10),
      partialResults: true,
    );

    return completer.future;
  }

  /// So sánh văn bản và tạo kết quả đánh giá
  PronunciationResult _compareTexts(String target, String recognized) {
    // Chuẩn hóa văn bản
    final targetWords = target.toLowerCase().split(' ');
    final recognizedWords = recognized.toLowerCase().split(' ');

    // Tính toán điểm số
    double accuracyScore =
        _calculateSimilarity(target.toLowerCase(), recognized.toLowerCase());
    double fluencyScore = _calculateFluencyScore(targetWords, recognizedWords);
    double completenessScore =
        _calculateCompletenessScore(targetWords, recognizedWords);
    double overallScore =
        (accuracyScore + fluencyScore + completenessScore) / 3;

    // Tạo kết quả từng từ
    List<WordResult> words = _analyzeWords(targetWords, recognizedWords);

    // Tạo phản hồi
    String feedback =
        _generateFeedback(overallScore, accuracyScore, fluencyScore);
    List<String> suggestions = _generateSuggestions(words, accuracyScore);

    return PronunciationResult(
      overallScore: overallScore,
      accuracyScore: accuracyScore,
      fluencyScore: fluencyScore,
      completenessScore: completenessScore,
      pronScore: accuracyScore,
      words: words,
      recognizedText: recognized,
      feedback: feedback,
      suggestions: suggestions,
    );
  }

  /// Tính toán độ tương tự giữa hai chuỗi
  double _calculateSimilarity(String text1, String text2) {
    if (text1 == text2) return 100.0;

    final words1 = text1.split(' ');
    final words2 = text2.split(' ');

    int matchCount = 0;
    int totalWords = words1.length;

    for (int i = 0; i < words1.length && i < words2.length; i++) {
      if (words1[i] == words2[i]) {
        matchCount++;
      }
    }

    return (matchCount / totalWords) * 100;
  }

  /// Tính điểm fluency
  double _calculateFluencyScore(List<String> target, List<String> recognized) {
    // Đánh giá dựa trên tốc độ và độ trôi chảy
    if (recognized.isEmpty) return 0.0;

    double lengthRatio = recognized.length / target.length;
    if (lengthRatio > 1.5 || lengthRatio < 0.5) {
      return 50.0; // Quá nhanh hoặc quá chậm
    }

    return 85.0; // Điểm fluency cơ bản
  }

  /// Tính điểm completeness
  double _calculateCompletenessScore(
      List<String> target, List<String> recognized) {
    if (target.isEmpty) return 100.0;
    return (recognized.length / target.length) * 100;
  }

  /// Phân tích từng từ
  List<WordResult> _analyzeWords(List<String> target, List<String> recognized) {
    List<WordResult> results = [];

    for (int i = 0; i < target.length; i++) {
      String targetWord = target[i];
      String recognizedWord = i < recognized.length ? recognized[i] : '';

      double wordAccuracy = targetWord == recognizedWord
          ? 100.0
          : _calculateSimilarity(targetWord, recognizedWord);

      results.add(WordResult(
        word: targetWord,
        accuracyScore: wordAccuracy,
        errorType: wordAccuracy < 80 ? 1.0 : 0.0,
        phonemes: [], // Sẽ được phân tích chi tiết hơn với API
      ));
    }

    return results;
  }

  /// Tạo phản hồi
  String _generateFeedback(double overall, double accuracy, double fluency) {
    if (overall >= 90) return 'Xuất sắc! Phát âm của bạn rất chuẩn.';
    if (overall >= 80) return 'Tốt! Một số từ cần cải thiện nhỏ.';
    if (overall >= 70) return 'Khá tốt. Hãy luyện tập thêm một số từ.';
    if (overall >= 60) return 'Cần cải thiện. Tập trung vào phát âm từng từ.';
    return 'Cần luyện tập nhiều hơn. Hãy nghe và lặp lại nhiều lần.';
  }

  /// Tạo gợi ý
  List<String> _generateSuggestions(List<WordResult> words, double accuracy) {
    List<String> suggestions = [];

    if (accuracy < 80) {
      suggestions.add('Hãy phát âm chậm và rõ ràng hơn');
      suggestions.add('Tập trung vào từng âm tiết');
    }

    // Tìm từ có điểm thấp
    var problematicWords = words.where((w) => w.accuracyScore < 70).toList();
    if (problematicWords.isNotEmpty) {
      suggestions.add(
          'Luyện tập thêm các từ: ${problematicWords.map((w) => w.word).join(', ')}');
    }

    suggestions.add('Nghe âm thanh mẫu và lặp lại nhiều lần');

    return suggestions;
  }

  /// Gọi API đánh giá phát âm (giả lập - cần thay bằng API thật)
  Future<PronunciationResult> _callPronunciationAPI(
    String text,
    Uint8List audioData,
  ) async {
    try {
      // Giả lập gọi API Speechace hoặc SpeechSuper
      // Trong thực tế, cần config API key và endpoint

      await Future.delayed(
          const Duration(seconds: 2)); // Giả lập thời gian xử lý

      // Tạo kết quả giả lập với độ chính xác cao hơn
      return PronunciationResult(
        overallScore: 85.0 + (DateTime.now().millisecond % 15),
        accuracyScore: 88.0 + (DateTime.now().millisecond % 10),
        fluencyScore: 82.0 + (DateTime.now().millisecond % 15),
        completenessScore: 90.0 + (DateTime.now().millisecond % 8),
        pronScore: 87.0 + (DateTime.now().millisecond % 12),
        words: text
            .split(' ')
            .map((word) => WordResult(
                  word: word,
                  accuracyScore: 80.0 + (word.hashCode % 20),
                  errorType: word.hashCode % 10 > 7 ? 1.0 : 0.0,
                  phonemes: [],
                ))
            .toList(),
        recognizedText: text, // Giả lập nhận diện hoàn hảo
        feedback:
            'Phân tích chi tiết từ AI: Phát âm tổng thể tốt, một số cải thiện nhỏ.',
        suggestions: [
          'Tập trung vào intonation',
          'Luyện tập rhythm của câu',
          'Cải thiện pronunciation của consonant clusters',
        ],
      );
    } catch (e) {
      debugPrint('API call failed: $e');
      return _createErrorResult('API assessment failed');
    }
  }

  /// Tạo kết quả lỗi
  PronunciationResult _createErrorResult(String message) {
    return PronunciationResult(
      overallScore: 0.0,
      accuracyScore: 0.0,
      fluencyScore: 0.0,
      completenessScore: 0.0,
      pronScore: 0.0,
      words: [],
      recognizedText: '',
      feedback: message,
      suggestions: ['Vui lòng thử lại'],
    );
  }

  /// Dọn dẹp resources
  Future<void> dispose() async {
    await _flutterTts.stop();
    await _audioRecorder.dispose();
    await _audioPlayer.dispose();
    await _speechToText.stop();
  }
}
