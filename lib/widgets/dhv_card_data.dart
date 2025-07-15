import '../data/dhv_lesson_content.dart';

// ===============================================
// DHV CARD DATA PROVIDER - CONTENT MANAGEMENT
// Sử dụng DHVLessonContent để lấy nội dung từ file data riêng biệt
// ===============================================
class DHVCardDataProvider {
  // ========================================
  // DELEGATED METHODS - Ủy quyền cho DHVLessonContent
  // ========================================

  /// Lấy data cho Visual Card theo lesson ID
  static Map<String, dynamic> getVisualCardData(int lessonId) {
    return DHVLessonContent.getContentForCard(
      cardType: 'visual',
      lessonId: lessonId,
    );
  }

  /// Lấy data cho Audio Card theo lesson ID
  static Map<String, dynamic> getAudioCardData(int lessonId) {
    return DHVLessonContent.getContentForCard(
      cardType: 'audio',
      lessonId: lessonId,
    );
  }

  /// Lấy data cho Interactive Card theo lesson ID
  static Map<String, dynamic> getInteractiveCardData(int lessonId) {
    return DHVLessonContent.getContentForCard(
      cardType: 'interactive',
      lessonId: lessonId,
    );
  }

  /// Lấy data cho Info Card theo lesson ID
  static Map<String, dynamic> getInfoCardData(int lessonId) {
    return DHVLessonContent.getContentForCard(
      cardType: 'info',
      lessonId: lessonId,
    );
  }

  // ========================================
  // LEGACY METHODS - Tương thích ngược
  // ========================================

  /// Legacy method cho Lesson 1 Visual - tương thích ngược
  static Map<String, dynamic> getLesson1VisualData() {
    return getVisualCardData(1);
  }

  /// Legacy method cho Lesson 1 Audio - tương thích ngược
  static Map<String, dynamic> getLesson1AudioData() {
    return getAudioCardData(1);
  }

  /// Legacy method cho Lesson 1 Interactive - tương thích ngược
  static Map<String, dynamic> getLesson1InteractiveData() {
    return getInteractiveCardData(1);
  }

  /// Legacy method cho Lesson 1 Info - tương thích ngược
  static Map<String, dynamic> getLesson1InfoData() {
    return getInfoCardData(1);
  }

  /// Legacy method cho Lesson 2 Visual - tương thích ngược
  static Map<String, dynamic> getLesson2VisualData() {
    return getVisualCardData(2);
  }

  /// Legacy method cho Lesson 2 Audio - tương thích ngược
  static Map<String, dynamic> getLesson2AudioData() {
    return getAudioCardData(2);
  }

  /// Legacy method cho Lesson 2 Interactive - tương thích ngược
  static Map<String, dynamic> getLesson2InteractiveData() {
    return getInteractiveCardData(2);
  }

  /// Legacy method cho Lesson 2 Info - tương thích ngược
  static Map<String, dynamic> getLesson2InfoData() {
    return getInfoCardData(2);
  }

  // ========================================
  // MAIN METHODS - Phương thức chính
  // ========================================

  /// Method để lấy tất cả data cho một bài học
  static Map<String, Map<String, dynamic>> getAllCardDataForLesson(
      int lessonId) {
    // Sử dụng trực tiếp DHVLessonContent
    if (DHVLessonContent.hasContentForLesson(lessonId)) {
      final content = DHVLessonContent.getAllContentForLesson(lessonId);
      return {
        'visual': content['visual'] as Map<String, dynamic>,
        'audio': content['audio'] as Map<String, dynamic>,
        'interactive': content['interactive'] as Map<String, dynamic>,
        'info': content['info'] as Map<String, dynamic>,
      };
    } else {
      // Fallback cho các lesson chưa có content
      return {
        'visual': _getDefaultVisualData(),
        'audio': _getDefaultAudioData(),
        'interactive': _getDefaultInteractiveData(),
        'info': _getDefaultInfoData(),
      };
    }
  }

  // Default card data cho các bài học chưa có nội dung
  static Map<String, dynamic> _getDefaultVisualData() {
    return {
      'title': 'Nội dung trực quan',
      'subtitle': 'Đang phát triển',
      'type': 'default',
      'content': 'Nội dung hình ảnh và video đang được cập nhật.',
      'highlights': [
        'Nội dung đang phát triển',
        'Sẽ có hình ảnh minh họa',
        'Video giải thích',
        'Biểu đồ thông tin'
      ]
    };
  }

  static Map<String, dynamic> _getDefaultAudioData() {
    return {
      'title': 'Nội dung âm thanh',
      'subtitle': 'Đang phát triển',
      'type': 'default',
      'content': 'Nội dung âm thanh và phát âm đang được cập nhật.',
      'audioText': 'Nội dung này đang được phát triển.',
      'highlights': [
        'Nội dung đang phát triển',
        'Sẽ có bài tập phát âm',
        'Từ vựng mới',
        'Luyện nghe'
      ]
    };
  }

  static Map<String, dynamic> _getDefaultInteractiveData() {
    return {
      'title': 'Hoạt động tương tác',
      'subtitle': 'Đang phát triển',
      'type': 'default',
      'content': 'Nội dung tương tác và quiz đang được cập nhật.',
      'highlights': [
        'Nội dung đang phát triển',
        'Sẽ có quiz trắc nghiệm',
        'Trò chơi giáo dục',
        'Bài tập tương tác'
      ]
    };
  }

  static Map<String, dynamic> _getDefaultInfoData() {
    return {
      'title': 'Thông tin chi tiết',
      'subtitle': 'Đang phát triển',
      'type': 'default',
      'content': 'Thông tin chi tiết và số liệu đang được cập nhật.',
      'highlights': [
        'Nội dung đang phát triển',
        'Sẽ có thống kê',
        'Dữ liệu chi tiết',
        'Biểu đồ phân tích'
      ]
    };
  }
}
