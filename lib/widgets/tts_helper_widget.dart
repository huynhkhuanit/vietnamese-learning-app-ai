import 'package:flutter/material.dart';
import '../services/universal_tts_service.dart';

/// Widget hỗ trợ TTS toàn cục với floating button và site map
class TTSHelperWidget extends StatefulWidget {
  final Widget child;
  final bool showFloatingButton;
  final bool showSiteMap;
  final Color? buttonColor;

  const TTSHelperWidget({
    super.key,
    required this.child,
    this.showFloatingButton = true,
    this.showSiteMap = true,
    this.buttonColor,
  });

  @override
  State<TTSHelperWidget> createState() => _TTSHelperWidgetState();
}

class _TTSHelperWidgetState extends State<TTSHelperWidget>
    with TickerProviderStateMixin {
  final UniversalTtsService _ttsService = UniversalTtsService();
  late AnimationController _fabController;
  late AnimationController _siteMapController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _siteMapAnimation;

  bool _isExpanded = false;
  bool _showSiteMap = false;
  bool _isPlaying = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimations();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    _ttsService.setCallbacks(
      onSpeechStart: () {
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      },
      onSpeechComplete: () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      },
      onSpeechError: (error) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      },
    );
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _siteMapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
    );

    _siteMapAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _siteMapController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fabController.dispose();
    _siteMapController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  void _toggleSiteMap() {
    setState(() {
      _showSiteMap = !_showSiteMap;
    });

    if (_showSiteMap) {
      _showSiteMapOverlay();
      _siteMapController.forward();
    } else {
      _siteMapController.reverse().then((_) {
        _removeOverlay();
      });
    }
  }

  void _showSiteMapOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildSiteMapOverlay(),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSiteMapOverlay() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      child: SlideTransition(
        position: _siteMapAnimation,
        child: Material(
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            color: Colors.white,
            child: _buildSiteMapContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildSiteMapContent() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Site Map - DHV University',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleSiteMap,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSiteMapSection(
                  'Học tập / Learning',
                  [
                    SiteMapItem('Trang chủ / Dashboard', Icons.home, () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }),
                    SiteMapItem('Unit 1 - Giới thiệu DHV', Icons.school, () {
                      // Navigate to Unit 1
                    }),
                    SiteMapItem('Unit 2 - Chương trình đào tạo', Icons.book,
                        () {
                      // Navigate to Unit 2
                    }),
                    SiteMapItem(
                        'Phát âm / Pronunciation', Icons.record_voice_over, () {
                      Navigator.pushNamed(context, '/pronunciation');
                    }),
                    SiteMapItem('AI Chatbot', Icons.chat, () {
                      Navigator.pushNamed(context, '/chatbot');
                    }),
                  ],
                ),
                _buildSiteMapSection(
                  'Tiện ích / Utilities',
                  [
                    SiteMapItem('Cài đặt / Settings', Icons.settings, () {
                      Navigator.pushNamed(context, '/settings');
                    }),
                    SiteMapItem('Tài khoản / Account', Icons.person, () {
                      Navigator.pushNamed(context, '/account');
                    }),
                    SiteMapItem('Ngôn ngữ / Language', Icons.language, () {
                      Navigator.pushNamed(context, '/language_selection');
                    }),
                  ],
                ),
                _buildSiteMapSection(
                  'Về DHV / About DHV',
                  [
                    SiteMapItem('Lịch sử 30 năm', Icons.history, () {
                      _speakDHVHistory();
                    }),
                    SiteMapItem('Cơ sở vật chất', Icons.business, () {
                      _speakDHVFacilities();
                    }),
                    SiteMapItem('Chương trình IT', Icons.computer, () {
                      _speakITProgram();
                    }),
                    SiteMapItem('VR Center', Icons.view_in_ar, () {
                      _speakVRCenter();
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Footer với TTS Controls
          _buildTTSControlsFooter(),
        ],
      ),
    );
  }

  Widget _buildSiteMapSection(String title, List<SiteMapItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...items.map((item) => _buildSiteMapListTile(item)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSiteMapListTile(SiteMapItem item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.blue),
      title: Text(item.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              await _ttsService.quickSpeak(item.title);
            },
            icon: const Icon(Icons.volume_up, color: Colors.blue, size: 20),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {
        _toggleSiteMap();
        item.onTap();
      },
    );
  }

  Widget _buildTTSControlsFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TTS Controls',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tốc độ / Speed: ${(_ttsService.speechRate * 100).round()}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Slider(
                value: _ttsService.speechRate,
                min: 0.1,
                max: 2.0,
                divisions: 19,
                onChanged: (value) {
                  _ttsService.setSpeechRate(value);
                  setState(() {});
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isPlaying ? () => _ttsService.stop() : null,
                icon: const Icon(Icons.stop, size: 16),
                label: const Text('Stop', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await _ttsService.speakEnglish(
                      "Welcome to DHV University TTS Assistant. Click on any text to hear pronunciation.");
                },
                icon: const Icon(Icons.help, size: 16),
                label: const Text('Help', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showFloatingButton) {
      return widget.child;
    }

    return Scaffold(
      body: widget.child,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Site Map Button
        if (widget.showSiteMap)
          AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabAnimation.value,
                child: FloatingActionButton(
                  onPressed: _toggleSiteMap,
                  backgroundColor: Colors.green,
                  heroTag: 'siteMap',
                  child: const Icon(Icons.map),
                ),
              );
            },
          ),

        if (widget.showSiteMap) SizedBox(height: _isExpanded ? 16 : 0),

        // Help Button
        AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              child: FloatingActionButton(
                onPressed: _showHelpDialog,
                backgroundColor: Colors.orange,
                heroTag: 'help',
                child: const Icon(Icons.help),
              ),
            );
          },
        ),

        SizedBox(height: _isExpanded ? 16 : 0),

        // Main TTS Button
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: widget.buttonColor ?? Colors.blue,
          heroTag: 'main',
          child: AnimatedRotation(
            turns: _isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isPlaying ? Icons.volume_up : Icons.headphones),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Colors.blue),
            SizedBox(width: 8),
            Text('TTS Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use TTS (Text-to-Speech):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Click on any blue text to hear pronunciation'),
              Text('• Use the site map button (green) to navigate'),
              Text('• Adjust speech speed in site map controls'),
              Text(
                  '• Text with Vietnamese characters will be read in Vietnamese'),
              Text('• Other text will be read in English'),
              SizedBox(height: 16),
              Text(
                'Cách sử dụng TTS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Nhấp vào bất kỳ văn bản màu xanh để nghe phát âm'),
              Text('• Sử dụng nút bản đồ (màu xanh lá) để điều hướng'),
              Text('• Điều chỉnh tốc độ nói trong điều khiển bản đồ'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _ttsService.speakEnglish(
                  "This is the TTS help system. Click on any blue text to hear it spoken aloud. Use the green map button to navigate the app.");
            },
            child: const Text('Demo'),
          ),
        ],
      ),
    );
  }

  // DHV Information Speaking Methods
  Future<void> _speakDHVHistory() async {
    await _ttsService.speakWithExplanation(
        "Trường Đại học Hùng Vương được thành lập năm 1995, với 30 năm phát triển",
        "Hung Vuong University was established in 1995, with 30 years of development");
  }

  Future<void> _speakDHVFacilities() async {
    await _ttsService.speakWithExplanation(
        "DHV có cơ sở vật chất hiện đại với VR Center 90 mét vuông và các phòng lab công nghệ cao",
        "DHV has modern facilities with a 90 square meter VR Center and high-tech laboratories");
  }

  Future<void> _speakITProgram() async {
    await _ttsService.speakWithExplanation(
        "Chương trình Công nghệ thông tin mã ngành 7480201 với đào tạo chuyên sâu",
        "Information Technology program code 7480201 with intensive training");
  }

  Future<void> _speakVRCenter() async {
    await _ttsService.speakWithExplanation(
        "Trung tâm Thực tế ảo với diện tích 90m2, trang bị công nghệ VR AR hiện đại",
        "Virtual Reality Center with 90 square meters area, equipped with modern VR AR technology");
  }
}

/// Model cho site map item
class SiteMapItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SiteMapItem(this.title, this.icon, this.onTap);
}
