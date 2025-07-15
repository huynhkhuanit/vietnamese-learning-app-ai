import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/celebration_dialog.dart';
import '../widgets/unlock_animation.dart';
import '../widgets/dhv_card_data.dart';
import '../widgets/clickable_text_widget.dart';
import '../widgets/duolingo_quiz_widget.dart';
import '../widgets/study_assistant_widget.dart';
import '../widgets/life_theme_lesson_widget.dart';
import '../data/dhv_quiz_data.dart';
import '../services/user_progress_service.dart';
import '../services/universal_tts_service.dart';
import '../services/xp_service.dart';
import '../models/user_experience.dart';

// ===============================================
// CORE UNITS DATA MODELS - DHV TUTORIAL SYSTEM
// ===============================================
class TutorialContent {
  final String title;
  final String content;
  final String imageUrl;
  final List<String> keyPoints;
  final String audioText;
  final Map<String, String> vocabulary;

  TutorialContent({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.keyPoints,
    required this.audioText,
    required this.vocabulary,
  });
}

// DHV Learning Card Types for Interactive Tutorial System
enum DHVCardType {
  visual, // Hình ảnh và video
  audio, // Âm thanh và phát âm
  interactive, // Tương tác và quiz
  info // Thông tin chi tiết
}

class DHVLearningCard {
  final String title;
  final String subtitle;
  final DHVCardType type;
  final String content;
  final List<String> highlights;
  final String? imageUrl;
  final String? audioText;
  final List<InteractiveElement>? interactiveElements;
  final Map<String, dynamic>? metadata;

  DHVLearningCard({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.content,
    required this.highlights,
    this.imageUrl,
    this.audioText,
    this.interactiveElements,
    this.metadata,
  });
}

class InteractiveElement {
  final String type; // 'quiz', 'timeline', 'stat', 'gallery'
  final String title;
  final dynamic data;
  final Color? color;

  InteractiveElement({
    required this.type,
    required this.title,
    required this.data,
    this.color,
  });
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool _disposed = false;

  // User progress stream
  Stream<DocumentSnapshot>? _progressStream;
  Map<String, dynamic>? _currentProgressData;

  // DHV Core Units - 2 chương đầy đủ về DHV University dựa trên data thực tế
  final List<LessonUnit> coreUnits = [
    // CHƯƠNG 1: TỔNG QUAN VỀ TRƯỜNG ĐẠI HỌC HÙNG VƯƠNG - HOÀN THÀNH 8/8
    LessonUnit(
      unitNumber: 1,
      title: 'Tổng quan về Trường ĐH Hùng Vương',
      description:
          'Lịch sử 30 năm (1995-2025), tên trường, sứ mệnh và cơ sở vật chất',
      color: const Color(0xFF1E88E5), // Blue - màu chủ đạo của trường
      icon: Icons.school,
      isCore: true,
      lessons: [
        Lesson(id: 1, title: 'Ý nghĩa tên trường Hùng Vương', completed: true),
        Lesson(
            id: 2,
            title: 'Lịch sử hình thành và phát triển (1995-2025)',
            completed: true),
        Lesson(
            id: 3,
            title: 'Sứ mệnh - Tầm nhìn - Giá trị cốt lõi',
            completed: true),
        Lesson(id: 4, title: 'Cơ sở vật chất và Campus', completed: true),
        Lesson(id: 5, title: 'Hệ thống tổ chức và cơ cấu', completed: true),
        Lesson(
            id: 6,
            title: 'Các đơn vị phòng ban liên quan sinh viên',
            completed: true),
        Lesson(id: 7, title: 'Các Khoa đào tạo tại DHV', completed: true),
        Lesson(
            id: 8,
            title: 'Kiểm tra Chương 1 - Tổng quan DHV',
            completed: true,
            isTest: true),
      ],
    ),

    // CHƯƠNG 2: CHƯƠNG TRÌNH ĐÀO TẠO - KHOA KỸ THUẬT CÔNG NGHỆ - 1/8 HOÀN THÀNH
    LessonUnit(
      unitNumber: 2,
      title: 'Chương trình đào tạo - Khoa Kỹ thuật Công nghệ',
      description: 'Chuẩn đầu ra, Ngành CNTT, Kỹ thuật máy tính và IoT',
      color: const Color(0xFF43A047), // Green - công nghệ xanh
      icon: Icons.computer,
      isCore: true,
      lessons: [
        Lesson(
            id: 9,
            title: 'Chuẩn đầu ra ngoại ngữ - tin học',
            completed: true,
            currentLevel: true),
        Lesson(id: 10, title: 'Ngành Công nghệ Thông tin', completed: false),
        Lesson(id: 11, title: 'Ngành Kỹ thuật Máy tính', completed: false),
        Lesson(
            id: 12,
            title: 'Chuyên sâu IoT và Hệ thống nhúng',
            completed: false),
        Lesson(id: 13, title: 'Phòng lab và trang thiết bị', completed: false),
        Lesson(
            id: 14,
            title: 'Đào tạo thực hành và dự án thực tế',
            completed: false),
        Lesson(id: 15, title: 'Cơ hội việc làm và thực tập', completed: false),
        Lesson(
            id: 16,
            title: 'Kiểm tra Chương 2 - Đào tạo Công nghệ',
            completed: false,
            isTest: true),
      ],
    ),
  ];

  // Life Theme Units - Màu sắc theo chủ đề
  final List<LessonUnit> lifeThemeUnits = [
    // UNIT 1: Gia đình & Mối quan hệ
    LessonUnit(
      unitNumber: 1,
      title: 'Gia đình & Mối quan hệ',
      description: 'Từ vựng về các thành viên gia đình và mối quan hệ xã hội',
      color: const Color(0xFFE91E63), // Pink - tình cảm gia đình ấm áp
      icon: Icons.family_restroom,
      isCore: false,
      lessons: [
        Lesson(
            id: 100,
            title: 'Bố mẹ và anh chị em',
            completed: false,
            currentLevel: true),
        Lesson(id: 101, title: 'Ông bà và họ hàng', completed: false),
        Lesson(id: 102, title: 'Bạn bè và người yêu', completed: false),
        Lesson(
            id: 103, title: 'Mô tả tính cách và ngoại hình', completed: false),
        Lesson(
            id: 104, title: 'Hoạt động gia đình cuối tuần', completed: false),
        Lesson(id: 105, title: 'Kỷ niệm và ngày lễ gia đình', completed: false),
        Lesson(id: 106, title: 'Giao tiếp với hàng xóm', completed: false),
        Lesson(
            id: 107,
            title: 'Kiểm tra Unit 1 - Family Circle',
            completed: false,
            isTest: true),
      ],
    ),

    // UNIT 2: Đồ ăn & Ẩm thực Việt Nam
    LessonUnit(
      unitNumber: 2,
      title: 'Đồ ăn & Ẩm thực Việt Nam',
      description: 'Khám phá món ăn truyền thống và văn hóa ẩm thực',
      color: const Color(0xFFFF9800), // Orange - màu thực phẩm tươi ngon
      icon: Icons.restaurant,
      isCore: false,
      lessons: [
        Lesson(
            id: 200,
            title: 'Phở, bánh mì và món ăn đường phố',
            completed: false),
        Lesson(id: 201, title: 'Cơm và các món chính', completed: false),
        Lesson(
            id: 202, title: 'Nước uống và trà cà phê Việt', completed: false),
        Lesson(id: 203, title: 'Đặt món và thanh toán', completed: false),
        Lesson(id: 204, title: 'Nấu ăn và nguyên liệu', completed: false),
        Lesson(
            id: 205,
            title: 'Ẩm thực 3 miền Bắc - Trung - Nam',
            completed: false),
        Lesson(id: 206, title: 'Văn hóa ăn uống Việt Nam', completed: false),
        Lesson(
            id: 207,
            title: 'Kiểm tra Unit 2 - Vietnamese Cuisine',
            completed: false,
            isTest: true),
      ],
    ),

    // UNIT 3: Công việc & Nghề nghiệp
    LessonUnit(
      unitNumber: 3,
      title: 'Công việc & Nghề nghiệp',
      description: 'Các nghề nghiệp phổ biến và môi trường làm việc',
      color: const Color(0xFF3F51B5), // Indigo - chuyên nghiệp và uy tín
      icon: Icons.work,
      isCore: false,
      lessons: [
        Lesson(id: 300, title: 'Các nghề nghiệp phổ biến', completed: false),
        Lesson(id: 301, title: 'Môi trường văn phòng', completed: false),
        Lesson(id: 302, title: 'Phỏng vấn xin việc', completed: false),
        Lesson(id: 303, title: 'Lương bổng và phúc lợi', completed: false),
        Lesson(id: 304, title: 'Kỹ năng mềm trong công việc', completed: false),
        Lesson(id: 305, title: 'Làm việc nhóm và giao tiếp', completed: false),
        Lesson(
            id: 306, title: 'Cân bằng công việc - cuộc sống', completed: false),
        Lesson(
            id: 307,
            title: 'Kiểm tra Unit 3 - Career Path',
            completed: false,
            isTest: true),
      ],
    ),

    // UNIT 4: Sở thích & Giải trí
    LessonUnit(
      unitNumber: 4,
      title: 'Sở thích & Giải trí',
      description: 'Hoạt động thể thao, nghệ thuật và giải trí',
      color: const Color(0xFF9C27B0), // Purple - sáng tạo và nghệ thuật
      icon: Icons.sports_soccer,
      isCore: false,
      lessons: [
        Lesson(id: 400, title: 'Thể thao và tập luyện', completed: false),
        Lesson(id: 401, title: 'Xem phim và nghe nhạc', completed: false),
        Lesson(id: 402, title: 'Du lịch và khám phá', completed: false),
        Lesson(id: 403, title: 'Nấu ăn và làm bánh', completed: false),
        Lesson(id: 404, title: 'Đọc sách và học tập', completed: false),
        Lesson(id: 405, title: 'Chơi game và công nghệ', completed: false),
        Lesson(id: 406, title: 'Nghệ thuật và sáng tạo', completed: false),
        Lesson(
            id: 407,
            title: 'Kiểm tra Unit 4 - Hobbies & Fun',
            completed: false,
            isTest: true),
      ],
    ),

    // UNIT 5: Sức khỏe & Y tế
    LessonUnit(
      unitNumber: 5,
      title: 'Sức khỏe & Y tế',
      description: 'Chăm sóc sức khỏe và các vấn đề y tế cơ bản',
      color: const Color(0xFF4CAF50), // Green - sức khỏe và sự sống
      icon: Icons.local_hospital,
      isCore: false,
      lessons: [
        Lesson(id: 500, title: 'Các bộ phận cơ thể', completed: false),
        Lesson(id: 501, title: 'Triệu chứng bệnh thường gặp', completed: false),
        Lesson(id: 502, title: 'Đi khám bác sĩ', completed: false),
        Lesson(id: 503, title: 'Thuốc men và điều trị', completed: false),
        Lesson(id: 504, title: 'Tập thể dục và dinh dưỡng', completed: false),
        Lesson(id: 505, title: 'Sơ cứu cơ bản', completed: false),
        Lesson(id: 506, title: 'Sức khỏe tinh thần', completed: false),
        Lesson(
            id: 507,
            title: 'Kiểm tra Unit 5 - Health Care',
            completed: false,
            isTest: true),
      ],
    ),

    // UNIT 6: Mua sắm & Tiền bạc
    LessonUnit(
      unitNumber: 6,
      title: 'Mua sắm & Tiền bạc',
      description: 'Kỹ năng mua bán, thương lượng và quản lý tài chính',
      color: const Color(0xFF795548), // Brown - ổn định tài chính
      icon: Icons.shopping_cart,
      isCore: false,
      lessons: [
        Lesson(id: 600, title: 'Quần áo và thời trang', completed: false),
        Lesson(id: 601, title: 'Đồ gia dụng và điện tử', completed: false),
        Lesson(id: 602, title: 'Trả giá và mặc cả', completed: false),
        Lesson(id: 603, title: 'Ngân hàng và thanh toán', completed: false),
        Lesson(
            id: 604, title: 'Chợ truyền thống và siêu thị', completed: false),
        Lesson(id: 605, title: 'Mua sắm online', completed: false),
        Lesson(id: 606, title: 'Quản lý tài chính cá nhân', completed: false),
        Lesson(
            id: 607,
            title: 'Kiểm tra Unit 6 - Shopping Smart',
            completed: false,
            isTest: true),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Initialize user progress and setup stream
    _initializeUserProgress();
  }

  Future<void> _initializeUserProgress() async {
    try {
      // Initialize user progress if needed
      await UserProgressService.initializeUserProgress();

      // Setup progress stream
      if (UserProgressService.currentUser != null) {
        _progressStream = UserProgressService.getUserProgressStream();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing user progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Show login prompt if user is not logged in
    if (UserProgressService.currentUser == null) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        appBar: const CustomAppBar(title: 'Bài học'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Vui lòng đăng nhập',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Để lưu tiến độ học tập và đồng bộ hóa dữ liệu',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Build main lesson screen with progress tracking
    return StreamBuilder<DocumentSnapshot>(
      stream: _progressStream,
      builder: (context, snapshot) {
        // Update current progress data from Firebase realtime
        if (snapshot.hasData && snapshot.data!.exists) {
          _currentProgressData = snapshot.data!.data() as Map<String, dynamic>?;
          print(
              'DEBUG: StreamBuilder updated progress data: ${_currentProgressData?.keys}');
        } else {
          print('DEBUG: StreamBuilder no data or document does not exist');
        }

        return _buildLessonScreen(isDarkMode);
      },
    );
  }

  Widget _buildLessonScreen(bool isDarkMode) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: 'Bài học',
        actions: const [
          Icon(Icons.star, color: Colors.white, size: 24),
          SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFFFF8E1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(2),
                labelColor: const Color(0xFFDA020E),
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                splashFactory: InkRipple.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white.withOpacity(0.15);
                  }
                  return Colors.transparent;
                }),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    height: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(Icons.school, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'DHV Core',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    height: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(Icons.psychology, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Life Theme',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoreUnitsView(isDarkMode),
          _buildLifeThemeUnitsView(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCoreUnitsView(bool isDarkMode) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  // Header for Core Units
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFDA020E).withOpacity(0.8),
                          const Color(0xFFFFD700).withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDA020E).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tìm hiểu về DHV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Học về lịch sử, cơ sở vật chất và Khoa Kỹ thuật Công nghệ của trường Đại học Hùng Vương TPHCM.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (index <= coreUnits.length) {
                  final unitIndex = index - 1;
                  if (unitIndex < coreUnits.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: LessonUnitCard(
                        unit: coreUnits[unitIndex],
                        isDarkMode: isDarkMode,
                        progressData: _currentProgressData,
                        onLessonCompleted: _onLessonCompleted,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                } else if (index == coreUnits.length + 1) {
                  // DHV Comprehensive Quiz Event - Appears after all units
                  return _buildDHVComprehensiveQuiz(isDarkMode);
                }
                return const SizedBox.shrink();
              },
              childCount: coreUnits.length + 2, // +1 for header, +1 for quiz
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLifeThemeUnitsView(bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  // Header for Life Theme Units - Đa dạng màu sắc theo chủ đề
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1), // Indigo - học tập
                          const Color(0xFF8B5CF6), // Purple - sáng tạo
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Học tiếng Việt cơ bản',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '6 chủ đề cuộc sống với màu sắc riêng biệt: Gia đình (Hồng), Ẩm thực (Cam), Công việc (Xanh dương), Giải trí (Tím), Sức khỏe (Xanh lá), Mua sắm (Nâu). Mỗi màu phản ánh đặc trưng của chủ đề.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final unitIndex = index - 1;
                  if (unitIndex < lifeThemeUnits.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: LessonUnitCard(
                        unit: lifeThemeUnits[unitIndex],
                        isDarkMode: isDarkMode,
                        progressData: _currentProgressData,
                        onLessonCompleted: _onLessonCompleted,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
              },
              childCount: lifeThemeUnits.length + 1,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================
  // DHV COMPREHENSIVE QUIZ WIDGET
  // ===============================================
  Widget _buildDHVComprehensiveQuiz(bool isDarkMode) {
    final quizData = DHVQuizDataProvider.getQuizData('dhv_comprehensive_quiz');
    final questions = quizData['questions'] as List<dynamic>? ?? [];

    if (questions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6B73FF).withOpacity(0.9),
                  const Color(0xFF9C27B0).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B73FF).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bài Kiểm Tra Tổng Hợp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Thử thách kiến thức toàn diện về DHV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'EVENT SPECIAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
              ],
            ),
          ),

          // Quiz Launch Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF6B73FF).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: QuizLauncherButton(
              quizData: quizData,
              unitColor: const Color(0xFF6B73FF),
              lessonTitle: 'Bài Kiểm Tra Tổng Hợp DHV',
              onCompleted: () {
                // Handle quiz completion
                _showQuizCompletionDialog();
              },
            ),
          ),

          // Quiz Features
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2A2A2A).withOpacity(0.7)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6B73FF).withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF6B73FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thông tin bài kiểm tra',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B73FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildQuizFeatureRow(
                  Icons.help_outline,
                  'Câu hỏi:',
                  '${questions.length} câu trắc nghiệm',
                  isDarkMode,
                ),
                const SizedBox(height: 8),
                _buildQuizFeatureRow(
                  Icons.timer_outlined,
                  'Thời gian:',
                  '~${questions.length * 2} phút',
                  isDarkMode,
                ),
                const SizedBox(height: 8),
                _buildQuizFeatureRow(
                  Icons.star_outline,
                  'Điểm tối đa:',
                  '${questions.length * 10} XP',
                  isDarkMode,
                ),
                const SizedBox(height: 8),
                _buildQuizFeatureRow(
                  Icons.school_outlined,
                  'Chủ đề:',
                  'Lịch sử, cơ cấu, chương trình đào tạo DHV',
                  isDarkMode,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: const Color(0xFF6B73FF),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hoàn thành bài kiểm tra để nhận chứng chỉ DHV Expert!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B73FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizFeatureRow(
      IconData icon, String label, String value, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B73FF),
            ),
          ),
        ),
      ],
    );
  }

  void _showQuizCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompletionCelebrationDialog(
        lessonId: 999, // Special ID for comprehensive quiz
        isCore: true,
        xpGained: 200, // Bonus XP for comprehensive quiz
        unitColor: const Color(0xFF6B73FF),
        lessonTitle: 'Bài Kiểm Tra Tổng Hợp DHV - Hoàn Thành!',
        onContinue: () {
          // Show certificate or special reward
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Chúc mừng! Bạn đã trở thành DHV Expert!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF6B73FF),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Callback when lesson is completed
  Future<void> _onLessonCompleted(int lessonId, bool isCore) async {
    print(
        'DEBUG: _onLessonCompleted called: lessonId=$lessonId, isCore=$isCore, mounted=$mounted');

    // Award XP through XP Service first
    final xpService = XPService();
    int xpGained = 0;

    try {
      // Update daily streak
      await xpService.updateDailyStreak();

      // Award XP based on lesson type
      if (isCore) {
        xpGained = await xpService.awardXP(
          XPActivityType.lessonCompleted,
          extraData: {'isDHVLesson': true},
        );
      } else {
        final isTestLesson = (lessonId % 100) == 7;
        final extraData = {
          'isLifeTheme': true,
          'isTest': isTestLesson,
        };

        // Check if completing a unit
        if (isTestLesson) {
          extraData['unitCompleted'] = true;
        }

        xpGained = await xpService.awardXP(
          XPActivityType.lessonCompleted,
          extraData: extraData,
        );
      }

      // Mark lesson as completed in Firebase
      print('DEBUG: Marking lesson as completed in Firebase...');
      await UserProgressService.markLessonCompleted(lessonId, isCore, xpGained);
      print('DEBUG: Firebase save successful, XP gained: $xpGained');

      // Wait a bit for Firebase to propagate changes
      await Future.delayed(const Duration(milliseconds: 500));

      // Show celebration dialog first
      if (mounted) {
        print('DEBUG: About to show celebration dialog');
        _showCelebrationDialog(lessonId, isCore, xpGained);
      } else {
        print('WARNING: Widget not mounted, cannot show celebration');
      }
    } catch (e) {
      print('Error completing lesson: $e');
      if (mounted) {
        String errorMessage = 'Lỗi khi lưu tiến độ';

        // Handle specific Firebase errors
        if (e.toString().contains('permission-denied')) {
          errorMessage =
              'Không có quyền lưu dữ liệu. Vui lòng kiểm tra đăng nhập.';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
        } else if (e.toString().contains('unavailable')) {
          errorMessage =
              'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                // Retry the operation
                _onLessonCompleted(lessonId, isCore);
              },
            ),
          ),
        );

        // Still show celebration even if save failed (local experience)
        _showCelebrationDialog(lessonId, isCore, xpGained);
      }
    }
  }

  void _showCelebrationDialog(int lessonId, bool isCore, int xpGained) {
    print(
        'DEBUG: Showing celebration dialog for lesson $lessonId, isCore: $isCore, XP: $xpGained');

    // Find lesson title for display
    String lessonTitle = 'Bài học';
    Color unitColor = Colors.blue;

    // Find lesson in core or life theme units
    for (var unit in [...coreUnits, ...lifeThemeUnits]) {
      for (var lesson in unit.lessons) {
        if (lesson.id == lessonId) {
          lessonTitle = lesson.title;
          unitColor = unit.color;
          print('DEBUG: Found lesson: $lessonTitle with color: $unitColor');
          break;
        }
      }
    }

    // Double check we're on the main screen
    if (!mounted) {
      print('WARNING: Widget not mounted, cannot show celebration');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        print('DEBUG: Building celebration dialog');
        return CompletionCelebrationDialog(
          lessonId: lessonId,
          isCore: isCore,
          xpGained: xpGained,
          unitColor: unitColor,
          lessonTitle: lessonTitle,
          onContinue: () {
            print('DEBUG: User pressed continue, showing unlock animation');
            _showNextLessonUnlock(lessonId, isCore, unitColor);
          },
        );
      },
    );
  }

  void _showNextLessonUnlock(
      int completedLessonId, bool isCore, Color unitColor) {
    print(
        'DEBUG: _showNextLessonUnlock called for lesson $completedLessonId, isCore: $isCore');

    // Force refresh the lesson list with updated progress from stream
    // The StreamBuilder will automatically rebuild with new Firebase data
    print('DEBUG: UI will refresh automatically via StreamBuilder');

    // Xác định bài học/unit tiếp theo sẽ được mở khóa
    String? nextLessonTitle;
    Color? nextUnitColor;
    bool isNextUnit = false;

    if (isCore) {
      // DHV Core logic
      if (completedLessonId < 16) {
        final nextLessonId = completedLessonId + 1;
        for (var unit in coreUnits) {
          for (var lesson in unit.lessons) {
            if (lesson.id == nextLessonId) {
              nextLessonTitle = lesson.title;
              nextUnitColor = unit.color;
              break;
            }
          }
        }
      }
    } else {
      // Life Theme logic - sử dụng logic mới
      if (completedLessonId >= 100 && completedLessonId < 607) {
        if (completedLessonId % 100 == 7) {
          // Hoàn thành unit, mở unit tiếp theo
          final currentUnitNumber = completedLessonId ~/ 100;
          final nextUnitNumber = currentUnitNumber + 1;

          if (nextUnitNumber <= 6) {
            final nextUnit = lifeThemeUnits.firstWhere(
              (u) => u.unitNumber == nextUnitNumber,
              orElse: () => lifeThemeUnits.first,
            );
            nextLessonTitle = 'Unit ${nextUnit.unitNumber}: ${nextUnit.title}';
            nextUnitColor = nextUnit.color;
            isNextUnit = true;
          }
        } else {
          // Mở bài tiếp theo trong cùng unit
          final nextLessonId = completedLessonId + 1;
          for (var unit in lifeThemeUnits) {
            for (var lesson in unit.lessons) {
              if (lesson.id == nextLessonId) {
                nextLessonTitle = lesson.title;
                nextUnitColor = unit.color;
                break;
              }
            }
          }
        }
      }
    }

    if (nextLessonTitle != null) {
      final displayColor = nextUnitColor ?? unitColor;

      // Show unlock notification after a delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.transparent,
            builder: (context) => Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: LessonUnlockNotification(
                  lessonTitle: nextLessonTitle!,
                  unitColor: displayColor,
                  onTap: () {
                    // Could navigate to the specific lesson here
                  },
                ),
              ),
            ),
          );
        }
      });
    }
  }
}

class LessonUnit {
  final int unitNumber;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final List<Lesson> lessons;
  final bool isCore;

  LessonUnit({
    required this.unitNumber,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.lessons,
    required this.isCore,
  });
}

class Lesson {
  final int id;
  final String title;
  final bool completed;
  final bool currentLevel;
  final bool isTest;

  Lesson({
    required this.id,
    required this.title,
    this.completed = false,
    this.currentLevel = false,
    this.isTest = false,
  });
}

class LessonUnitCard extends StatefulWidget {
  final LessonUnit unit;
  final bool isDarkMode;
  final Map<String, dynamic>? progressData;
  final Future<void> Function(int lessonId, bool isCore) onLessonCompleted;

  const LessonUnitCard({
    super.key,
    required this.unit,
    required this.isDarkMode,
    this.progressData,
    required this.onLessonCompleted,
  });

  @override
  State<LessonUnitCard> createState() => _LessonUnitCardState();
}

class _LessonUnitCardState extends State<LessonUnitCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress from Firebase data
    final totalLessons = widget.unit.lessons.length;
    final progress = UserProgressService.getUnitProgress(
        widget.unit.unitNumber, widget.unit.isCore, widget.progressData);
    final completedLessons = (progress * totalLessons).round();

    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.unit.color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                if (isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.unit.color,
                    widget.unit.color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.unit.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Unit ${widget.unit.unitNumber}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Core/Theme Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.unit.isCore
                                        ? Colors.amber.withOpacity(0.9)
                                        : Colors.green.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (widget.unit.isCore
                                                ? Colors.amber
                                                : Colors.green)
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.unit.isCore
                                            ? Icons.school
                                            : Icons.psychology,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.unit.isCore
                                            ? 'DHV CORE'
                                            : 'CHỦ ĐỀ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.unit.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 3.14159,
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description with theme indicator
                  Row(
                    children: [
                      if (!widget.unit.isCore) ...[
                        Icon(
                          Icons.psychology,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          widget.unit.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedLessons/$totalLessons',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Lessons List
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children:
                          widget.unit.lessons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lesson = entry.value;

                        // Bỏ logic wasJustUnlocked vì không cần animation đặc biệt

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LessonItem(
                            lesson: lesson,
                            unitColor: widget.unit.color,
                            isDarkMode: widget.isDarkMode,
                            progressData: widget.progressData,
                            isCore: widget.unit.isCore,
                            onLessonCompleted: widget.onLessonCompleted,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class LessonItem extends StatelessWidget {
  final Lesson lesson;
  final Color unitColor;
  final bool isDarkMode;
  final Map<String, dynamic>? progressData;
  final bool isCore;
  final Future<void> Function(int lessonId, bool isCore) onLessonCompleted;

  const LessonItem({
    super.key,
    required this.lesson,
    required this.unitColor,
    required this.isDarkMode,
    this.progressData,
    required this.isCore,
    required this.onLessonCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng cùng logic mở khóa cho cả DHV Core và Life Theme
    final isCompleted =
        UserProgressService.isLessonCompleted(lesson.id, isCore, progressData);
    final isUnlocked =
        UserProgressService.isLessonUnlocked(lesson.id, isCore, progressData);
    final isCurrent = isUnlocked && !isCompleted;

    // Enhanced Debug logging for Life Theme lessons
    if (lesson.id >= 100 && lesson.id <= 110) {
      final sectionData = progressData?[isCore ? 'dhvCore' : 'lifeTheme']
          as Map<String, dynamic>?;
      final completedLessons = sectionData?['completedLessons'] ?? [];
      final currentLesson = sectionData?['currentLesson'] ?? (isCore ? 1 : 100);

      print(
          'DEBUG ENHANCED: Lesson ${lesson.id}: completed=$isCompleted, unlocked=$isUnlocked, current=$isCurrent');
      print('  - completedLessons: $completedLessons');
      print('  - currentLesson: $currentLesson');
      print(
          '  - previousLesson ${lesson.id - 1} completed: ${completedLessons.contains(lesson.id - 1)}');
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToLessonDetail(context, isUnlocked, isCompleted);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.withOpacity(0.08)
              : isCurrent
                  ? Colors.white
                  : isUnlocked
                      ? (isDarkMode ? const Color(0xFF2A2A2A) : Colors.white)
                      : (isDarkMode
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(16),
          border: isCurrent
              ? Border.all(color: unitColor, width: 3)
              : isCompleted
                  ? Border.all(color: Colors.green, width: 2)
                  : isUnlocked
                      ? Border.all(
                          color: Colors.grey.withOpacity(0.3), width: 1)
                      : Border.all(
                          color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: unitColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: unitColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : isCompleted
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? unitColor
                    : isCurrent
                        ? unitColor
                        : (isDarkMode
                            ? const Color(0xFF4A4A4A)
                            : const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(24),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: unitColor.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                lesson.isTest
                    ? Icons.quiz
                    : isCompleted
                        ? Icons.check_circle
                        : isCurrent
                            ? (lesson.id <= 16
                                ? Icons.menu_book // Core lessons use book icon
                                : Icons
                                    .play_circle_filled) // Life Theme lessons use play icon
                            : Icons.lock,
                color: isCompleted
                    ? Colors.white
                    : isCurrent
                        ? Colors.white
                        : (isDarkMode ? Colors.white54 : Colors.black54),
                size: isCurrent ? 26 : 24,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 16, // Bỏ scale cho bài học hiện tại
                      fontWeight:
                          FontWeight.w600, // Bỏ bold cho bài học hiện tại
                      color: isCompleted
                          ? Colors.green.shade700
                          : isCurrent
                              ? unitColor
                              : isUnlocked
                                  ? (isDarkMode ? Colors.white : Colors.black87)
                                  : (isDarkMode
                                      ? Colors.white38
                                      : Colors.black38),
                      // Bỏ shadows cho bài học hiện tại
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lesson.isTest) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Kiểm tra unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted
                            ? Colors.green.shade600
                            : isCurrent
                                ? unitColor.withOpacity(0.8)
                                : isUnlocked
                                    ? (isDarkMode
                                        ? Colors.white70
                                        : Colors.black54)
                                    : (isDarkMode
                                        ? Colors.white30
                                        : Colors.grey),
                      ),
                    ),
                  ] else if (lesson.id <= 16) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 12,
                          color: unitColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lesson.id <= 8
                                ? 'Hướng dẫn về DHV'
                                : 'Hướng dẫn về Khoa Kỹ thuật',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: unitColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else if (lesson.id >= 100) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 12,
                          color: unitColor
                              .withOpacity(0.7), // Bỏ điều kiện isCurrent
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Học tiếng Việt thực hành',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w500, // Bỏ điều kiện isCurrent
                              color: unitColor
                                  .withOpacity(0.7), // Bỏ điều kiện isCurrent
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Progress/Status
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hoàn thành',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else if (isCurrent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      unitColor,
                      unitColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: unitColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hiện tại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else if (!isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Khóa',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Show "Sẵn sàng" for unlocked but not current lessons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: unitColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: unitColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sẵn sàng',
                      style: TextStyle(
                        color: unitColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToLessonDetail(
      BuildContext context, bool isUnlocked, bool isCompleted) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hoàn thành bài học trước để mở khóa bài này!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Determine if this is a Core Unit lesson (tutorial) or Life Theme lesson (interactive)
    final isCoreLessonUnit = lesson.id <= 16; // Lessons 1-16 are Core Units
    final isLifeThemeLesson = lesson.id >= 100; // Life Theme lessons are 100+

    if (isCoreLessonUnit) {
      // Core lessons are tutorial/information based
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CoreTutorialScreen(
            lesson: lesson,
            unitColor: unitColor,
            onLessonCompleted: onLessonCompleted,
            isCore: isCore,
          ),
        ),
      );
    } else if (isLifeThemeLesson) {
      // Life Theme lessons are interactive Duolingo-style lessons
      final unitNumber =
          (lesson.id ~/ 100); // 100-107 = Unit 1, 200-207 = Unit 2, etc.
      final lessonInUnit = lesson.id % 100; // 0-7 lessons in each unit

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LifeThemeLessonWidget(
            unitNumber: unitNumber,
            lessonNumber: lessonInUnit,
            unitTitle: lesson.title,
            unitColor: unitColor,
            onCompleted: () async {
              // Handle completion and XP gain
              await onLessonCompleted(lesson.id, isCore);
              Navigator.of(context).pop();
            },
            onExit: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } else {
      // Fallback for other lesson types
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonDetailScreen(
            lesson: lesson,
            unitColor: unitColor,
            onLessonCompleted: onLessonCompleted,
            isCore: isCore,
          ),
        ),
      );
    }
  }
}

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final Color unitColor;
  final Future<void> Function(int lessonId, bool isCore) onLessonCompleted;
  final bool isCore;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.unitColor,
    required this.onLessonCompleted,
    required this.isCore,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int currentExercise = 0;
  int totalExercises = 5;
  late List<Exercise> lessonExercises;

  @override
  void initState() {
    super.initState();
    lessonExercises = _getExercisesForLesson(widget.lesson.id);
    totalExercises = lessonExercises.length;
  }

  // Map exercises to specific lessons
  List<Exercise> _getExercisesForLesson(int lessonId) {
    switch (lessonId) {
      // ================================
      // CHƯƠNG 1: TỔNG QUAN VỀ TRƯỜNG
      // ================================
      case 1: // Ý nghĩa tên trường Hùng Vương
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Tên trường Hùng Vương được đặt theo ai?',
            options: [
              'Vua Hùng Vương - Quốc tổ dân tộc',
              'Anh hùng dân tộc',
              'Nhà văn nổi tiếng',
              'Nhà khoa học'
            ],
            correctAnswer: 0,
            vietnameseWord: 'Quốc tổ',
            pronunciation: '/kʷoːk⁵ to³/',
            explanation:
                'Được mang tên Quốc tổ là một vinh dự lớn cho Trường. Điều này động viên Thầy, Trò nhà Trường cố gắng dạy thật tốt, học thật tốt.',
            unitTheme: 'DHV_HERITAGE',
          ),
          Exercise(
            type: ExerciseType.wordCard,
            question: 'Từ này có nghĩa là gì?',
            options: ['University', 'College', 'School', 'Academy'],
            correctAnswer: 0,
            vietnameseWord: 'Đại học',
            pronunciation: '/ɗaːj⁵ hoɁ⁵/',
            imageUrl: 'assets/images/dhv_campus.jpg',
            explanation: 'Đại học là cơ sở giáo dục bậc cao nhất.',
            unitTheme: 'DHV_EDUCATION',
          ),
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Ngày truyền thống của trường DHV là ngày nào?',
            options: [
              '9 tháng 3',
              '9 tháng 5 âm lịch',
              '20 tháng 11',
              '2 tháng 9'
            ],
            correctAnswer: 1,
            vietnameseWord: 'Ngày truyền thống',
            pronunciation: '/ŋaːj¹ t͡ʃɯjən¹ toːŋ⁵/',
            explanation:
                'Ngày 9 tháng 5 âm lịch - ngày Giỗ Quốc tổ Hùng Vương làm ngày truyền thống của Trường.',
            unitTheme: 'DHV_TRADITION',
          ),
          Exercise(
            type: ExerciseType.fillInBlank,
            question: 'Trụ sở chính DHV tại _____ Nguyễn Trãi, Quận 5',
            options: ['736', '728', '740', '750'],
            correctAnswer: 0,
            vietnameseWord: '736 Nguyễn Trãi',
            pronunciation: '/baː ba ʃaw baː zɯk ŋwiən t͡ʃaːj/',
            explanation: 'Địa chỉ chính xác của trường DHV.',
            unitTheme: 'DHV_CAMPUS',
          ),
        ];

      case 2: // Lịch sử hình thành và phát triển (1995-2025)
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Trường Đại học Hùng Vương được thành lập năm nào?',
            options: ['1993', '1995', '1997', '2000'],
            correctAnswer: 1,
            vietnameseWord: 'Năm 1995',
            pronunciation: '/naːm⁵ t͡ʃiːn⁵ zaː³ baː³ lăm¹/',
            explanation:
                'Ngày 14/8/1995 Thủ tướng Chính phủ ban hành Quyết định số 470/TTg thành lập Trường Đại học Dân lập Hùng Vương.',
            unitTheme: 'DHV_HISTORY',
          ),
          Exercise(
            type: ExerciseType.fillInBlank,
            question:
                'Năm 2008, trường được đổi tên thành Trường Đại học Hùng Vương _____',
            options: ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Cần Thơ'],
            correctAnswer: 1,
            vietnameseWord: 'TP. Hồ Chí Minh',
            pronunciation: '/thaːn⁵ foː³ hoː¹ t͡ʃiː¹ min⁵/',
            explanation:
                'Ngày 14/05/2008 được đổi tên thành Trường Đại học Hùng Vương TP. Hồ Chí Minh.',
            unitTheme: 'DHV_EVOLUTION',
          ),
          Exercise(
            type: ExerciseType.multipleChoice,
            question:
                'Năm 2010, trường chuyển đổi từ dân lập sang loại hình nào?',
            options: ['Công lập', 'Tư thục', 'Bán công', 'Liên kết'],
            correctAnswer: 1,
            vietnameseWord: 'Tư thục',
            pronunciation: '/tɯ¹ thuk⁵/',
            explanation:
                'Ngày 19/05/2010 Thủ tướng ban hành Quyết định số 705/QĐ-TTg chuyển đổi từ dân lập sang tư thục.',
            unitTheme: 'DHV_STATUS',
          ),
        ];

      case 3: // Sứ mệnh - Tầm nhìn - Giá trị cốt lõi
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Cơ quan chủ quản của DHV là gì?',
            options: [
              'Bộ Công an',
              'Bộ Giáo dục và Đào tạo',
              'Bộ Nội vụ',
              'UBND TP.HCM'
            ],
            correctAnswer: 1,
            vietnameseWord: 'Bộ Giáo dục và Đào tạo',
            pronunciation: '/boː³ zaːw⁵ zuk⁵ vaː¹ ɗaːw⁵ taːw⁵/',
            explanation: 'DHV thuộc Bộ Giáo dục và Đào tạo quản lý.',
            unitTheme: 'DHV_MANAGEMENT',
          ),
          Exercise(
            type: ExerciseType.fillInBlank,
            question:
                'Các vua Hùng đã có công dựng nước, Bác cháu ta phải cùng nhau _____ nước',
            options: ['xây', 'giữ', 'yêu', 'bảo vệ'],
            correctAnswer: 1,
            vietnameseWord: 'Giữ nước',
            pronunciation: '/zɯ⁵ nɯək⁵/',
            explanation:
                'Lời Chủ tịch Hồ Chí Minh - kim chỉ nam của trường DHV.',
            unitTheme: 'DHV_MISSION',
          ),
        ];

      case 4: // Cơ sở vật chất và Campus
        return [
          Exercise(
            type: ExerciseType.fillInBlank,
            question: 'Trụ sở chính DHV tại số _____ Nguyễn Trãi, Quận 5',
            options: ['756', '758', '760', '762'],
            correctAnswer: 0,
            vietnameseWord: '756 Nguyễn Trãi',
            pronunciation: '/baː⁵ năm¹ ʃaw⁵ ŋɯiən¹ t͡ʃaːj¹/',
            explanation:
                'Địa chỉ chính xác: 756 Nguyễn Trãi, Phường 11, Quận 5, TP.HCM.',
            unitTheme: 'DHV_ADDRESS',
          ),
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Tượng Vua Hùng được dựng tại trụ sở nào?',
            options: [
              '756 Nguyễn Trãi',
              '680 Ngô Quyền',
              'Cơ sở 3',
              'Tất cả đều có'
            ],
            correctAnswer: 0,
            vietnameseWord: 'Tượng Vua Hùng',
            pronunciation: '/tɯəŋ⁵ vɯa¹ hʊŋ¹/',
            explanation:
                'Tượng Vua Hùng được dựng tại trụ sở chính 756 Nguyễn Trãi.',
            unitTheme: 'DHV_SYMBOL',
          ),
        ];

      case 5: // Hệ thống tổ chức và cơ cấu
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Từ "Xin chào" trong tiếng Việt có nghĩa là gì?',
            options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
            correctAnswer: 0,
            vietnameseWord: 'Xin chào',
            pronunciation: '/sin t͡ʃaːw/',
            explanation: 'Đây là cách chào hỏi phổ biến nhất trong tiếng Việt.',
            unitTheme: 'GREETINGS',
          ),
          Exercise(
            type: ExerciseType.fillInBlank,
            question: 'Điền từ còn thiếu: "Tôi _____ Mai"',
            options: ['tên', 'là', 'ở', 'có'],
            correctAnswer: 1,
            vietnameseWord: 'Tôi là Mai',
            pronunciation: '/toːj laː maj/',
            explanation: 'Động từ "là" dùng để giới thiệu tên hoặc danh tính.',
            unitTheme: 'INTRODUCTION',
          ),
        ];

      case 6: // Văn hóa truyền thống Việt Nam
        return [
          Exercise(
            type: ExerciseType.wordCard,
            question: 'Chọn nghĩa đúng của từ này:',
            options: ['Conical hat', 'Rice field', 'Bamboo', 'Temple'],
            correctAnswer: 0,
            vietnameseWord: 'Nón lá',
            pronunciation: '/noːn laː/',
            imageUrl: 'assets/images/non_la.jpg',
            explanation:
                'Nón lá là biểu tượng văn hóa truyền thống của Việt Nam.',
            unitTheme: 'CULTURE',
          ),
          Exercise(
            type: ExerciseType.pronunciation,
            question: 'Phát âm từ sau đây:',
            vietnameseWord: 'Cảm ơn',
            pronunciation: '/kaːm ʔən/',
            options: [],
            correctAnswer: 0,
            explanation: 'Cách cảm ơn lịch sự trong tiếng Việt.',
            unitTheme: 'POLITENESS',
          ),
        ];

      // ================================
      // CHƯƠNG 2: CHƯƠNG TRÌNH ĐÀO TẠO - KHOA KỸ THUẬT CÔNG NGHỆ
      // ================================
      case 9: // Chuẩn đầu ra ngoại ngữ - tin học
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question:
                'Chuẩn đầu ra ngoại ngữ của DHV yêu cầu sinh viên đạt trình độ nào?',
            options: [
              'TOEIC 450 hoặc tương đương',
              'IELTS 6.0',
              'TOEFL 80',
              'Không yêu cầu'
            ],
            correctAnswer: 0,
            vietnameseWord: 'TOEIC 450',
            pronunciation: '/toː¹ ik⁵ boːn¹ năm¹ mɯəj¹/',
            explanation:
                'Sinh viên DHV cần đạt TOEIC 450 điểm hoặc chứng chỉ tương đương để tốt nghiệp.',
            unitTheme: 'GRADUATION_REQUIREMENT',
          ),
          Exercise(
            type: ExerciseType.fillInBlank,
            question:
                'Chuẩn đầu ra tin học yêu cầu sinh viên có chứng chỉ _____ cơ bản',
            options: ['Microsoft Office', 'Adobe', 'AutoCAD', 'Photoshop'],
            correctAnswer: 0,
            vietnameseWord: 'Microsoft Office',
            pronunciation: '/maj¹ kʲɾo¹ sɔft⁵ ɔ¹ fis⁵/',
            explanation:
                'Sinh viên cần có chứng chỉ Microsoft Office cơ bản để tốt nghiệp.',
            unitTheme: 'IT_CERTIFICATION',
          ),
          Exercise(
            type: ExerciseType.flashcard,
            question: 'Thẻ từ vựng lập trình cơ bản:',
            flashcardSet: [
              FlashCard(
                front: 'Software',
                back: 'Phần mềm',
                pronunciation: '/faːn mem/',
                example: 'Sinh viên CNTT học lập trình phần mềm.',
                difficulty: 'beginner',
              ),
              FlashCard(
                front: 'Programming',
                back: 'Lập trình',
                pronunciation: '/lap t͡ʃin/',
                example: 'Lập trình là kỹ năng cốt lõi của sinh viên CNTT.',
                difficulty: 'beginner',
              ),
            ],
            options: [],
            correctAnswer: 0,
            vietnameseWord: 'Thuật ngữ CNTT',
            pronunciation: '/thwət ŋɯ koŋ ŋe thoŋ tin/',
            explanation: 'Những thuật ngữ cơ bản trong CNTT.',
            unitTheme: 'PROGRAMMING_BASICS',
          ),
        ];

      case 10: // Kỹ thuật Máy tính - IoT
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'CNTT là viết tắt của gì?',
            options: [
              'Công nghệ Thông tin',
              'Cơ sở Nữ Tu',
              'Căn nhà Trống trải',
              'Cửa Nam Thành'
            ],
            correctAnswer: 0,
            vietnameseWord: 'Công nghệ Thông tin',
            pronunciation: '/koŋ¹ ŋe⁵ tʰoŋ¹ tin¹/',
            explanation:
                'CNTT - Information Technology là ngành đào tạo chủ lực của Khoa Kỹ thuật Công nghệ.',
            unitTheme: 'IT_MAJOR',
          ),
          Exercise(
            type: ExerciseType.flashcard,
            question: 'Thẻ từ vựng chuyên ngành CNTT:',
            flashcardSet: [
              FlashCard(
                front: 'Software',
                back: 'Phần mềm',
                pronunciation: '/faːn¹ mɛm¹/',
                example: 'Sinh viên CNTT học lập trình phần mềm.',
                difficulty: 'beginner',
              ),
              FlashCard(
                front: 'Database',
                back: 'Cơ sở dữ liệu',
                pronunciation: '/kəː¹ səː³ zɯ⁵ lieu⁵/',
                example: 'Cơ sở dữ liệu lưu trữ thông tin của hệ thống.',
                difficulty: 'intermediate',
              ),
              FlashCard(
                front: 'Network',
                back: 'Mạng máy tính',
                pronunciation: '/maːŋ⁵ maːj¹ tin⁵/',
                example: 'Mạng máy tính kết nối các thiết bị với nhau.',
                difficulty: 'beginner',
              ),
            ],
            options: [],
            correctAnswer: 0,
            vietnameseWord: 'Thuật ngữ CNTT',
            pronunciation: '/tʰwət̚⁵ ŋɯ⁵ koŋ¹ ŋe⁵ tʰoŋ¹ tin¹/',
            explanation: 'Những thuật ngữ cơ bản trong ngành CNTT.',
            unitTheme: 'IT_VOCABULARY',
          ),
        ];

      // ================================
      // LIFE THEME UNITS - Independent Vietnamese Learning
      // ================================
      case 100: // Bố mẹ và anh chị em (Life Theme Unit 1)
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: '"Bố" trong tiếng Việt có nghĩa là gì?',
            options: ['Father', 'Mother', 'Brother', 'Uncle'],
            correctAnswer: 0,
            vietnameseWord: 'Bố',
            pronunciation: '/boː/',
            explanation: 'Cách gọi thân mật với cha trong gia đình.',
            unitTheme: 'FAMILY_FATHER',
          ),
          Exercise(
            type: ExerciseType.flashcard,
            question: 'Thẻ từ vựng gia đình:',
            flashcardSet: [
              FlashCard(
                front: 'Mother',
                back: 'Mẹ',
                pronunciation: '/me/',
                example: 'Mẹ tôi nấu ăn rất ngon.',
                difficulty: 'beginner',
              ),
              FlashCard(
                front: 'Elder brother',
                back: 'Anh trai',
                pronunciation: '/an t͡ʃaj/',
                example: 'Anh trai tôi đang học đại học.',
                difficulty: 'beginner',
              ),
            ],
            options: [],
            correctAnswer: 0,
            vietnameseWord: 'Gia đình',
            pronunciation: '/za din/',
            explanation: 'Từ vựng cơ bản về thành viên gia đình.',
            unitTheme: 'FAMILY_MEMBERS',
          ),
        ];

      case 200: // Phở, bánh mì (Life Theme Unit 2)
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Món ăn nào là đặc sản nổi tiếng của Việt Nam?',
            options: ['Pizza', 'Phở', 'Sushi', 'Hamburger'],
            correctAnswer: 1,
            vietnameseWord: 'Phở',
            pronunciation: '/fɤː/',
            explanation: 'Phở là món ăn truyền thống đặc trưng của Việt Nam.',
            unitTheme: 'VIETNAMESE_FOOD',
          ),
          Exercise(
            type: ExerciseType.wordCard,
            question: 'Món ăn này là gì?',
            options: ['Bread', 'Sandwich', 'Vietnamese sandwich', 'Burger'],
            correctAnswer: 2,
            vietnameseWord: 'Bánh mì',
            pronunciation: '/ban mi/',
            imageUrl: 'assets/images/banh_mi.jpg',
            explanation: 'Bánh mì Việt Nam - món ăn đường phố phổ biến.',
            unitTheme: 'STREET_FOOD',
          ),
        ];

      case 300: // Các nghề nghiệp phổ biến (Life Theme Unit 3)
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Nghề nghiệp nào liên quan đến máy tính?',
            options: ['Bác sĩ', 'Lập trình viên', 'Giáo viên', 'Nông dân'],
            correctAnswer: 1,
            vietnameseWord: 'Lập trình viên',
            pronunciation: '/lap t͡ʃin vien/',
            explanation: 'Người viết code và phát triển phần mềm.',
            unitTheme: 'IT_JOBS',
          ),
          Exercise(
            type: ExerciseType.flashcard,
            question: 'Thẻ từ vựng nghề nghiệp:',
            flashcardSet: [
              FlashCard(
                front: 'Teacher',
                back: 'Giáo viên',
                pronunciation: '/zaːo vien/',
                example: 'Giáo viên dạy học ở trường.',
                difficulty: 'beginner',
              ),
              FlashCard(
                front: 'Doctor',
                back: 'Bác sĩ',
                pronunciation: '/bak ʃi/',
                example: 'Bác sĩ chữa bệnh cho người dân.',
                difficulty: 'beginner',
              ),
            ],
            options: [],
            correctAnswer: 0,
            vietnameseWord: 'Nghề nghiệp',
            pronunciation: '/ŋe ŋiep/',
            explanation: 'Các nghề nghiệp phổ biến trong xã hội.',
            unitTheme: 'CAREERS',
          ),
        ];

      case 400: // Thể thao và tập luyện (Life Theme Unit 4)
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Hoạt động nào là thể thao?',
            options: ['Xem TV', 'Đá bóng', 'Nghe nhạc', 'Nấu ăn'],
            correctAnswer: 1,
            vietnameseWord: 'Đá bóng',
            pronunciation: '/daː boŋ/',
            explanation: 'Môn thể thao vua được yêu thích ở Việt Nam.',
            unitTheme: 'SPORTS',
          ),
          Exercise(
            type: ExerciseType.matching,
            question: 'Ghép môn thể thao với tiếng Việt:',
            options: ['Football', 'Basketball', 'Swimming', 'Running'],
            matchingPairs: ['Đá bóng', 'Bóng rổ', 'Bơi lội', 'Chạy bộ'],
            correctAnswer: 0,
            vietnameseWord: 'Đá bóng',
            pronunciation: '/daː boŋ/',
            explanation: 'Các môn thể thao phổ biến.',
            unitTheme: 'SPORTS_TYPES',
          ),
        ];

      case 500: // Các bộ phận cơ thể (Life Theme Unit 5)
        return [
          Exercise(
            type: ExerciseType.wordCard,
            question: 'Bộ phận cơ thể này là gì?',
            options: ['Hand', 'Foot', 'Eye', 'Ear'],
            correctAnswer: 2,
            vietnameseWord: 'Mắt',
            pronunciation: '/mat/',
            imageUrl: 'assets/images/eye.jpg',
            explanation: 'Cơ quan thị giác quan trọng của con người.',
            unitTheme: 'BODY_PARTS',
          ),
          Exercise(
            type: ExerciseType.flashcard,
            question: 'Thẻ từ vựng bộ phận cơ thể:',
            flashcardSet: [
              FlashCard(
                front: 'Head',
                back: 'Đầu',
                pronunciation: '/ɗəw/',
                example: 'Đầu chứa não bộ của con người.',
                difficulty: 'beginner',
              ),
              FlashCard(
                front: 'Heart',
                back: 'Tim',
                pronunciation: '/tim/',
                example: 'Tim đập để bơm máu.',
                difficulty: 'beginner',
              ),
            ],
            options: [],
            correctAnswer: 0,
            vietnameseWord: 'Cơ thể',
            pronunciation: '/kə the/',
            explanation: 'Các bộ phận cơ thể con người.',
            unitTheme: 'HUMAN_BODY',
          ),
        ];

      case 600: // Quần áo và thời trang (Life Theme Unit 6)
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Từ "áo" trong tiếng Việt có nghĩa là gì?',
            options: ['Pants', 'Shirt', 'Shoes', 'Hat'],
            correctAnswer: 1,
            vietnameseWord: 'Áo',
            pronunciation: '/aːo/',
            explanation: 'Quần áo là đồ mặc hàng ngày.',
            unitTheme: 'CLOTHING',
          ),
          Exercise(
            type: ExerciseType.dialoguePractice,
            question: 'Hội thoại: Mua quần áo',
            dialogue: [
              DialogueLine(
                speaker: 'Khách hàng',
                text: 'Tôi muốn mua một cái áo.',
                translation: 'I want to buy a shirt.',
              ),
              DialogueLine(
                speaker: 'Nhân viên',
                text: 'Bạn muốn màu gì và size nào?',
                translation: 'What color and size do you want?',
              ),
            ],
            options: [
              'Màu đỏ, size M',
              'Màu xanh, size L',
              'Màu đen, size S',
              'Tôi sẽ xem thêm'
            ],
            correctAnswer: 0,
            vietnameseWord: 'Màu đỏ, size M',
            pronunciation: '/maːw ɗoː saj em/',
            explanation: 'Cách đặt hàng khi mua quần áo.',
            unitTheme: 'SHOPPING_CLOTHES',
          ),
        ];

      default:
        // Default exercises for lessons without specific content
        return [
          Exercise(
            type: ExerciseType.multipleChoice,
            question: 'Bài học này đang được phát triển. Chọn đáp án đúng:',
            options: [
              'Đang cập nhật',
              'Sẽ có sớm',
              'Vui lòng chờ',
              'Tất cả đều đúng'
            ],
            correctAnswer: 3,
            vietnameseWord: 'Đang phát triển',
            pronunciation: '/ɗaŋ fat t͡ʃien/',
            explanation:
                'Nội dung bài học sẽ được cập nhật trong phiên bản tiếp theo.',
            unitTheme: 'UNDER_DEVELOPMENT',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progress = (currentExercise + 1) / totalExercises;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: CustomAppBar(
        title: widget.lesson.title,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // Add scroll to prevent overflow
              padding: const EdgeInsets.all(20),
              child: ExerciseWidget(
                exercise: lessonExercises[currentExercise],
                unitColor: widget.unitColor,
                isDarkMode: isDarkMode,
                onAnswer: _handleAnswer,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              '${currentExercise + 1}/$totalExercises',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAnswer(bool isCorrect) {
    if (isCorrect) {
      if (currentExercise < totalExercises - 1) {
        setState(() {
          currentExercise++;
        });
      } else {
        // Lesson completed
        _showCompletionDialog();
      }
    } else {
      // Show incorrect feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sai rồi! Hãy thử lại.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: widget.unitColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chúc mừng!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn đã hoàn thành bài học này!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Close this simple dialog first
                Navigator.pop(context);

                // Navigate back to lesson list first
                if (mounted) {
                  Navigator.pop(context);
                }

                // Wait a bit for navigation to complete
                await Future.delayed(const Duration(milliseconds: 300));

                // Call the completion callback which will show the celebration dialog
                await widget.onLessonCompleted(widget.lesson.id, widget.isCore);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.unitColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================
// CORE TUTORIAL SCREEN - DHV UNIVERSITY GUIDE
// ===============================================
class CoreTutorialScreen extends StatefulWidget {
  final Lesson lesson;
  final Color unitColor;
  final Future<void> Function(int lessonId, bool isCore) onLessonCompleted;
  final bool isCore;

  const CoreTutorialScreen({
    super.key,
    required this.lesson,
    required this.unitColor,
    required this.onLessonCompleted,
    required this.isCore,
  });

  @override
  State<CoreTutorialScreen> createState() => _CoreTutorialScreenState();
}

class _CoreTutorialScreenState extends State<CoreTutorialScreen>
    with TickerProviderStateMixin, TTSCapability {
  late FlutterTts flutterTts;
  late TutorialContent tutorialContent;
  late List<DHVLearningCard> learningCards;
  late AnimationController _animationController;
  late TabController _cardTabController;
  final UniversalTtsService _universalTts = UniversalTtsService();

  int currentSection = 0;
  bool isPlaying = false;
  bool _disposed = false;
  int selectedCardIndex = 0;
  PageController pageController = PageController();
  final bool _showTTSHelper = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initUniversalTTS();
    tutorialContent = _getTutorialContent(widget.lesson.id);
    learningCards = _createLearningCards(widget.lesson.id);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardTabController = TabController(
      length: 4, // 4 types of cards
      vsync: this,
    );

    _animationController.forward();
  }

  void _initTts() {
    flutterTts = FlutterTts();
    _configureTts();
  }

  Future<void> _initUniversalTTS() async {
    await _universalTts.initialize();
    _universalTts.setCallbacks(
      onSpeechStart: () {
        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }
      },
      onSpeechComplete: () {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      },
      onSpeechError: (error) {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      },
    );
  }

  Future<void> _configureTts() async {
    if (_disposed) return;
    try {
      await flutterTts.setLanguage("vi-VN");
      await flutterTts.setSpeechRate(0.6);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      print('TTS configuration error: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (_disposed) return;
    await _universalTts.quickSpeak(text);
  }

  // Tạo 4 loại learning cards cho mỗi bài học DHV
  List<DHVLearningCard> _createLearningCards(int lessonId) {
    switch (lessonId) {
      case 1: // Lịch sử 30 năm DHV
        return [
          // VISUAL CARD - Hình ảnh và thông tin trực quan
          DHVLearningCard(
            title: "Hành trình 30 năm",
            subtitle: "Từ 1995 đến nay",
            type: DHVCardType.visual,
            content:
                "Khám phá lịch sử phát triển của Đại học Hùng Vương qua 30 năm với những cột mốc quan trọng.",
            highlights: [
              "1995: Thành lập trường",
              "2000: Mở rộng cơ sở",
              "2010: Đạt chuẩn chất lượng",
              "2020: Chuyển đổi số",
              "2025: Kỷ niệm 30 năm"
            ],
            imageUrl: "assets/images/dhv_timeline.jpg",
            interactiveElements: [
              InteractiveElement(
                type: 'timeline',
                title: 'Timeline phát triển',
                data: {
                  'events': [
                    {
                      'year': '1995',
                      'event': 'Thành lập trường',
                      'detail': 'DHV được thành lập tại TP.HCM'
                    },
                    {
                      'year': '2000',
                      'event': 'Mở rộng cơ sở',
                      'detail': 'Xây dựng cơ sở 2 tại Ngô Quyền'
                    },
                    {
                      'year': '2010',
                      'event': 'Đạt chuẩn',
                      'detail': 'Được công nhận chất lượng giáo dục'
                    },
                    {
                      'year': '2020',
                      'event': 'Chuyển đổi số',
                      'detail': 'Áp dụng công nghệ trong giảng dạy'
                    },
                    {
                      'year': '2025',
                      'event': 'Kỷ niệm 30 năm',
                      'detail': 'Celebration milestone'
                    }
                  ]
                },
                color: const Color(0xFF1E88E5),
              ),
            ],
          ),

          // AUDIO CARD - Âm thanh và phát âm
          DHVLearningCard(
            title: "Nghe và phát âm",
            subtitle: "Học cách nói về lịch sử",
            type: DHVCardType.audio,
            content:
                "Luyện phát âm các từ khóa quan trọng về lịch sử trường DHV.",
            highlights: [
              "Đại học Hùng Vương",
              "Thành lập năm 1995",
              "Ba mười năm phát triển",
              "Truyền thống giáo dục"
            ],
            audioText:
                "Trường Đại học Hùng Vương được thành lập vào năm một nghìn chín trăm chín mười lăm tại thành phố Hồ Chí Minh.",
            interactiveElements: [
              InteractiveElement(
                type: 'pronunciation',
                title: 'Thực hành phát âm',
                data: [
                  {
                    'word': 'Đại học',
                    'ipa': '/ɗaːj hoɁ/',
                    'meaning': 'University'
                  },
                  {
                    'word': 'Thành lập',
                    'ipa': '/thaːn lap/',
                    'meaning': 'Establish'
                  },
                  {
                    'word': 'Phát triển',
                    'ipa': '/fat t͡ʃien/',
                    'meaning': 'Development'
                  },
                ],
              ),
            ],
          ),

          // INTERACTIVE CARD - Tương tác và quiz
          DHVLearningCard(
            title: "Kiểm tra kiến thức",
            subtitle: "Quiz tương tác về DHV",
            type: DHVCardType.interactive,
            content:
                "Trả lời các câu hỏi để kiểm tra hiểu biết về lịch sử trường.",
            highlights: [
              "5 câu hỏi trắc nghiệm",
              "Có giải thích đáp án",
              "Điểm số thời gian thực",
              "Thử thách bạn bè"
            ],
            interactiveElements: [
              InteractiveElement(
                type: 'quiz',
                title: 'Mini Quiz',
                data: {
                  'questions': [
                    {
                      'question': 'DHV được thành lập năm nào?',
                      'options': ['1993', '1995', '1997', '2000'],
                      'correct': 1,
                      'explanation':
                          'DHV được thành lập năm 1995, đã gần 30 năm phát triển.'
                    },
                    {
                      'question': 'DHV có mấy cơ sở tại TP.HCM?',
                      'options': ['1', '2', '3', '4'],
                      'correct': 1,
                      'explanation': 'DHV có 2 cơ sở: Nguyễn Trãi và Ngô Quyền.'
                    }
                  ]
                },
              ),
            ],
          ),

          // INFO CARD - Thông tin chi tiết và số liệu
          DHVLearningCard(
            title: "Thông tin chi tiết",
            subtitle: "Số liệu và thành tích",
            type: DHVCardType.info,
            content:
                "Các thông tin chi tiết về thành tích và con số ấn tượng của DHV.",
            highlights: [
              "3000+ sinh viên đang học",
              "150+ giảng viên chất lượng",
              "95% tỷ lệ có việc làm",
              "50+ doanh nghiệp đối tác"
            ],
            interactiveElements: [
              InteractiveElement(
                type: 'stats',
                title: 'Thống kê DHV',
                data: {
                  'stats': [
                    {
                      'label': 'Sinh viên',
                      'value': '3000+',
                      'icon': 'school',
                      'color': 0xFF4CAF50
                    },
                    {
                      'label': 'Giảng viên',
                      'value': '150+',
                      'icon': 'person',
                      'color': 0xFF2196F3
                    },
                    {
                      'label': 'Tỷ lệ việc làm',
                      'value': '95%',
                      'icon': 'work',
                      'color': 0xFFFF9800
                    },
                    {
                      'label': 'Đối tác',
                      'value': '50+',
                      'icon': 'business',
                      'color': 0xFF9C27B0
                    },
                  ]
                },
              ),
            ],
          ),
        ];

      case 2: // Campus và cơ sở vật chất
        return [
          DHVLearningCard(
            title: "Tour ảo Campus",
            subtitle: "Khám phá cơ sở vật chất",
            type: DHVCardType.visual,
            content: "Tham quan các cơ sở của DHV qua hình ảnh và video 360°.",
            highlights: [
              "Cơ sở 1: 736 Nguyễn Trãi",
              "Cơ sở 2: 140 Ngô Quyền",
              "Thư viện hiện đại",
              "Phòng lab công nghệ"
            ],
            imageUrl: "assets/images/dhv_campus_tour.jpg",
            interactiveElements: [
              InteractiveElement(
                type: 'gallery',
                title: 'Thư viện ảnh Campus',
                data: {
                  'images': [
                    {
                      'url': 'assets/images/campus1.jpg',
                      'title': 'Cổng chính cơ sở 1'
                    },
                    {
                      'url': 'assets/images/campus2.jpg',
                      'title': 'Thư viện trường'
                    },
                    {'url': 'assets/images/lab.jpg', 'title': 'Phòng lab CNTT'},
                    {
                      'url': 'assets/images/classroom.jpg',
                      'title': 'Phòng học hiện đại'
                    },
                  ]
                },
              ),
            ],
          ),
          DHVLearningCard(
            title: "Từ vựng Campus",
            subtitle: "Học từ vựng về cơ sở vật chất",
            type: DHVCardType.audio,
            content:
                "Học các từ vựng quan trọng liên quan đến campus và cơ sở vật chất.",
            highlights: [
              "Thư viện - Library",
              "Phòng lab - Laboratory",
              "Căng-tin - Canteen",
              "Sân vận động - Stadium"
            ],
            audioText:
                "Campus DHV có đầy đủ tiện ích như thư viện, phòng lab, căng-tin và sân thể thao.",
          ),
          DHVLearningCard(
            title: "Tìm đường trong trường",
            subtitle: "Trò chơi định hướng",
            type: DHVCardType.interactive,
            content:
                "Thử thách tìm đường và định vị các địa điểm trong campus DHV.",
            highlights: [
              "Bản đồ tương tác",
              "Tìm phòng học",
              "Định vị tiện ích",
              "Thách thức thời gian"
            ],
            interactiveElements: [
              InteractiveElement(
                type: 'map',
                title: 'Bản đồ DHV',
                data: {
                  'locations': [
                    {
                      'name': 'Văn phòng Khoa CNTT',
                      'floor': '2',
                      'building': 'A'
                    },
                    {
                      'name': 'Thư viện trung tâm',
                      'floor': '1',
                      'building': 'B'
                    },
                    {'name': 'Phòng lab IoT', 'floor': '3', 'building': 'A'},
                    {
                      'name': 'Căng-tin sinh viên',
                      'floor': '1',
                      'building': 'C'
                    },
                  ]
                },
              ),
            ],
          ),
          DHVLearningCard(
            title: "Tiện ích Campus",
            subtitle: "Dịch vụ và hỗ trợ sinh viên",
            type: DHVCardType.info,
            content:
                "Tìm hiểu về các tiện ích và dịch vụ hỗ trợ sinh viên tại DHV.",
            highlights: [
              "WiFi miễn phí toàn campus",
              "Thư viện mở 24/7",
              "Căng-tin đa dạng món ăn",
              "Khu vực nghỉ ngơi"
            ],
          ),
        ];

      default:
        // Default cards cho các bài học khác
        return [
          DHVLearningCard(
            title: "Đang phát triển",
            subtitle: "Nội dung sẽ có sớm",
            type: DHVCardType.info,
            content:
                "Bài học này đang được phát triển với nhiều tính năng tương tác mới.",
            highlights: ["Đang cập nhật"],
          ),
        ];
    }
  }

  TutorialContent _getTutorialContent(int lessonId) {
    switch (lessonId) {
      case 1: // Lịch sử 30 năm DHV
        return TutorialContent(
          title: 'Lịch sử 30 năm Đại học Hùng Vương',
          content:
              '''Trường Đại học Hùng Vương được thành lập vào năm 1995 tại thành phố Hồ Chí Minh. Sau gần 30 năm xây dựng và phát triển, DHV đã trở thành một trong những trường đại học uy tín tại Việt Nam.

Trường được đặt theo tên của vua Hùng Vương - vị vua đầu tiên của dân tộc Việt Nam, thể hiện truyền thống và văn hóa dân tộc. Với phương châm "Đào tạo nhân tài - Phục vụ xã hội", DHV cam kết mang đến chất lượng giáo dục tốt nhất.

Qua các năm, trường đã đào tạo hàng nghìn sinh viên trong nhiều lĩnh vực khác nhau, đặc biệt mạnh về công nghệ thông tin và kỹ thuật.''',
          imageUrl: 'assets/images/dhv_history.jpg',
          keyPoints: [
            'Thành lập năm 1995',
            'Gần 30 năm phát triển',
            'Đặt tên theo vua Hùng Vương',
            'Phương châm: Đào tạo nhân tài - Phục vụ xã hội',
            'Mạnh về công nghệ thông tin'
          ],
          audioText:
              'Trường Đại học Hùng Vương được thành lập vào năm một nghìn chín trăm chín mười lăm tại thành phố Hồ Chí Minh. Sau gần ba mười năm xây dựng và phát triển, DHV đã trở thành một trong những trường đại học uy tín tại Việt Nam.',
          vocabulary: {
            'Thành lập': 'Established',
            'Phát triển': 'Development',
            'Uy tín': 'Prestigious',
            'Truyền thống': 'Tradition',
            'Chất lượng': 'Quality'
          },
        );

      case 2: // Campus và cơ sở vật chất
        return TutorialContent(
          title: 'Campus và Cơ sở vật chất DHV',
          content:
              '''Đại học Hùng Vương hiện có hai cơ sở chính tại thành phố Hồ Chí Minh:

Cơ sở 1: 736 Nguyễn Trãi, Quận 5 - Đây là trụ sở chính của trường, nơi đặt văn phòng ban giám hiệu và các phòng ban chức năng.

Cơ sở 2: 140 Ngô Quyền, Quận 5 - Khu vực này tập trung các phòng học, thí nghiệm và hoạt động đào tạo.

Cả hai cơ sở đều được trang bị đầy đủ tiện ích hiện đại như thư viện, phòng máy tính, phòng thí nghiệm chuyên ngành, khu vực sinh hoạt sinh viên và căng-tin.''',
          imageUrl: 'assets/images/dhv_campus.jpg',
          keyPoints: [
            '2 cơ sở tại TP.HCM',
            'Cơ sở 1: 736 Nguyễn Trãi, Q.5',
            'Cơ sở 2: 140 Ngô Quyền, Q.5',
            'Trang bị tiện ích hiện đại',
            'Thư viện và phòng thí nghiệm'
          ],
          audioText:
              'Đại học Hùng Vương hiện có hai cơ sở chính tại thành phố Hồ Chí Minh. Cơ sở một tại bảy ba sáu Nguyễn Trãi, Quận năm. Cơ sở hai tại một bốn không Ngô Quyền, Quận năm.',
          vocabulary: {
            'Cơ sở': 'Campus',
            'Trụ sở': 'Headquarters',
            'Tiện ích': 'Facilities',
            'Thư viện': 'Library',
            'Phòng thí nghiệm': 'Laboratory'
          },
        );

      case 9: // Chuyên ngành CNTT
        return TutorialContent(
          title: 'Chuyên ngành Công nghệ Thông tin',
          content:
              '''Khoa Kỹ thuật Công nghệ của DHV cung cấp chương trình đào tạo chuyên ngành Công nghệ Thông tin (CNTT) với chất lượng cao.

Chương trình CNTT tại DHV được thiết kế để đáp ứng nhu cầu thực tế của thị trường lao động. Sinh viên sẽ được học các môn học cơ bản như lập trình, cơ sở dữ liệu, mạng máy tính, và các môn chuyên sâu như trí tuệ nhân tạo, phát triển web, ứng dụng di động.

Đặc biệt, nhà trường chú trọng đào tạo thực hành với các dự án thực tế, giúp sinh viên có kinh nghiệm làm việc ngay sau khi tốt nghiệp.''',
          imageUrl: 'assets/images/it_department.jpg',
          keyPoints: [
            'Chương trình CNTT chất lượng cao',
            'Đáp ứng nhu cầu thị trường',
            'Học từ cơ bản đến chuyên sâu',
            'Trọng tâm đào tạo thực hành',
            'Dự án thực tế'
          ],
          audioText:
              'Khoa Kỹ thuật Công nghệ của DHV cung cấp chương trình đào tạo chuyên ngành Công nghệ Thông tin với chất lượng cao. Sinh viên sẽ được học các môn học cơ bản như lập trình, cơ sở dữ liệu, mạng máy tính.',
          vocabulary: {
            'Công nghệ Thông tin': 'Information Technology',
            'Lập trình': 'Programming',
            'Cơ sở dữ liệu': 'Database',
            'Mạng máy tính': 'Computer Network',
            'Trí tuệ nhân tạo': 'Artificial Intelligence'
          },
        );

      case 10: // Kỹ thuật Máy tính - IoT
        return TutorialContent(
          title: 'Kỹ thuật Máy tính - IoT & Embedded',
          content:
              '''Chuyên ngành Kỹ thuật Máy tính tại DHV tập trung vào hai lĩnh vực tiên tiến: Internet of Things (IoT) và Hệ thống nhúng (Embedded Systems).

IoT - Vạn vật kết nối: Sinh viên sẽ học cách kết nối các thiết bị thông minh, từ cảm biến đến hệ thống điều khiển thông minh trong nhà, xe hơi, và thành phố thông minh.

Hệ thống nhúng: Tập trung vào lập trình và thiết kế các hệ thống máy tính được tích hợp vào các thiết bị khác như điện thoại, xe hơi, thiết bị y tế.

Đây là những ngành học có triển vọng cao trong thời đại công nghệ 4.0.''',
          imageUrl: 'assets/images/iot_lab.jpg',
          keyPoints: [
            'Chuyên về IoT và Embedded',
            'IoT - Vạn vật kết nối',
            'Hệ thống nhúng',
            'Ứng dụng thực tế cao',
            'Triển vọng thời đại 4.0'
          ],
          audioText:
              'Chuyên ngành Kỹ thuật Máy tính tại DHV tập trung vào hai lĩnh vực tiên tiến: Internet of Things và Hệ thống nhúng. Đây là những ngành học có triển vọng cao trong thời đại công nghệ bốn chấm không.',
          vocabulary: {
            'Kỹ thuật Máy tính': 'Computer Engineering',
            'IoT': 'Internet of Things',
            'Hệ thống nhúng': 'Embedded Systems',
            'Cảm biến': 'Sensor',
            'Thành phố thông minh': 'Smart City'
          },
        );

      case 3: // Giá trị và sứ mệnh trường
        return TutorialContent(
          title: 'Giá trị và Sứ mệnh Đại học Hùng Vương',
          content:
              '''Đại học Hùng Vương được xây dựng trên những giá trị cốt lõi và sứ mệnh rõ ràng:

SỨ MỆNH: "Đào tạo nhân tài - Phục vụ xã hội"
DHV cam kết đào tạo những con người có tri thức, kỹ năng và phẩm chất đạo đức cao, đóng góp tích cực cho sự phát triển của xã hội.

GIÁ TRỊ CỐT LÕI:
- Chất lượng: Luôn đặt chất lượng giáo dục lên hàng đầu
- Sáng tạo: Khuyến khích tư duy sáng tạo và đổi mới
- Trách nhiệm: Có trách nhiệm với sinh viên và xã hội
- Phát triển bền vững: Hướng tới sự phát triển lâu dài

TẦM NHÌN: Trở thành trường đại học hàng đầu về công nghệ và kỹ thuật tại Việt Nam.''',
          imageUrl: 'assets/images/dhv_mission.jpg',
          keyPoints: [
            'Sứ mệnh: Đào tạo nhân tài - Phục vụ xã hội',
            'Giá trị: Chất lượng, Sáng tạo, Trách nhiệm',
            'Tầm nhìn: Trường hàng đầu về công nghệ',
            'Phát triển bền vững',
            'Phục vụ cộng đồng'
          ],
          audioText:
              'Đại học Hùng Vương có sứ mệnh đào tạo nhân tài phục vụ xã hội. Giá trị cốt lõi bao gồm chất lượng, sáng tạo, trách nhiệm và phát triển bền vững.',
          vocabulary: {
            'Sứ mệnh': 'Mission',
            'Giá trị cốt lõi': 'Core Values',
            'Tầm nhìn': 'Vision',
            'Nhân tài': 'Talent',
            'Bền vững': 'Sustainable'
          },
        );

      case 4: // Cộng đồng DHV
        return TutorialContent(
          title: 'Cộng đồng DHV - Sinh viên và Giảng viên',
          content:
              '''Cộng đồng Đại học Hùng Vương là một gia đình lớn gồm sinh viên, giảng viên và cán bộ nhân viên.

SINH VIÊN DHV:
- Hiện tại trường có hơn 3.000 sinh viên đang theo học
- Đến từ khắp các tỉnh thành trên cả nước
- Tích cực tham gia các hoạt động học thuật và ngoại khóa
- Tinh thần đoàn kết, hỗ trợ lẫn nhau

ĐỘI NGŨ GIẢNG VIÊN:
- Hơn 150 giảng viên có trình độ cao
- Nhiều Tiến sĩ, Thạc sĩ trong các lĩnh vực chuyên môn
- Kinh nghiệm giảng dạy và nghiên cứu phong phú
- Tận tâm với công việc giáo dục

MÔI TRƯỜNG HỌC TẬP:
- Thân thiện, cởi mở
- Khuyến khích sự sáng tạo và phát triển
- Hỗ trợ sinh viên toàn diện''',
          imageUrl: 'assets/images/dhv_community.jpg',
          keyPoints: [
            'Hơn 3.000 sinh viên',
            'Hơn 150 giảng viên chất lượng',
            'Cộng đồng đoàn kết',
            'Môi trường thân thiện',
            'Hỗ trợ toàn diện'
          ],
          audioText:
              'Cộng đồng Đại học Hùng Vương gồm hơn ba nghìn sinh viên và hơn một trăm năm mười giảng viên. Đây là một môi trường học tập thân thiện và đoàn kết.',
          vocabulary: {
            'Cộng đồng': 'Community',
            'Giảng viên': 'Lecturer',
            'Sinh viên': 'Student',
            'Đoàn kết': 'United',
            'Tận tâm': 'Dedicated'
          },
        );

      case 11: // Phòng Lab và Thiết bị
        return TutorialContent(
          title: 'Phòng Lab và Thiết bị hiện đại',
          content:
              '''Khoa Kỹ thuật Công nghệ DHV được trang bị các phòng thí nghiệm và thiết bị hiện đại để phục vụ việc giảng dạy và nghiên cứu.

PHÒNG THÍ NGHIỆM CNTT:
- Phòng máy tính với hơn 100 máy tính hiện đại
- Cấu hình mạnh phục vụ lập trình và thiết kế
- Phần mềm chuyên ngành được cập nhật thường xuyên

PHÒNG LAB IoT VÀ EMBEDDED:
- Arduino, Raspberry Pi và các board mạch chuyên dụng
- Cảm biến và thiết bị IoT đa dạng
- Môi trường thực hành dự án thực tế

PHÒNG LAB MẠNG:
- Thiết bị mạng Cisco, Router, Switch
- Mô phỏng các mô hình mạng thực tế
- Đào tạo chứng chỉ quốc tế

Tất cả đều được bảo trì và nâng cấp định kỳ để đảm bảo chất lượng học tập tốt nhất.''',
          imageUrl: 'assets/images/tech_lab.jpg',
          keyPoints: [
            'Phòng máy tính 100+ máy hiện đại',
            'Lab IoT với Arduino, Raspberry Pi',
            'Lab mạng với thiết bị Cisco',
            'Phần mềm chuyên ngành',
            'Bảo trì nâng cấp định kỳ'
          ],
          audioText:
              'Khoa Kỹ thuật Công nghệ DHV có phòng máy tính với hơn một trăm máy hiện đại, phòng lab IoT với Arduino và Raspberry Pi, cùng phòng lab mạng với thiết bị Cisco.',
          vocabulary: {
            'Phòng thí nghiệm': 'Laboratory',
            'Thiết bị': 'Equipment',
            'Cấu hình': 'Configuration',
            'Cảm biến': 'Sensor',
            'Nâng cấp': 'Upgrade'
          },
        );

      case 12: // Đào tạo thực hành
        return TutorialContent(
          title: 'Đào tạo thực hành - Dự án thực tế',
          content:
              '''DHV đặc biệt chú trọng đào tạo thực hành và kết nối với doanh nghiệp để sinh viên có kinh nghiệm thực tế.

PHƯƠNG PHÁP ĐÀO TẠO:
- 50% lý thuyết - 50% thực hành
- Dự án từng môn học gắn với thực tế
- Làm việc nhóm và thuyết trình

ĐỐI TÁC DOANH NGHIỆP:
- Hợp tác với các công ty công nghệ lớn
- Sinh viên được thực tập tại doanh nghiệp
- Cơ hội việc làm sau tốt nghiệp

DỰ ÁN SINH VIÊN:
- Website thương mại điện tử
- Ứng dụng di động
- Hệ thống IoT thông minh
- Trí tuệ nhân tạo ứng dụng

CHỨNG CHỈ QUỐC TẾ:
- AWS, Google Cloud
- Cisco Networking
- Microsoft Certified
- Oracle Database''',
          imageUrl: 'assets/images/practical_training.jpg',
          keyPoints: [
            '50% lý thuyết - 50% thực hành',
            'Hợp tác với doanh nghiệp',
            'Dự án thực tế đa dạng',
            'Chứng chỉ quốc tế',
            'Cơ hội việc làm cao'
          ],
          audioText:
              'DHV đào tạo với tỷ lệ năm mười phần trăm lý thuyết và năm mười phần trăm thực hành. Sinh viên làm dự án thực tế và có cơ hội thực tập tại doanh nghiệp.',
          vocabulary: {
            'Thực hành': 'Practice',
            'Dự án': 'Project',
            'Doanh nghiệp': 'Enterprise',
            'Thực tập': 'Internship',
            'Chứng chỉ': 'Certificate'
          },
        );

      case 13: // Thuật ngữ lập trình
        return TutorialContent(
          title: 'Thuật ngữ lập trình cơ bản',
          content:
              '''Để học tốt ngành CNTT, sinh viên cần nắm vững các thuật ngữ lập trình cơ bản.

NGÔN NGỮ LẬP TRÌNH:
- Python: Ngôn ngữ phổ biến, dễ học
- Java: Mạnh mẽ, ứng dụng enterprise
- JavaScript: Phát triển web
- C++: Lập trình hệ thống
- PHP: Phát triển web backend

KHÁI NIỆM CƠ BẢN:
- Algorithm (Thuật toán): Cách giải quyết vấn đề
- Variable (Biến): Lưu trữ dữ liệu
- Function (Hàm): Khối code có thể tái sử dụng
- Loop (Vòng lặp): Lặp lại các thao tác
- Condition (Điều kiện): Rẽ nhánh trong code

CƠ SỞ DỮ LIỆU:
- Database: Cơ sở dữ liệu
- SQL: Ngôn ngữ truy vấn
- Table: Bảng dữ liệu
- Query: Truy vấn dữ liệu''',
          imageUrl: 'assets/images/programming_terms.jpg',
          keyPoints: [
            'Python, Java, JavaScript, C++, PHP',
            'Algorithm - Thuật toán',
            'Variable, Function, Loop',
            'Database và SQL',
            'Khái niệm cơ bản quan trọng'
          ],
          audioText:
              'Sinh viên CNTT cần học các ngôn ngữ như Python, Java, JavaScript. Nắm vững thuật toán, biến, hàm và cơ sở dữ liệu.',
          vocabulary: {
            'Lập trình': 'Programming',
            'Thuật toán': 'Algorithm',
            'Biến': 'Variable',
            'Hàm': 'Function',
            'Cơ sở dữ liệu': 'Database'
          },
        );

      case 14: // AI và Machine Learning
        return TutorialContent(
          title: 'Công nghệ AI và Machine Learning',
          content:
              '''Trí tuệ nhân tạo (AI) và Học máy (Machine Learning) là xu hướng công nghệ hàng đầu hiện nay.

TRÁCH TỪ NHÂN TẠO (AI):
- Mô phỏng trí thông minh của con người
- Ứng dụng trong nhiều lĩnh vực
- Xử lý ngôn ngữ tự nhiên
- Thị giác máy tính
- Robot thông minh

HỌC MÁY (MACHINE LEARNING):
- Máy tính tự học từ dữ liệu
- Nhận diện hình ảnh, giọng nói
- Dự đoán và phân tích
- Gợi ý sản phẩm
- Xe tự lái

ỨNG DỤNG TẠI DHV:
- Môn học AI/ML trong chương trình
- Dự án nghiên cứu sinh viên
- Chatbot hỗ trợ sinh viên
- Hệ thống gợi ý môn học
- Phân tích dữ liệu giáo dục

CÔNG CỤ VÀ THƯ VIỆN:
- TensorFlow, PyTorch
- Scikit-learn, Pandas
- OpenCV cho thị giác máy tính''',
          imageUrl: 'assets/images/ai_ml.jpg',
          keyPoints: [
            'AI mô phỏng trí thông minh',
            'ML tự học từ dữ liệu',
            'Ứng dụng đa lĩnh vực',
            'Nghiên cứu tại DHV',
            'Công cụ TensorFlow, PyTorch'
          ],
          audioText:
              'Trí tuệ nhân tạo và Học máy là xu hướng hàng đầu. DHV đào tạo sinh viên về AI ML với các công cụ hiện đại như TensorFlow và PyTorch.',
          vocabulary: {
            'Trí tuệ nhân tạo': 'Artificial Intelligence',
            'Học máy': 'Machine Learning',
            'Dữ liệu': 'Data',
            'Thuật toán': 'Algorithm',
            'Mô hình': 'Model'
          },
        );

      case 15: // Thực tập và việc làm
        return TutorialContent(
          title: 'Thực tập và Cơ hội việc làm',
          content:
              '''DHV cam kết hỗ trợ sinh viên tìm kiếm cơ hội thực tập và việc làm sau tốt nghiệp.

CHƯƠNG TRÌNH THỰC TẬP:
- Bắt buộc 3 tháng thực tập cuối khóa
- Hợp tác với hơn 50 doanh nghiệp IT
- Thực tập tại các công ty lớn như FPT, VNG, Saigon Technology
- Hỗ trợ tìm vị trí phù hợp

CƠ HỘI VIỆC LÀM:
- Tỷ lệ có việc làm sau tốt nghiệp: 95%
- Mức lương khởi điểm: 8-15 triệu/tháng
- Các vị trí phổ biến: Developer, Tester, System Admin
- Cơ hội thăng tiến nhanh

HỖ TRỢ TỪ TRƯỜNG:
- Career Day hàng năm
- Workshop kỹ năng mềm
- Hướng dẫn viết CV, phỏng vấn
- Kết nối alumni network
- Tư vấn nghề nghiệp

DOANH NGHIỆP ĐỐI TÁC:
- FPT Software
- VNG Corporation  
- Saigon Technology
- TMA Solutions
- Và nhiều startup công nghệ''',
          imageUrl: 'assets/images/career_opportunities.jpg',
          keyPoints: [
            'Thực tập 3 tháng bắt buộc',
            'Hợp tác 50+ doanh nghiệp',
            '95% có việc làm sau tốt nghiệp',
            'Lương 8-15 triệu khởi điểm',
            'Hỗ trợ Career Day và workshop'
          ],
          audioText:
              'DHV hỗ trợ sinh viên thực tập tại hơn năm mười doanh nghiệp. Tỷ lệ có việc làm sau tốt nghiệp là chín mười lăm phần trăm với mức lương từ tám đến mười lăm triệu đồng.',
          vocabulary: {
            'Thực tập': 'Internship',
            'Việc làm': 'Job',
            'Doanh nghiệp': 'Company',
            'Tốt nghiệp': 'Graduate',
            'Lương': 'Salary'
          },
        );

      case 16: // Kiểm tra Chương 2 - Đào tạo Công nghệ
        return TutorialContent(
          title: 'Kiểm tra Chương 2 - Đào tạo Công nghệ',
          content:
              '''Đây là bài kiểm tra tổng hợp kiến thức Chương 2 về chương trình đào tạo Khoa Kỹ thuật Công nghệ tại DHV.

NỘI DUNG KIỂM TRA:
- Chuẩn đầu ra ngoại ngữ và tin học
- Ngành Công nghệ Thông tin tại DHV
- Chuyên ngành Kỹ thuật Máy tính
- Chuyên sâu IoT và Hệ thống nhúng
- Phòng lab và trang thiết bị hiện đại
- Phương pháp đào tạo thực hành
- Cơ hội thực tập và việc làm

HÌNH THỨC KIỂM TRA:
- Trắc nghiệm đa lựa chọn
- Câu hỏi ngắn về thuật ngữ
- Bài tập thực hành mini
- Thời gian: 45 phút

KẾT QUẢ MONG ĐỢI:
- Nắm vững kiến thức cơ bản về CNTT
- Hiểu rõ cơ hội nghề nghiệp
- Sẵn sàng cho các chương tiếp theo''',
          imageUrl: 'assets/images/final_test.jpg',
          keyPoints: [
            'Kiểm tra tổng hợp Chương 2',
            'Nội dung đào tạo CNTT',
            'Trắc nghiệm và thực hành',
            '45 phút làm bài',
            'Chuẩn bị chương tiếp theo'
          ],
          audioText:
              'Bài kiểm tra Chương hai tổng hợp kiến thức về đào tạo Khoa Kỹ thuật Công nghệ. Thời gian làm bài là bốn mười lăm phút với hình thức trắc nghiệm và thực hành.',
          vocabulary: {
            'Kiểm tra': 'Test/Exam',
            'Tổng hợp': 'Comprehensive',
            'Trắc nghiệm': 'Multiple Choice',
            'Thực hành': 'Practice',
            'Kết quả': 'Result'
          },
        );

      default:
        return TutorialContent(
          title: 'Nội dung đang được cập nhật',
          content:
              'Bài học này đang được phát triển. Nội dung sẽ được cập nhật trong phiên bản tiếp theo.',
          imageUrl: 'assets/images/dhv_campus.jpg',
          keyPoints: ['Đang phát triển', 'Sẽ cập nhật sớm'],
          audioText: 'Nội dung bài học đang được phát triển',
          vocabulary: {},
        );
    }
  }

  Widget _buildImageWithPlaceholder(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.unitColor.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Placeholder when image doesn't exist
            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.unitColor.withOpacity(0.3),
                    widget.unitColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.lesson.id <= 8 ? Icons.school : Icons.computer,
                    size: 64,
                    color: widget.unitColor.withOpacity(0.7),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.lesson.id <= 8
                        ? 'Hình ảnh\nĐại học Hùng Vương'
                        : 'Hình ảnh\nKhoa Kỹ thuật Công nghệ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.unitColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hình ảnh minh họa sẽ được\ncập nhật trong phiên bản tiếp theo',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.unitColor.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          appBar: CustomAppBar(
            title: widget.lesson.title,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.12),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _cardTabController,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          blurRadius: 3,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(2),
                    labelColor: widget.unitColor,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    splashFactory: InkRipple.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withOpacity(0.1);
                      }
                      return Colors.transparent;
                    }),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        height: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.visibility, size: 15),
                                ),
                                const SizedBox(width: 4),
                                const Text('Xem',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.headphones, size: 15),
                                ),
                                const SizedBox(width: 4),
                                const Text('Nghe',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.touch_app, size: 15),
                                ),
                                const SizedBox(width: 3),
                                const Text('T.tác',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:
                                      const Icon(Icons.info_outline, size: 15),
                                ),
                                const SizedBox(width: 3),
                                const Text('Chi tiết',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Header với thông tin bài học
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.unitColor,
                      widget.unitColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.unitColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.lesson.id <= 8 ? Icons.school : Icons.computer,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutorialContent.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${learningCards.length} phần học tương tác',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'DHV CORE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Nội dung 4 loại card
              Expanded(
                child: TabBarView(
                  controller: _cardTabController,
                  children: [
                    // VISUAL CARD
                    _buildCardContent(DHVCardType.visual, isDarkMode),
                    // AUDIO CARD
                    _buildCardContent(DHVCardType.audio, isDarkMode),
                    // INTERACTIVE CARD
                    _buildCardContent(DHVCardType.interactive, isDarkMode),
                    // INFO CARD
                    _buildCardContent(DHVCardType.info, isDarkMode),
                  ],
                ),
              ),

              // Complete Button
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      await Future.delayed(const Duration(milliseconds: 300));
                      await widget.onLessonCompleted(
                          widget.lesson.id, widget.isCore);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.unitColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hoàn thành bài học',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // DHVStudyAssistantWidget - Trợ lý học tập floating
        DHVStudyAssistantWidget(
          lessonData: {
            'title': tutorialContent.title,
            'content': tutorialContent.content,
            'keyPoints': tutorialContent.keyPoints,
            'visual': DHVCardDataProvider.getVisualCardData(widget.lesson.id),
            'audio': DHVCardDataProvider.getAudioCardData(widget.lesson.id),
            'interactive':
                DHVCardDataProvider.getInteractiveCardData(widget.lesson.id),
            'info': DHVCardDataProvider.getInfoCardData(widget.lesson.id),
          },
        ),
      ],
    );
  }

  // Build nội dung cho từng loại card sử dụng Data Provider
  Widget _buildCardContent(DHVCardType cardType, bool isDarkMode) {
    // Lấy dữ liệu từ Data Provider
    final allCardData =
        DHVCardDataProvider.getAllCardDataForLesson(widget.lesson.id);

    Map<String, dynamic> cardData;
    switch (cardType) {
      case DHVCardType.visual:
        cardData = allCardData['visual'] ?? {};
        break;
      case DHVCardType.audio:
        cardData = allCardData['audio'] ?? {};
        break;
      case DHVCardType.interactive:
        cardData = allCardData['interactive'] ?? {};
        break;
      case DHVCardType.info:
        cardData = allCardData['info'] ?? {};
        break;
    }

    return _buildCardContentByType(cardType, cardData, isDarkMode);
  }

  // Build nội dung card theo type
  Widget _buildCardContentByType(
      DHVCardType cardType, Map<String, dynamic> cardData, bool isDarkMode) {
    switch (cardType) {
      case DHVCardType.visual:
        return _buildVisualCardContent(cardData, isDarkMode);
      case DHVCardType.audio:
        return _buildAudioCardContent(cardData, isDarkMode);
      case DHVCardType.interactive:
        return _buildInteractiveCardContent(cardData, isDarkMode);
      case DHVCardType.info:
        return _buildInfoCardContent(cardData, isDarkMode);
    }
  }

  // ===============================================
  // NEW CARD CONTENT BUILDERS USING DATA PROVIDER
  // ===============================================

  // VISUAL CARD CONTENT - Sử dụng data provider
  Widget _buildVisualCardContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.visibility,
            title: cardData['title'] ?? 'Xem',
            subtitle: cardData['subtitle'] ?? 'Nội dung trực quan',
            color: const Color(0xFF4CAF50),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // Content based on type
          if (cardData['type'] == 'timeline')
            _buildTimelineContent(cardData, isDarkMode)
          else if (cardData['type'] == 'gallery')
            _buildGalleryContent(cardData, isDarkMode)
          else
            _buildDefaultVisualContent(cardData, isDarkMode),

          const SizedBox(height: 20),

          // Highlights với Click-to-Speak
          if (cardData['highlights'] != null)
            ClickableContentListWidget(
              contentList: (cardData['highlights'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              title: 'Điểm nổi bật',
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
              highlightColor: Colors.green.withOpacity(0.1),
              onItemSpeak: (index, content) {
                // Log khi người dùng click để nghe
                debugPrint('Đang phát âm: $content');
              },
            ),
        ],
      ),
    );
  }

  // AUDIO CARD CONTENT - Sử dụng data provider
  Widget _buildAudioCardContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.headphones,
            title: cardData['title'] ?? 'Nghe',
            subtitle: cardData['subtitle'] ?? 'Luyện nghe và phát âm',
            color: const Color(0xFF2196F3),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // Content based on type
          if (cardData['type'] == 'pronunciation')
            _buildPronunciationContent(cardData, isDarkMode)
          else if (cardData['type'] == 'vocabulary')
            _buildVocabularyContent(cardData, isDarkMode)
          else
            _buildDefaultAudioContent(cardData, isDarkMode),

          const SizedBox(height: 20),

          // Highlights với Click-to-Speak - Audio Card
          if (cardData['highlights'] != null)
            ClickableContentListWidget(
              contentList: (cardData['highlights'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              title: 'Từ vựng và phát âm',
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
              highlightColor: Colors.blue.withOpacity(0.1),
              showSlowModeButton: true,
              onItemSpeak: (index, content) {
                debugPrint('Đang phát âm từ vựng: $content');
              },
            ),
        ],
      ),
    );
  }

  // INTERACTIVE CARD CONTENT - Sử dụng data provider
  Widget _buildInteractiveCardContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.touch_app,
            title: cardData['title'] ?? 'Tương tác',
            subtitle: cardData['subtitle'] ?? 'Hoạt động tương tác',
            color: const Color(0xFFFF9800),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // Content based on type
          if (cardData['type'] == 'quiz')
            _buildQuizContent(cardData, isDarkMode)
          else if (cardData['type'] == 'map')
            _buildMapContent(cardData, isDarkMode)
          else
            _buildDefaultInteractiveContent(cardData, isDarkMode),

          const SizedBox(height: 20),

          // Highlights với Click-to-Speak - Interactive Card
          if (cardData['highlights'] != null)
            ClickableContentListWidget(
              contentList: (cardData['highlights'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              title: 'Tính năng tương tác',
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
              ),
              highlightColor: Colors.orange.withOpacity(0.1),
              onItemSpeak: (index, content) {
                debugPrint('Đang giới thiệu tính năng: $content');
              },
            ),
        ],
      ),
    );
  }

  // INFO CARD CONTENT - Sử dụng data provider
  Widget _buildInfoCardContent(Map<String, dynamic> cardData, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.info,
            title: cardData['title'] ?? 'Chi tiết',
            subtitle: cardData['subtitle'] ?? 'Thông tin chi tiết',
            color: const Color(0xFF9C27B0),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // Content based on type
          if (cardData['type'] == 'stats')
            _buildStatsContent(cardData, isDarkMode)
          else
            _buildDefaultInfoContent(cardData, isDarkMode),

          const SizedBox(height: 20),

          // Highlights với Click-to-Speak - Info Card
          if (cardData['highlights'] != null)
            ClickableContentListWidget(
              contentList: (cardData['highlights'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              title: 'Thông tin quan trọng',
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
              highlightColor: Colors.purple.withOpacity(0.1),
              onItemSpeak: (index, content) {
                debugPrint('Đang đọc thông tin: $content');
              },
            ),
        ],
      ),
    );
  }

  // ===============================================
  // HELPER METHODS - CARD COMPONENTS
  // ===============================================

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(
      List<dynamic> highlights, bool isDarkMode, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điểm nổi bật',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),
          ...highlights.map((highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        highlight.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ===============================================
  // CONTENT TYPE BUILDERS
  // ===============================================

  Widget _buildTimelineContent(Map<String, dynamic> cardData, bool isDarkMode) {
    final timelineData = cardData['timelineData'] as List<dynamic>? ?? [];

    return ClickableContentListWidget(
      contentList: timelineData.map((event) {
        return "${event['year']}: ${event['event']}";
      }).toList(),
      title: 'Dòng thời gian DHV',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4CAF50),
      ),
      contentStyle: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
      highlightColor: Colors.green.withOpacity(0.1),
      autoNumbering: false,
      showPlayAllButton: true,
      showSlowModeButton: true,
      onItemSpeak: (index, content) {
        debugPrint('Đang đọc sự kiện lịch sử: $content');
      },
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String eventText,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.unitColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: widget.unitColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.unitColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  eventText,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryContent(Map<String, dynamic> cardData, bool isDarkMode) {
    final images = cardData['images'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 64, color: Colors.grey),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 32, color: Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        image['title']?.toString() ?? '',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultVisualContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            cardData['content']?.toString() ?? 'Nội dung đang được cập nhật',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    final pronunciationData =
        cardData['pronunciationData'] as List<dynamic>? ?? [];

    if (pronunciationData.isEmpty) {
      return _buildDefaultAudioContent(cardData, isDarkMode);
    }

    return ClickableContentListWidget(
      contentList: pronunciationData.map((word) {
        return "${word['word']} - ${word['meaning']} (${word['ipa']})";
      }).toList(),
      title: 'Luyện phát âm từ vựng',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2196F3),
      ),
      contentStyle: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
      highlightColor: Colors.blue.withOpacity(0.1),
      showSlowModeButton: true,
      showRepeatButton: true,
      onItemSpeak: (index, content) {
        // Extract chỉ từ vựng để phát âm
        final word = pronunciationData[index]['word']?.toString() ?? '';
        debugPrint('Đang luyện phát âm từ: $word');
      },
    );
  }

  Widget _buildVocabularyContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    final vocabulary = cardData['vocabulary'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Từ vựng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...vocabulary.entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _speak(entry.key),
                    icon: Icon(
                      Icons.volume_up,
                      color: widget.unitColor,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDefaultAudioContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.headphones,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            cardData['content']?.toString() ?? 'Nội dung âm thanh',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _speak(cardData['audioText']?.toString() ?? ''),
            icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
            label: Text(isPlaying ? 'Dừng' : 'Phát âm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.unitColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(Map<String, dynamic> cardData, bool isDarkMode) {
    // Lấy quiz data từ DHVQuizDataProvider dựa vào lesson ID
    // Map lesson ID sang quiz key
    String quizKey = '';
    if (widget.lesson.id <= 3) {
      quizKey = 'unit1_basics';
    } else if (widget.lesson.id == 4) {
      quizKey = 'unit1_dhv_psychology';
    } else if (widget.lesson.id == 5) {
      quizKey = 'unit1_common_mistakes';
    } else if (widget.lesson.id <= 10) {
      quizKey = 'unit2_storytelling';
    } else if (widget.lesson.id <= 15) {
      quizKey = 'unit3_confidence';
    } else if (widget.lesson.id <= 20) {
      quizKey = 'unit4_conversation';
    } else if (widget.lesson.id >= 100) {
      quizKey = 'unit5_vietnamese';
    }

    final quizData = DHVQuizDataProvider.getQuizData(quizKey);
    final questions = quizData['questions'] as List<dynamic>? ?? [];

    // Nếu không có câu hỏi, hiển thị nội dung mặc định
    if (questions.isEmpty) {
      return _buildDefaultInteractiveContent(cardData, isDarkMode);
    }

    // Sử dụng QuizLauncherButton từ DuolingoQuizWidget
    return Column(
      children: [
        // Quiz launcher button với animation đẹp
        QuizLauncherButton(
          quizData: quizData,
          unitColor: widget.unitColor,
          lessonTitle: widget.lesson.title,
          onCompleted: () {
            // Cập nhật tiến độ khi hoàn thành quiz
            setState(() {
              // Mark quiz as completed
              debugPrint('Quiz completed for ${widget.lesson.title}');
            });

            // Show celebration
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => CompletionCelebrationDialog(
                lessonId: widget.lesson.id,
                isCore: true,
                xpGained: questions.length * 10,
                unitColor: widget.unitColor,
                lessonTitle: '${widget.lesson.title} - Quiz',
                onContinue: () {
                  // Quiz completed
                },
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Additional quiz info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.unitColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thông tin quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.unitColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildQuizInfoRow(
                icon: Icons.help_outline,
                label: 'Số câu hỏi:',
                value: '${questions.length} câu',
              ),
              const SizedBox(height: 8),
              _buildQuizInfoRow(
                icon: Icons.timer_outlined,
                label: 'Thời gian dự kiến:',
                value: '~${questions.length * 2} phút',
              ),
              const SizedBox(height: 8),
              _buildQuizInfoRow(
                icon: Icons.star_outline,
                label: 'Kinh nghiệm:',
                value: '+${questions.length * 10} XP',
              ),
              const SizedBox(height: 12),
              Text(
                'Lưu ý: Quiz giúp củng cố kiến thức DHV với phản hồi chi tiết cho từng câu hỏi.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: widget.unitColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent(Map<String, dynamic> cardData, bool isDarkMode) {
    final mapData = cardData['mapData'] as Map<String, dynamic>? ?? {};
    final locations = mapData['locations'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.map, size: 64, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        ...locations.map((location) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: widget.unitColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location['name']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tầng ${location['floor']} - Tòa ${location['building']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDefaultInteractiveContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            cardData['content']?.toString() ?? 'Nội dung tương tác',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> cardData, bool isDarkMode) {
    final statsData = cardData['statsData'] as Map<String, dynamic>? ?? {};
    final stats = statsData['stats'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê DHV',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              label: stat['label']?.toString() ?? '',
              value: stat['value']?.toString() ?? '',
              iconName: stat['icon']?.toString() ?? 'info',
              color: Color(stat['color'] as int? ?? 0xFF9C27B0),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String iconName,
    required Color color,
  }) {
    IconData icon;
    switch (iconName) {
      case 'school':
        icon = Icons.school;
        break;
      case 'person':
        icon = Icons.person;
        break;
      case 'work':
        icon = Icons.work;
        break;
      case 'business':
        icon = Icons.business;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultInfoContent(
      Map<String, dynamic> cardData, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info,
            size: 64,
            color: widget.unitColor,
          ),
          const SizedBox(height: 16),
          Text(
            cardData['content']?.toString() ?? 'Thông tin chi tiết',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==============================================
  // OLD METHODS - MARKED FOR REMOVAL/CLEANUP
  // ==============================================

  // OLD AUDIO CARD - TO BE REMOVED (REPLACED BY DATA PROVIDER)
  Widget _buildAudioCard(DHVLearningCard card, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF4CAF50).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.headphones, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        card.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Play button
                IconButton(
                  onPressed: () {
                    if (card.audioText != null) {
                      _speak(card.audioText!);
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pronunciation Practice
          if (card.interactiveElements != null)
            ...card.interactiveElements!.map((element) {
              if (element.type == 'pronunciation') {
                return _buildPronunciationWidget(element, isDarkMode);
              }
              return const SizedBox.shrink();
            }),

          // Vocabulary Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: card.highlights.length,
            itemBuilder: (context, index) {
              final vocab = card.highlights[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vocab.split(' - ').first,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (vocab.contains(' - ')) ...[
                      const SizedBox(height: 8),
                      Text(
                        vocab.split(' - ').last,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => _speak(vocab.split(' - ').first),
                      icon: const Icon(
                        Icons.volume_up,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // INTERACTIVE CARD - Tương tác và quiz
  Widget _buildInteractiveCard(DHVLearningCard card, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800),
                  const Color(0xFFFF9800).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        card.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Interactive Elements
          if (card.interactiveElements != null)
            ...card.interactiveElements!.map((element) {
              if (element.type == 'quiz') {
                return _buildQuizWidget(element, isDarkMode);
              } else if (element.type == 'map') {
                return _buildMapWidget(element, isDarkMode);
              }
              return const SizedBox.shrink();
            }),

          // Features
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tính năng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(height: 16),
                ...card.highlights.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF9800).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: const Color(0xFFFF9800),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // INFO CARD - Thông tin chi tiết và số liệu
  Widget _buildInfoCard(DHVLearningCard card, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0),
                  const Color(0xFF9C27B0).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        card.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Statistics (nếu có)
          if (card.interactiveElements != null)
            ...card.interactiveElements!.map((element) {
              if (element.type == 'stats') {
                return _buildStatsWidget(element, isDarkMode);
              }
              return const SizedBox.shrink();
            }),

          // Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Info highlights
                ...card.highlights.map((info) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C27B0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.star,
                              color: const Color(0xFF9C27B0),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              info,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Widgets cho các card
  Widget _buildTimelineWidget(InteractiveElement element, bool isDarkMode) {
    final events = element.data['events'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: element.color ?? const Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 20),
          ...events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == events.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: element.color ?? const Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 60,
                          color: (element.color ?? const Color(0xFF1E88E5))
                              .withOpacity(0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Event content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (element.color ?? const Color(0xFF1E88E5))
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event['year'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: element.color ?? const Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event['event'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['detail'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPronunciationWidget(
      InteractiveElement element, bool isDarkMode) {
    final pronunciations = element.data as List<dynamic>;

    return Column(
      children: pronunciations.map<Widget>((pronunciation) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pronunciation['word'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pronunciation['ipa'],
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pronunciation['meaning'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _speak(pronunciation['word']),
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuizWidget(InteractiveElement element, bool isDarkMode) {
    final questions = element.data['questions'] as List<dynamic>;

    return StatefulBuilder(
      builder: (context, setState) {
        int currentQuestion = 0;
        int? selectedAnswer;
        bool showExplanation = false;
        int score = 0;

        final question = questions[currentQuestion];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Câu ${currentQuestion + 1}/${questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Điểm: $score',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question
              Text(
                question['question'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              ...question['options'].asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = selectedAnswer == index;
                final isCorrect = index == question['correct'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: showExplanation
                        ? null
                        : () {
                            setState(() {
                              selectedAnswer = index;
                              showExplanation = true;
                              if (isCorrect) score += 10;
                            });
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: showExplanation
                            ? (isCorrect
                                ? Colors.green.withOpacity(0.1)
                                : (isSelected
                                    ? Colors.red.withOpacity(0.1)
                                    : (isDarkMode
                                        ? const Color(0xFF3A3A3A)
                                        : Colors.grey[100])))
                            : (isSelected
                                ? const Color(0xFFFF9800).withOpacity(0.1)
                                : (isDarkMode
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.grey[100])),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showExplanation
                              ? (isCorrect
                                  ? Colors.green
                                  : (isSelected
                                      ? Colors.red
                                      : Colors.grey[300]!))
                              : (isSelected
                                  ? const Color(0xFFFF9800)
                                  : Colors.grey[300]!),
                          width: showExplanation ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (showExplanation)
                            Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : (isSelected ? Icons.cancel : null),
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Explanation
              if (showExplanation) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giải thích:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question['explanation'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Next button
                if (currentQuestion < questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestion++;
                        selectedAnswer = null;
                        showExplanation = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Câu tiếp theo'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      // Show final score
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hoàn thành Quiz!'),
                          content: Text(
                              'Điểm số của bạn: $score/${questions.length * 10}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Xem kết quả'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapWidget(InteractiveElement element, bool isDarkMode) {
    final locations = element.data['locations'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 20),

          // Map placeholder with locations
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
              ),
            ),
            child: Stack(
              children: [
                // Map background
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: const Color(0xFFFF9800).withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bản đồ DHV Campus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),

                // Location markers (positioned randomly for demo)
                ...locations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final location = entry.value;
                  final positions = [
                    const Offset(30, 40),
                    const Offset(150, 80),
                    const Offset(80, 120),
                    const Offset(200, 60),
                  ];

                  return Positioned(
                    left: positions[index % positions.length].dx,
                    top: positions[index % positions.length].dy,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${location['name']} - Tầng ${location['floor']}, Tòa ${location['building']}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Locations list
          ...locations.map((location) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFFF9800),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      'Tầng ${location['floor']} - Tòa ${location['building']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatsWidget(InteractiveElement element, bool isDarkMode) {
    final stats = element.data['stats'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              final color = Color(stat['color']);
              final icon = _getIconFromString(stat['icon']);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stat['value'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'person':
        return Icons.person;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    try {
      flutterTts.stop();
    } catch (e) {
      print('TTS stop error during dispose: $e');
    }
    _animationController.dispose();
    _cardTabController.dispose();
    pageController.dispose();
    super.dispose();
  }
}

enum ExerciseType {
  multipleChoice,
  fillInBlank,
  wordCard,
  pronunciation,
  matching,
  sequencing,
  flashcard,
  dialoguePractice,
}

class Exercise {
  final ExerciseType type;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String vietnameseWord;
  final String pronunciation;
  final String? imageUrl;
  final String explanation;
  final String unitTheme;
  final List<String>? matchingPairs;
  final List<int>? correctSequence;
  final List<FlashCard>? flashcardSet;
  final List<DialogueLine>? dialogue;

  Exercise({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.vietnameseWord,
    required this.pronunciation,
    this.imageUrl,
    required this.explanation,
    required this.unitTheme,
    this.matchingPairs,
    this.correctSequence,
    this.flashcardSet,
    this.dialogue,
  });
}

class FlashCard {
  final String front;
  final String back;
  final String pronunciation;
  final String example;
  final String difficulty;

  FlashCard({
    required this.front,
    required this.back,
    required this.pronunciation,
    required this.example,
    required this.difficulty,
  });
}

class DialogueLine {
  final String speaker;
  final String text;
  final String translation;

  DialogueLine({
    required this.speaker,
    required this.text,
    required this.translation,
  });
}

class ExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  final Color unitColor;
  final bool isDarkMode;
  final Function(bool) onAnswer;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.unitColor,
    required this.isDarkMode,
    required this.onAnswer,
  });

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  int? selectedAnswer;
  late FlutterTts flutterTts;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    flutterTts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    if (_disposed) return;
    try {
      await flutterTts.setLanguage("vi-VN"); // Tiếng Việt
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      print('TTS configuration error: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (_disposed) return;
    try {
      await flutterTts.stop();
      await flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    try {
      flutterTts.stop();
    } catch (e) {
      print('TTS stop error during dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.exercise.question,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 24),

        // DHV Flashcard System
        if (widget.exercise.type == ExerciseType.flashcard)
          _buildFlashcardWidget(),

        // DHV Dialogue Practice
        if (widget.exercise.type == ExerciseType.dialoguePractice)
          _buildDialogueWidget(),

        // Advanced Matching Exercise
        if (widget.exercise.type == ExerciseType.matching)
          _buildMatchingWidget(),

        // Sequencing Exercise
        if (widget.exercise.type == ExerciseType.sequencing)
          _buildSequencingWidget(),

        if (widget.exercise.type == ExerciseType.wordCard &&
            widget.exercise.imageUrl != null)
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 300,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.unitColor.withOpacity(0.1),
                border: Border.all(
                  color: widget.unitColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image with error handling
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: widget.unitColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.exercise.imageUrl != null
                          ? Image.asset(
                              widget.exercise.imageUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Placeholder when image doesn't exist
                                return Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        widget.unitColor.withOpacity(0.3),
                                        widget.unitColor.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.exercise.unitTheme
                                                .contains('DHV')
                                            ? Icons.school
                                            : widget.exercise.unitTheme
                                                    .contains('FAMILY')
                                                ? Icons.family_restroom
                                                : widget.exercise.unitTheme
                                                        .contains('FOOD')
                                                    ? Icons.restaurant
                                                    : widget.exercise.unitTheme
                                                            .contains('WORK')
                                                        ? Icons.work
                                                        : widget.exercise
                                                                .unitTheme
                                                                .contains(
                                                                    'SPORT')
                                                            ? Icons
                                                                .sports_soccer
                                                            : widget.exercise
                                                                    .unitTheme
                                                                    .contains(
                                                                        'HEALTH')
                                                                ? Icons
                                                                    .local_hospital
                                                                : widget.exercise
                                                                        .unitTheme
                                                                        .contains(
                                                                            'SHOP')
                                                                    ? Icons
                                                                        .shopping_cart
                                                                    : Icons
                                                                        .image,
                                        size: 48,
                                        color: widget.unitColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Hình ảnh\nminh họa',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: widget.unitColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Icon(
                              widget.exercise.unitTheme.contains('DHV')
                                  ? Icons.school
                                  : Icons.image,
                              size: 60,
                              color: widget.unitColor,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Vietnamese word
                  Text(
                    widget.exercise.vietnameseWord,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.unitColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // IPA pronunciation
                  Text(
                    widget.exercise.pronunciation,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color:
                          widget.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Explanation
                  Text(
                    widget.exercise.explanation,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Audio button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _speak(widget.exercise.vietnameseWord);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.unitColor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: widget.unitColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Nghe phát âm',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (widget.exercise.type == ExerciseType.pronunciation)
          Center(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: widget.unitColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.unitColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.exercise.vietnameseWord,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.unitColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exercise.pronunciation,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exercise.explanation,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode
                              ? Colors.white60
                              : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Listen button
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _speak(widget.exercise.vietnameseWord);
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: widget.unitColor,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.unitColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nghe',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    // Record button
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showRecordingDialog();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phát âm',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (widget.exercise.type != ExerciseType.pronunciation &&
            widget.exercise.type != ExerciseType.flashcard &&
            widget.exercise.type != ExerciseType.dialoguePractice &&
            widget.exercise.type != ExerciseType.matching &&
            widget.exercise.type != ExerciseType.sequencing) ...[
          const SizedBox(height: 24),
          ...widget.exercise.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswer == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedAnswer = index;
                  });
                  HapticFeedback.lightImpact();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    widget.onAnswer(index == widget.exercise.correctAnswer);
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.unitColor.withOpacity(0.1)
                        : (widget.isDarkMode
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: widget.unitColor, width: 2)
                        : Border.all(
                            color: widget.isDarkMode
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: widget.unitColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? widget.unitColor
                                : (widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black87),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: widget.unitColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showRecordingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ghi âm phát âm',
          style: TextStyle(color: widget.unitColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              size: 64,
              color: widget.unitColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Hãy phát âm: "${widget.exercise.vietnameseWord}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              widget.exercise.explanation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tính năng nhận diện giọng nói sẽ được phát triển trong phiên bản tiếp theo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAnswer(true); // Temporary pass
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  // DHV Flashcard Learning System
  Widget _buildFlashcardWidget() {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        itemCount: widget.exercise.flashcardSet!.length,
        itemBuilder: (context, index) {
          final flashcard = widget.exercise.flashcardSet![index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: FlashCardWidget(
              flashcard: flashcard,
              unitColor: widget.unitColor,
              isDarkMode: widget.isDarkMode,
              onSpeak: _speak,
            ),
          );
        },
      ),
    );
  }

  // DHV Dialogue Practice Widget
  Widget _buildDialogueWidget() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.unitColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.unitColor.withOpacity(0.3)),
          ),
          child: Column(
            children: widget.exercise.dialogue!.map((line) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DialogueLineWidget(
                  line: line,
                  unitColor: widget.unitColor,
                  isDarkMode: widget.isDarkMode,
                  onSpeak: _speak,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Chọn phản hồi phù hợp:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.exercise.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = selectedAnswer == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedAnswer = index;
                });
                HapticFeedback.lightImpact();
                Future.delayed(const Duration(milliseconds: 500), () {
                  widget.onAnswer(index == widget.exercise.correctAnswer);
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.unitColor.withOpacity(0.1)
                      : (widget.isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? widget.unitColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? widget.unitColor
                              : (widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black87),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: widget.unitColor),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Advanced Matching Exercise for Tech Terms
  Widget _buildMatchingWidget() {
    return Column(
      children: [
        Text(
          'Kéo thả để ghép đúng thuật ngữ:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: Row(
            children: [
              // English terms
              Expanded(
                child: Column(
                  children:
                      widget.exercise.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final term = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.unitColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: widget.unitColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          term,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: widget.unitColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              // Vietnamese terms
              Expanded(
                child: Column(
                  children: widget.exercise.matchingPairs!
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final term = entry.value;
                    final isCorrect = index == widget.exercise.correctAnswer;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedAnswer = index;
                          });
                          HapticFeedback.lightImpact();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            widget.onAnswer(isCorrect);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedAnswer == index
                                ? widget.unitColor.withOpacity(0.2)
                                : (widget.isDarkMode
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedAnswer == index
                                  ? widget.unitColor
                                  : Colors.grey[300]!,
                              width: selectedAnswer == index ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            term,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: selectedAnswer == index
                                  ? widget.unitColor
                                  : (widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // DHV Training Process Sequencing
  Widget _buildSequencingWidget() {
    return Column(
      children: [
        Text(
          'Sắp xếp theo đúng thứ tự:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ReorderableListView.builder(
            itemCount: widget.exercise.options.length,
            onReorder: (oldIndex, newIndex) {
              // Handle reordering logic here
              HapticFeedback.lightImpact();
            },
            itemBuilder: (context, index) {
              final step = widget.exercise.options[index];
              return Container(
                key: ValueKey(step),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.unitColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: widget.unitColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.drag_handle,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Check sequence correctness
            widget.onAnswer(true); // Simplified for now
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.unitColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Kiểm tra thứ tự'),
        ),
      ],
    );
  }
}

// Supporting Widgets for DHV Learning System
class FlashCardWidget extends StatefulWidget {
  final FlashCard flashcard;
  final Color unitColor;
  final bool isDarkMode;
  final Function(String) onSpeak;

  const FlashCardWidget({
    super.key,
    required this.flashcard,
    required this.unitColor,
    required this.isDarkMode,
    required this.onSpeak,
  });

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  bool isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipped = !isFlipped;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Container(
          key: ValueKey(isFlipped),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.unitColor,
                widget.unitColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.unitColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isFlipped) ...[
                // Front side - English
                Text(
                  widget.flashcard.front,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.flashcard.difficulty.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                // Back side - Vietnamese
                Text(
                  widget.flashcard.back,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.flashcard.pronunciation,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.flashcard.example,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () {
                    widget.onSpeak(widget.flashcard.back);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                isFlipped ? 'Nhấn để xem tiếng Anh' : 'Nhấn để xem tiếng Việt',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogueLineWidget extends StatelessWidget {
  final DialogueLine line;
  final Color unitColor;
  final bool isDarkMode;
  final Function(String) onSpeak;

  const DialogueLineWidget({
    super.key,
    required this.line,
    required this.unitColor,
    required this.isDarkMode,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isStudent = line.speaker.contains('sinh viên');

    return Container(
      margin: EdgeInsets.only(
        left: isStudent ? 0 : 40,
        right: isStudent ? 40 : 0,
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isStudent
            ? unitColor.withOpacity(0.1)
            : (isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[200]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStudent ? unitColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                line.speaker,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: unitColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => onSpeak(line.text),
                icon: Icon(
                  Icons.volume_up,
                  size: 16,
                  color: unitColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            line.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            line.translation,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Animated Tab Widget
