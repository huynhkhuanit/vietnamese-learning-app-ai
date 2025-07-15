import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Universal Text-to-Speech Service cho ứng dụng học tiếng Việt
/// Hỗ trợ người dùng nước ngoài nghe phát âm tiếng Việt
class UniversalTtsService {
  static final UniversalTtsService _instance = UniversalTtsService._internal();
  factory UniversalTtsService() => _instance;
  UniversalTtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isEnabled = true;
  bool _isPlaying = false;
  double _speechRate = 0.6; // Tốc độ phát âm chậm hơn cho người mới học
  double _volume = 1.0;
  double _pitch = 1.0;
  String _currentLanguage = 'vi-VN'; // Mặc định tiếng Việt
  String? _lastSpokenText;

  // Callback cho các sự kiện TTS
  VoidCallback? _onSpeechStart;
  VoidCallback? _onSpeechComplete;
  Function(String)? _onSpeechError;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get currentLanguage => _currentLanguage;
  String? get lastSpokenText => _lastSpokenText;

  /// Khởi tạo TTS service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _flutterTts = FlutterTts();
      await _loadPreferences();
      await _configureTts();
      _setupCallbacks();

      _isInitialized = true;
      debugPrint('Universal TTS Service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize Universal TTS Service: $e');
      return false;
    }
  }

  /// Tải cài đặt từ SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool('tts_enabled') ?? true;
      _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.6;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;
      _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
      _currentLanguage = prefs.getString('tts_language') ?? 'vi-VN';
    } catch (e) {
      debugPrint('Error loading TTS preferences: $e');
    }
  }

  /// Lưu cài đặt vào SharedPreferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tts_enabled', _isEnabled);
      await prefs.setDouble('tts_speech_rate', _speechRate);
      await prefs.setDouble('tts_volume', _volume);
      await prefs.setDouble('tts_pitch', _pitch);
      await prefs.setString('tts_language', _currentLanguage);
    } catch (e) {
      debugPrint('Error saving TTS preferences: $e');
    }
  }

  /// Cấu hình TTS
  Future<void> _configureTts() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.setLanguage(_currentLanguage);
      await _flutterTts!.setSpeechRate(_speechRate);
      await _flutterTts!.setVolume(_volume);
      await _flutterTts!.setPitch(_pitch);
    } catch (e) {
      debugPrint('Error configuring TTS: $e');
    }
  }

  /// Thiết lập callbacks
  void _setupCallbacks() {
    if (_flutterTts == null) return;

    try {
      _flutterTts!.setStartHandler(() {
        _isPlaying = true;
        _onSpeechStart?.call();
      });

      _flutterTts!.setCompletionHandler(() {
        _isPlaying = false;
        _onSpeechComplete?.call();
      });

      _flutterTts!.setErrorHandler((msg) {
        _isPlaying = false;
        _onSpeechError?.call(msg);
        debugPrint('TTS Error: $msg');
      });
    } catch (e) {
      debugPrint('Error setting up TTS callbacks: $e');
    }
  }

  /// Đọc văn bản
  Future<void> speak(
    String text, {
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (!_isInitialized || !_isEnabled || text.trim().isEmpty) {
      debugPrint(
          'TTS: Cannot speak - not initialized or disabled or empty text');
      return;
    }

    try {
      // Dừng speech hiện tại nếu đang phát
      if (_isPlaying) {
        debugPrint('TTS: Stopping current speech before starting new one');
        await stop();
        // Wait a bit to ensure previous speech is stopped
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint(
          'TTS: Starting to speak: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');

      // Thiết lập các tham số tạm thời nếu có
      if (language != null && language != _currentLanguage) {
        await _flutterTts!.setLanguage(language);
        debugPrint('TTS: Set language to $language');
      }
      if (speechRate != null) {
        await _flutterTts!.setSpeechRate(speechRate);
        debugPrint('TTS: Set speech rate to $speechRate');
      }
      if (volume != null) {
        await _flutterTts!.setVolume(volume);
      }
      if (pitch != null) {
        await _flutterTts!.setPitch(pitch);
      }

      _lastSpokenText = text;
      _isPlaying = true; // Set immediately to prevent race conditions

      await _flutterTts!.speak(text);

      // Khôi phục cài đặt mặc định
      if (language != null && language != _currentLanguage) {
        await _flutterTts!.setLanguage(_currentLanguage);
      }
      if (speechRate != null) {
        await _flutterTts!.setSpeechRate(_speechRate);
      }
      if (volume != null) {
        await _flutterTts!.setVolume(_volume);
      }
      if (pitch != null) {
        await _flutterTts!.setPitch(_pitch);
      }
    } catch (e) {
      debugPrint('Error speaking text: $e');
      _isPlaying = false;
      _onSpeechError?.call(e.toString());
    }
  }

  /// Đọc từ tiếng Việt với phiên âm
  Future<void> speakVietnamese(
    String text, {
    bool slow = false,
  }) async {
    await speak(
      text,
      language: 'vi-VN',
      speechRate: slow ? 0.4 : _speechRate,
    );
  }

  /// Đọc từ tiếng Anh (cho người dùng quốc tế)
  Future<void> speakEnglish(String text) async {
    await speak(
      text,
      language: 'en-US',
      speechRate: _speechRate,
    );
  }

  /// Đọc với nhiều tùy chọn nâng cao
  Future<void> speakWithOptions({
    required String text,
    bool slow = false,
    bool repeat = false,
    String? language,
  }) async {
    double speechRate = slow ? 0.4 : _speechRate;

    await speak(
      text,
      language: language,
      speechRate: speechRate,
    );

    if (repeat) {
      await Future.delayed(const Duration(milliseconds: 800));
      await speak(
        text,
        language: language,
        speechRate: speechRate,
      );
    }
  }

  /// Tạm dừng TTS (nếu platform hỗ trợ)
  Future<void> pause() async {
    if (_flutterTts != null) {
      await _flutterTts!.pause();
    }
  }

  /// Đọc từ theo từng từ (để học phát âm)
  Future<void> speakWordByWord(
    String sentence, {
    Duration pauseBetweenWords = const Duration(milliseconds: 500),
  }) async {
    if (!_isInitialized || !_isEnabled) return;

    final words = sentence.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].trim().isNotEmpty) {
        await speak(words[i].trim());

        // Đợi speech hoàn thành
        while (_isPlaying) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Tạm dừng giữa các từ
        if (i < words.length - 1) {
          await Future.delayed(pauseBetweenWords);
        }
      }
    }
  }

  /// Đọc với giải thích (cho mục đích học tập)
  Future<void> speakWithExplanation(String vietnamese, String english) async {
    // Đọc tiếng Việt
    await speakVietnamese(vietnamese);

    // Đợi speech hoàn thành
    while (_isPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Tạm dừng
    await Future.delayed(const Duration(milliseconds: 500));

    // Đọc tiếng Anh
    await speakEnglish("In English: $english");
  }

  /// Dừng speech
  Future<void> stop() async {
    if (_flutterTts != null) {
      try {
        debugPrint('TTS: Stopping speech (was playing: $_isPlaying)');
        await _flutterTts!.stop();
        _isPlaying = false;
        debugPrint('TTS: Speech stopped successfully');
      } catch (e) {
        debugPrint('Error stopping TTS: $e');
        _isPlaying = false;
      }
    } else {
      _isPlaying = false;
    }
  }

  /// Thiết lập callbacks
  void setCallbacks({
    VoidCallback? onSpeechStart,
    VoidCallback? onSpeechComplete,
    Function(String)? onSpeechError,
  }) {
    _onSpeechStart = onSpeechStart;
    _onSpeechComplete = onSpeechComplete;
    _onSpeechError = onSpeechError;
  }

  /// Bật/tắt TTS
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _savePreferences();
    if (!enabled && _isPlaying) {
      await stop();
    }
  }

  /// Thiết lập tốc độ phát âm
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 2.0);
    if (_flutterTts != null) {
      try {
        await _flutterTts!.setSpeechRate(_speechRate);
      } catch (e) {
        debugPrint('Error setting speech rate: $e');
      }
    }
    await _savePreferences();
  }

  /// Thiết lập âm lượng
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_flutterTts != null) {
      try {
        await _flutterTts!.setVolume(_volume);
      } catch (e) {
        debugPrint('Error setting volume: $e');
      }
    }
    await _savePreferences();
  }

  /// Thiết lập cao độ giọng nói
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    if (_flutterTts != null) {
      try {
        await _flutterTts!.setPitch(_pitch);
      } catch (e) {
        debugPrint('Error setting pitch: $e');
      }
    }
    await _savePreferences();
  }

  /// Thiết lập ngôn ngữ
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    if (_flutterTts != null) {
      try {
        await _flutterTts!.setLanguage(_currentLanguage);
      } catch (e) {
        debugPrint('Error setting language: $e');
      }
    }
    await _savePreferences();
  }

  /// Dọn dẹp resources
  Future<void> dispose() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
      _isInitialized = false;
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error disposing TTS service: $e');
    }
  }

  /// Phương thức tiện ích cho việc đọc nhanh
  Future<void> quickSpeak(String text) async {
    if (text.trim().isEmpty) return;

    // Tự động phát hiện ngôn ngữ và điều chỉnh
    final isVietnamese = _containsVietnameseCharacters(text);
    final language = isVietnamese ? 'vi-VN' : 'en-US';

    await speak(text, language: language);
  }

  /// Kiểm tra xem text có chứa ký tự tiếng Việt không
  bool _containsVietnameseCharacters(String text) {
    final vietnamesePattern = RegExp(
        r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]');
    return vietnamesePattern.hasMatch(text.toLowerCase());
  }
}
