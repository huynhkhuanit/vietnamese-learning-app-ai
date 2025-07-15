/// DHV Quiz Data Provider
/// Cung cấp câu hỏi quiz cho từng bài học
class DHVQuizDataProvider {
  /// Get quiz data for a specific lesson
  static Map<String, dynamic> getQuizData(String lessonId) {
    final quizzes = _quizDatabase[lessonId];
    if (quizzes == null) return _emptyQuiz;

    return {
      'questions': quizzes,
      'lessonId': lessonId,
    };
  }

  static final Map<String, dynamic> _emptyQuiz = {
    'questions': [],
  };

  static final Map<String, List<Map<String, dynamic>>> _quizDatabase = {
    // ===============================================
    // SPECIAL EVENT QUIZ - BÀI KIỂM TRA TỔNG HỢP DHV
    // ===============================================
    'dhv_comprehensive_quiz': [
      {
        'question':
            'Trường Đại học Hùng Vương TP.HCM được thành lập vào năm nào?',
        'options': ['1993', '1995', '1997', '2000'],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Trường được thành lập theo Quyết định số 470/TTg ngày 14/08/1995 của Thủ tướng Chính Phủ',
        'audioText':
            'Trường Đại học Hùng Vương thành phố Hồ Chí Minh được thành lập vào năm một nghìn chín trăm chín mười lăm',
        'difficulty': 'basic',
        'category': 'lịch sử',
      },
      {
        'question': 'Trụ sở chính của trường DHV nằm ở địa chỉ nào?',
        'options': [
          '736 Nguyễn Trãi, Phường 11, Quận 5',
          '756 Nguyễn Trãi, Phường 11, Quận 5',
          '28-30 Ngô Quyền, Phường 6, Quận 5',
          '680 Ngô Quyền, Phường 5, Quận 5'
        ],
        'correct': 0,
        'type': 'multiple_choice',
        'explanation':
            'Trụ sở chính tại 736 Nguyễn Trãi, Phường 11, Quận 5, TP.HCM',
        'audioText':
            'Trụ sở chính của trường nằm tại bảy ba sáu Nguyễn Trãi, Phường mười một, Quận năm',
        'difficulty': 'basic',
        'category': 'địa chỉ',
      },
      {
        'question': 'Ngày truyền thống của trường DHV là ngày nào?',
        'options': [
          '10 tháng 3 (âm lịch)',
          '9 tháng 3 (âm lịch)',
          '20 tháng 11',
          '2 tháng 9'
        ],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Ngày 9 tháng 3 âm lịch là ngày Giỗ Quốc tổ Hùng Vương, được chọn làm ngày truyền thống của trường',
        'audioText':
            'Ngày truyền thống của trường là ngày chín tháng ba âm lịch',
        'difficulty': 'basic',
        'category': 'truyền thống',
      },
      {
        'question': 'Slogan của trường DHV là gì?',
        'options': [
          'Hào khí Hùng Vương - Tương lai vững bước',
          'Tiên phong - Sáng tạo - Phát triển',
          'Tri thức - Phẩm chất - Thành công',
          'Học tập - Rèn luyện - Cống hiến'
        ],
        'correct': 0,
        'type': 'multiple_choice',
        'explanation':
            'Slogan "Hào khí Hùng Vương - Tương lai vững bước" thể hiện tinh thần và định hướng của trường',
        'audioText':
            'Slogan của trường là Hào khí Hùng Vương, Tương lai vững bước',
        'difficulty': 'intermediate',
        'category': 'văn hóa',
      },
      {
        'question': 'Ba giá trị cốt lõi của trường DHV là gì?',
        'options': [
          'Trách nhiệm - Tôn trọng - Tự tin',
          'Trách nhiệm - Trung nghĩa - Tự tin',
          'Tôn trọng - Trung thực - Tự lập',
          'Trung nghĩa - Tôn trọng - Tự chủ'
        ],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Ba giá trị cốt lõi: Trách nhiệm (Responsibility), Trung nghĩa (Respect), Tự tin (Readiness) - 3R',
        'audioText': 'Ba giá trị cốt lõi là Trách nhiệm, Trung nghĩa và Tự tin',
        'difficulty': 'intermediate',
        'category': 'giá trị',
      },
      {
        'question': 'Loại hình của trường DHV hiện tại là gì?',
        'options': ['Công lập', 'Bán công', 'Dân lập', 'Tư thục'],
        'correct': 3,
        'type': 'multiple_choice',
        'explanation':
            'Từ năm 2010, trường chuyển từ dân lập sang tư thục theo Quyết định số 705/QĐ-TTg',
        'audioText': 'Trường hiện tại là trường tư thục',
        'difficulty': 'basic',
        'category': 'loại hình',
      },
      {
        'question': 'Trường DHV có bao nhiêu khoa đào tạo chính?',
        'options': ['5 khoa', '6 khoa', '7 khoa', '8 khoa'],
        'correct': 2,
        'type': 'multiple_choice',
        'explanation':
            'DHV có 7 khoa: Quản trị KD-Marketing, Tài chính-Ngân hàng-Kế toán, Ngôn ngữ, Du lịch-Nhà hàng-Khách sạn, Kỹ thuật Công nghệ, Luật, Khoa học sức khỏe',
        'audioText': 'Trường có bảy khoa đào tạo chính',
        'difficulty': 'intermediate',
        'category': 'cơ cấu',
      },
      {
        'question': 'Mã ngành Công nghệ Thông tin tại DHV là gì?',
        'options': ['7480101', '7480201', '7480301', '7480401'],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation': 'Ngành Công nghệ Thông tin có mã ngành 7480201',
        'audioText':
            'Mã ngành Công nghệ Thông tin là bảy bốn tám không hai không một',
        'difficulty': 'advanced',
        'category': 'chuyên ngành',
      },
      {
        'question': 'Khoa Kỹ thuật Công nghệ có phòng thực hành đặc biệt nào?',
        'options': [
          'Phòng thí nghiệm hóa học',
          'Phòng thực hành VR/Metaverse',
          'Phòng studio âm nhạc',
          'Phòng thực hành y khoa'
        ],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Khoa có phòng thực hành VR, Metaverse đầu tiên tại Việt Nam với công nghệ tiên tiến',
        'audioText': 'Khoa có phòng thực hành VR và Metaverse hiện đại',
        'difficulty': 'advanced',
        'category': 'cơ sở vật chất',
      },
      {
        'question': 'Chuẩn đầu ra ngoại ngữ cho sinh viên DHV là gì?',
        'options': [
          'Bậc 3/6 khung năng lực',
          'Bậc 4/6 khung năng lực',
          'Bậc 5/6 khung năng lực',
          'IELTS 6.0'
        ],
        'correct': 2,
        'type': 'multiple_choice',
        'explanation':
            'Sinh viên tốt nghiệp phải đạt tối thiểu bậc 5 trong Khung năng lực ngoại ngữ 6 bậc dùng cho Việt Nam',
        'audioText':
            'Chuẩn đầu ra ngoại ngữ là bậc năm trên sáu trong khung năng lực',
        'difficulty': 'intermediate',
        'category': 'chuẩn đầu ra',
      },
      {
        'question': 'Diện tích phòng VR Center của trường là bao nhiêu?',
        'options': ['60m²', '90m²', '120m²', '150m²'],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'VR Center có diện tích 90m² với 12 chỗ ngồi trải nghiệm, phục vụ 25-30 người học',
        'audioText': 'Phòng VR Center có diện tích chín mười mét vuông',
        'difficulty': 'advanced',
        'category': 'cơ sở vật chất',
      },
      {
        'question': 'Học phí tại DHV được tính theo đơn vị nào?',
        'options': ['Học kỳ', 'Năm học', 'Tín chỉ', 'Môn học'],
        'correct': 2,
        'type': 'multiple_choice',
        'explanation':
            'DHV áp dụng hình thức đào tạo theo hệ thống tín chỉ, học phí tính theo số tín chỉ đăng ký',
        'audioText': 'Học phí được tính theo tín chỉ',
        'difficulty': 'basic',
        'category': 'học phí',
      },
      {
        'question': 'Khoa Ngôn ngữ có những ngành nào?',
        'options': [
          'Anh, Pháp, Đức, Ý',
          'Anh, Trung, Nhật, Hàn',
          'Anh, Trung, Nhật, Nga',
          'Anh, Trung, Thái, Lào'
        ],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Khoa Ngôn ngữ có 4 ngành: Ngôn ngữ Anh, Ngôn ngữ Trung Quốc, Ngôn ngữ Nhật, Ngôn ngữ Hàn Quốc',
        'audioText': 'Khoa Ngôn ngữ có Anh, Trung, Nhật và Hàn',
        'difficulty': 'intermediate',
        'category': 'ngôn ngữ',
      },
      {
        'question': 'Số điện thoại tổng đài của trường DHV là?',
        'options': [
          '028 7100 1888',
          '028 7100 1999',
          '028 7100 1777',
          '028 7100 1666'
        ],
        'correct': 0,
        'type': 'multiple_choice',
        'explanation': 'Số điện thoại tổng đài: (+84) 287 1001 888',
        'audioText':
            'Số điện thoại tổng đài là không hai tám, bảy một không zero một tám tám tám',
        'difficulty': 'basic',
        'category': 'liên hệ',
      },
      {
        'question': 'Email chính thức của trường DHV là?',
        'options': [
          'info@dhv.vn',
          'dhv@edu.vn',
          'info@dhv.edu.vn',
          'contact@dhv.edu.vn'
        ],
        'correct': 2,
        'type': 'multiple_choice',
        'explanation': 'Email chính thức: info@dhv.edu.vn',
        'audioText': 'Email chính thức là info tại dhv chấm edu chấm vn',
        'difficulty': 'basic',
        'category': 'liên hệ',
      },
      {
        'question': 'Website chính thức của trường DHV là gì?',
        'options': [
          'www.dhv.vn',
          'www.dhv.edu.vn',
          'www.hungvuong.edu.vn',
          'www.dhvuniversity.edu.vn'
        ],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation': 'Website chính thức: www.dhv.edu.vn',
        'audioText': 'Website chính thức là www chấm dhv chấm edu chấm vn',
        'difficulty': 'basic',
        'category': 'liên hệ',
      },
      {
        'question': 'Tầm nhìn của trường DHV là gì?',
        'options': [
          'Trường đại học hàng đầu Việt Nam',
          'Trường đại học định hướng ứng dụng theo mô hình khởi nghiệp',
          'Trường đại học công nghệ số 1',
          'Trường đại học quốc tế'
        ],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'DHV trở thành trường đại học định hướng ứng dụng theo mô hình đại học khởi nghiệp hàng đầu Việt Nam và khu vực Châu Á',
        'audioText':
            'Tầm nhìn là trở thành trường đại học định hướng ứng dụng theo mô hình khởi nghiệp',
        'difficulty': 'intermediate',
        'category': 'tầm nhìn',
      },
      {
        'question': 'Đoàn TNCS Hồ Chí Minh trường DHV được thành lập năm nào?',
        'options': ['1995', '1996', '1997', '1998'],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Đoàn TNCS Hồ Chí Minh trường DHV được thành lập từ 25/04/1996',
        'audioText':
            'Đoàn thanh niên được thành lập năm một nghìn chín trăm chín mười sáu',
        'difficulty': 'advanced',
        'category': 'tổ chức',
      },
      {
        'question': 'Hội Sinh viên trường DHV được thành lập vào năm nào?',
        'options': ['2003', '2005', '2007', '2009'],
        'correct': 1,
        'type': 'multiple_choice',
        'explanation':
            'Hội Sinh viên trường Đại học Hùng Vương TPHCM được thành lập năm 2005',
        'audioText':
            'Hội sinh viên được thành lập năm hai nghìn không trăm lẻ năm',
        'difficulty': 'advanced',
        'category': 'tổ chức',
      },
      {
        'question': 'Logo mới nhất của trường DHV được công bố vào năm nào?',
        'options': ['2017', '2019', '2021', '2023'],
        'correct': 3,
        'type': 'multiple_choice',
        'explanation':
            'Ngày 14/11/2023, trường DHV thay đổi logo và bộ nhận diện thương hiệu mới đánh dấu bước ngoặt lớn',
        'audioText':
            'Logo mới được công bố năm hai nghìn không trăm hai mười ba',
        'difficulty': 'advanced',
        'category': 'thương hiệu',
      },
    ],

    // Unit 1 - Giới thiệu về trường DHV
    'unit1_basics': [
      {
        'question':
            'Trường Đại học Hùng Vương TP.HCM được thành lập vào năm nào?',
        'options': ['1993', '1995', '1997', '2000'],
        'correct': 1,
        'explanation':
            'Trường được thành lập theo Quyết định số 470/TTg ngày 14/08/1995 của Thủ tướng Chính Phủ',
        'hint': 'Là một trong những trường đại học ngoài công lập đầu tiên',
      },
      {
        'question': 'Ngày truyền thống của trường DHV là ngày nào?',
        'options': [
          '10 tháng 3 (âm lịch)',
          '9 tháng 3 (âm lịch)',
          '10 tháng 3 (dương lịch)',
          '9 tháng 3 (dương lịch)'
        ],
        'correct': 1,
        'explanation':
            'Ngày 9 tháng 3 âm lịch là ngày Giỗ Quốc tổ Hùng Vương, được chọn làm ngày truyền thống của trường',
        'hint': 'Liên quan đến Giỗ Tổ Hùng Vương',
      },
      {
        'question': 'Linh vật của trường DHV là gì?',
        'options': ['Chim Phượng Hoàng', 'Chim Lạc', 'Rồng Việt', 'Hổ Vàng'],
        'correct': 1,
        'explanation':
            'Chim Lạc được xem là biểu tượng của nhà nước Âu Lạc, tượng trưng cho điềm lành và sự phát triển',
      },
    ],

    'unit1_dhv_psychology': [
      {
        'question': 'Trụ sở chính của trường DHV ở đâu?',
        'options': [
          '736 Nguyễn Trãi, Phường 11, Quận 5',
          '756 Nguyễn Trãi, Phường 11, Quận 5',
          '28-30 Ngô Quyền, Phường 6, Quận 5',
          '736 Nguyễn Văn Cừ, Quận 5'
        ],
        'correct': 0,
        'explanation':
            'Trụ sở chính tại 736 Nguyễn Trãi, Phường 11, Quận 5, TP.HCM',
        'hint': 'Địa chỉ có số 736',
      },
      {
        'question': 'Slogan của trường DHV là gì?',
        'options': [
          'Hào khí Hùng Vương - Tương lai vững bước',
          'Tiên phong - Sáng tạo - Phát triển',
          'Tri thức - Phẩm chất - Thành công',
          'Học tập - Rèn luyện - Cống hiến'
        ],
        'correct': 0,
        'explanation':
            'Slogan "Hào khí Hùng Vương - Tương lai vững bước" thể hiện tinh thần và định hướng của trường',
      },
    ],

    'unit1_common_mistakes': [
      {
        'question': 'Giá trị cốt lõi của trường DHV bao gồm?',
        'options': [
          'Trách nhiệm - Tôn trọng - Tự tin',
          'Trách nhiệm - Trung nghĩa - Tự tin',
          'Tôn trọng - Trung thực - Tự lập',
          'Trung nghĩa - Tôn trọng - Tự chủ'
        ],
        'correct': 1,
        'explanation':
            'Ba giá trị cốt lõi: Trách nhiệm (Responsibility), Trung nghĩa (Respect), Tự tin (Readiness)',
        'hint': 'Ba chữ R trong tiếng Anh',
      },
      {
        'question': 'Loại hình của trường DHV là gì?',
        'options': ['Công lập', 'Bán công', 'Dân lập', 'Tư thục'],
        'correct': 3,
        'explanation':
            'Từ năm 2010, trường chuyển từ dân lập sang tư thục theo Quyết định số 705/QĐ-TTg',
        'hint': 'Chuyển đổi từ năm 2010',
      },
    ],

    // Unit 2 - Khoa Kỹ thuật Công nghệ
    'unit2_storytelling': [
      {
        'question': 'Khoa Kỹ thuật Công nghệ có phòng thực hành đặc biệt nào?',
        'options': [
          'Phòng thí nghiệm hóa học',
          'Phòng thực hành VR/Metaverse',
          'Phòng studio âm nhạc',
          'Phòng thực hành y khoa'
        ],
        'correct': 1,
        'explanation':
            'Khoa có phòng thực hành VR, Metaverse đầu tiên tại Việt Nam với công nghệ tiên tiến',
        'hint': 'Công nghệ thực tế ảo',
      },
      {
        'question': 'Mã ngành Công nghệ Thông tin tại DHV là gì?',
        'options': ['7480101', '7480201', '7480301', '7480401'],
        'correct': 1,
        'explanation': 'Ngành Công nghệ Thông tin có mã ngành 7480201',
      },
    ],

    'unit2_social_proof': [
      {
        'question': 'Các chuyên ngành của ngành CNTT tại DHV bao gồm?',
        'options': [
          'Công nghệ phần mềm, An ninh mạng, AI',
          'Công nghệ phần mềm, Truyền thông đa phương tiện, Mạng máy tính',
          'Lập trình web, Mobile, Game',
          'Big Data, Cloud Computing, IoT'
        ],
        'correct': 1,
        'explanation':
            'Gồm 4 chuyên ngành: Công nghệ phần mềm, Truyền thông đa phương tiện, Mạng máy tính và truyền thông, Kỹ thuật máy tính',
      },
      {
        'question': 'Diện tích phòng VR Center của trường là bao nhiêu?',
        'options': ['60m²', '90m²', '120m²', '150m²'],
        'correct': 1,
        'explanation':
            'VR Center có diện tích 90m² với 12 chỗ ngồi trải nghiệm, phục vụ 25-30 người học',
        'hint': 'Dưới 100m²',
      },
    ],

    'unit2_humor': [
      {
        'question': 'Chuẩn đầu ra ngoại ngữ cho sinh viên DHV là gì?',
        'options': [
          'Bậc 3/6 khung năng lực',
          'Bậc 4/6 khung năng lực',
          'Bậc 5/6 khung năng lực',
          'IELTS 6.0'
        ],
        'correct': 2,
        'explanation':
            'Sinh viên tốt nghiệp phải đạt tối thiểu bậc 5 trong Khung năng lực ngoại ngữ 6 bậc dùng cho Việt Nam',
      },
      {
        'question': 'Học phí tại DHV được tính theo?',
        'options': ['Học kỳ', 'Năm học', 'Tín chỉ', 'Môn học'],
        'correct': 2,
        'explanation':
            'DHV áp dụng hình thức đào tạo theo hệ thống tín chỉ, học phí tính theo số tín chỉ đăng ký',
        'hint': 'Hệ thống tín chỉ',
      },
    ],

    // Unit 3 - Các Khoa và Ngành học
    'unit3_confidence': [
      {
        'question': 'Trường DHV có bao nhiêu khoa đào tạo chính?',
        'options': ['5 khoa', '6 khoa', '7 khoa', '8 khoa'],
        'correct': 2,
        'explanation':
            'DHV có 7 khoa: Quản trị KD-Marketing, Tài chính-Ngân hàng-Kế toán, Ngôn ngữ, Du lịch-Nhà hàng-Khách sạn, Kỹ thuật Công nghệ, Luật, Khoa học sức khỏe',
      },
      {
        'question': 'Khoa nào có ngành Tâm lý học?',
        'options': [
          'Khoa Khoa học sức khỏe',
          'Khoa Quản trị Kinh doanh - Marketing',
          'Khoa Ngôn ngữ',
          'Khoa Luật'
        ],
        'correct': 1,
        'explanation':
            'Ngành Tâm lý học (mã 7310401) thuộc Khoa Quản trị Kinh doanh - Marketing',
        'hint': 'Liên quan đến hành vi con người trong kinh doanh',
      },
    ],

    'unit3_value_creation': [
      {
        'question': 'Khoa Ngôn ngữ có những ngành nào?',
        'options': [
          'Anh, Pháp, Đức, Ý',
          'Anh, Trung, Nhật, Hàn',
          'Anh, Trung, Nhật, Nga',
          'Anh, Trung, Thái, Lào'
        ],
        'correct': 1,
        'explanation':
            'Khoa Ngôn ngữ có 4 ngành: Ngôn ngữ Anh, Ngôn ngữ Trung Quốc, Ngôn ngữ Nhật, Ngôn ngữ Hàn Quốc',
      },
      {
        'question': 'Ngành nào có mã 7810201?',
        'options': [
          'Quản trị Du lịch',
          'Quản trị Nhà hàng',
          'Quản trị Khách sạn',
          'Quản trị Lữ hành'
        ],
        'correct': 2,
        'explanation':
            'Ngành Quản trị Khách sạn có mã 7810201 với 2 chuyên ngành: Quản trị khách sạn và dịch vụ lưu trú, Quản trị nhà hàng và dịch vụ ăn uống',
        'hint': 'Liên quan đến lưu trú',
      },
    ],

    'unit3_long_term': [
      {
        'question': 'Vườn ươm khởi nghiệp DHV hỗ trợ sinh viên như thế nào?',
        'options': [
          'Chỉ cho vay vốn',
          'Cơ sở vật chất, tư vấn, kết nối và đào tạo',
          'Chỉ cho thuê văn phòng',
          'Chỉ tư vấn pháp lý'
        ],
        'correct': 1,
        'explanation':
            'Vườn ươm DHV cung cấp hỗ trợ toàn diện: cơ sở vật chất, tư vấn chuyên môn, mạng lưới kết nối, mentorship và các khóa đào tạo',
      },
      {
        'question': 'Ngành Công nghệ Tài chính (Fintech) có mã ngành nào?',
        'options': ['7340201', '7340203', '7340205', '7340207'],
        'correct': 2,
        'explanation':
            'Ngành Công nghệ Tài chính (Fintech) có mã ngành 7340205, thuộc Khoa Tài chính - Ngân hàng - Kế toán',
        'hint': 'Kết thúc bằng 05',
      },
    ],

    // Unit 4 - Cơ sở vật chất và Dịch vụ
    'unit4_conversation': [
      {
        'question': 'Thư viện DHV cung cấp những dịch vụ nào?',
        'options': [
          'Chỉ cho mượn sách',
          'Sách, internet, học nhóm, không gian yên tĩnh',
          'Chỉ có phòng đọc',
          'Chỉ có sách giáo khoa'
        ],
        'correct': 1,
        'explanation':
            'Thư viện DHV có hàng ngàn đầu sách, khu vực đọc sách, truy cập internet, học nhóm với không gian hiện đại, thoáng đãng',
      },
      {
        'question': 'Số điện thoại tổng đài của trường DHV là?',
        'options': [
          '028 7100 1888',
          '028 7100 1999',
          '028 7100 1777',
          '028 7100 1666'
        ],
        'correct': 0,
        'explanation': 'Số điện thoại tổng đài: (+84) 287 1001 888',
        'hint': 'Kết thúc bằng 888',
      },
    ],

    'unit4_professional': [
      {
        'question': 'Cơ sở 1 của trường DHV ở đâu?',
        'options': [
          '736 Nguyễn Trãi, Q.5',
          '28-30 Ngô Quyền, P.6, Q.5',
          '30 Ngô Quyền, P.7, Q.5',
          '28 Nguyễn Trãi, P.6, Q.5'
        ],
        'correct': 1,
        'explanation': 'Cơ sở 1 tại 28-30 Ngô Quyền, Phường 6, Quận 5, TP.HCM',
      },
      {
        'question': 'Email chính thức của trường DHV là?',
        'options': [
          'info@dhv.vn',
          'dhv@edu.vn',
          'info@dhv.edu.vn',
          'contact@dhv.edu.vn'
        ],
        'correct': 2,
        'explanation': 'Email chính thức: info@dhv.edu.vn',
        'hint': 'Bắt đầu bằng info@',
      },
    ],

    'unit4_balance': [
      {
        'question': 'Tầm nhìn của trường DHV là gì?',
        'options': [
          'Trường đại học hàng đầu Việt Nam',
          'Trường đại học định hướng ứng dụng theo mô hình khởi nghiệp',
          'Trường đại học công nghệ số 1',
          'Trường đại học quốc tế'
        ],
        'correct': 1,
        'explanation':
            'DHV trở thành trường đại học định hướng ứng dụng theo mô hình đại học khởi nghiệp hàng đầu Việt Nam và khu vực Châu Á',
      },
      {
        'question': 'Đoàn TNCS Hồ Chí Minh trường DHV được thành lập năm nào?',
        'options': ['1995', '1996', '1997', '1998'],
        'correct': 1,
        'explanation':
            'Đoàn TNCS Hồ Chí Minh trường DHV được thành lập từ 25/04/1996',
        'hint': 'Một năm sau khi trường thành lập',
      },
    ],

    // Unit 5 - Chương trình đào tạo CNTT
    'unit5_vietnamese': [
      {
        'question':
            'Trong chương trình CNTT, môn học nào thuộc học kỳ 1 năm 1?',
        'options': [
          'Lập trình C/C++',
          'Nhập môn điện toán',
          'Cơ sở dữ liệu',
          'Mạng máy tính'
        ],
        'correct': 1,
        'explanation':
            'Học kỳ 1 năm 1 gồm: Nhập môn điện toán, Giải tích 1, Tư duy phản biện trong CNTT, Anh văn tổng quát 1',
      },
      {
        'question': 'Chuẩn đầu ra của ngành CNTT về kỹ năng ngoại ngữ là gì?',
        'options': [
          'TOEIC 450',
          'IELTS 5.0',
          'Bậc 3/6 khung năng lực',
          'Bậc 5/6 khung năng lực'
        ],
        'correct': 3,
        'explanation':
            'PLO6: Sử dụng tiếng Anh thành thạo đạt trình độ bậc 5/6 theo Khung năng lực ngoại ngữ của Việt Nam',
        'hint': 'Bậc 5 trên tổng số 6 bậc',
      },
    ],

    'unit5_cross_cultural': [
      {
        'question': 'Hội Sinh viên trường DHV được thành lập vào năm nào?',
        'options': ['2003', '2005', '2007', '2009'],
        'correct': 1,
        'explanation':
            'Hội Sinh viên trường Đại học Hùng Vương TPHCM được thành lập năm 2005',
      },
      {
        'question': 'Phòng Công tác Sinh viên và Xã hội có số máy lẻ (EXT) là?',
        'options': ['101', '102', '103', '104'],
        'correct': 3,
        'explanation':
            'Phòng Công tác Sinh viên và Xã hội có số máy lẻ EXT: 104, đặt tại Cơ sở 1',
        'hint': 'Số lớn nhất trong các đáp án',
      },
    ],

    'unit5_modern_dhv': [
      {
        'question': 'Website chính thức của trường DHV là gì?',
        'options': [
          'www.dhv.vn',
          'www.dhv.edu.vn',
          'www.hungvuong.edu.vn',
          'www.dhvuniversity.edu.vn'
        ],
        'correct': 1,
        'explanation': 'Website chính thức: www.dhv.edu.vn',
      },
      {
        'question': 'Logo mới nhất của trường DHV được công bố vào năm nào?',
        'options': ['2017', '2019', '2021', '2023'],
        'correct': 3,
        'explanation':
            'Ngày 14/11/2023, trường DHV thay đổi logo và bộ nhận diện thương hiệu mới đánh dấu bước ngoặt lớn',
        'hint': 'Gần đây nhất',
      },
    ],
  };

  /// Check if a lesson has quiz
  static bool hasQuiz(String lessonId) {
    return _quizDatabase.containsKey(lessonId) &&
        _quizDatabase[lessonId]!.isNotEmpty;
  }

  /// Get quiz statistics for progress tracking
  static Map<String, int> getQuizStats() {
    int totalQuizzes = 0;
    int totalQuestions = 0;

    _quizDatabase.forEach((lessonId, questions) {
      if (questions.isNotEmpty) {
        totalQuizzes++;
        totalQuestions += questions.length;
      }
    });

    return {
      'totalQuizzes': totalQuizzes,
      'totalQuestions': totalQuestions,
      'lessonsWithQuiz': _quizDatabase.keys.length,
    };
  }
}
