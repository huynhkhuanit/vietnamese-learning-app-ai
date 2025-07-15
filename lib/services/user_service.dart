import '../models/user.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserService._();

  User? _currentUser;

  User? get currentUser => _currentUser;

  // Sample users for demonstration
  static final List<User> _sampleUsers = [
    // User registered via app
    User.fromAppRegistration(
      id: 'app_001',
      name: 'Khuân Nguyễn',
      email: 'khuan@example.com',
    ),

    // User from Google OAuth
    User.fromOAuth(
      id: 'google_001',
      name: 'Mai Trần',
      email: 'mai.tran@gmail.com',
      avatarUrl:
          'https://lh3.googleusercontent.com/a/ACg8ocL_example_avatar_url',
      authProvider: AuthProvider.google,
    ),

    // User from Facebook OAuth
    User.fromOAuth(
      id: 'facebook_001',
      name: 'Phúc Lê',
      email: 'phuc.le@example.com',
      avatarUrl: 'https://scontent.facebook.com/example_avatar',
      authProvider: AuthProvider.facebook,
    ),

    // User from Apple OAuth
    User.fromOAuth(
      id: 'apple_001',
      name: 'Linh Võ',
      email: 'linh.vo@icloud.com',
      authProvider: AuthProvider.apple, // Apple users often have no avatar URL
    ),
  ];

  // Initialize with a sample user (for demonstration)
  void initializeWithSampleUser({int userIndex = 0}) {
    if (userIndex >= 0 && userIndex < _sampleUsers.length) {
      _currentUser = _sampleUsers[userIndex];
    } else {
      _currentUser = _sampleUsers[0]; // Default to first user
    }
  }

  // Set current user
  void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Update user experience
  void updateExperience(int experienceGained) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        experience: _currentUser!.experience + experienceGained,
      );
    }
  }

  // Update user avatar URL (for OAuth users)
  void updateAvatarUrl(String avatarUrl) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatarUrl: avatarUrl);
    }
  }

  // Simulate login with different providers
  Future<User> loginWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User.fromOAuth(
      id: 'google_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'user@gmail.com',
      avatarUrl: 'https://lh3.googleusercontent.com/example',
      authProvider: AuthProvider.google,
    );

    setCurrentUser(user);
    return user;
  }

  Future<User> loginWithFacebook() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User.fromOAuth(
      id: 'facebook_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Facebook User',
      email: 'user@facebook.com',
      avatarUrl: 'https://scontent.facebook.com/example',
      authProvider: AuthProvider.facebook,
    );

    setCurrentUser(user);
    return user;
  }

  Future<User> loginWithApple() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User.fromOAuth(
      id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Apple User',
      email: 'user@icloud.com',
      authProvider: AuthProvider.apple,
    );

    setCurrentUser(user);
    return user;
  }

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Get user's progress level based on experience
  int get userLevel {
    if (_currentUser == null) return 1;
    return (_currentUser!.experience / 100).floor() + 1;
  }

  // Get experience needed for next level
  int get experienceToNextLevel {
    if (_currentUser == null) return 100;
    final currentLevel = userLevel;
    final experienceForCurrentLevel = (currentLevel - 1) * 100;
    final experienceForNextLevel = currentLevel * 100;
    return experienceForNextLevel - _currentUser!.experience;
  }

  // Get sample users for testing
  static List<User> get sampleUsers => List.unmodifiable(_sampleUsers);
}
