import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/xp_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pronunciation_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/chatbot_screen.dart';
import 'theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase bằng FirebaseService
  await FirebaseService.initialize();

  // Khởi tạo NotificationService
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Schedule smart reminders after initialization
    await notificationService.scheduleSmartReminders();
    print('Smart notifications scheduled successfully');
  } catch (e) {
    print('Failed to initialize notification service: $e');
  }

  // Khởi tạo XP Service
  try {
    final xpService = XPService();
    await xpService.initializeUserExperience();
    print('XP Service initialized successfully');
  } catch (e) {
    print('Failed to initialize XP service: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Việt Ngữ Thông Minh',
            theme: ThemeData(
              primaryColor: const Color(0xFFDA020E),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFDA020E),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            darkTheme: ThemeData(
              primaryColor: const Color(0xFFDA020E),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFDA020E),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            themeMode: themeNotifier.themeMode,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const MainNavigation(),
              '/pronunciation': (context) => const PronunciationScreen(),
              '/lessons': (context) => const LessonScreen(),
              '/settings': (context) => SettingsScreen(
                    isDark: context.watch<ThemeNotifier>().isDarkMode,
                    onThemeChanged: (value) => context
                        .read<ThemeNotifier>()
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  ),
              '/language-selection': (context) =>
                  const LanguageSelectionScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
            },
          );
        },
      ),
    );
  }
}

// Global key to access MainNavigation from anywhere
final GlobalKey<State<MainNavigation>> mainNavigationKey =
    GlobalKey<State<MainNavigation>>();

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  // Static method to navigate to a specific tab
  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationState>();
    state?._onItemTapped(index);
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF58CC02);

    final List<Widget> screens = [
      const DashboardScreen(),
      const LessonScreen(),
      const PronunciationScreen(),
      const ChatbotScreen(),
      SettingsScreen(
        isDark: context.watch<ThemeNotifier>().isDarkMode,
        onThemeChanged: (value) => context
            .read<ThemeNotifier>()
            .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Bài học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Phát âm',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
