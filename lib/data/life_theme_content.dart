import 'package:flutter/material.dart';

// ===============================================
// LIFE THEME CONTENT DATA - VIETNAMESE LEARNING
// ===============================================

class LifeThemeContentProvider {
  // Main content data for all Life Theme units
  static final Map<int, Map<String, dynamic>> _unitContent = {
    // UNIT 1: GIA ĐÌNH & MỐI QUAN HỆ (100-107)
    1: {
      'title': 'Gia đình & Mối quan hệ',
      'description':
          'Học từ vựng và giao tiếp về gia đình, họ hàng và các mối quan hệ xã hội',
      'color': const Color(0xFFE91E63),
      'icon': Icons.family_restroom,
      'totalLessons': 8,
      'vocabulary': {
        // Core Family Terms
        'immediate_family': [
          {'vn': 'bố', 'en': 'father/dad', 'ipa': '/boː/', 'audio': 'bo.mp3'},
          {'vn': 'mẹ', 'en': 'mother/mom', 'ipa': '/mɛ/', 'audio': 'me.mp3'},
          {'vn': 'con', 'en': 'child', 'ipa': '/kɔn/', 'audio': 'con.mp3'},
          {
            'vn': 'anh',
            'en': 'older brother',
            'ipa': '/aɲ/',
            'audio': 'anh.mp3'
          },
          {
            'vn': 'chị',
            'en': 'older sister',
            'ipa': '/t͡ʃi/',
            'audio': 'chi.mp3'
          },
          {
            'vn': 'em',
            'en': 'younger sibling',
            'ipa': '/ɛm/',
            'audio': 'em.mp3'
          },
          {'vn': 'vợ', 'en': 'wife', 'ipa': '/vəː/', 'audio': 'vo.mp3'},
          {
            'vn': 'chồng',
            'en': 'husband',
            'ipa': '/t͡ʃoŋm/',
            'audio': 'chong.mp3'
          },
        ],
        'extended_family': [
          {
            'vn': 'ông',
            'en': 'grandfather',
            'ipa': '/oŋm/',
            'audio': 'ong.mp3'
          },
          {'vn': 'bà', 'en': 'grandmother', 'ipa': '/baː/', 'audio': 'ba.mp3'},
          {
            'vn': 'cô',
            'en': 'aunt (father\'s sister)',
            'ipa': '/koː/',
            'audio': 'co.mp3'
          },
          {
            'vn': 'dì',
            'en': 'aunt (mother\'s sister)',
            'ipa': '/ziː/',
            'audio': 'di.mp3'
          },
          {
            'vn': 'chú',
            'en': 'uncle (father\'s brother)',
            'ipa': '/t͡ʃu/',
            'audio': 'chu.mp3'
          },
          {
            'vn': 'cậu',
            'en': 'uncle (mother\'s brother)',
            'ipa': '/kəw/',
            'audio': 'cau.mp3'
          },
          {
            'vn': 'anh/chị họ',
            'en': 'cousin',
            'ipa': '/aɲ t͡ʃi hoː/',
            'audio': 'anh_chi_ho.mp3'
          },
        ],
        'relationships': [
          {'vn': 'bạn', 'en': 'friend', 'ipa': '/baːn/', 'audio': 'ban.mp3'},
          {
            'vn': 'bạn thân',
            'en': 'close friend',
            'ipa': '/baːn tʰaːn/',
            'audio': 'ban_than.mp3'
          },
          {
            'vn': 'người yêu',
            'en': 'boyfriend/girlfriend',
            'ipa': '/ŋɯəj iɛw/',
            'audio': 'nguoi_yeu.mp3'
          },
          {
            'vn': 'hàng xóm',
            'en': 'neighbor',
            'ipa': '/haːŋ soːm/',
            'audio': 'hang_xom.mp3'
          },
          {
            'vn': 'đồng nghiệp',
            'en': 'colleague',
            'ipa': '/doŋm ŋiɛp/',
            'audio': 'dong_nghiep.mp3'
          },
        ]
      },
      'grammar_patterns': [
        {
          'pattern': 'Đây là [person]',
          'meaning': 'This is [person]',
          'examples': ['Đây là bố tôi', 'Đây là mẹ tôi', 'Đây là anh trai tôi']
        },
        {
          'pattern': '[Person] của tôi',
          'meaning': 'My [person]',
          'examples': [
            'Bố của tôi làm bác sĩ',
            'Mẹ của tôi rất tốt',
            'Anh của tôi học đại học'
          ]
        }
      ]
    },

    // UNIT 2: ĐỒ ĂN & ẨM THỰC VIỆT NAM (200-207)
    2: {
      'title': 'Đồ ăn & Ẩm thực Việt Nam',
      'description': 'Khám phá ẩm thực Việt Nam từ cơ bản đến nâng cao',
      'color': const Color(0xFFFFC107),
      'icon': Icons.restaurant,
      'totalLessons': 8,
      'vocabulary': {
        'street_food': [
          {
            'vn': 'phở',
            'en': 'pho (noodle soup)',
            'ipa': '/fəː/',
            'audio': 'pho.mp3'
          },
          {
            'vn': 'bánh mì',
            'en': 'Vietnamese sandwich',
            'ipa': '/baɲ miː/',
            'audio': 'banh_mi.mp3'
          },
          {
            'vn': 'bún chả',
            'en': 'grilled pork with noodles',
            'ipa': '/bun t͡ʃaː/',
            'audio': 'bun_cha.mp3'
          },
          {
            'vn': 'chả cá',
            'en': 'grilled fish',
            'ipa': '/t͡ʃaː kaː/',
            'audio': 'cha_ca.mp3'
          },
          {
            'vn': 'nem rán',
            'en': 'spring rolls',
            'ipa': '/nɛm zaːn/',
            'audio': 'nem_ran.mp3'
          },
          {
            'vn': 'bánh xèo',
            'en': 'Vietnamese pancake',
            'ipa': '/baɲ sɛw/',
            'audio': 'banh_xeo.mp3'
          },
        ],
        'main_dishes': [
          {'vn': 'cơm', 'en': 'rice', 'ipa': '/kəm/', 'audio': 'com.mp3'},
          {'vn': 'thịt', 'en': 'meat', 'ipa': '/tʰit/', 'audio': 'thit.mp3'},
          {'vn': 'cá', 'en': 'fish', 'ipa': '/kaː/', 'audio': 'ca.mp3'},
          {'vn': 'gà', 'en': 'chicken', 'ipa': '/gaː/', 'audio': 'ga.mp3'},
          {'vn': 'rau', 'en': 'vegetables', 'ipa': '/zaw/', 'audio': 'rau.mp3'},
          {'vn': 'canh', 'en': 'soup', 'ipa': '/kaɲ/', 'audio': 'canh.mp3'},
        ],
        'beverages': [
          {'vn': 'nước', 'en': 'water', 'ipa': '/nɯək/', 'audio': 'nuoc.mp3'},
          {'vn': 'trà', 'en': 'tea', 'ipa': '/t͡ʃaː/', 'audio': 'tra.mp3'},
          {
            'vn': 'cà phê',
            'en': 'coffee',
            'ipa': '/kaː fɛ/',
            'audio': 'ca_phe.mp3'
          },
          {'vn': 'bia', 'en': 'beer', 'ipa': '/bia/', 'audio': 'bia.mp3'},
          {
            'vn': 'nước ngọt',
            'en': 'soft drink',
            'ipa': '/nɯək ŋɔt/',
            'audio': 'nuoc_ngot.mp3'
          },
        ]
      },
      'grammar_patterns': [
        {
          'pattern': 'Tôi muốn [food]',
          'meaning': 'I want [food]',
          'examples': [
            'Tôi muốn ăn phở',
            'Tôi muốn uống cà phê',
            'Tôi muốn bánh mì'
          ]
        },
        {
          'pattern': '[Food] này ngon không?',
          'meaning': 'Is this [food] delicious?',
          'examples': [
            'Phở này ngon không?',
            'Bánh mì này ngon không?',
            'Cà phê này ngon không?'
          ]
        }
      ]
    },

    // UNIT 3: CÔNG VIỆC & NGHỀ NGHIỆP (300-307)
    3: {
      'title': 'Công việc & Nghề nghiệp',
      'description': 'Từ vựng và giao tiếp trong môi trường làm việc',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.work,
      'totalLessons': 8,
      'vocabulary': {
        'common_jobs': [
          {
            'vn': 'bác sĩ',
            'en': 'doctor',
            'ipa': '/baːk ʃi/',
            'audio': 'bac_si.mp3'
          },
          {
            'vn': 'giáo viên',
            'en': 'teacher',
            'ipa': '/zaːw viɛn/',
            'audio': 'giao_vien.mp3'
          },
          {
            'vn': 'kỹ sư',
            'en': 'engineer',
            'ipa': '/ki ʃɯ/',
            'audio': 'ky_su.mp3'
          },
          {
            'vn': 'lập trình viên',
            'en': 'programmer',
            'ipa': '/lap t͡ʃiɲ viɛn/',
            'audio': 'lap_trinh_vien.mp3'
          },
          {
            'vn': 'nhân viên',
            'en': 'employee',
            'ipa': '/ɲaːn viɛn/',
            'audio': 'nhan_vien.mp3'
          },
          {
            'vn': 'quản lý',
            'en': 'manager',
            'ipa': '/kwaːn li/',
            'audio': 'quan_ly.mp3'
          },
        ],
        'workplace': [
          {
            'vn': 'công ty',
            'en': 'company',
            'ipa': '/koŋ ti/',
            'audio': 'cong_ty.mp3'
          },
          {
            'vn': 'văn phòng',
            'en': 'office',
            'ipa': '/vaːn foŋ/',
            'audio': 'van_phong.mp3'
          },
          {'vn': 'họp', 'en': 'meeting', 'ipa': '/hop/', 'audio': 'hop.mp3'},
          {
            'vn': 'dự án',
            'en': 'project',
            'ipa': '/zu aːn/',
            'audio': 'du_an.mp3'
          },
          {
            'vn': 'lương',
            'en': 'salary',
            'ipa': '/lɯəŋ/',
            'audio': 'luong.mp3'
          },
        ]
      },
      'grammar_patterns': [
        {
          'pattern': 'Tôi làm [job]',
          'meaning': 'I work as [job]',
          'examples': ['Tôi làm bác sĩ', 'Tôi làm kỹ sư', 'Tôi làm giáo viên']
        }
      ]
    },

    // UNIT 4: SỞ THÍCH & GIẢI TRÍ (400-407)
    4: {
      'title': 'Sở thích & Giải trí',
      'description': 'Hoạt động thể thao, nghệ thuật và giải trí',
      'color': const Color(0xFFFF5722),
      'icon': Icons.sports_soccer,
      'totalLessons': 8,
      'vocabulary': {
        'sports': [
          {
            'vn': 'đá bóng',
            'en': 'football/soccer',
            'ipa': '/daː boŋ/',
            'audio': 'da_bong.mp3'
          },
          {
            'vn': 'bơi lội',
            'en': 'swimming',
            'ipa': '/bəj loj/',
            'audio': 'boi_loi.mp3'
          },
          {
            'vn': 'chạy bộ',
            'en': 'running',
            'ipa': '/t͡ʃaj bo/',
            'audio': 'chay_bo.mp3'
          },
          {
            'vn': 'bóng rổ',
            'en': 'basketball',
            'ipa': '/boŋ zo/',
            'audio': 'bong_ro.mp3'
          },
          {
            'vn': 'cầu lông',
            'en': 'badminton',
            'ipa': '/kəw loŋ/',
            'audio': 'cau_long.mp3'
          },
        ],
        'entertainment': [
          {
            'vn': 'xem phim',
            'en': 'watch movies',
            'ipa': '/sɛm fim/',
            'audio': 'xem_phim.mp3'
          },
          {
            'vn': 'nghe nhạc',
            'en': 'listen to music',
            'ipa': '/ŋɛ ɲak/',
            'audio': 'nghe_nhac.mp3'
          },
          {
            'vn': 'đọc sách',
            'en': 'read books',
            'ipa': '/dok ʃaːk/',
            'audio': 'doc_sach.mp3'
          },
          {
            'vn': 'chơi game',
            'en': 'play games',
            'ipa': '/t͡ʃəj gɛm/',
            'audio': 'choi_game.mp3'
          },
        ]
      },
      'grammar_patterns': [
        {
          'pattern': 'Tôi thích [activity]',
          'meaning': 'I like [activity]',
          'examples': [
            'Tôi thích đá bóng',
            'Tôi thích xem phim',
            'Tôi thích nghe nhạc'
          ]
        }
      ]
    },

    // UNIT 5: SỨC KHỎE & Y TẾ (500-507)
    5: {
      'title': 'Sức khỏe & Y tế',
      'description': 'Chăm sóc sức khỏe và các vấn đề y tế cơ bản',
      'color': const Color(0xFF607D8B),
      'icon': Icons.local_hospital,
      'totalLessons': 8,
      'vocabulary': {
        'body_parts': [
          {'vn': 'đầu', 'en': 'head', 'ipa': '/ɗəw/', 'audio': 'dau.mp3'},
          {'vn': 'mắt', 'en': 'eyes', 'ipa': '/mat/', 'audio': 'mat.mp3'},
          {'vn': 'tai', 'en': 'ears', 'ipa': '/taj/', 'audio': 'tai.mp3'},
          {'vn': 'tay', 'en': 'hands', 'ipa': '/taj/', 'audio': 'tay.mp3'},
          {
            'vn': 'chân',
            'en': 'legs/feet',
            'ipa': '/t͡ʃaːn/',
            'audio': 'chan.mp3'
          },
          {'vn': 'tim', 'en': 'heart', 'ipa': '/tim/', 'audio': 'tim.mp3'},
        ],
        'health_conditions': [
          {
            'vn': 'đau',
            'en': 'pain/hurt',
            'ipa': '/ɗaw/',
            'audio': 'dau_hurt.mp3'
          },
          {'vn': 'sốt', 'en': 'fever', 'ipa': '/ʃot/', 'audio': 'sot.mp3'},
          {'vn': 'ho', 'en': 'cough', 'ipa': '/ho/', 'audio': 'ho.mp3'},
          {
            'vn': 'cảm lạnh',
            'en': 'cold',
            'ipa': '/kaːm laɲ/',
            'audio': 'cam_lanh.mp3'
          },
        ]
      },
      'grammar_patterns': [
        {
          'pattern': 'Tôi bị đau [body part]',
          'meaning': 'I have pain in [body part]',
          'examples': ['Tôi bị đau đầu', 'Tôi bị đau bụng', 'Tôi bị đau lưng']
        }
      ]
    },

    // UNIT 6: MUA SẮM & TIỀN BẠC (600-607)
    6: {
      'title': 'Mua sắm & Tiền bạc',
      'description': 'Kỹ năng mua bán và quản lý tài chính',
      'color': const Color(0xFF795548),
      'icon': Icons.shopping_cart,
      'totalLessons': 8,
      'vocabulary': {
        'shopping': [
          {'vn': 'mua', 'en': 'buy', 'ipa': '/mua/', 'audio': 'mua.mp3'},
          {'vn': 'bán', 'en': 'sell', 'ipa': '/baːn/', 'audio': 'ban.mp3'},
          {'vn': 'tiền', 'en': 'money', 'ipa': '/tiɛn/', 'audio': 'tien.mp3'},
          {'vn': 'đắt', 'en': 'expensive', 'ipa': '/ɗat/', 'audio': 'dat.mp3'},
          {'vn': 'rẻ', 'en': 'cheap', 'ipa': '/zɛ/', 'audio': 're.mp3'},
          {'vn': 'chợ', 'en': 'market', 'ipa': '/t͡ʃəː/', 'audio': 'cho.mp3'},
        ],
        'clothing': [
          {'vn': 'áo', 'en': 'shirt', 'ipa': '/aːw/', 'audio': 'ao.mp3'},
          {'vn': 'quần', 'en': 'pants', 'ipa': '/kwaːn/', 'audio': 'quan.mp3'},
          {'vn': 'giày', 'en': 'shoes', 'ipa': '/zaːj/', 'audio': 'giay.mp3'},
          {'vn': 'túi', 'en': 'bag', 'ipa': '/tuj/', 'audio': 'tui.mp3'},
        ]
      },
      'grammar_patterns': [
        {
          'pattern': '[Item] này bao nhiêu tiền?',
          'meaning': 'How much is this [item]?',
          'examples': [
            'Áo này bao nhiêu tiền?',
            'Quần này bao nhiêu tiền?',
            'Giày này bao nhiêu tiền?'
          ]
        }
      ]
    }
  };

  // Get unit content by unit number
  static Map<String, dynamic>? getUnitContent(int unitNumber) {
    return _unitContent[unitNumber];
  }

  // Get all vocabulary for a unit
  static Map<String, List<Map<String, dynamic>>> getUnitVocabulary(
      int unitNumber) {
    final unitData = _unitContent[unitNumber];
    if (unitData == null) return {};
    return Map<String, List<Map<String, dynamic>>>.from(
        unitData['vocabulary'] ?? {});
  }

  // Get grammar patterns for a unit
  static List<Map<String, dynamic>> getGrammarPatterns(int unitNumber) {
    final unitData = _unitContent[unitNumber];
    if (unitData == null) return [];
    return List<Map<String, dynamic>>.from(unitData['grammar_patterns'] ?? []);
  }

  // Get all vocabulary words for a unit (flattened)
  static List<Map<String, dynamic>> getAllVocabularyWords(int unitNumber) {
    final vocabulary = getUnitVocabulary(unitNumber);
    final allWords = <Map<String, dynamic>>[];

    for (var wordList in vocabulary.values) {
      allWords.addAll(wordList);
    }

    return allWords;
  }

  // Get vocabulary by category
  static List<Map<String, dynamic>> getVocabularyByCategory(
      int unitNumber, String category) {
    final vocabulary = getUnitVocabulary(unitNumber);
    return List<Map<String, dynamic>>.from(vocabulary[category] ?? []);
  }

  // Get random vocabulary for practice
  static List<Map<String, dynamic>> getRandomVocabulary(
      int unitNumber, int count) {
    final allWords = getAllVocabularyWords(unitNumber);
    allWords.shuffle();
    return allWords.take(count).toList();
  }

  // Get unit title
  static String getUnitTitle(int unitNumber) {
    final unitData = _unitContent[unitNumber];
    return unitData?['title'] ?? 'Unit $unitNumber';
  }

  // Get unit color
  static Color getUnitColor(int unitNumber) {
    final unitData = _unitContent[unitNumber];
    return unitData?['color'] ?? Colors.blue;
  }

  // Get unit icon
  static IconData getUnitIcon(int unitNumber) {
    final unitData = _unitContent[unitNumber];
    return unitData?['icon'] ?? Icons.book;
  }

  // Check if unit exists
  static bool hasUnit(int unitNumber) {
    return _unitContent.containsKey(unitNumber);
  }

  // Get all available unit numbers
  static List<int> getAllUnitNumbers() {
    return _unitContent.keys.toList()..sort();
  }
}
