import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:firebase_auth/firebase_auth.dart';

class UserAvatarWithHat extends StatefulWidget {
  final User? user;
  final double size;
  final bool showHat;
  final VoidCallback? onTap;

  const UserAvatarWithHat({
    super.key,
    this.user,
    this.size = 40,
    this.showHat = true,
    this.onTap,
  });

  @override
  State<UserAvatarWithHat> createState() => _UserAvatarWithHatState();
}

class _UserAvatarWithHatState extends State<UserAvatarWithHat>
    with TickerProviderStateMixin {
  late AnimationController _hatController;
  late AnimationController _avatarController;
  late Animation<double> _hatAnimation;
  late Animation<double> _avatarScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for the conical hat gentle floating effect
    _hatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _hatAnimation = Tween<double>(
      begin: -0.5,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _hatController,
      curve: Curves.easeInOut,
    ));

    // Animation for avatar hover effect
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _avatarController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hatController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _avatarController.forward(),
      onTapUp: (_) => _avatarController.reverse(),
      onTapCancel: () => _avatarController.reverse(),
      child: SizedBox(
        width: widget.size + 24, // Reduced extra space
        height: widget.size + 20, // Reduced extra space
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Avatar - positioned in center
            Positioned(
              left: 12,
              top: 12,
              child: AnimatedBuilder(
                animation: _avatarScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _avatarScaleAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Conical Hat - positioned slightly above avatar center, like wearing a hat
            if (widget.showHat)
              AnimatedBuilder(
                animation:
                    Listenable.merge([_hatAnimation, _avatarScaleAnimation]),
                builder: (context, child) {
                  return Positioned(
                    left: (widget.size + 24 - widget.size * 1.1) /
                        2, // Center horizontally
                    top: -widget.size * 0.25 +
                        _hatAnimation.value, // Position higher above avatar
                    child: Transform.scale(
                      scale: _avatarScaleAnimation.value * 0.95 +
                          0.05, // Subtle scale with avatar but less pronounced
                      child: Transform.rotate(
                        angle: 0.05, // Smaller tilt for more natural look
                        child: Container(
                          width: widget.size *
                              1.1, // Slightly bigger than avatar but not too much
                          height: widget.size * 1.1,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(1, 3),
                              ),
                              // Additional shadow for floating effect
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              // Add subtle gradient overlay to make it look more like it's floating above
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/non_la.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to old custom paint if image fails to load
                                  return CustomPaint(
                                    painter: ConicalHatPainter(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Provider Badge (if OAuth login) - positioned to not conflict with hat
            if (widget.user != null && _getAuthProvider() != null)
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _getProviderColor(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getProviderIcon(),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    // Use Firebase User's photoURL if available
    if (widget.user?.photoURL != null && widget.user!.photoURL!.isNotEmpty) {
      return Image.network(
        widget.user!.photoURL!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          );
        },
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF58CC02),
            Color(0xFF1CB0F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getDisplayName().substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getDisplayName() {
    if (widget.user?.displayName != null &&
        widget.user!.displayName!.isNotEmpty) {
      return widget.user!.displayName!;
    }
    if (widget.user?.email != null) {
      return widget.user!.email!.split('@')[0];
    }
    return 'U';
  }

  String? _getAuthProvider() {
    if (widget.user == null) return null;

    // Check provider data to determine OAuth provider
    for (final providerInfo in widget.user!.providerData) {
      if (providerInfo.providerId == 'google.com') {
        return 'google';
      } else if (providerInfo.providerId == 'facebook.com') {
        return 'facebook';
      } else if (providerInfo.providerId == 'apple.com') {
        return 'apple';
      }
    }
    return null;
  }

  Color _getProviderColor() {
    final provider = _getAuthProvider();
    switch (provider) {
      case 'google':
        return const Color(0xFF4285F4);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'apple':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  IconData _getProviderIcon() {
    final provider = _getAuthProvider();
    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'facebook':
        return Icons.facebook;
      case 'apple':
        return Icons.apple;
      default:
        return Icons.person;
    }
  }
}

// Keep the original CustomPaint as fallback
class ConicalHatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Hat base (golden/straw color)
    paint.color = const Color(0xFFD4AF37);
    canvas.drawCircle(center, radius, paint);

    // Hat gradient for 3D effect
    const gradient = RadialGradient(
      center: Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        Color(0xFFF4E99B),
        Color(0xFFD4AF37),
        Color(0xFFB8941F),
      ],
      stops: [0.0, 0.7, 1.0],
    );

    paint.shader =
        gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    // Hat rim (darker edge)
    paint.shader = null;
    paint.color = const Color(0xFFB8941F);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, paint);

    // Traditional pattern lines
    paint.color = const Color(0xFFB8941F).withOpacity(0.6);
    paint.strokeWidth = 0.8;

    // Concentric circles pattern
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * 0.2 * i, paint);
    }

    // Radial lines pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final startX = center.dx + (radius * 0.3) * Math.cos(angle);
      final startY = center.dy + (radius * 0.3) * Math.sin(angle);
      final endX = center.dx + (radius * 0.8) * Math.cos(angle);
      final endY = center.dy + (radius * 0.8) * Math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Center point decoration
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFB8941F);
    canvas.drawCircle(center, radius * 0.1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
