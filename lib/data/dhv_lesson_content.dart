/// DHV Learning Content Data - Dựa trên dữ liệu thực tế từ Sổ Tay Sinh Viên DHV
/// File này chứa tất cả nội dung cho các DHV Learning Cards theo 2 chương chính
/// Chương 1: Giới thiệu về Trường ĐH Hùng Vương
/// Chương 2: Các chương trình đào tạo - Focus Khoa Kỹ thuật Công nghệ
library;

class DHVLessonContent {
  // ========================================
  // VISUAL CONTENT - Nội dung hình ảnh
  // ========================================

  /// Timeline data cho các bài học - dựa trên dữ liệu thực tế DHV
  static Map<int, List<Map<String, dynamic>>> getTimelineData() {
    return {
      1: [
        {
          'year': '1995',
          'event':
              'Ngày 14/8/1995: Thủ tướng Chính phủ ban hành Quyết định số 470/TTg thành lập Trường Đại học Dân lập Hùng Vương'
        },
        {
          'year': '2008',
          'event':
              'Ngày 14/05/2008: Đổi tên thành Trường Đại học Hùng Vương TP. Hồ Chí Minh'
        },
        {
          'year': '2010',
          'event':
              'Ngày 19/05/2010: Chuyển đổi từ dân lập sang tư thục theo Quyết định số 705/QĐ-TTg'
        },
        {
          'year': '2017',
          'event':
              'Ngày 05/04/2017: Công bố logo và bộ nhận diện thương hiệu mới'
        },
        {
          'year': '2025',
          'event':
              'Ngày 14/11/2025: Thay đổi logo và bộ nhận diện thương hiệu mới - Kỷ niệm 30 năm'
        },
      ],
      2: [
        {'year': '1995', 'event': 'Bắt đầu với các ngành sư phạm cơ bản'},
        {
          'year': '2015',
          'event':
              'Thành lập Khoa Kỹ thuật Công nghệ - mở ngành Công nghệ Thông tin'
        },
        {
          'year': '2020',
          'event': 'Áp dụng công nghệ VR/Metaverse đầu tiên tại Việt Nam'
        },
        {
          'year': '2025',
          'event': 'Phát triển hoàn thiện với AI, Machine Learning, IoT'
        },
      ],
      3: [
        {
          'year': '2015',
          'event': 'Thành lập VR Center - diện tích 90m2, 12 chỗ trải nghiệm'
        },
        {
          'year': '2018',
          'event': 'Xây dựng phòng máy tính hiện đại với thiết bị đồng bộ'
        },
        {
          'year': '2020',
          'event': 'Nâng cấp thư viện số với hàng nghìn đầu sách điện tử'
        },
        {
          'year': '2022',
          'event': 'Hoàn thiện hệ thống phòng học với máy lạnh, máy chiếu, wifi'
        },
      ],
      4: [
        {
          'year': '1995',
          'event': 'Khởi đầu với cơ sở vật chất cơ bản tại TP.HCM'
        },
        {'year': '2008', 'event': 'Mở rộng cơ sở I tại 28-50 Ngô Quyền, Q.5'},
        {
          'year': '2017',
          'event': 'Nâng cấp toàn diện cơ sở vật chất và trang thiết bị'
        },
        {
          'year': '2025',
          'event': 'Hoàn thiện campus hiện đại với công nghệ 4.0'
        },
      ],
      5: [
        {
          'year': '1995',
          'event': 'Thành lập với cơ cấu đơn giản - Hiệu trưởng và các bộ phận'
        },
        {
          'year': '2010',
          'event': 'Hoàn thiện cơ cấu tổ chức với đầy đủ phòng ban chức năng'
        },
        {
          'year': '2017',
          'event': 'Thành lập đầy đủ 7 Khoa đào tạo chuyên ngành'
        },
        {
          'year': '2025',
          'event':
              'Cơ cấu hoàn chỉnh: Ban Giám hiệu, 8 Phòng, 7 Khoa, 5 Trung tâm'
        },
      ],
      6: [
        {
          'year': '2000',
          'event': 'Thành lập Phòng Công tác Sinh viên đầu tiên'
        },
        {'year': '2010', 'event': 'Mở rộng với Phòng Đào tạo và Khảo thí'},
        {
          'year': '2015',
          'event': 'Thành lập Trung tâm Tuyển sinh và Quan hệ doanh nghiệp'
        },
        {
          'year': '2020',
          'event': 'Hoàn thiện hệ thống hỗ trợ toàn diện cho sinh viên'
        },
      ],
      7: [
        {'year': '1995-2000', 'event': 'Khởi đầu với các ngành Sư phạm cơ bản'},
        {'year': '2005-2010', 'event': 'Mở rộng với Khoa Kinh tế và Quản trị'},
        {'year': '2015', 'event': 'Thành lập Khoa Kỹ thuật Công nghệ'},
        {
          'year': '2025',
          'event':
              'Đầy đủ 7 Khoa: QTKD, TCNH, Ngôn ngữ, Du lịch, KTCN, Luật, KHSK'
        },
      ],
      8: [
        {
          'year': '2015',
          'event': 'Khởi đầu chuyên ngành Kỹ thuật máy tính trong ngành CNTT'
        },
        {
          'year': '2018',
          'event': 'Phát triển curriculum với các môn IoT và hệ thống nhúng'
        },
        {
          'year': '2020',
          'event': 'Ứng dụng AI và Machine Learning vào chương trình đào tạo'
        },
        {
          'year': '2025',
          'event': 'Hoàn thiện chuyên ngành với công nghệ 4.0 hiện đại'
        },
      ],
      9: [
        {
          'year': '2015',
          'event': 'Ban hành chuẩn đầu ra đầu tiên cho các ngành'
        },
        {
          'year': '2018',
          'event': 'Cập nhật chuẩn ngoại ngữ theo khung Châu Âu CEFR'
        },
        {
          'year': '2020',
          'event': 'Tích hợp chuẩn tin học Microsoft Office Specialist'
        },
        {
          'year': '2025',
          'event': 'Hoàn thiện chuẩn đầu ra theo xu hướng số hóa'
        },
      ],
      10: [
        {
          'year': '2010',
          'event': 'Bắt đầu nghiên cứu về Internet of Things (IoT)'
        },
        {
          'year': '2015',
          'event': 'Đưa IoT vào chương trình đào tạo chuyên ngành KTMT'
        },
        {
          'year': '2020',
          'event': 'Phát triển lab IoT với các thiết bị sensor hiện đại'
        },
        {
          'year': '2025',
          'event': 'Hoàn thiện hệ sinh thái IoT trong campus thông minh'
        },
      ],
      11: [
        {
          'year': '2012',
          'event': 'Nghiên cứu và phát triển hệ thống nhúng cơ bản'
        },
        {
          'year': '2017',
          'event': 'Tích hợp embedded systems vào curriculum KTMT'
        },
        {
          'year': '2021',
          'event': 'Xây dựng lab embedded với ARM, Arduino, Raspberry Pi'
        },
        {'year': '2025', 'event': 'Ứng dụng embedded AI và edge computing'},
      ],
      12: [
        {
          'year': '2016',
          'event': 'Bắt đầu ứng dụng Machine Learning trong nghiên cứu'
        },
        {'year': '2019', 'event': 'Đưa AI/ML vào chương trình đào tạo CNTT'},
        {
          'year': '2022',
          'event': 'Phát triển các project AI thực tế với doanh nghiệp'
        },
        {
          'year': '2025',
          'event': 'Trở thành center AI hàng đầu khu vực miền Nam'
        },
      ],
      13: [
        {
          'year': '2018',
          'event': 'Nghiên cứu Big Data và analytics cho doanh nghiệp'
        },
        {
          'year': '2020',
          'event': 'Xây dựng data center và cloud infrastructure'
        },
        {
          'year': '2023',
          'event': 'Triển khai data science program với Python/R'
        },
        {'year': '2025', 'event': 'Hoàn thiện data-driven university model'},
      ],
      14: [
        {
          'year': '2019',
          'event': 'Khởi đầu nghiên cứu về Blockchain technology'
        },
        {'year': '2021', 'event': 'Phát triển smart contracts và DApps'},
        {'year': '2023', 'event': 'Ứng dụng blockchain trong quản lý học tập'},
        {
          'year': '2025',
          'event': 'Trở thành blockchain hub cho education sector'
        },
      ],
      15: [
        {
          'year': '2020',
          'event': 'Bắt đầu nghiên cứu Cybersecurity và bảo mật'
        },
        {'year': '2022', 'event': 'Thành lập Security Operations Center (SOC)'},
        {
          'year': '2024',
          'event': 'Triển khai ethical hacking và penetration testing'
        },
        {'year': '2025', 'event': 'Trở thành cybersecurity training center'},
      ],
      16: [
        {
          'year': '2021',
          'event': 'Khởi đầu Cloud Computing và DevOps practices'
        },
        {
          'year': '2023',
          'event': 'Xây dựng multi-cloud infrastructure với AWS/Azure'
        },
        {
          'year': '2024',
          'event': 'Triển khai containerization với Docker/Kubernetes'
        },
        {
          'year': '2025',
          'event': 'Hoàn thiện cloud-native university architecture'
        },
      ],
    };
  }

  /// Gallery data cho các bài học - dựa trên cơ sở vật chất thực tế DHV
  static Map<int, List<Map<String, dynamic>>> getGalleryData() {
    return {
      1: [
        {
          'title': 'Trụ sở chính DHV',
          'description': '756 Nguyễn Trãi, Phường 11, Quận 5, TP.HCM',
          'imageUrl': 'assets/images/dhv_main_campus.jpg'
        },
        {
          'title': 'Cơ sở I',
          'description': '28-50 Ngô Quyền, Phường 6, Quận 5, TP.HCM',
          'imageUrl': 'assets/images/dhv_campus_1.jpg'
        },
        {
          'title': 'Logo truyền thống',
          'description': 'Logo DHV từ 1995 với slogan "Hào khí Hùng Vương"',
          'imageUrl': 'assets/images/dhv_old_logo.png'
        },
        {
          'title': 'Logo mới 2025',
          'description': 'Bộ nhận diện thương hiệu mới "Tương lai vững bước"',
          'imageUrl': 'assets/images/dhv_new_logo.png'
        },
      ],
      2: [
        {
          'title': 'VR Center',
          'description':
              'Diện tích 90m2, 12 chỗ ngồi trải nghiệm, 25-50 học viên',
          'imageUrl': 'assets/images/vr_center.jpg'
        },
        {
          'title': 'Phòng máy tính',
          'description': 'Thiết bị máy tính đồng bộ hiện đại cho học tập',
          'imageUrl': 'assets/images/computer_lab.jpg'
        },
        {
          'title': 'Phòng học',
          'description': 'Máy lạnh, máy chiếu, wifi - không gian lý tưởng',
          'imageUrl': 'assets/images/classroom.jpg'
        },
        {
          'title': 'Thư viện',
          'description': 'Hàng nghìn đầu sách, khu đọc, internet, học nhóm',
          'imageUrl': 'assets/images/library.jpg'
        },
      ],
      3: [
        {
          'title': 'Linh vật Chim Lạc',
          'description':
              'Biểu tượng của nhà nước Âu Lạc, điềm lành và phát triển',
          'imageUrl': 'assets/images/chim_lac.png'
        },
        {
          'title': 'Văn phòng các Khoa',
          'description':
              'Không gian hiện đại, kết nối thân thiện với sinh viên',
          'imageUrl': 'assets/images/faculty_office.jpg'
        },
        {
          'title': 'Khu vực học nhóm',
          'description': 'Không gian mở khuyến khích trao đổi và thảo luận',
          'imageUrl': 'assets/images/study_area.jpg'
        },
      ],
      4: [
        {
          'title': 'Trụ sở chính 756 Nguyễn Trãi',
          'description': 'Cơ sở chính với đầy đủ tiện nghi hiện đại',
          'imageUrl': 'assets/images/main_building.jpg'
        },
        {
          'title': 'Cơ sở I Ngô Quyền',
          'description': 'Cơ sở phụ rộng rãi cho hoạt động học tập',
          'imageUrl': 'assets/images/ngo_quyen_campus.jpg'
        },
        {
          'title': 'Cảnh quan xanh',
          'description': 'Môi trường học tập thân thiện với thiên nhiên',
          'imageUrl': 'assets/images/green_campus.jpg'
        },
        {
          'title': 'Khu vực sinh hoạt',
          'description': 'Không gian nghỉ ngơi và giao lưu của sinh viên',
          'imageUrl': 'assets/images/student_activities.jpg'
        },
      ],
      5: [
        {
          'title': 'Ban Giám hiệu',
          'description': 'Hiệu trưởng và 2 Hiệu phó điều hành trường',
          'imageUrl': 'assets/images/leadership_team.jpg'
        },
        {
          'title': 'Sơ đồ tổ chức',
          'description': 'Cơ cấu hoàn chỉnh từ lãnh đạo đến cơ sở',
          'imageUrl': 'assets/images/organization_chart.jpg'
        },
        {
          'title': 'Hội đồng Trường',
          'description': 'Cơ quan quyết định chiến lược phát triển',
          'imageUrl': 'assets/images/board_council.jpg'
        },
        {
          'title': 'Các Hội đồng chuyên môn',
          'description': 'Khoa học Đào tạo, Đảm bảo chất lượng',
          'imageUrl': 'assets/images/academic_councils.jpg'
        },
      ],
      6: [
        {
          'title': 'Phòng Công tác Sinh viên',
          'description': 'Hỗ trợ và chăm sóc sinh viên toàn diện',
          'imageUrl': 'assets/images/student_affairs.jpg'
        },
        {
          'title': 'Phòng Đào tạo',
          'description': 'Quản lý chương trình và hoạt động đào tạo',
          'imageUrl': 'assets/images/academic_office.jpg'
        },
        {
          'title': 'Trung tâm Tuyển sinh',
          'description': 'Tư vấn tuyển sinh và quan hệ doanh nghiệp',
          'imageUrl': 'assets/images/admission_center.jpg'
        },
        {
          'title': 'Phòng Khảo thí',
          'description': 'Tổ chức thi cử và đánh giá chất lượng',
          'imageUrl': 'assets/images/examination_office.jpg'
        },
      ],
      7: [
        {
          'title': 'Khoa Quản trị Kinh doanh',
          'description': 'Marketing, Thương mại điện tử, Quản trị nhân lực',
          'imageUrl': 'assets/images/business_faculty.jpg'
        },
        {
          'title': 'Khoa Kỹ thuật Công nghệ',
          'description': 'CNTT, Kỹ thuật máy tính, VR/AI/IoT',
          'imageUrl': 'assets/images/tech_faculty.jpg'
        },
        {
          'title': 'Khoa Ngôn ngữ',
          'description': 'Tiếng Anh, Nhật, Trung, Hàn với công nghệ Metaverse',
          'imageUrl': 'assets/images/language_faculty.jpg'
        },
        {
          'title': '4 Khoa khác',
          'description': 'Tài chính, Du lịch, Luật, Khoa học Sức khỏe',
          'imageUrl': 'assets/images/other_faculties.jpg'
        },
      ],
      8: [
        {
          'title': 'Chuyên ngành Kỹ thuật máy tính',
          'description': 'Thiết kế mạch logic, lập trình nhúng điều khiển',
          'imageUrl': 'assets/images/computer_engineering.jpg'
        },
        {
          'title': 'Lab Hệ thống vi xử lý',
          'description': 'Thực hành với ARM Cortex, STM32, PIC',
          'imageUrl': 'assets/images/microprocessor_lab.jpg'
        },
        {
          'title': 'Linh kiện điện tử',
          'description': 'Sensors, actuators, IC, development boards',
          'imageUrl': 'assets/images/electronic_components.jpg'
        },
        {
          'title': 'Project embedded systems',
          'description': 'Smart home, robotics, automation projects',
          'imageUrl': 'assets/images/embedded_projects.jpg'
        },
      ],
      9: [
        {
          'title': 'Chuẩn ngoại ngữ CEFR',
          'description': 'Khung tham chiếu ngôn ngữ chung Châu Âu',
          'imageUrl': 'assets/images/cefr_standard.jpg'
        },
        {
          'title': 'Chứng chỉ Microsoft',
          'description': 'Office Specialist, Azure, Programming',
          'imageUrl': 'assets/images/microsoft_certs.jpg'
        },
        {
          'title': 'Kỹ năng số 4.0',
          'description': 'AI, Data Analytics, Digital Marketing',
          'imageUrl': 'assets/images/digital_skills.jpg'
        },
        {
          'title': 'Đánh giá năng lực',
          'description': 'Hệ thống kiểm tra và xác nhận chuẩn đầu ra',
          'imageUrl': 'assets/images/competency_assessment.jpg'
        },
      ],
      10: [
        {
          'title': 'IoT Lab DHV',
          'description': 'Lab Internet of Things với sensors và gateways',
          'imageUrl': 'assets/images/iot_lab.jpg'
        },
        {
          'title': 'Smart sensors',
          'description': 'Temperature, humidity, motion, light sensors',
          'imageUrl': 'assets/images/smart_sensors.jpg'
        },
        {
          'title': 'IoT Gateway',
          'description': 'Raspberry Pi, ESP32, Arduino connectivity',
          'imageUrl': 'assets/images/iot_gateway.jpg'
        },
        {
          'title': 'Smart Campus DHV',
          'description': 'IoT deployment trong campus thông minh',
          'imageUrl': 'assets/images/smart_campus.jpg'
        },
      ],
      11: [
        {
          'title': 'Embedded Systems Lab',
          'description': 'Phòng thực hành hệ thống nhúng hiện đại',
          'imageUrl': 'assets/images/embedded_lab.jpg'
        },
        {
          'title': 'Arduino Development',
          'description': 'Arduino Uno, Nano, Mega cho prototyping',
          'imageUrl': 'assets/images/arduino_dev.jpg'
        },
        {
          'title': 'Raspberry Pi Projects',
          'description': 'Single board computer cho embedded Linux',
          'imageUrl': 'assets/images/raspberry_pi.jpg'
        },
        {
          'title': 'ARM Cortex Development',
          'description': 'STM32, TI LaunchPad cho advanced embedded',
          'imageUrl': 'assets/images/arm_cortex.jpg'
        },
      ],
      12: [
        {
          'title': 'AI/ML Research Center',
          'description': 'Trung tâm nghiên cứu trí tuệ nhân tạo DHV',
          'imageUrl': 'assets/images/ai_research.jpg'
        },
        {
          'title': 'Machine Learning Lab',
          'description': 'GPU clusters cho deep learning training',
          'imageUrl': 'assets/images/ml_lab.jpg'
        },
        {
          'title': 'Computer Vision',
          'description': 'Image processing, object detection projects',
          'imageUrl': 'assets/images/computer_vision.jpg'
        },
        {
          'title': 'Natural Language Processing',
          'description': 'Vietnamese NLP, chatbot development',
          'imageUrl': 'assets/images/nlp_lab.jpg'
        },
      ],
      13: [
        {
          'title': 'Big Data Center',
          'description': 'Trung tâm xử lý dữ liệu lớn DHV',
          'imageUrl': 'assets/images/big_data_center.jpg'
        },
        {
          'title': 'Data Analytics Lab',
          'description': 'Hadoop, Spark cluster cho data processing',
          'imageUrl': 'assets/images/data_analytics.jpg'
        },
        {
          'title': 'Cloud Infrastructure',
          'description': 'AWS, Azure, GCP cloud services',
          'imageUrl': 'assets/images/cloud_infra.jpg'
        },
        {
          'title': 'Data Visualization',
          'description': 'Tableau, Power BI, Python dashboard',
          'imageUrl': 'assets/images/data_viz.jpg'
        },
      ],
      14: [
        {
          'title': 'Blockchain Lab',
          'description': 'Phòng thực hành công nghệ blockchain',
          'imageUrl': 'assets/images/blockchain_lab.jpg'
        },
        {
          'title': 'Smart Contracts',
          'description': 'Ethereum, Solidity development environment',
          'imageUrl': 'assets/images/smart_contracts.jpg'
        },
        {
          'title': 'Cryptocurrency Mining',
          'description': 'Educational mining rig và wallet security',
          'imageUrl': 'assets/images/crypto_mining.jpg'
        },
        {
          'title': 'DApps Development',
          'description': 'Decentralized applications for education',
          'imageUrl': 'assets/images/dapps_dev.jpg'
        },
      ],
      15: [
        {
          'title': 'Cybersecurity Lab',
          'description': 'Phòng thực hành an ninh mạng DHV',
          'imageUrl': 'assets/images/cybersec_lab.jpg'
        },
        {
          'title': 'Ethical Hacking',
          'description': 'Penetration testing và vulnerability assessment',
          'imageUrl': 'assets/images/ethical_hacking.jpg'
        },
        {
          'title': 'Security Operations Center',
          'description': 'SOC monitoring và incident response',
          'imageUrl': 'assets/images/soc_center.jpg'
        },
        {
          'title': 'Forensics Investigation',
          'description': 'Digital forensics và malware analysis',
          'imageUrl': 'assets/images/forensics.jpg'
        },
      ],
      16: [
        {
          'title': 'Cloud Computing Lab',
          'description': 'Phòng thực hành điện toán đám mây',
          'imageUrl': 'assets/images/cloud_lab.jpg'
        },
        {
          'title': 'DevOps Pipeline',
          'description': 'CI/CD với Jenkins, Git, Docker',
          'imageUrl': 'assets/images/devops_pipeline.jpg'
        },
        {
          'title': 'Container Orchestration',
          'description': 'Kubernetes cluster management',
          'imageUrl': 'assets/images/kubernetes.jpg'
        },
        {
          'title': 'Microservices Architecture',
          'description': 'Distributed systems và API gateway',
          'imageUrl': 'assets/images/microservices.jpg'
        },
      ],
    };
  }

  // ========================================
  // AUDIO CONTENT - Nội dung âm thanh
  // ========================================

  /// Pronunciation data cho các bài học - từ vựng thực tế DHV
  static Map<int, List<Map<String, dynamic>>> getPronunciationData() {
    return {
      1: [
        {
          'word': 'Hùng Vương',
          'ipa': '/hʊŋ¹ vɯɤŋ¹/',
          'meaning': 'Hung Vuong - Tên Quốc tổ, tên trường đại học'
        },
        {
          'word': 'Quốc tổ',
          'ipa': '/kwok⁵ tso³/',
          'meaning': 'National ancestor - Tổ tiên của dân tộc'
        },
        {
          'word': 'Tư thục',
          'ipa': '/tɨ¹ thuk⁵/',
          'meaning': 'Private - Loại hình trường ngoài công lập'
        },
        {
          'word': 'Sứ mệnh',
          'ipa': '/ʂɨ³ mɛɲ⁵/',
          'meaning': 'Mission - Nhiệm vụ và mục đích của tổ chức'
        },
        {
          'word': 'Tầm nhìn',
          'ipa': '/tam¹ ɲin³/',
          'meaning': 'Vision - Định hướng phát triển tương lai'
        },
        {
          'word': 'Chim Lạc',
          'ipa': '/tʂim¹ laːk⁵/',
          'meaning': 'Lac bird - Linh vật biểu tượng nhà nước Âu Lạc'
        },
      ],
      2: [
        {
          'word': 'Công nghệ thông tin',
          'ipa': '/koŋ¹ ŋɛ⁵ tʰoŋ¹ tin¹/',
          'meaning': 'Information Technology - Ngành học về máy tính'
        },
        {
          'word': 'Metaverse',
          'ipa': '/ˈmetəˌvɜːrs/',
          'meaning': 'Virtual world - Thế giới ảo ba chiều'
        },
        {
          'word': 'VR Center',
          'ipa': '/viː ɑːr ˈsentər/',
          'meaning': 'Virtual Reality Center - Trung tâm thực tế ảo'
        },
        {
          'word': 'Trí tuệ nhân tạo',
          'ipa': '/tʂi³ twe⁵ ɲən¹ taːw³/',
          'meaning': 'Artificial Intelligence - AI, máy học thông minh'
        },
        {
          'word': 'Machine Learning',
          'ipa': '/məˈʃiːn ˈlɜːrnɪŋ/',
          'meaning': 'Học máy - Phương pháp dạy máy tính học'
        },
        {
          'word': 'IoT',
          'ipa': '/aɪ oʊ tiː/',
          'meaning': 'Internet of Things - Mạng lưới vạn vật kết nối'
        },
      ],
      3: [
        {
          'word': 'Cơ sở vật chất',
          'ipa': '/kɤ¹ ʂɤ³ vat⁵ tʂat⁵/',
          'meaning': 'Facilities - Trang thiết bị và hạ tầng'
        },
        {
          'word': 'Phòng máy',
          'ipa': '/foŋ¹ maːj¹/',
          'meaning': 'Computer lab - Phòng thực hành máy tính'
        },
        {
          'word': 'Thư viện',
          'ipa': '/tʰɨ¹ viən³/',
          'meaning': 'Library - Nơi lưu trữ sách và tài liệu'
        },
        {
          'word': 'Wifi',
          'ipa': '/ˈwaɪfaɪ/',
          'meaning': 'Wireless network - Mạng internet không dây'
        },
      ],
      4: [
        {
          'word': 'Cơ sở vật chất',
          'ipa': '/kɤ¹ ʂɤ³ vat⁵ tʂat⁵/',
          'meaning': 'Facilities - Trang thiết bị và hạ tầng vật chất'
        },
        {
          'word': 'Campus',
          'ipa': '/ˈkæmpəs/',
          'meaning': 'University campus - Khuôn viên trường đại học'
        },
        {
          'word': 'Máy lạnh',
          'ipa': '/maːj¹ laːɲ³/',
          'meaning': 'Air conditioner - Thiết bị điều hòa không khí'
        },
        {
          'word': 'Máy chiếu',
          'ipa': '/maːj¹ tʂiə́w³/',
          'meaning': 'Projector - Thiết bị chiếu hình ảnh'
        },
      ],
      5: [
        {
          'word': 'Hệ thống tổ chức',
          'ipa': '/hɛ⁵ tʰoŋ³ tɔ³ tʂɨ̌k⁵/',
          'meaning': 'Organizational system - Cơ cấu quản lý'
        },
        {
          'word': 'Ban Giám hiệu',
          'ipa': '/ban¹ zaːm³ hiə̀w⁵/',
          'meaning': 'Board of Directors - Lãnh đạo trường'
        },
        {
          'word': 'Hội đồng',
          'ipa': '/hoj¹ doŋ³/',
          'meaning': 'Council - Cơ quan quyết định tập thể'
        },
        {
          'word': 'Phòng ban',
          'ipa': '/foŋ¹ ban¹/',
          'meaning': 'Department - Đơn vị chức năng'
        },
      ],
      6: [
        {
          'word': 'Công tác sinh viên',
          'ipa': '/koŋ¹ taːk⁵ ʂiɲ¹ viən¹/',
          'meaning': 'Student Affairs - Chăm sóc hỗ trợ sinh viên'
        },
        {
          'word': 'Đào tạo',
          'ipa': '/daːw¹ taw³/',
          'meaning': 'Training/Education - Quá trình giảng dạy'
        },
        {
          'word': 'Tuyển sinh',
          'ipa': '/twiən³ ʂiɲ¹/',
          'meaning': 'Admission - Tuyển chọn học sinh vào trường'
        },
        {
          'word': 'Khảo thí',
          'ipa': '/kʰaːw³ tʰi³/',
          'meaning': 'Examination - Tổ chức kỳ thi'
        },
      ],
      7: [
        {
          'word': 'Khoa đào tạo',
          'ipa': '/kʰwaː¹ daːw¹ taw³/',
          'meaning': 'Faculty - Đơn vị đào tạo chuyên ngành'
        },
        {
          'word': 'Quản trị kinh doanh',
          'ipa': '/kwaːn³ tʂi³ kiɲ¹ zoan¹/',
          'meaning': 'Business Administration - Ngành quản lý doanh nghiệp'
        },
        {
          'word': 'Kỹ thuật công nghệ',
          'ipa': '/ki³ tʰuat⁵ koŋ¹ ŋɛ⁵/',
          'meaning': 'Engineering Technology - Ngành kỹ thuật ứng dụng'
        },
        {
          'word': 'Ngôn ngữ',
          'ipa': '/ŋon¹ ŋɨ̃³/',
          'meaning': 'Language - Tiếng nói và chữ viết'
        },
      ],
      8: [
        {
          'word': 'Kỹ thuật máy tính',
          'ipa': '/ki³ tʰuat⁵ maːj¹ tiɲ³/',
          'meaning':
              'Computer Engineering - Thiết kế và phát triển hệ thống máy tính'
        },
        {
          'word': 'Vi xử lý',
          'ipa': '/vi¹ sɨ̃³ li³/',
          'meaning': 'Microprocessor - Bộ xử lý trung tâm của máy tính'
        },
        {
          'word': 'Hệ thống nhúng',
          'ipa': '/hɛ⁵ tʰoŋ³ ɲuŋ³/',
          'meaning': 'Embedded Systems - Hệ thống máy tính chuyên dụng'
        },
        {
          'word': 'Linh kiện điện tử',
          'ipa': '/liɲ¹ kiən³ diən⁵ tɨ̃³/',
          'meaning': 'Electronic Components - Các bộ phận điện tử'
        },
        {
          'word': 'Mạch logic',
          'ipa': '/maːk⁵ ˈlɔdʒɪk/',
          'meaning': 'Logic Circuit - Mạch thực hiện các phép toán logic'
        },
        {
          'word': 'Lập trình nhúng',
          'ipa': '/lap⁵ tʂiɲ³ ɲuŋ³/',
          'meaning': 'Embedded Programming - Lập trình cho hệ thống nhúng'
        },
      ],
      9: [
        {
          'word': 'Chuẩn đầu ra',
          'ipa': '/tʂuən³ dəw¹ raː¹/',
          'meaning': 'Learning outcomes - Kết quả học tập đạt được'
        },
        {
          'word': 'Ngoại ngữ',
          'ipa': '/ŋwaːj⁵ ŋɨ̃³/',
          'meaning': 'Foreign language - Tiếng nước ngoài'
        },
        {
          'word': 'Tin học',
          'ipa': '/tin¹ hok⁵/',
          'meaning': 'Computer science - Khoa học máy tính'
        },
        {
          'word': 'CEFR',
          'ipa': '/siː iː ɛf ɑːr/',
          'meaning': 'European Framework - Khung tham chiếu Châu Âu'
        },
      ],
      10: [
        {
          'word': 'Internet of Things',
          'ipa': '/ˈɪntərnet ʌv θɪŋz/',
          'meaning': 'IoT - Mạng lưới các thiết bị kết nối internet'
        },
        {
          'word': 'Cảm biến',
          'ipa': '/kaːm³ biən³/',
          'meaning': 'Sensor - Thiết bị thu thập dữ liệu môi trường'
        },
        {
          'word': 'Gateway',
          'ipa': '/ˈɡeɪtweɪ/',
          'meaning': 'Cổng kết nối - Thiết bị trung gian kết nối mạng'
        },
        {
          'word': 'Smart Campus',
          'ipa': '/smɑːrt ˈkæmpəs/',
          'meaning': 'Trường thông minh - Campus ứng dụng IoT'
        },
        {
          'word': 'Connectivity',
          'ipa': '/kəˌnɛkˈtɪvɪti/',
          'meaning': 'Khả năng kết nối - Tính năng liên kết thiết bị'
        },
        {
          'word': 'Protocol',
          'ipa': '/ˈproʊtəkɔːl/',
          'meaning': 'Giao thức - Quy tắc truyền thông dữ liệu'
        },
      ],
      11: [
        {
          'word': 'Arduino',
          'ipa': '/ɑːrˈduinoʊ/',
          'meaning': 'Platform phát triển phần cứng mã nguồn mở'
        },
        {
          'word': 'Raspberry Pi',
          'ipa': '/ˈræzˌbɛri paɪ/',
          'meaning': 'Single board computer chạy Linux'
        },
        {
          'word': 'ARM Cortex',
          'ipa': '/ɑːrm ˈkɔːrteks/',
          'meaning': 'Kiến trúc vi xử lý hiệu năng cao'
        },
        {
          'word': 'Firmware',
          'ipa': '/ˈfɜːrmwɛr/',
          'meaning': 'Phần mềm cấp thấp điều khiển phần cứng'
        },
        {
          'word': 'Real-time',
          'ipa': '/riːl taɪm/',
          'meaning': 'Thời gian thực - Xử lý tức thời'
        },
        {
          'word': 'Debugging',
          'ipa': '/dɪˈbʌɡɪŋ/',
          'meaning': 'Gỡ lỗi - Tìm và sửa lỗi chương trình'
        },
      ],
      12: [
        {
          'word': 'Artificial Intelligence',
          'ipa': '/ˌɑːrtɪˈfɪʃəl ɪnˈtelɪdʒəns/',
          'meaning': 'AI - Trí tuệ nhân tạo'
        },
        {
          'word': 'Deep Learning',
          'ipa': '/diːp ˈlɜːrnɪŋ/',
          'meaning': 'Học sâu - Mạng neural nhiều lớp'
        },
        {
          'word': 'Neural Network',
          'ipa': '/ˈnʊrəl ˈnetˌwɜːrk/',
          'meaning': 'Mạng neural - Mô phỏng não bộ con người'
        },
        {
          'word': 'Computer Vision',
          'ipa': '/kəmˈpjuːtər ˈvɪʒən/',
          'meaning': 'Thị giác máy tính - Xử lý và phân tích hình ảnh'
        },
        {
          'word': 'Natural Language Processing',
          'ipa': '/ˈnætʃərəl ˈlæŋɡwɪdʒ ˈproʊsesɪŋ/',
          'meaning': 'NLP - Xử lý ngôn ngữ tự nhiên'
        },
        {
          'word': 'GPU Computing',
          'ipa': '/dʒiː piː juː kəmˈpjuːtɪŋ/',
          'meaning': 'Tính toán GPU - Xử lý song song hiệu năng cao'
        },
      ],
      13: [
        {
          'word': 'Big Data',
          'ipa': '/bɪɡ ˈdeɪtə/',
          'meaning': 'Dữ liệu lớn - Tập dữ liệu khổng lồ'
        },
        {
          'word': 'Data Analytics',
          'ipa': '/ˈdeɪtə æn̩əˈlɪtɪks/',
          'meaning': 'Phân tích dữ liệu - Khai thác thông tin từ dữ liệu'
        },
        {
          'word': 'Hadoop',
          'ipa': '/həˈduːp/',
          'meaning': 'Framework xử lý dữ liệu phân tán'
        },
        {
          'word': 'Apache Spark',
          'ipa': '/əˈpætʃi spɑːrk/',
          'meaning': 'Engine xử lý dữ liệu tốc độ cao'
        },
        {
          'word': 'Data Visualization',
          'ipa': '/ˈdeɪtə vɪʒuəlaɪˈzeɪʃən/',
          'meaning': 'Trực quan hóa dữ liệu - Biểu diễn dữ liệu bằng đồ họa'
        },
        {
          'word': 'Cloud Computing',
          'ipa': '/klaʊd kəmˈpjuːtɪŋ/',
          'meaning': 'Điện toán đám mây - Dịch vụ máy tính qua internet'
        },
      ],
      14: [
        {
          'word': 'Blockchain',
          'ipa': '/ˈblɔːktʃeɪn/',
          'meaning': 'Chuỗi khối - Cơ sở dữ liệu phân tán bảo mật'
        },
        {
          'word': 'Smart Contract',
          'ipa': '/smɑːrt ˈkɑːntrækt/',
          'meaning': 'Hợp đồng thông minh - Hợp đồng tự động thực thi'
        },
        {
          'word': 'Cryptocurrency',
          'ipa': '/ˈkrɪptoʊˌkɜːrənsi/',
          'meaning': 'Tiền điện tử - Tiền kỹ thuật số'
        },
        {
          'word': 'Ethereum',
          'ipa': '/ɪˈθɪriəm/',
          'meaning': 'Platform blockchain hỗ trợ smart contracts'
        },
        {
          'word': 'DApps',
          'ipa': '/di æps/',
          'meaning': 'Decentralized Apps - Ứng dụng phi tập trung'
        },
        {
          'word': 'Mining',
          'ipa': '/ˈmaɪnɪŋ/',
          'meaning': 'Đào coin - Quá trình xác thực giao dịch blockchain'
        },
      ],
      15: [
        {
          'word': 'Cybersecurity',
          'ipa': '/ˈsaɪbərˌsɪkjʊrɪti/',
          'meaning': 'An ninh mạng - Bảo vệ hệ thống số khỏi tấn công'
        },
        {
          'word': 'Ethical Hacking',
          'ipa': '/ˈeθɪkəl ˈhækɪŋ/',
          'meaning': 'Hack có đạo đức - Kiểm tra bảo mật hệ thống'
        },
        {
          'word': 'Penetration Testing',
          'ipa': '/ˌpenəˈtreɪʃən ˈtestɪŋ/',
          'meaning': 'Pentest - Kiểm tra xâm nhập hệ thống'
        },
        {
          'word': 'Vulnerability',
          'ipa': '/ˌvʌlnərəˈbɪləti/',
          'meaning': 'Lỗ hổng bảo mật - Điểm yếu trong hệ thống'
        },
        {
          'word': 'Malware',
          'ipa': '/ˈmælwɛr/',
          'meaning': 'Phần mềm độc hại - Virus, trojan, spyware'
        },
        {
          'word': 'Forensics',
          'ipa': '/fəˈrensɪks/',
          'meaning': 'Điều tra số - Phân tích chứng cứ kỹ thuật số'
        },
      ],
      16: [
        {
          'word': 'DevOps',
          'ipa': '/devɒps/',
          'meaning': 'Development Operations - Phương pháp phát triển phần mềm'
        },
        {
          'word': 'Containerization',
          'ipa': '/kənˌteɪnəraɪˈzeɪʃən/',
          'meaning': 'Đóng gói ứng dụng - Isolation và portability'
        },
        {
          'word': 'Docker',
          'ipa': '/ˈdɔːkər/',
          'meaning': 'Platform container hóa ứng dụng'
        },
        {
          'word': 'Kubernetes',
          'ipa': '/ˌkuːbərˈneɪtɪz/',
          'meaning': 'Orchestration platform cho containers'
        },
        {
          'word': 'Microservices',
          'ipa': '/ˈmaɪkroʊˌsɜːrvɪsəz/',
          'meaning': 'Kiến trúc chia nhỏ ứng dụng thành các dịch vụ'
        },
        {
          'word': 'CI/CD',
          'ipa': '/siː aɪ siː diː/',
          'meaning': 'Continuous Integration/Deployment - Tích hợp liên tục'
        },
      ],
    };
  }

  /// Vocabulary data cho các bài học - từ vựng thực tế về DHV
  static Map<int, Map<String, String>> getVocabularyData() {
    return {
      1: {
        'trường đại học': 'university - cơ sở giáo dục bậc cao',
        'quốc tổ': 'national ancestor - tổ tiên của dân tộc Việt',
        'hùng vương': 'hung vuong - vua đầu tiên của Việt Nam',
        'tư thục': 'private - loại hình trường ngoài công lập',
        'sứ mệnh': 'mission - nhiệm vụ và mục tiêu của trường',
        'tầm nhìn': 'vision - định hướng phát triển tương lai',
        'giá trị cốt lõi': 'core values - trách nhiệm, trung nghĩa, tự tin',
        'chim lạc': 'lac bird - linh vật trường, biểu tượng Âu Lạc',
        'văn lang': 'van lang - nhà nước đầu tiên của Việt Nam',
        'bộ giáo dục': 'ministry of education - cơ quan quản lý giáo dục',
      },
      2: {
        'công nghệ thông tin': 'information technology - ngành CNTT',
        'thực tế ảo': 'virtual reality - công nghệ VR, metaverse',
        'trí tuệ nhân tạo': 'artificial intelligence - AI, máy học',
        'học máy': 'machine learning - phương pháp dạy máy',
        'internet vạn vật': 'internet of things - IoT, kết nối thiết bị',
        'dữ liệu lớn': 'big data - xử lý dữ liệu khổng lồ',
        'khởi nghiệp': 'startup - bắt đầu kinh doanh sáng tạo',
        'vườn ươm': 'incubator - hỗ trợ dự án khởi nghiệp',
      },
      3: {
        'cơ sở vật chất': 'facilities - trang thiết bị và hạ tầng',
        'trụ sở chính': 'main campus - địa chỉ 756 Nguyễn Trãi Q5',
        'vr center': 'VR center - trung tâm thực tế ảo 90m2',
        'phòng máy tính': 'computer lab - phòng thực hành IT',
        'thư viện': 'library - nơi lưu trữ sách và tài liệu',
        'wifi miễn phí': 'free wifi - internet không dây toàn trường',
        'máy chiếu': 'projector - thiết bị hiển thị bài giảng',
        'máy lạnh': 'air conditioner - điều hòa không khí',
      },
      4: {
        'campus': 'campus - khuôn viên trường đại học',
        'cơ sở chính': 'main campus - 756 Nguyễn Trãi, Q.5',
        'cơ sở I': 'campus I - 28-50 Ngô Quyền, Q.5',
        'trang thiết bị': 'equipment - máy móc và dụng cụ',
        'hiện đại': 'modern - tiên tiến và đương đại',
        'không gian xanh': 'green space - khu vực cây cỏ',
        'môi trường học tập': 'learning environment - bầu không khí giáo dục',
        'tiện nghi': 'amenities - các tiện ích phục vụ',
      },
      5: {
        'tổ chức': 'organization - cơ cấu quản lý',
        'ban giám hiệu': 'board of directors - lãnh đạo trường',
        'hiệu trưởng': 'rector/president - người đứng đầu trường',
        'hiệu phó': 'vice rector - phó hiệu trưởng',
        'hội đồng trường': 'university council - cơ quan quyết định',
        'phòng ban': 'department - đơn vị chức năng',
        'khoa': 'faculty - đơn vị đào tạo',
        'trung tâm': 'center - đơn vị chuyên môn',
      },
      6: {
        'công tác sinh viên': 'student affairs - chăm sóc SV',
        'phòng đào tạo': 'academic office - quản lý học tập',
        'tuyển sinh': 'admission - tiếp nhận học sinh mới',
        'quan hệ doanh nghiệp': 'enterprise relations - liên kết với DN',
        'khảo thí': 'examination - tổ chức thi cử',
        'hỗ trợ sinh viên': 'student support - giúp đỡ SV',
        'học bổng': 'scholarship - hỗ trợ tài chính học tập',
        'hoạt động ngoại khóa': 'extracurricular - ngoài chương trình',
      },
      7: {
        'khoa đào tạo': 'academic faculty - đơn vị giảng dạy',
        'quản trị kinh doanh': 'business administration - ngành QTKD',
        'kỹ thuật công nghệ': 'engineering technology - ngành KTCN',
        'ngôn ngữ': 'languages - ngoại ngữ và tiếng Việt',
        'tài chính ngân hàng': 'finance banking - ngành TCNH',
        'du lịch': 'tourism - ngành du lịch lữ hành',
        'luật': 'law - ngành pháp luật',
        'khoa học sức khỏe': 'health science - ngành y tế',
      },
      9: {
        'chuẩn đầu ra': 'learning outcomes - kết quả học tập',
        'ngoại ngữ': 'foreign language - tiếng nước ngoài',
        'tin học': 'computer science - khoa học máy tính',
        'cefr': 'CEFR - khung tham chiếu Châu Âu',
        'microsoft office': 'MS Office - bộ phần mềm văn phòng',
        'chứng chỉ': 'certificate - bằng chứng năng lực',
        'kỹ năng số': 'digital skills - năng lực công nghệ',
        'đánh giá năng lực': 'competency assessment - kiểm tra kỹ năng',
      },
      8: {
        'kỹ thuật máy tính':
            'computer engineering - thiết kế hệ thống máy tính',
        'vi xử lý': 'microprocessor - bộ xử lý trung tâm',
        'hệ thống nhúng': 'embedded systems - hệ thống máy tính chuyên dụng',
        'linh kiện điện tử': 'electronic components - các bộ phận điện tử',
        'mạch logic': 'logic circuit - mạch thực hiện phép toán logic',
        'lập trình nhúng':
            'embedded programming - lập trình cho hệ thống nhúng',
        'arm cortex': 'ARM architecture - kiến trúc vi xử lý hiệu năng cao',
        'thiết kế logic số': 'digital logic design - thiết kế mạch số',
      },
      10: {
        'internet of things': 'IoT - mạng lưới thiết bị kết nối internet',
        'cảm biến': 'sensor - thiết bị thu thập dữ liệu môi trường',
        'gateway': 'cổng kết nối - thiết bị trung gian kết nối mạng',
        'smart campus': 'trường thông minh - campus ứng dụng IoT',
        'connectivity': 'khả năng kết nối - tính năng liên kết thiết bị',
        'protocol': 'giao thức - quy tắc truyền thông dữ liệu',
        'esp32': 'microcontroller - vi điều khiển với WiFi/Bluetooth',
        'wireless network': 'mạng không dây - kết nối không cần cáp',
      },
      11: {
        'arduino': 'platform phát triển phần cứng mã nguồn mở',
        'raspberry pi': 'single board computer - máy tính đơn bảng',
        'arm cortex': 'kiến trúc vi xử lý hiệu năng cao',
        'firmware': 'phần mềm cấp thấp - điều khiển phần cứng',
        'real-time': 'thời gian thực - xử lý tức thời',
        'debugging': 'gỡ lỗi - tìm và sửa lỗi chương trình',
        'stm32': 'vi điều khiển 32-bit ARM Cortex',
        'embedded linux': 'hệ điều hành Linux cho hệ thống nhúng',
      },
      12: {
        'artificial intelligence': 'AI - trí tuệ nhân tạo',
        'deep learning': 'học sâu - mạng neural nhiều lớp',
        'neural network': 'mạng neural - mô phỏng não bộ con người',
        'computer vision': 'thị giác máy tính - xử lý phân tích hình ảnh',
        'natural language processing': 'NLP - xử lý ngôn ngữ tự nhiên',
        'gpu computing': 'tính toán GPU - xử lý song song hiệu năng cao',
        'tensorflow': 'framework machine learning của Google',
        'pytorch': 'thư viện deep learning của Facebook',
      },
      13: {
        'big data': 'dữ liệu lớn - tập dữ liệu khổng lồ',
        'data analytics': 'phân tích dữ liệu - khai thác thông tin từ dữ liệu',
        'hadoop': 'framework xử lý dữ liệu phân tán',
        'apache spark': 'engine xử lý dữ liệu tốc độ cao',
        'data visualization': 'trực quan hóa dữ liệu - biểu diễn bằng đồ họa',
        'cloud computing': 'điện toán đám mây - dịch vụ máy tính qua internet',
        'data mining': 'khai thác dữ liệu - tìm kiếm pattern trong dữ liệu',
        'business intelligence':
            'thông minh kinh doanh - phân tích để ra quyết định',
      },
      14: {
        'blockchain': 'chuỗi khối - cơ sở dữ liệu phân tán bảo mật',
        'smart contract': 'hợp đồng thông minh - hợp đồng tự động thực thi',
        'cryptocurrency': 'tiền điện tử - tiền kỹ thuật số',
        'ethereum': 'platform blockchain hỗ trợ smart contracts',
        'dapps': 'decentralized apps - ứng dụng phi tập trung',
        'mining': 'đào coin - quá trình xác thực giao dịch blockchain',
        'consensus': 'cơ chế đồng thuận - thuật toán xác thực giao dịch',
        'decentralization':
            'phi tập trung - không có cơ quan quản lý trung tâm',
      },
      15: {
        'cybersecurity': 'an ninh mạng - bảo vệ hệ thống số khỏi tấn công',
        'ethical hacking': 'hack có đạo đức - kiểm tra bảo mật hệ thống',
        'penetration testing': 'pentest - kiểm tra xâm nhập hệ thống',
        'vulnerability': 'lỗ hổng bảo mật - điểm yếu trong hệ thống',
        'malware': 'phần mềm độc hại - virus trojan spyware',
        'forensics': 'điều tra số - phân tích chứng cứ kỹ thuật số',
        'firewall': 'tường lửa - hệ thống bảo vệ mạng',
        'encryption': 'mã hóa - bảo vệ thông tin bằng thuật toán',
      },
      16: {
        'devops': 'development operations - phương pháp phát triển phần mềm',
        'containerization': 'đóng gói ứng dụng - isolation và portability',
        'docker': 'platform container hóa ứng dụng',
        'kubernetes': 'orchestration platform cho containers',
        'microservices': 'kiến trúc chia nhỏ ứng dụng thành các dịch vụ',
        'ci/cd': 'continuous integration deployment - tích hợp liên tục',
        'jenkins': 'automation server cho CI/CD pipeline',
        'cloud native': 'ứng dụng được thiết kế cho môi trường cloud',
      },
    };
  }

  // ========================================
  // INTERACTIVE CONTENT - Nội dung tương tác
  // ========================================

  /// Quiz data cho các bài học - dựa trên thông tin thực tế DHV
  static Map<int, Map<String, dynamic>> getQuizData() {
    return {
      1: {
        'title': 'Kiểm tra kiến thức về Trường ĐH Hùng Vương',
        'questions': [
          {
            'question':
                'Trường Đại học Hùng Vương được thành lập theo quyết định nào?',
            'options': [
              '470/TTg ngày 14/8/1995',
              '705/QĐ-TTg năm 2010',
              '4167/BGDĐT-PC năm 2008',
              '123/TTg năm 2000'
            ],
            'correct': 0,
            'explanation':
                'Thủ tướng Chính phủ ban hành Quyết định số 470/TTg ngày 14/8/1995 thành lập Trường Đại học Dân lập Hùng Vương.'
          },
          {
            'question': 'Ý nghĩa tên trường Hùng Vương liên quan đến điều gì?',
            'options': [
              'Tên của nhà sáng lập',
              'Tên Quốc tổ dân tộc Việt',
              'Tên địa danh lịch sử',
              'Tên vua thời Nguyễn'
            ],
            'correct': 1,
            'explanation':
                'Trường mang tên Quốc tổ Hùng Vương để ghi nhớ và phát huy truyền thống tốt đẹp của thời đại Hùng Vương, văn hóa Văn Lang.'
          },
          {
            'question': 'Linh vật của trường DHV là gì?',
            'options': ['Rồng vàng', 'Chim Lạc', 'Sư tử', 'Phượng hoàng'],
            'correct': 1,
            'explanation':
                'Chim Lạc là biểu tượng của nhà nước Âu Lạc, tượng trưng cho điềm lành, sự bền vững và phát triển.'
          },
          {
            'question': 'DHV chuyển từ dân lập sang tư thục vào năm nào?',
            'options': ['2008', '2010', '2017', '2025'],
            'correct': 1,
            'explanation':
                'Ngày 19/05/2010, Thủ tướng ban hành Quyết định số 705/QĐ-TTg chuyển đổi từ dân lập sang tư thục.'
          },
        ],
      },
      2: {
        'title': 'Quiz về Khoa Kỹ thuật Công nghệ và Công nghệ hiện đại',
        'questions': [
          {
            'question':
                'VR Center tại DHV có diện tích và sức chứa là bao nhiêu?',
            'options': [
              '60m2, 20 người',
              '90m2, 25-50 người',
              '120m2, 60 người',
              '150m2, 80 người'
            ],
            'correct': 1,
            'explanation':
                'VR Center có diện tích 90m2, 12 chỗ ngồi trải nghiệm, phục vụ khoảng 25-50 học viên.'
          },
          {
            'question': 'Công nghệ nào được DHV áp dụng đầu tiên tại Việt Nam?',
            'options': [
              'AI và Machine Learning',
              'VR và Metaverse',
              'Blockchain',
              'IoT'
            ],
            'correct': 1,
            'explanation':
                'DHV là trường đầu tiên tại Việt Nam áp dụng công nghệ VR/Metaverse trong giảng dạy.'
          },
          {
            'question': 'Ngành Công nghệ Thông tin tại DHV có mã ngành là gì?',
            'options': ['7480201', '7540101', '7220201', '7810105'],
            'correct': 0,
            'explanation':
                'Ngành Công nghệ Thông tin tại DHV có mã ngành 7480201.'
          },
          {
            'question': 'DHV ứng dụng công nghệ nào trong đào tạo?',
            'options': [
              'Chỉ VR',
              'VR, AI, Metaverse, BigData',
              'Chỉ AI',
              'Chỉ Metaverse'
            ],
            'correct': 1,
            'explanation':
                'DHV ứng dụng đa dạng công nghệ: VR, Metaverse, AI, Machine Learning, BigData trong đào tạo.'
          },
        ],
      },
      3: {
        'title': 'Quiz về Cơ sở vật chất và Tổ chức DHV',
        'questions': [
          {
            'question': 'Trụ sở chính của DHV tọa lạc ở đâu?',
            'options': [
              '28-50 Ngô Quyền, Q5',
              '756 Nguyễn Trãi, Q5',
              '123 Lê Lợi, Q1',
              '456 Trần Hưng Đạo, Q3'
            ],
            'correct': 1,
            'explanation':
                'Trụ sở chính DHV ở 756 Nguyễn Trãi, Phường 11, Quận 5, TP.HCM.'
          },
          {
            'question': 'DHV có bao nhiêu khoa đào tạo chính?',
            'options': ['5 khoa', '6 khoa', '7 khoa', '8 khoa'],
            'correct': 2,
            'explanation':
                'DHV có 7 khoa: Quản trị KD-Marketing, Tài chính-NH-Kế toán, Ngôn ngữ, Du lịch-Khách sạn, Kỹ thuật Công nghệ, Luật, Khoa học Sức khỏe.'
          },
          {
            'question': 'Thư viện DHV cung cấp những tiện ích nào?',
            'options': [
              'Chỉ sách giấy',
              'Sách, internet, khu đọc, học nhóm',
              'Chỉ internet',
              'Chỉ khu đọc sách'
            ],
            'correct': 1,
            'explanation':
                'Thư viện DHV có hàng nghìn đầu sách, khu đọc, truy cập internet, học nhóm với không gian hiện đại.'
          },
        ],
      },
      4: {
        'title': 'Quiz về Cơ sở vật chất DHV',
        'questions': [
          {
            'question': 'DHV có bao nhiêu cơ sở chính?',
            'options': ['1 cơ sở', '2 cơ sở', '3 cơ sở', '4 cơ sở'],
            'correct': 1,
            'explanation':
                'DHV có 2 cơ sở: Trụ sở chính 756 Nguyễn Trãi và Cơ sở I 28-50 Ngô Quyền.'
          },
          {
            'question': 'Mỗi phòng học DHV được trang bị gì?',
            'options': [
              'Chỉ bàn ghế',
              'Máy lạnh, máy chiếu, wifi',
              'Chỉ máy chiếu',
              'Chỉ wifi'
            ],
            'correct': 1,
            'explanation':
                'Các phòng học DHV đều có máy lạnh, máy chiếu và wifi tạo môi trường học tập lý tưởng.'
          },
        ],
      },
      5: {
        'title': 'Quiz về Hệ thống tổ chức DHV',
        'questions': [
          {
            'question': 'Ban Giám hiệu DHV gồm những ai?',
            'options': [
              'Chỉ Hiệu trưởng',
              'Hiệu trưởng và 1 Hiệu phó',
              'Hiệu trưởng và 2 Hiệu phó',
              'Hiệu trưởng và 3 Hiệu phó'
            ],
            'correct': 2,
            'explanation':
                'Ban Giám hiệu DHV gồm 1 Hiệu trưởng và 2 Hiệu phó điều hành trường.'
          },
          {
            'question': 'DHV có bao nhiêu phòng ban chức năng?',
            'options': ['6 phòng', '7 phòng', '8 phòng', '9 phòng'],
            'correct': 2,
            'explanation':
                'DHV có 8 phòng ban chức năng hỗ trợ hoạt động giảng dạy và quản lý.'
          },
        ],
      },
      6: {
        'title': 'Quiz về Các phòng ban hỗ trợ sinh viên',
        'questions': [
          {
            'question': 'Phòng nào chịu trách nhiệm chăm sóc sinh viên?',
            'options': [
              'Phòng Đào tạo',
              'Phòng Công tác Sinh viên',
              'Phòng Tài chính',
              'Phòng Hành chính'
            ],
            'correct': 1,
            'explanation':
                'Phòng Công tác Sinh viên chuyên chăm sóc và hỗ trợ sinh viên toàn diện.'
          },
          {
            'question': 'Trung tâm Tuyển sinh có chức năng gì?',
            'options': [
              'Chỉ tuyển sinh',
              'Tuyển sinh và quan hệ doanh nghiệp',
              'Chỉ quan hệ doanh nghiệp',
              'Đào tạo sinh viên'
            ],
            'correct': 1,
            'explanation':
                'Trung tâm Tuyển sinh vừa tư vấn tuyển sinh vừa phát triển quan hệ với doanh nghiệp.'
          },
        ],
      },
      7: {
        'title': 'Quiz về 7 Khoa đào tạo tại DHV',
        'questions': [
          {
            'question': 'Khoa nào chuyên về công nghệ và kỹ thuật?',
            'options': [
              'Khoa Quản trị Kinh doanh',
              'Khoa Ngôn ngữ',
              'Khoa Kỹ thuật Công nghệ',
              'Khoa Du lịch'
            ],
            'correct': 2,
            'explanation':
                'Khoa Kỹ thuật Công nghệ chuyên đào tạo CNTT, Kỹ thuật máy tính và các công nghệ hiện đại.'
          },
          {
            'question': 'Khoa Ngôn ngữ ứng dụng công nghệ nào?',
            'options': ['VR', 'AI', 'Metaverse', 'Tất cả các công nghệ trên'],
            'correct': 3,
            'explanation':
                'Khoa Ngôn ngữ ứng dụng VR, AI, Metaverse trong giảng dạy tiếng Anh, Nhật, Trung, Hàn.'
          },
        ],
      },
      9: {
        'title': 'Quiz về Chuẩn đầu ra ngoại ngữ - tin học',
        'questions': [
          {
            'question': 'Chuẩn ngoại ngữ DHV theo khung nào?',
            'options': ['IELTS', 'TOEFL', 'CEFR', 'Cambridge'],
            'correct': 2,
            'explanation':
                'DHV áp dụng chuẩn ngoại ngữ theo khung tham chiếu ngôn ngữ chung Châu Âu (CEFR).'
          },
          {
            'question': 'Chuẩn tin học DHV liên quan đến chứng chỉ nào?',
            'options': [
              'Adobe',
              'Microsoft Office Specialist',
              'Google',
              'Apple'
            ],
            'correct': 1,
            'explanation':
                'DHV tích hợp chuẩn tin học Microsoft Office Specialist và các chứng chỉ công nghệ khác.'
          },
        ],
      },
      10: {
        'title': 'Quiz về Internet of Things (IoT)',
        'questions': [
          {
            'question': 'IoT là viết tắt của từ gì?',
            'options': [
              'Internet of Technology',
              'Internet of Things',
              'Internet of Transfer',
              'Internet of Training'
            ],
            'correct': 1,
            'explanation':
                'IoT (Internet of Things) là mạng lưới các thiết bị vật lý kết nối internet để thu thập và trao đổi dữ liệu.'
          },
          {
            'question': 'Thành phần chính của hệ thống IoT là gì?',
            'options': [
              'Sensor, Gateway, Cloud',
              'Chỉ có Sensor',
              'Chỉ có Cloud',
              'Chỉ có Gateway'
            ],
            'correct': 0,
            'explanation':
                'Hệ thống IoT gồm Sensor (thu thập dữ liệu), Gateway (truyền dữ liệu), và Cloud (xử lý dữ liệu).'
          },
          {
            'question': 'ESP32 trong IoT được sử dụng để làm gì?',
            'options': [
              'Chỉ kết nối WiFi',
              'Vi điều khiển với WiFi/Bluetooth',
              'Chỉ xử lý dữ liệu',
              'Chỉ hiển thị kết quả'
            ],
            'correct': 1,
            'explanation':
                'ESP32 là vi điều khiển tích hợp WiFi và Bluetooth, thường dùng làm gateway trong các project IoT.'
          },
          {
            'question': 'Smart Campus DHV ứng dụng IoT như thế nào?',
            'options': [
              'Chỉ theo dõi nhiệt độ',
              'Giám sát toàn diện: nhiệt độ, ánh sáng, chuyển động',
              'Chỉ kết nối internet',
              'Chỉ tiết kiệm điện'
            ],
            'correct': 1,
            'explanation':
                'Smart Campus DHV sử dụng IoT để giám sát môi trường toàn diện và tối ưu hóa tài nguyên.'
          },
        ],
      },
      11: {
        'title': 'Quiz về Hệ thống Nhúng (Embedded Systems)',
        'questions': [
          {
            'question': 'Arduino được sử dụng chủ yếu để làm gì?',
            'options': [
              'Lập trình web',
              'Prototyping và học tập embedded',
              'Xử lý dữ liệu lớn',
              'Thiết kế giao diện'
            ],
            'correct': 1,
            'explanation':
                'Arduino là platform mã nguồn mở, phù hợp cho prototyping nhanh và học tập lập trình embedded.'
          },
          {
            'question': 'Raspberry Pi khác Arduino ở điểm nào?',
            'options': [
              'Không có khác biệt',
              'Pi chạy OS, Arduino là microcontroller',
              'Pi rẻ hơn Arduino',
              'Arduino mạnh hơn Pi'
            ],
            'correct': 1,
            'explanation':
                'Raspberry Pi là single board computer chạy Linux OS, Arduino là microcontroller với realtime processing.'
          },
          {
            'question': 'ARM Cortex được sử dụng trong lĩnh vực nào?',
            'options': [
              'Chỉ điện thoại',
              'Vi xử lý hiệu năng cao cho embedded',
              'Chỉ máy tính',
              'Chỉ xe hơi'
            ],
            'correct': 1,
            'explanation':
                'ARM Cortex là kiến trúc vi xử lý được sử dụng rộng rãi trong embedded systems từ IoT đến automotive.'
          },
          {
            'question': 'Firmware trong embedded systems là gì?',
            'options': [
              'Phần cứng',
              'Phần mềm cấp thấp điều khiển phần cứng',
              'Hệ điều hành',
              'Ứng dụng người dùng'
            ],
            'correct': 1,
            'explanation':
                'Firmware là phần mềm cấp thấp được lưu trong memory của chip, điều khiển trực tiếp phần cứng.'
          },
        ],
      },
      12: {
        'title': 'Quiz về AI & Machine Learning',
        'questions': [
          {
            'question': 'Machine Learning là một nhánh của lĩnh vực nào?',
            'options': [
              'Toán học',
              'Artificial Intelligence',
              'Vật lý',
              'Hóa học'
            ],
            'correct': 1,
            'explanation':
                'Machine Learning là một nhánh quan trọng của AI, cho phép máy tính học và cải thiện từ dữ liệu.'
          },
          {
            'question':
                'Deep Learning khác với Machine Learning truyền thống ở đâu?',
            'options': [
              'Không có khác biệt',
              'Sử dụng neural networks nhiều lớp',
              'Chỉ xử lý hình ảnh',
              'Không cần dữ liệu'
            ],
            'correct': 1,
            'explanation':
                'Deep Learning sử dụng neural networks với nhiều lớp ẩn để học các pattern phức tạp từ dữ liệu.'
          },
          {
            'question': 'Computer Vision được ứng dụng trong lĩnh vực nào?',
            'options': [
              'Chỉ game',
              'Nhận dạng khuôn mặt, xe tự lái, y tế',
              'Chỉ mạng xã hội',
              'Chỉ điện thoại'
            ],
            'correct': 1,
            'explanation':
                'Computer Vision có ứng dụng rộng rãi từ security, automotive, healthcare đến retail và manufacturing.'
          },
          {
            'question': 'GPU trong AI/ML được sử dụng để làm gì?',
            'options': [
              'Chỉ hiển thị đồ họa',
              'Tính toán song song để training models',
              'Lưu trữ dữ liệu',
              'Kết nối mạng'
            ],
            'correct': 1,
            'explanation':
                'GPU có khả năng xử lý song song mạnh mẽ, rất phù hợp cho việc training các mô hình AI/ML lớn.'
          },
        ],
      },
      13: {
        'title': 'Quiz về Big Data Analytics',
        'questions': [
          {
            'question': 'Big Data được đặc trưng bởi bao nhiêu "V"?',
            'options': ['2V', '3V', '4V', '5V'],
            'correct': 2,
            'explanation':
                'Big Data có 4V: Volume (khối lượng), Velocity (tốc độ), Variety (đa dạng), Veracity (độ tin cậy).'
          },
          {
            'question': 'Apache Spark khác với Hadoop ở điểm nào?',
            'options': [
              'Không có khác biệt',
              'Spark xử lý in-memory, nhanh hơn',
              'Hadoop mới hơn',
              'Spark chỉ xử lý text'
            ],
            'correct': 1,
            'explanation':
                'Apache Spark xử lý dữ liệu in-memory, nhanh hơn Hadoop MapReduce đến 100 lần trong một số trường hợp.'
          },
          {
            'question': 'Cloud Computing hỗ trợ Big Data như thế nào?',
            'options': [
              'Không hỗ trợ',
              'Cung cấp tài nguyên tính toán co giãn',
              'Chỉ lưu trữ',
              'Chỉ bảo mật'
            ],
            'correct': 1,
            'explanation':
                'Cloud Computing cung cấp tài nguyên tính toán và lưu trữ co giãn, phù hợp cho xử lý Big Data.'
          },
          {
            'question': 'Data Visualization quan trọng vì lý do gì?',
            'options': [
              'Chỉ để đẹp',
              'Giúp hiểu insights từ dữ liệu phức tạp',
              'Tiết kiệm thời gian',
              'Giảm kích thước file'
            ],
            'correct': 1,
            'explanation':
                'Data Visualization giúp con người hiểu được insights và patterns từ dữ liệu phức tạp một cách trực quan.'
          },
        ],
      },
      14: {
        'title': 'Quiz về Blockchain & Cryptocurrency',
        'questions': [
          {
            'question': 'Blockchain là gì?',
            'options': [
              'Một loại cryptocurrency',
              'Cơ sở dữ liệu phân tán bảo mật',
              'Một ngôn ngữ lập trình',
              'Một hệ điều hành'
            ],
            'correct': 1,
            'explanation':
                'Blockchain là công nghệ cơ sở dữ liệu phân tán, lưu trữ dữ liệu theo chuỗi khối được mã hóa và bảo mật.'
          },
          {
            'question': 'Smart Contract hoạt động như thế nào?',
            'options': [
              'Cần người vận hành',
              'Tự động thực thi khi đáp ứng điều kiện',
              'Chỉ lưu trữ dữ liệu',
              'Chỉ xử lý thanh toán'
            ],
            'correct': 1,
            'explanation':
                'Smart Contract là hợp đồng tự động thực thi khi các điều kiện được định trước đã được đáp ứng.'
          },
          {
            'question': 'Ethereum khác với Bitcoin ở điểm nào?',
            'options': [
              'Không có khác biệt',
              'Ethereum hỗ trợ smart contracts',
              'Bitcoin nhanh hơn',
              'Ethereum chỉ là tiền điện tử'
            ],
            'correct': 1,
            'explanation':
                'Ethereum không chỉ là cryptocurrency mà còn là platform để phát triển DApps và smart contracts.'
          },
          {
            'question': 'DApps (Decentralized Apps) có đặc điểm gì?',
            'options': [
              'Chạy trên server trung tâm',
              'Chạy trên mạng blockchain phi tập trung',
              'Chỉ xử lý dữ liệu',
              'Không cần internet'
            ],
            'correct': 1,
            'explanation':
                'DApps chạy trên mạng blockchain phi tập trung, không có single point of failure và không bị kiểm soát bởi một tổ chức.'
          },
        ],
      },
      15: {
        'title': 'Quiz về Cybersecurity',
        'questions': [
          {
            'question': 'Ethical Hacking khác với hacking thông thường ở đâu?',
            'options': [
              'Không có khác biệt',
              'Có sự cho phép và nhằm cải thiện bảo mật',
              'Chỉ tấn công hệ thống nhỏ',
              'Không sử dụng tools'
            ],
            'correct': 1,
            'explanation':
                'Ethical Hacking được thực hiện với sự cho phép, nhằm tìm lỗ hổng để cải thiện bảo mật hệ thống.'
          },
          {
            'question': 'Penetration Testing là gì?',
            'options': [
              'Kiểm tra hiệu năng',
              'Mô phỏng tấn công để tìm lỗ hổng',
              'Backup dữ liệu',
              'Cài đặt phần mềm'
            ],
            'correct': 1,
            'explanation':
                'Penetration Testing là quá trình mô phỏng tấn công vào hệ thống để tìm ra các lỗ hổng bảo mật.'
          },
          {
            'question': 'SOC (Security Operations Center) có chức năng gì?',
            'options': [
              'Phát triển phần mềm',
              'Giám sát và phản ứng với incident bảo mật',
              'Thiết kế giao diện',
              'Quản lý tài chính'
            ],
            'correct': 1,
            'explanation':
                'SOC là trung tâm giám sát bảo mật 24/7, phát hiện và phản ứng nhanh với các threat và incident.'
          },
          {
            'question': 'Digital Forensics được sử dụng để làm gì?',
            'options': [
              'Tạo backup',
              'Thu thập và phân tích chứng cứ số',
              'Thiết kế website',
              'Lập trình game'
            ],
            'correct': 1,
            'explanation':
                'Digital Forensics là quá trình thu thập, bảo toàn và phân tích chứng cứ kỹ thuật số để điều tra tội phạm mạng.'
          },
        ],
      },
      16: {
        'title': 'Quiz về DevOps & Cloud Computing',
        'questions': [
          {
            'question': 'DevOps kết hợp hai lĩnh vực nào?',
            'options': [
              'Design và Marketing',
              'Development và Operations',
              'Data và Analytics',
              'Security và Network'
            ],
            'correct': 1,
            'explanation':
                'DevOps kết hợp Development (phát triển) và Operations (vận hành) để tăng tốc độ delivery và chất lượng phần mềm.'
          },
          {
            'question': 'Docker được sử dụng để làm gì?',
            'options': [
              'Thiết kế giao diện',
              'Container hóa ứng dụng',
              'Quản lý cơ sở dữ liệu',
              'Tạo website'
            ],
            'correct': 1,
            'explanation':
                'Docker là platform containerization, giúp đóng gói ứng dụng và dependencies thành containers portable.'
          },
          {
            'question': 'Kubernetes được sử dụng để làm gì?',
            'options': [
              'Lập trình mobile',
              'Orchestration và quản lý containers',
              'Thiết kế database',
              'Tạo API'
            ],
            'correct': 1,
            'explanation':
                'Kubernetes là container orchestration platform, tự động hóa deployment, scaling và management của containers.'
          },
          {
            'question': 'CI/CD có lợi ích gì?',
            'options': [
              'Chỉ tiết kiệm thời gian',
              'Tự động hóa build, test, deploy',
              'Chỉ giảm chi phí',
              'Chỉ tăng bảo mật'
            ],
            'correct': 1,
            'explanation':
                'CI/CD tự động hóa quá trình build, test và deploy, giúp giảm lỗi, tăng tốc delivery và cải thiện chất lượng code.'
          },
        ],
      },
    };
  }

  /// Map data cho các bài học - địa điểm thực tế tại DHV
  static Map<int, Map<String, dynamic>> getMapData() {
    return {
      1: {
        'title': 'Bản đồ các cơ sở DHV',
        'locations': [
          {
            'name': 'Trụ sở chính',
            'address': '756 Nguyễn Trãi, P.11, Q.5',
            'phone': '(+84) 287 1001 888',
            'description':
                'Cơ sở chính với tượng Vua Hùng và các phòng ban chính'
          },
          {
            'name': 'Cơ sở I',
            'address': '28-50 Ngô Quyền, P.6, Q.5',
            'phone': '(+84) 287 1001 888',
            'description': 'Cơ sở phụ với các phòng học và lab bổ sung'
          },
          {
            'name': 'Văn phòng tuyển sinh',
            'address': 'Tầng trệt - Trụ sở chính',
            'phone': '0287.1001.888',
            'description': 'Trung tâm tuyển sinh và quan hệ doanh nghiệp'
          },
        ],
      },
      2: {
        'title': 'Bản đồ Cơ sở vật chất DHV',
        'locations': [
          {
            'name': 'VR Center',
            'floor': 'Tầng 2',
            'area': '90m2',
            'description': '12 chỗ ngồi trải nghiệm VR, phục vụ 25-50 học viên'
          },
          {
            'name': 'Phòng máy tính',
            'floor': 'Tầng 3-4',
            'equipment': 'Máy tính đồng bộ hiện đại',
            'description': 'Phòng thực hành cho sinh viên IT và các ngành khác'
          },
          {
            'name': 'Thư viện',
            'floor': 'Tầng 1-2',
            'features': 'Sách, internet, học nhóm',
            'description':
                'Hàng nghìn đầu sách với không gian hiện đại, yên tĩnh'
          },
          {
            'name': 'Phòng học',
            'floor': 'Các tầng',
            'facilities': 'Máy lạnh, máy chiếu, wifi',
            'description': 'Không gian học tập lý tưởng khuyến khích trao đổi'
          },
          {
            'name': 'Văn phòng các Khoa',
            'floor': 'Tầng 2-5',
            'features': 'Hiện đại, thân thiện',
            'description': 'Không gian làm việc kết nối với sinh viên'
          },
        ],
      },
      3: {
        'title': 'Bản đồ Tổ chức DHV',
        'locations': [
          {
            'name': 'Ban Giám hiệu',
            'position': 'Hiệu trưởng + 2 Hiệu phó',
            'function': 'Lãnh đạo và điều hành nhà trường',
            'description': 'Cơ quan lãnh đạo cao nhất của trường'
          },
          {
            'name': '8 Phòng ban chức năng',
            'departments': 'Tài chính-KT, Tổ chức-NS, Hành chính, Đào tạo...',
            'function': 'Hỗ trợ hoạt động giảng dạy và quản lý',
            'description': 'Các phòng ban phục vụ sinh viên và giảng viên'
          },
          {
            'name': '7 Khoa đào tạo',
            'faculties': 'QTKD, TCNH, Ngôn ngữ, Du lịch, KTCN, Luật, KHSK',
            'function': 'Đào tạo các ngành chuyên môn',
            'description': 'Đơn vị trực tiếp đào tạo sinh viên'
          },
          {
            'name': 'Các tổ chức đoàn thể',
            'organizations': 'Công đoàn, Hội SV, Đoàn TN',
            'function': 'Sinh hoạt và hỗ trợ sinh viên',
            'description': 'Tổ chức các hoạt động ngoại khóa và hỗ trợ'
          },
        ],
      },
      4: {
        'title': 'Bản đồ Cơ sở vật chất DHV',
        'locations': [
          {
            'name': 'Trụ sở chính',
            'address': '756 Nguyễn Trãi, P.11, Q.5',
            'facilities': 'Tượng Vua Hùng, các phòng ban chính',
            'description': 'Cơ sở chính với đầy đủ tiện nghi hiện đại'
          },
          {
            'name': 'Cơ sở I',
            'address': '28-50 Ngô Quyền, P.6, Q.5',
            'facilities': 'Phòng học, lab bổ sung',
            'description': 'Cơ sở phụ rộng rãi cho hoạt động học tập'
          },
          {
            'name': 'Khu vực xanh',
            'location': 'Xung quanh campus',
            'features': 'Cây cỏ, không gian nghỉ ngơi',
            'description': 'Môi trường học tập thân thiện với thiên nhiên'
          },
        ],
      },
      5: {
        'title': 'Bản đồ Hệ thống tổ chức DHV',
        'locations': [
          {
            'name': 'Hội đồng Trường',
            'role': 'Quyết định chiến lược',
            'members': 'Chủ tịch và các thành viên',
            'description': 'Cơ quan quyết định chiến lược phát triển'
          },
          {
            'name': 'Ban Giám hiệu',
            'role': 'Điều hành',
            'structure': '1 Hiệu trưởng + 2 Hiệu phó',
            'description': 'Lãnh đạo và điều hành nhà trường'
          },
          {
            'name': 'Các Hội đồng chuyên môn',
            'types': 'Khoa học, Đào tạo, Đảm bảo chất lượng',
            'function': 'Tư vấn chuyên môn',
            'description': 'Tư vấn và hỗ trợ quyết định chuyên môn'
          },
        ],
      },
      6: {
        'title': 'Bản đồ Phòng ban hỗ trợ sinh viên',
        'locations': [
          {
            'name': 'Phòng Công tác Sinh viên',
            'floor': 'Tầng trệt',
            'services': 'Hỗ trợ, chăm sóc SV',
            'description': 'Hỗ trợ và chăm sóc sinh viên toàn diện'
          },
          {
            'name': 'Phòng Đào tạo',
            'floor': 'Tầng 1',
            'services': 'Quản lý chương trình học',
            'description': 'Quản lý chương trình và hoạt động đào tạo'
          },
          {
            'name': 'Trung tâm Tuyển sinh',
            'floor': 'Tầng trệt',
            'services': 'Tuyển sinh, quan hệ DN',
            'description': 'Tư vấn tuyển sinh và quan hệ doanh nghiệp'
          },
          {
            'name': 'Phòng Khảo thí',
            'floor': 'Tầng 2',
            'services': 'Tổ chức thi cử',
            'description': 'Tổ chức thi cử và đánh giá chất lượng'
          },
        ],
      },
      7: {
        'title': 'Bản đồ 7 Khoa đào tạo DHV',
        'locations': [
          {
            'name': 'Khoa Quản trị Kinh doanh',
            'specialties': 'Marketing, TMĐT, QTNS',
            'floor': 'Tầng 3',
            'description': 'Đào tạo quản lý, kinh doanh và marketing'
          },
          {
            'name': 'Khoa Kỹ thuật Công nghệ',
            'specialties': 'CNTT, KTMT, VR/AI/IoT',
            'floor': 'Tầng 4-5',
            'description': 'Công nghệ thông tin và kỹ thuật máy tính'
          },
          {
            'name': 'Khoa Ngôn ngữ',
            'specialties': 'Anh, Nhật, Trung, Hàn',
            'technologies': 'Metaverse',
            'description': 'Ngoại ngữ với công nghệ Metaverse'
          },
          {
            'name': '4 Khoa khác',
            'faculties': 'TCNH, Du lịch, Luật, KHSK',
            'focus': 'Đa ngành',
            'description': 'Tài chính, Du lịch, Luật, Sức khỏe'
          },
        ],
      },
      7: {
        'title': 'Bản đồ 7 Khoa đào tạo DHV',
        'locations': [
          {
            'name': 'Khoa Quản trị Kinh doanh',
            'specialties': 'Marketing, TMĐT, QTNS',
            'floor': 'Tầng 3',
            'description': 'Đào tạo quản lý, kinh doanh và marketing'
          },
          {
            'name': 'Khoa Kỹ thuật Công nghệ',
            'specialties': 'CNTT, KTMT, VR/AI/IoT',
            'floor': 'Tầng 4-5',
            'description': 'Công nghệ thông tin và kỹ thuật máy tính'
          },
          {
            'name': 'Khoa Ngôn ngữ',
            'specialties': 'Anh, Nhật, Trung, Hàn',
            'technologies': 'Metaverse',
            'description': 'Ngoại ngữ với công nghệ Metaverse'
          },
          {
            'name': '4 Khoa khác',
            'faculties': 'TCNH, Du lịch, Luật, KHSK',
            'focus': 'Đa ngành',
            'description': 'Tài chính, Du lịch, Luật, Sức khỏe'
          },
        ],
      },
      9: {
        'title': 'Bản đồ Chuẩn đầu ra DHV',
        'locations': [
          {
            'name': 'Trung tâm Ngoại ngữ',
            'standards': 'CEFR A2-B2',
            'languages': 'Anh, Nhật, Trung, Hàn',
            'description': 'Đào tạo ngoại ngữ theo chuẩn quốc tế'
          },
          {
            'name': 'Trung tâm Tin học',
            'certifications': 'Microsoft Office Specialist',
            'skills': 'Office, Programming, Digital',
            'description': 'Đào tạo tin học theo chuẩn Microsoft'
          },
          {
            'name': 'Đánh giá năng lực',
            'methods': 'Thi, project, thực hành',
            'validation': 'Chứng chỉ quốc tế',
            'description': 'Hệ thống kiểm tra và xác nhận chuẩn đầu ra'
          },
        ],
      },
      10: {
        'title': 'Bản đồ IoT Lab DHV',
        'locations': [
          {
            'name': 'IoT Development Lab',
            'floor': 'Tầng 4 - Khoa KTCN',
            'equipment': 'Arduino, ESP32, Raspberry Pi',
            'description': 'Lab phát triển IoT với sensor networks'
          },
          {
            'name': 'Smart Campus Control Room',
            'floor': 'Tầng 5',
            'features': 'Monitoring dashboard, data analytics',
            'description': 'Trung tâm điều khiển smart campus DHV'
          },
          {
            'name': 'Sensor Network Testbed',
            'location': 'Khắp campus',
            'sensors': 'Temperature, humidity, motion, air quality',
            'description': 'Mạng lưới sensor thực tế trong campus'
          },
          {
            'name': 'Cloud IoT Platform',
            'platform': 'AWS IoT Core, Azure IoT',
            'services': 'Data ingestion, processing, visualization',
            'description': 'Platform cloud xử lý dữ liệu IoT'
          },
        ],
      },
      11: {
        'title': 'Bản đồ Embedded Systems Lab',
        'locations': [
          {
            'name': 'Arduino Development Station',
            'floor': 'Tầng 4 - Lab A',
            'boards': 'Uno, Nano, Mega, ESP32',
            'description': 'Trạm phát triển Arduino cho beginners'
          },
          {
            'name': 'Raspberry Pi Computing Lab',
            'floor': 'Tầng 4 - Lab B',
            'models': 'Pi 4, Pi Zero, Pi Pico',
            'description': 'Lab single board computing với Linux'
          },
          {
            'name': 'ARM Cortex Development',
            'floor': 'Tầng 5 - Advanced Lab',
            'platforms': 'STM32, TI LaunchPad, NXP',
            'description': 'Lab phát triển embedded systems chuyên nghiệp'
          },
          {
            'name': 'Hardware Prototyping',
            'equipment': 'Breadboard, oscilloscope, multimeter',
            'components': '1000+ electronic components',
            'description': 'Khu vực tạo prototype phần cứng'
          },
        ],
      },
      12: {
        'title': 'Bản đồ AI/ML Research Center',
        'locations': [
          {
            'name': 'GPU Computing Cluster',
            'floor': 'Tầng 5 - Server Room',
            'hardware': 'NVIDIA RTX 4090, Tesla V100',
            'description': 'Cluster GPU cho deep learning training'
          },
          {
            'name': 'Computer Vision Lab',
            'floor': 'Tầng 4 - Lab C',
            'equipment': 'Cameras, image processing workstations',
            'description': 'Lab nghiên cứu thị giác máy tính'
          },
          {
            'name': 'NLP Research Space',
            'focus': 'Vietnamese language processing',
            'projects': 'Chatbot, sentiment analysis, translation',
            'description': 'Nghiên cứu xử lý ngôn ngữ tự nhiên Việt'
          },
          {
            'name': 'AI Demo Showcase',
            'floor': 'Tầng 2 - Exhibition',
            'demos': 'Face recognition, object detection',
            'description': 'Khu trưng bày các ứng dụng AI thực tế'
          },
        ],
      },
      13: {
        'title': 'Bản đồ Big Data Center DHV',
        'locations': [
          {
            'name': 'Hadoop Cluster',
            'floor': 'Tầng 5 - Data Center',
            'nodes': '12 nodes, 48TB storage',
            'description': 'Cụm Hadoop xử lý dữ liệu phân tán'
          },
          {
            'name': 'Spark Analytics Lab',
            'floor': 'Tầng 4 - Lab D',
            'tools': 'Apache Spark, Kafka, Elasticsearch',
            'description': 'Lab phân tích dữ liệu realtime'
          },
          {
            'name': 'Cloud Integration Hub',
            'platforms': 'AWS, Azure, Google Cloud',
            'services': 'Data lakes, warehouses, pipelines',
            'description': 'Hub tích hợp các cloud services'
          },
          {
            'name': 'Data Visualization Studio',
            'tools': 'Tableau, Power BI, D3.js',
            'displays': '4K monitors, interactive boards',
            'description': 'Studio tạo dashboard và visualization'
          },
        ],
      },
      14: {
        'title': 'Bản đồ Blockchain Lab DHV',
        'locations': [
          {
            'name': 'Blockchain Development Lab',
            'floor': 'Tầng 4 - Lab E',
            'platforms': 'Ethereum, Hyperledger, Solana',
            'description': 'Lab phát triển blockchain applications'
          },
          {
            'name': 'Cryptocurrency Mining Rig',
            'purpose': 'Educational demonstration',
            'equipment': 'ASIC miners, GPU rigs',
            'description': 'Hệ thống đào coin để giáo dục'
          },
          {
            'name': 'Smart Contract Testing',
            'tools': 'Remix IDE, Truffle, Ganache',
            'networks': 'Testnet environments',
            'description': 'Môi trường test smart contracts'
          },
          {
            'name': 'DApp Showcase',
            'applications': 'Educational credentials, voting',
            'users': 'Students, faculty, staff',
            'description': 'Ứng dụng blockchain thực tế trong giáo dục'
          },
        ],
      },
      15: {
        'title': 'Bản đồ Cybersecurity Lab DHV',
        'locations': [
          {
            'name': 'Penetration Testing Lab',
            'floor': 'Tầng 5 - Secure Lab',
            'tools': 'Kali Linux, Metasploit, Burp Suite',
            'description': 'Lab thực hành ethical hacking'
          },
          {
            'name': 'Security Operations Center',
            'floor': 'Tầng 5 - SOC Room',
            'monitoring': '24/7 network monitoring',
            'description': 'Trung tâm giám sát bảo mật DHV'
          },
          {
            'name': 'Digital Forensics Lab',
            'equipment': 'Forensic workstations, write blockers',
            'software': 'EnCase, FTK, Autopsy',
            'description': 'Lab điều tra tội phạm mạng'
          },
          {
            'name': 'Vulnerable Systems Range',
            'purpose': 'Practice targets',
            'systems': 'Intentionally vulnerable VMs',
            'description': 'Môi trường thực hành tấn công an toàn'
          },
        ],
      },
      16: {
        'title': 'Bản đồ DevOps & Cloud Lab',
        'locations': [
          {
            'name': 'Container Orchestration Lab',
            'floor': 'Tầng 5 - Lab F',
            'platforms': 'Docker, Kubernetes, OpenShift',
            'description': 'Lab thực hành containerization'
          },
          {
            'name': 'CI/CD Pipeline Center',
            'tools': 'Jenkins, GitLab CI, GitHub Actions',
            'integration': 'Automated testing, deployment',
            'description': 'Trung tâm automation và delivery'
          },
          {
            'name': 'Multi-Cloud Environment',
            'providers': 'AWS, Azure, GCP',
            'services': 'IaaS, PaaS, SaaS demonstrations',
            'description': 'Môi trường đa cloud thực tế'
          },
          {
            'name': 'Microservices Playground',
            'architecture': 'Service mesh, API gateways',
            'monitoring': 'Prometheus, Grafana, Jaeger',
            'description': 'Thực hành kiến trúc microservices'
          },
        ],
      },
    };
  }

  // ========================================
  // INFO CONTENT - Nội dung thông tin
  // ========================================

  /// Stats data cho các bài học - thống kê thực tế DHV
  static Map<int, Map<String, dynamic>> getStatsData() {
    return {
      1: {
        'title': 'Thống kê Trường ĐH Hùng Vương',
        'stats': [
          {
            'label': 'Năm thành lập',
            'value': '1995',
            'icon': 'calendar_today',
            'color': 0xFF1E88E5,
          },
          {
            'label': 'Tuổi đời',
            'value': '30 năm',
            'icon': 'star',
            'color': 0xFFFF9800,
          },
          {
            'label': 'Số khoa đào tạo',
            'value': '7 khoa',
            'icon': 'school',
            'color': 0xFF4CAF50,
          },
          {
            'label': 'Loại hình',
            'value': 'Tư thục',
            'icon': 'business',
            'color': 0xFF9C27B0,
          },
          {
            'label': 'Cơ sở',
            'value': '2 cơ sở',
            'icon': 'location_city',
            'color': 0xFFE91E63,
          },
          {
            'label': 'Ngày truyền thống',
            'value': '9/5 ÂL',
            'icon': 'flag',
            'color': 0xFFFF5722,
          },
        ],
      },
      2: {
        'title': 'Thống kê Công nghệ và Cơ sở vật chất',
        'stats': [
          {
            'label': 'VR Center',
            'value': '90m²',
            'icon': 'view_in_ar',
            'color': 0xFF1976D2,
          },
          {
            'label': 'Chỗ trải nghiệm VR',
            'value': '12 chỗ',
            'icon': 'chair',
            'color': 0xFF388E3C,
          },
          {
            'label': 'Học viên VR',
            'value': '25-50',
            'icon': 'people',
            'color': 0xFFF57C00,
          },
          {
            'label': 'Công nghệ tiên tiến',
            'value': 'VR/AI',
            'icon': 'smart_toy',
            'color': 0xFF7B1FA2,
          },
          {
            'label': 'Phòng máy tính',
            'value': 'Hiện đại',
            'icon': 'computer',
            'color': 0xFF00BCD4,
          },
          {
            'label': 'Thư viện',
            'value': 'Nghìn sách',
            'icon': 'library_books',
            'color': 0xFF795548,
          },
        ],
      },
      3: {
        'title': 'Thống kê Khoa Kỹ thuật Công nghệ',
        'stats': [
          {
            'label': 'Ngành chính',
            'value': 'CNTT',
            'icon': 'computer',
            'color': 0xFF1565C0,
          },
          {
            'label': 'Mã ngành',
            'value': '7480201',
            'icon': 'tag',
            'color': 0xFF2E7D32,
          },
          {
            'label': 'Chuyên ngành',
            'value': '4 chuyên ngành',
            'icon': 'category',
            'color': 0xFFE65100,
          },
          {
            'label': 'Metaverse',
            'value': 'Đầu tiên VN',
            'icon': 'language',
            'color': 0xFF6A1B9A,
          },
          {
            'label': 'Công nghệ',
            'value': 'AI/ML/IoT',
            'icon': 'psychology',
            'color': 0xFFD32F2F,
          },
          {
            'label': 'Thực tập',
            'value': 'Doanh nghiệp',
            'icon': 'work',
            'color': 0xFF00796B,
          },
        ],
      },
      4: {
        'title': 'Thống kê Cơ sở vật chất DHV',
        'stats': [
          {
            'label': 'Cơ sở chính',
            'value': '2 cơ sở',
            'icon': 'location_city',
            'color': 0xFF1565C0,
          },
          {
            'label': 'Địa chỉ chính',
            'value': '756 NT, Q5',
            'icon': 'place',
            'color': 0xFF2E7D32,
          },
          {
            'label': 'Cơ sở I',
            'value': '28-50 NQ, Q5',
            'icon': 'business',
            'color': 0xFFE65100,
          },
          {
            'label': 'Trang thiết bị',
            'value': 'Hiện đại',
            'icon': 'settings',
            'color': 0xFF6A1B9A,
          },
          {
            'label': 'Phòng học',
            'value': 'Máy lạnh + Wifi',
            'icon': 'class',
            'color': 0xFFD32F2F,
          },
          {
            'label': 'Môi trường',
            'value': 'Xanh - Sạch',
            'icon': 'eco',
            'color': 0xFF00796B,
          },
        ],
      },
      5: {
        'title': 'Thống kê Hệ thống tổ chức DHV',
        'stats': [
          {
            'label': 'Ban Giám hiệu',
            'value': '3 người',
            'icon': 'person',
            'color': 0xFF1565C0,
          },
          {
            'label': 'Phòng ban',
            'value': '8 phòng',
            'icon': 'business_center',
            'color': 0xFF2E7D32,
          },
          {
            'label': 'Khoa đào tạo',
            'value': '7 khoa',
            'icon': 'school',
            'color': 0xFFE65100,
          },
          {
            'label': 'Trung tâm',
            'value': '5 trung tâm',
            'icon': 'hub',
            'color': 0xFF6A1B9A,
          },
          {
            'label': 'Hội đồng',
            'value': 'Khoa học + ĐT',
            'icon': 'groups',
            'color': 0xFFD32F2F,
          },
          {
            'label': 'Cơ cấu',
            'value': 'Hoàn chỉnh',
            'icon': 'account_tree',
            'color': 0xFF00796B,
          },
        ],
      },
      6: {
        'title': 'Thống kê Phòng ban hỗ trợ SV',
        'stats': [
          {
            'label': 'CTSV',
            'value': 'Chăm sóc SV',
            'icon': 'support_agent',
            'color': 0xFF1565C0,
          },
          {
            'label': 'Đào tạo',
            'value': 'Quản lý CT',
            'icon': 'school',
            'color': 0xFF2E7D32,
          },
          {
            'label': 'Tuyển sinh',
            'value': 'TS + QHDN',
            'icon': 'how_to_reg',
            'color': 0xFFE65100,
          },
          {
            'label': 'Khảo thí',
            'value': 'Thi + ĐG',
            'icon': 'quiz',
            'color': 0xFF6A1B9A,
          },
          {
            'label': 'Học bổng',
            'value': 'Hỗ trợ TC',
            'icon': 'card_giftcard',
            'color': 0xFFD32F2F,
          },
          {
            'label': 'Hỗ trợ 24/7',
            'value': 'Toàn diện',
            'icon': 'help_center',
            'color': 0xFF00796B,
          },
        ],
      },
      7: {
        'title': 'Thống kê 7 Khoa đào tạo DHV',
        'stats': [
          {
            'label': 'QTKD',
            'value': 'Marketing',
            'icon': 'trending_up',
            'color': 0xFF1565C0,
          },
          {
            'label': 'KTCN',
            'value': 'CNTT + VR',
            'icon': 'computer',
            'color': 0xFF2E7D32,
          },
          {
            'label': 'Ngôn ngữ',
            'value': '4 ngoại ngữ',
            'icon': 'translate',
            'color': 0xFFE65100,
          },
          {
            'label': 'TCNH',
            'value': 'Tài chính',
            'icon': 'account_balance',
            'color': 0xFF6A1B9A,
          },
          {
            'label': 'Du lịch',
            'value': 'Hospitality',
            'icon': 'flight',
            'color': 0xFFD32F2F,
          },
          {
            'label': 'Luật + KHSK',
            'value': '2 khoa mới',
            'icon': 'gavel',
            'color': 0xFF00796B,
          },
        ],
      },
      9: {
        'title': 'Thống kê Chuẩn đầu ra DHV',
        'stats': [
          {
            'label': 'CEFR',
            'value': 'A2-B2',
            'icon': 'language',
            'color': 0xFF1565C0,
          },
          {
            'label': 'Microsoft',
            'value': 'Office Spec',
            'icon': 'computer',
            'color': 0xFF2E7D32,
          },
          {
            'label': 'Kỹ năng số',
            'value': 'Digital 4.0',
            'icon': 'touch_app',
            'color': 0xFFE65100,
          },
          {
            'label': 'Chứng chỉ',
            'value': 'Quốc tế',
            'icon': 'verified',
            'color': 0xFF6A1B9A,
          },
          {
            'label': 'Đánh giá',
            'value': 'Thực hành',
            'icon': 'assessment',
            'color': 0xFFD32F2F,
          },
          {
            'label': 'Cập nhật',
            'value': '2025',
            'icon': 'update',
            'color': 0xFF00796B,
          },
        ],
      },
    };
  }

  /// Campus amenities data - tiện ích thực tế tại DHV
  static Map<int, List<Map<String, String>>> getCampusAmenities() {
    return {
      2: [
        {
          'name': 'VR Center',
          'description': 'Trung tâm thực tế ảo 90m2 với 12 chỗ trải nghiệm'
        },
        {
          'name': 'Phòng máy tính',
          'description': 'Thiết bị máy tính đồng bộ hiện đại cho thực hành'
        },
        {
          'name': 'Thư viện hiện đại',
          'description': 'Hàng nghìn đầu sách, khu đọc, internet, học nhóm'
        },
        {
          'name': 'Phòng học tiêu chuẩn',
          'description': 'Máy lạnh, máy chiếu, wifi - không gian lý tưởng'
        },
        {
          'name': 'Wifi miễn phí',
          'description': 'Internet tốc độ cao trong toàn bộ campus'
        },
        {
          'name': 'Văn phòng các Khoa',
          'description': 'Không gian hiện đại, thân thiện với sinh viên'
        },
        {
          'name': 'Khu vực học nhóm',
          'description': 'Không gian mở khuyến khích trao đổi và thảo luận'
        },
        {
          'name': 'Hệ thống truyền thông',
          'description': 'Website, Facebook, YouTube, Zalo kết nối sinh viên'
        },
      ],
      3: [
        {
          'name': 'Trụ sở chính',
          'description': '756 Nguyễn Trãi P.11 Q.5 - Tượng Vua Hùng'
        },
        {
          'name': 'Cơ sở I',
          'description': '28-50 Ngô Quyền P.6 Q.5 - Cơ sở phụ'
        },
        {
          'name': 'Hotline tuyển sinh',
          'description': '(+84) 287 1001 888 - Hỗ trợ 24/7'
        },
        {
          'name': 'Email info',
          'description': 'info@dhv.edu.vn - Liên hệ thông tin'
        },
        {
          'name': 'Website chính thức',
          'description': 'dhv.edu.vn - Cổng thông tin trường'
        },
        {
          'name': 'Fanpage Facebook',
          'description': 'facebook.com/hungvuonguni - Cập nhật tin tức'
        },
        {
          'name': 'YouTube Channel',
          'description': 'youtube.com/@hungvuonguni - Video giới thiệu'
        },
      ],
    };
  }

  // ========================================
  // HIGHLIGHTS - Điểm nổi bật
  // ========================================

  /// Highlights cho Visual Cards
  static Map<int, List<String>> getVisualHighlights() {
    return {
      1: [
        '30 năm lịch sử từ 1995 - mang tên Quốc tổ',
        'Quyết định 470/TTg thành lập trường dân lập',
        'Chuyển đổi sang tư thục năm 2010',
        'Logo mới 2025 "Tương lai vững bước"',
        'Linh vật Chim Lạc - biểu tượng Âu Lạc',
      ],
      2: [
        'VR Center 90m2 đầu tiên tại Việt Nam',
        'Phòng máy tính hiện đại đồng bộ',
        'Thư viện hàng nghìn sách + internet',
        'Phòng học máy lạnh, máy chiếu, wifi',
        'Văn phòng khoa thân thiện sinh viên',
      ],
      3: [
        'Trụ sở chính 756 Nguyễn Trãi Q5',
        'Cơ sở I tại 28-50 Ngô Quyền Q5',
        '7 khoa đào tạo đa ngành nghề',
        'Hệ thống tổ chức hoàn chỉnh',
        'Các tổ chức đoàn thể hỗ trợ SV',
      ],
      4: [
        '2 cơ sở chính tại Quận 5',
        'Trang thiết bị hiện đại đồng bộ',
        'Phòng học có máy lạnh + wifi',
        'Cảnh quan xanh thân thiện',
        'Môi trường học tập lý tưởng',
      ],
      5: [
        'Ban Giám hiệu 1+2 (Hiệu trưởng + 2 Hiệu phó)',
        'Hệ thống 8 phòng ban chức năng',
        'Cơ cấu tổ chức hoàn chỉnh từ 2025',
        'Hội đồng Trường và các hội đồng chuyên môn',
        'Quản lý chuyên nghiệp, hiệu quả',
      ],
      6: [
        'Phòng CTSV - chăm sóc sinh viên toàn diện',
        'Phòng Đào tạo - quản lý chương trình học',
        'Trung tâm Tuyển sinh + Quan hệ doanh nghiệp',
        'Phòng Khảo thí - tổ chức thi và đánh giá',
        'Hỗ trợ sinh viên 24/7 từ A-Z',
      ],
      7: [
        'Khoa QTKD - Marketing, TMĐT, QTNS',
        'Khoa KTCN - CNTT, KTMT, VR/AI/IoT',
        'Khoa Ngôn ngữ - 4 ngoại ngữ + Metaverse',
        'Khoa TCNH - Tài chính Ngân hàng',
        'Khoa Du lịch, Luật, KHSK',
      ],
      9: [
        'Chuẩn ngoại ngữ CEFR A2-B2',
        'Chứng chỉ Microsoft Office Specialist',
        'Kỹ năng số 4.0 - AI, Data, Digital',
        'Đánh giá thực hành và dự án thực tế',
        'Cập nhật theo xu hướng 2025',
      ],
      10: [
        'IoT lab với Arduino, ESP32, Raspberry Pi',
        'Smart Campus DHV với sensor networks',
        '50 tỷ thiết bị IoT dự kiến năm 2030',
        'Cloud platform AWS IoT, Azure IoT',
        'Ứng dụng IoT trong giáo dục thông minh',
      ],
      11: [
        'Arduino - platform mã nguồn mở',
        'Raspberry Pi - single board computer',
        'ARM Cortex - kiến trúc vi xử lý tiên tiến',
        'STM32, TI LaunchPad development boards',
        '98% thiết bị điện tử có vi xử lý',
      ],
      12: [
        'GPU clusters cho deep learning training',
        'Computer Vision lab với AI cameras',
        'NLP research cho tiếng Việt',
        '1.35 tỷ USD thị trường AI Việt Nam',
        'TensorFlow, PyTorch frameworks',
      ],
      13: [
        'Hadoop cluster 48TB storage',
        'Apache Spark in-memory processing',
        'Multi-cloud: AWS, Azure, GCP',
        '2.5 quintillion bytes dữ liệu/ngày',
        'Tableau, Power BI visualization',
      ],
      14: [
        'Ethereum blockchain development',
        'Smart contracts với Solidity',
        'DApps cho education sector',
        '68 triệu ví crypto toàn cầu',
        'Educational mining rigs',
      ],
      15: [
        'Penetration testing lab với Kali Linux',
        'SOC room giám sát 24/7',
        'Digital forensics investigation',
        '3.5 triệu việc làm cybersecurity thiếu',
        'Vulnerable VMs cho practice',
      ],
      16: [
        'Docker containerization platform',
        'Kubernetes orchestration',
        'CI/CD pipeline automation',
        '83% doanh nghiệp áp dụng cloud',
        'Microservices architecture',
      ],
    };
  }

  /// Highlights cho Audio Cards
  static Map<int, List<String>> getAudioHighlights() {
    return {
      1: [
        'Phát âm từ "Hùng Vương" - tên Quốc tổ',
        'Từ vựng về lịch sử và truyền thống',
        'Thuật ngữ tổ chức giáo dục',
        'Ký hiệu phiên âm quốc tế (IPA)',
        'Từ khóa về sứ mệnh và tầm nhìn',
      ],
      2: [
        'Thuật ngữ công nghệ VR/Metaverse',
        'Phát âm từ tiếng Anh IT: AI, IoT, ML',
        'Từ vựng chuyên ngành CNTT',
        'Giao tiếp trong môi trường tech',
        'Pronunciation về cơ sở vật chất',
      ],
      3: [
        'Từ vựng về cơ sở vật chất',
        'Thuật ngữ trang thiết bị hiện đại',
        'Phát âm địa chỉ và địa điểm',
        'Từ khóa về tổ chức và quản lý',
        'Vocabulary về tiện ích campus',
      ],
      4: [
        'Phát âm "campus" và "cơ sở vật chất"',
        'Từ vựng trang thiết bị hiện đại',
        'Pronunciation địa chỉ 2 cơ sở',
        'Thuật ngữ về tiện nghi và môi trường',
        'Vocabulary về không gian học tập',
      ],
      5: [
        'Từ khóa tổ chức và cơ cấu quản lý',
        'Phát âm "Ban Giám hiệu, Hội đồng"',
        'Vocabulary về phòng ban chức năng',
        'Thuật ngữ hệ thống điều hành',
        'Pronunciation cấu trúc tổ chức',
      ],
      6: [
        'Từ vựng về hỗ trợ sinh viên',
        'Phát âm các phòng ban chuyên môn',
        'Thuật ngữ công tác sinh viên',
        'Vocabulary tuyển sinh và đào tạo',
        'Pronunciation dịch vụ hỗ trợ',
      ],
      7: [
        'Tên các khoa và chuyên ngành',
        'Phát âm ngành học tiếng Anh/Việt',
        'Vocabulary về lĩnh vực đào tạo',
        'Thuật ngữ kinh doanh và công nghệ',
        'Pronunciation tên các faculty',
      ],
      9: [
        'Từ khóa chuẩn đầu ra và đánh giá',
        'Phát âm "CEFR" và "Microsoft"',
        'Vocabulary về chứng chỉ quốc tế',
        'Thuật ngữ kỹ năng số và công nghệ',
        'Pronunciation năng lực và đánh giá',
      ],
      10: [
        'Thuật ngữ IoT: sensor, gateway, protocol',
        'Phát âm "Internet of Things"',
        'Vocabulary về smart devices',
        'Pronunciation ESP32, Arduino',
        'Từ khóa connectivity và networking',
      ],
      11: [
        'Phát âm Arduino và Raspberry Pi',
        'Thuật ngữ embedded: firmware, real-time',
        'Vocabulary về ARM Cortex architecture',
        'Pronunciation debugging và testing',
        'Từ khóa microcontroller và SBC',
      ],
      12: [
        'Thuật ngữ AI/ML: neural network, GPU',
        'Phát âm TensorFlow, PyTorch',
        'Vocabulary Computer Vision',
        'Pronunciation deep learning',
        'Từ khóa NLP và machine learning',
      ],
      13: [
        'Thuật ngữ Big Data: Hadoop, Spark',
        'Phát âm Apache và visualization',
        'Vocabulary cloud computing',
        'Pronunciation analytics và insights',
        'Từ khóa data mining và warehouse',
      ],
      14: [
        'Thuật ngữ Blockchain: cryptocurrency',
        'Phát âm Ethereum và Solidity',
        'Vocabulary smart contracts',
        'Pronunciation decentralization',
        'Từ khóa DApps và consensus',
      ],
      15: [
        'Thuật ngữ Security: penetration testing',
        'Phát âm cybersecurity và forensics',
        'Vocabulary ethical hacking',
        'Pronunciation vulnerability',
        'Từ khóa malware và encryption',
      ],
      16: [
        'Thuật ngữ DevOps: containerization',
        'Phát âm Docker và Kubernetes',
        'Vocabulary CI/CD pipeline',
        'Pronunciation microservices',
        'Từ khóa automation và deployment',
      ],
    };
  }

  /// Highlights cho Interactive Cards
  static Map<int, List<String>> getInteractiveHighlights() {
    return {
      1: [
        'Quiz về lịch sử 30 năm DHV',
        'Câu hỏi quyết định thành lập',
        'Kiến thức về Quốc tổ Hùng Vương',
        'Bản đồ các cơ sở DHV',
        'Giải thích chi tiết mỗi câu trả lời',
      ],
      2: [
        'Quiz công nghệ VR/Metaverse',
        'Bản đồ cơ sở vật chất hiện đại',
        'Tìm hiểu VR Center 90m2',
        'Khám phá phòng máy và thư viện',
        'Tương tác với tiện ích campus',
      ],
      3: [
        'Quiz về tổ chức và cấu trúc',
        'Bản đồ hệ thống 7 khoa',
        'Tìm hiểu các phòng ban chức năng',
        'Khám phá tổ chức đoàn thể',
        'Địa điểm trụ sở và cơ sở',
      ],
      4: [
        'Quiz về 2 cơ sở DHV',
        'Bản đồ cơ sở vật chất chi tiết',
        'Khám phá trang thiết bị hiện đại',
        'Tương tác với môi trường campus',
        'Tìm hiểu tiện nghi học tập',
      ],
      5: [
        'Quiz về cơ cấu tổ chức DHV',
        'Bản đồ hệ thống điều hành',
        'Tìm hiểu Ban Giám hiệu và Hội đồng',
        'Khám phá 8 phòng ban chức năng',
        'Cấu trúc quản lý chuyên nghiệp',
      ],
      6: [
        'Quiz về các phòng ban hỗ trợ',
        'Bản đồ dịch vụ sinh viên',
        'Tìm hiểu CTSV và Đào tạo',
        'Khám phá Tuyển sinh và Khảo thí',
        'Hệ thống hỗ trợ toàn diện',
      ],
      7: [
        'Quiz về 7 khoa đào tạo',
        'Bản đồ các ngành và chuyên ngành',
        'Tìm hiểu QTKD, KTCN, Ngôn ngữ',
        'Khám phá TCNH, Du lịch, Luật, KHSK',
        'Đa dạng lĩnh vực đào tạo',
      ],
      9: [
        'Quiz về chuẩn đầu ra DHV',
        'Bản đồ hệ thống đánh giá',
        'Tìm hiểu CEFR và Microsoft',
        'Khám phá kỹ năng số 4.0',
        'Chuẩn quốc tế và thực hành',
      ],
      10: [
        'Quiz IoT với smart devices',
        'Bản đồ IoT lab và equipment',
        'Thực hành với sensor networks',
        'Demo smart campus DHV',
        'Tương tác với cloud platforms',
      ],
      11: [
        'Lab thực hành Arduino programming',
        'Bản đồ embedded systems lab',
        'Demo Raspberry Pi projects',
        'Thực hành ARM Cortex development',
        'Hardware prototyping workshop',
      ],
      12: [
        'Demo AI/ML applications',
        'Bản đồ GPU computing cluster',
        'Thực hành computer vision',
        'Interactive neural network training',
        'Vietnamese NLP demonstrations',
      ],
      13: [
        'Quiz Big Data concepts',
        'Bản đồ Hadoop cluster setup',
        'Demo Apache Spark processing',
        'Interactive data visualization',
        'Cloud analytics playground',
      ],
      14: [
        'Demo blockchain applications',
        'Bản đồ cryptocurrency ecosystem',
        'Thực hành smart contract coding',
        'Interactive DApp development',
        'Educational mining demonstration',
      ],
      15: [
        'Lab penetration testing thực tế',
        'Bản đồ security infrastructure',
        'Demo ethical hacking tools',
        'Interactive vulnerability assessment',
        'Forensics investigation simulation',
      ],
      16: [
        'Quiz DevOps methodology',
        'Bản đồ cloud deployment',
        'Demo containerization với Docker',
        'Interactive CI/CD pipeline',
        'Microservices architecture lab',
      ],
    };
  }

  /// Highlights cho Info Cards
  static Map<int, List<String>> getInfoHighlights() {
    return {
      1: [
        'Thành lập 1995 - 30 năm phát triển',
        '7 khoa đào tạo đa ngành nghề',
        '2 cơ sở tại Quận 5 TP.HCM',
        'Loại hình tư thục từ 2010',
        'Ngày truyền thống 9/5 âm lịch',
      ],
      2: [
        'VR Center 90m2 đầu tiên Việt Nam',
        '12 chỗ trải nghiệm VR hiện đại',
        'Phòng máy tính đồng bộ tiên tiến',
        'Thư viện hàng nghìn đầu sách',
        'Wifi miễn phí toàn trường',
      ],
      3: [
        'Ngành CNTT mã 7480201',
        '4 chuyên ngành công nghệ',
        'Metaverse đầu tiên tại VN',
        'AI, Machine Learning, IoT',
        'Thực tập tại doanh nghiệp',
      ],
      4: [
        '2 cơ sở tại Quận 5 TP.HCM',
        'Trang thiết bị hiện đại đồng bộ',
        'Phòng học có máy lạnh + wifi',
        'Môi trường xanh - sạch - đẹp',
        'Cơ sở vật chất đạt chuẩn quốc tế',
      ],
      5: [
        '1 Hiệu trưởng + 2 Hiệu phó',
        '8 phòng ban chức năng',
        '7 khoa đào tạo chuyên nghiệp',
        '5 trung tâm hỗ trợ',
        'Cơ cấu tổ chức hoàn chỉnh 2025',
      ],
      6: [
        'CTSV - chăm sóc sinh viên 24/7',
        'Đào tạo - quản lý chương trình học',
        'Tuyển sinh + quan hệ doanh nghiệp',
        'Khảo thí - tổ chức và đánh giá',
        'Hỗ trợ toàn diện từ A đến Z',
      ],
      7: [
        '7 khoa đào tạo đa ngành nghề',
        'QTKD - Marketing, TMĐT, QTNS',
        'KTCN - CNTT + VR/AI/IoT',
        'Ngôn ngữ - 4 ngoại ngữ + Metaverse',
        'TCNH, Du lịch, Luật, KHSK',
      ],
      9: [
        'Chuẩn ngoại ngữ CEFR A2-B2',
        'Microsoft Office Specialist',
        'Kỹ năng số 4.0 - AI/Data/Digital',
        'Chứng chỉ quốc tế được công nhận',
        'Đánh giá thực hành + dự án thực tế',
      ],
      10: [
        '50 tỷ thiết bị IoT kết nối năm 2030',
        'ESP32, Arduino platforms',
        'AWS IoT Core, Azure IoT cloud',
        'Smart campus với sensor networks',
        'IoT market tăng 25% mỗi năm',
      ],
      11: [
        '98% thiết bị điện tử có vi xử lý',
        'Arduino - 30 triệu boards đã bán',
        'ARM dominates 95% mobile market',
        'Raspberry Pi - 50 triệu units sold',
        'Embedded systems: 90 tỷ USD market',
      ],
      12: [
        '1.35 tỷ USD thị trường AI Việt Nam',
        'GPU computing 100x faster',
        'TensorFlow - 180 triệu downloads',
        'Computer Vision 40% CAGR growth',
        'Vietnam top 3 AI outsourcing',
      ],
      13: [
        '2.5 quintillion bytes dữ liệu mỗi ngày',
        'Apache Spark nhanh hơn Hadoop 100 lần',
        'Big Data market: 273 tỷ USD năm 2026',
        'Cloud adoption 83% doanh nghiệp',
        'Data scientists tăng lương 50%',
      ],
      14: [
        '68 triệu ví crypto toàn cầu',
        'Ethereum 400K smart contracts',
        'Blockchain market 163 tỷ USD năm 2028',
        'DeFi locked value hơn 200 tỷ USD',
        'NFT market cap đỉnh 40 tỷ USD',
      ],
      15: [
        '3.5 triệu việc làm cybersecurity thiếu',
        'Cyberattacks tăng 600% thời pandemic',
        'Security market 300 tỷ USD năm 2025',
        'Chi phí breach trung bình 4.35 triệu USD',
        'Vietnam thiếu 500K nhân lực cyber',
      ],
      16: [
        '83% doanh nghiệp áp dụng cloud',
        'Docker đã deploy 20 tỷ containers',
        'Kubernetes adoption 89% enterprises',
        'DevOps market 30 tỷ USD năm 2028',
        'CI/CD giảm bugs 50-90%',
      ],
    };
  }

  // ========================================
  // CONTENT TITLES & SUBTITLES
  // ========================================

  /// Card titles cho từng loại và bài học - 3 chương DHV Core
  static Map<String, Map<int, Map<String, String>>> getCardTitles() {
    return {
      'visual': {
        1: {
          'title': 'Lịch sử DHV',
          'subtitle': 'Từ 1995 đến 2025 - 30 năm mang tên Quốc tổ'
        },
        2: {
          'title': 'Cơ sở vật chất',
          'subtitle': 'VR Center, phòng máy, thư viện hiện đại'
        },
        3: {
          'title': 'Campus & Địa điểm',
          'subtitle': '2 cơ sở tại Q5 và cơ cấu tổ chức'
        },
        4: {
          'title': 'Cơ sở vật chất',
          'subtitle': '2 cơ sở hiện đại với đầy đủ tiện nghi'
        },
        5: {
          'title': 'Hệ thống tổ chức',
          'subtitle': 'Ban Giám hiệu, 8 phòng ban, 7 khoa'
        },
        6: {
          'title': 'Phòng ban hỗ trợ',
          'subtitle': 'CTSV, Đào tạo, Tuyển sinh, Khảo thí'
        },
        7: {
          'title': '7 Khoa đào tạo',
          'subtitle': 'QTKD, KTCN, Ngôn ngữ và 4 khoa khác'
        },
        9: {
          'title': 'Chuẩn đầu ra',
          'subtitle': 'CEFR, Microsoft, kỹ năng số 4.0'
        },
        10: {
          'title': 'IoT - Vạn vật kết nối',
          'subtitle': 'Cảm biến, thiết bị thông minh, smart city'
        },
        11: {
          'title': 'Hệ thống nhúng',
          'subtitle': 'Arduino, Raspberry Pi, ARM Cortex'
        },
        12: {
          'title': 'AI & Machine Learning',
          'subtitle': 'Deep Learning, Computer Vision, GPU'
        },
        13: {
          'title': 'Big Data Analytics',
          'subtitle': 'Hadoop, Apache Spark, Cloud Computing'
        },
        14: {
          'title': 'Blockchain & Crypto',
          'subtitle': 'Smart Contracts, DApps, Mining'
        },
        15: {
          'title': 'Cybersecurity',
          'subtitle': 'Ethical Hacking, Penetration Testing'
        },
        16: {
          'title': 'DevOps & Microservices',
          'subtitle': 'Docker, Kubernetes, CI/CD Pipeline'
        },
      },
      'audio': {
        1: {
          'title': 'Phát âm lịch sử',
          'subtitle': 'Hùng Vương, Quốc tổ, truyền thống'
        },
        2: {
          'title': 'Thuật ngữ Công nghệ',
          'subtitle': 'VR, AI, Metaverse, IoT, Machine Learning'
        },
        3: {
          'title': 'Từ vựng Campus',
          'subtitle': 'Cơ sở vật chất, trang thiết bị, tiện ích'
        },
        4: {
          'title': 'Phát âm Cơ sở',
          'subtitle': 'Campus, trang thiết bị, tiện nghi'
        },
        5: {
          'title': 'Từ vựng Tổ chức',
          'subtitle': 'Ban Giám hiệu, phòng ban, hội đồng'
        },
        6: {
          'title': 'Thuật ngữ Hỗ trợ',
          'subtitle': 'CTSV, đào tạo, tuyển sinh, khảo thí'
        },
        7: {
          'title': 'Tên các Khoa',
          'subtitle': 'QTKD, KTCN, ngôn ngữ và chuyên ngành'
        },
        9: {
          'title': 'Phát âm Chuẩn',
          'subtitle': 'CEFR, Microsoft, kỹ năng số'
        },
        10: {
          'title': 'Thuật ngữ IoT',
          'subtitle': 'Internet of Things, sensor, smart device'
        },
        11: {
          'title': 'Từ vựng Embedded',
          'subtitle': 'Vi xử lý, mạch logic, lập trình nhúng'
        },
        12: {
          'title': 'Phát âm AI/ML',
          'subtitle': 'Machine Learning, Deep Learning, Neural Network'
        },
        13: {
          'title': 'Thuật ngữ Big Data',
          'subtitle': 'Data Mining, Cloud Computing, Analytics'
        },
        14: {
          'title': 'Từ vựng Blockchain',
          'subtitle': 'Cryptocurrency, Smart Contract, Decentralization'
        },
        15: {
          'title': 'Thuật ngữ Security',
          'subtitle': 'Penetration Testing, Vulnerability, Encryption'
        },
        16: {
          'title': 'Phát âm DevOps',
          'subtitle': 'Container, Microservices, Deployment'
        },
      },
      'interactive': {
        1: {
          'title': 'Quiz Lịch sử DHV',
          'subtitle': 'Kiểm tra kiến thức về trường'
        },
        2: {'title': 'Quiz Công nghệ', 'subtitle': 'VR Center, AI, ngành CNTT'},
        3: {'title': 'Bản đồ DHV', 'subtitle': 'Khám phá cơ sở và tổ chức'},
        4: {
          'title': 'Quiz Cơ sở vật chất',
          'subtitle': 'Trang thiết bị và campus'
        },
        5: {'title': 'Quiz Tổ chức', 'subtitle': 'Cơ cấu và hệ thống quản lý'},
        6: {'title': 'Bản đồ Hỗ trợ SV', 'subtitle': 'Phòng ban và dịch vụ'},
        7: {'title': 'Quiz 7 Khoa', 'subtitle': 'Ngành học và chuyên môn'},
        9: {'title': 'Quiz Chuẩn đầu ra', 'subtitle': 'CEFR và chứng chỉ'},
        10: {'title': 'Quiz IoT', 'subtitle': 'Smart devices và ứng dụng'},
        11: {'title': 'Lab Embedded', 'subtitle': 'Arduino và Raspberry Pi'},
        12: {
          'title': 'Demo AI/ML',
          'subtitle': 'Computer Vision và Deep Learning'
        },
        13: {
          'title': 'Quiz Big Data',
          'subtitle': 'Analytics và Cloud Computing'
        },
        14: {
          'title': 'Demo Blockchain',
          'subtitle': 'Smart Contracts và DApps'
        },
        15: {
          'title': 'Lab Security',
          'subtitle': 'Penetration Testing thực tế'
        },
        16: {'title': 'Quiz DevOps', 'subtitle': 'Container và Microservices'},
      },
      'info': {
        1: {'title': 'Thống kê DHV', 'subtitle': '30 năm, 7 khoa, 2 cơ sở'},
        2: {'title': 'Công nghệ tiên tiến', 'subtitle': 'VR 90m2, AI/ML, IoT'},
        3: {'title': 'Khoa CNTT', 'subtitle': 'Mã 7480201, 4 chuyên ngành'},
        4: {
          'title': 'Thống kê Cơ sở',
          'subtitle': '2 cơ sở, trang thiết bị hiện đại'
        },
        5: {
          'title': 'Thống kê Tổ chức',
          'subtitle': '1+2 BGH, 8 phòng, 7 khoa'
        },
        6: {
          'title': 'Thống kê Hỗ trợ',
          'subtitle': 'CTSV, đào tạo, tuyển sinh'
        },
        7: {
          'title': 'Thống kê 7 Khoa',
          'subtitle': 'Đa ngành nghề, chuyên sâu'
        },
        9: {
          'title': 'Thống kê Chuẩn',
          'subtitle': 'CEFR, Microsoft, kỹ năng số'
        },
        10: {
          'title': 'Thống kê IoT',
          'subtitle': '50 tỷ thiết bị kết nối năm 2030'
        },
        11: {
          'title': 'Thống kê Embedded',
          'subtitle': '98% thiết bị điện tử có vi xử lý'
        },
        12: {
          'title': 'Thống kê AI/ML',
          'subtitle': '1.35 tỷ USD thị trường AI Việt Nam'
        },
        13: {
          'title': 'Thống kê Big Data',
          'subtitle': '2.5 quintillion bytes dữ liệu/ngày'
        },
        14: {
          'title': 'Thống kê Blockchain',
          'subtitle': '68 triệu ví crypto toàn cầu'
        },
        15: {
          'title': 'Thống kê Security',
          'subtitle': '3.5 triệu việc làm cybersecurity thiếu'
        },
        16: {
          'title': 'Thống kê DevOps',
          'subtitle': '83% doanh nghiệp áp dụng cloud'
        },
      },
    };
  }

  // ========================================
  // UTILITY METHODS - Phương thức hỗ trợ
  // ========================================

  /// Lấy content cho một card cụ thể
  static Map<String, dynamic> getContentForCard({
    required String cardType,
    required int lessonId,
  }) {
    final titles = getCardTitles();
    final cardTitles = titles[cardType]?[lessonId] ??
        {'title': 'Đang cập nhật', 'subtitle': 'Nội dung sẽ được bổ sung'};

    Map<String, dynamic> content = {
      'title': cardTitles['title'],
      'subtitle': cardTitles['subtitle'],
      'highlights': [],
    };

    switch (cardType) {
      case 'visual':
        content['highlights'] = getVisualHighlights()[lessonId] ?? [];
        final timelineData = getTimelineData()[lessonId];
        final galleryData = getGalleryData()[lessonId];

        if (timelineData != null && timelineData.isNotEmpty) {
          content['type'] = 'timeline';
          content['timelineData'] = timelineData;
        } else if (galleryData != null && galleryData.isNotEmpty) {
          content['type'] = 'gallery';
          content['images'] = galleryData;
        } else {
          content['type'] = 'default';
          content['content'] = 'Nội dung hình ảnh về ${cardTitles['title']}';
        }
        break;

      case 'audio':
        content['highlights'] = getAudioHighlights()[lessonId] ?? [];
        final pronunciationData = getPronunciationData()[lessonId];
        final vocabularyData = getVocabularyData()[lessonId];

        if (pronunciationData != null && pronunciationData.isNotEmpty) {
          content['type'] = 'pronunciation';
          content['pronunciationData'] = pronunciationData;
        } else if (vocabularyData != null && vocabularyData.isNotEmpty) {
          content['type'] = 'vocabulary';
          content['vocabulary'] = vocabularyData;
        } else {
          content['type'] = 'default';
          content['content'] = 'Nội dung âm thanh đang được cập nhật';
          content['audioText'] = 'Xin chào, đây là bài học tiếng Việt';
        }
        break;

      case 'interactive':
        content['highlights'] = getInteractiveHighlights()[lessonId] ?? [];
        final quizData = getQuizData()[lessonId];
        final mapData = getMapData()[lessonId];

        if (quizData != null) {
          content['type'] = 'quiz';
          content['quizData'] = quizData;
        } else if (mapData != null) {
          content['type'] = 'map';
          content['mapData'] = mapData;
        } else {
          content['type'] = 'default';
          content['content'] = 'Nội dung tương tác đang được cập nhật';
        }
        break;

      case 'info':
        content['highlights'] = getInfoHighlights()[lessonId] ?? [];
        final statsData = getStatsData()[lessonId];

        if (statsData != null) {
          content['type'] = 'stats';
          content['statsData'] = statsData;
        } else {
          content['type'] = 'default';
          content['content'] = 'Thông tin chi tiết đang được cập nhật';
        }
        break;

      default:
        content['type'] = 'default';
        content['content'] = 'Nội dung đang được phát triển';
    }

    return content;
  }

  /// Lấy tất cả content cho một bài học
  static Map<String, dynamic> getAllContentForLesson(int lessonId) {
    return {
      'visual': getContentForCard(cardType: 'visual', lessonId: lessonId),
      'audio': getContentForCard(cardType: 'audio', lessonId: lessonId),
      'interactive':
          getContentForCard(cardType: 'interactive', lessonId: lessonId),
      'info': getContentForCard(cardType: 'info', lessonId: lessonId),
    };
  }

  /// Kiểm tra xem lesson có content hay không
  static bool hasContentForLesson(int lessonId) {
    // Kiểm tra dựa trên card titles có data cho lesson này không
    return getCardTitles()['visual']?.containsKey(lessonId) ?? false;
  }

  /// Lấy danh sách các lesson có content
  static List<int> getAvailableLessons() {
    return getCardTitles()['visual']?.keys.toList() ?? [];
  }
}
