class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final AuthProvider? authProvider;
  final DateTime? lastLogin;
  final int experience;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.authProvider,
    this.lastLogin,
    this.experience = 0,
  });

  // Factory method to create User from OAuth providers
  factory User.fromOAuth({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
    required AuthProvider authProvider,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      authProvider: authProvider,
      lastLogin: DateTime.now(),
    );
  }

  // Factory method for app registration (no OAuth)
  factory User.fromAppRegistration({
    required String id,
    required String name,
    required String email,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      authProvider: null,
      lastLogin: DateTime.now(),
    );
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    AuthProvider? authProvider,
    DateTime? lastLogin,
    int? experience,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      lastLogin: lastLogin ?? this.lastLogin,
      experience: experience ?? this.experience,
    );
  }

  // Getter for display name (first name only)
  String get displayName {
    final names = name.split(' ');
    return names.isNotEmpty ? names.first : name;
  }

  // Check if user has custom avatar
  bool get hasCustomAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  // Get avatar source description
  String get avatarSource {
    if (authProvider != null) {
      return authProvider!.displayName;
    }
    return hasCustomAvatar ? 'Custom' : 'Default';
  }
}

enum AuthProvider {
  google('Google'),
  facebook('Facebook'),
  apple('Apple');

  const AuthProvider(this.displayName);

  final String displayName;
}
