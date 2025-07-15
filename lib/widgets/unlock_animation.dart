import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class UnlockAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isUnlocked;
  final Duration delay;
  final Color unitColor;

  const UnlockAnimationWidget({
    super.key,
    required this.child,
    required this.isUnlocked,
    this.delay = Duration.zero,
    required this.unitColor,
  });

  @override
  State<UnlockAnimationWidget> createState() => _UnlockAnimationWidgetState();
}

class _UnlockAnimationWidgetState extends State<UnlockAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _unlockController;
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;

  bool _hasPlayedUnlock = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Unlock animation
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Glow pulse effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation (bouncy unlock)
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _unlockController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Rotation animation (lock turning)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi / 4,
    ).animate(CurvedAnimation(
      parent: _unlockController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _unlockController,
      curve: const Interval(0.0, 0.5),
    ));

    // Shimmer animation (light sweep)
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Glow animation (pulsing border)
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(UnlockAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUnlocked && !oldWidget.isUnlocked && !_hasPlayedUnlock) {
      _playUnlockAnimation();
    }
  }

  Future<void> _playUnlockAnimation() async {
    if (_hasPlayedUnlock) return;
    _hasPlayedUnlock = true;

    // Haptic feedback nhẹ hơn
    HapticFeedback.lightImpact();

    // Wait for delay
    await Future.delayed(widget.delay);

    // Start unlock animation mượt mà hơn
    _unlockController.forward();

    // Start shimmer effect
    await Future.delayed(const Duration(milliseconds: 200));
    _shimmerController.forward();

    // Start glow pulse (repeating) với thời gian ngắn hơn
    await Future.delayed(const Duration(milliseconds: 100));
    _glowController.repeat(reverse: true);

    // Stop glow after shorter time
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _unlockController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUnlocked) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _unlockController,
        _shimmerController,
        _glowController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Glow effect when unlocked
              BoxShadow(
                color: widget.unitColor.withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 15 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content with transform
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 0.1, // Subtle rotation
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: widget.child,
                  ),
                ),
              ),

              // Shimmer overlay effect
              if (_shimmerController.isAnimating)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: OverflowBox(
                      child: Transform.translate(
                        offset: Offset(
                          _shimmerAnimation.value *
                              (MediaQuery.of(context).size.width + 100),
                          0,
                        ),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.6),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Unlock icon overlay
              if (_unlockController.isAnimating)
                Positioned(
                  top: -10,
                  right: -10,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.unitColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_open,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class LessonUnlockNotification extends StatefulWidget {
  final String lessonTitle;
  final Color unitColor;
  final VoidCallback? onTap;

  const LessonUnlockNotification({
    super.key,
    required this.lessonTitle,
    required this.unitColor,
    this.onTap,
  });

  @override
  State<LessonUnlockNotification> createState() =>
      _LessonUnlockNotificationState();
}

class _LessonUnlockNotificationState extends State<LessonUnlockNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6),
    ));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.unitColor,
                  widget.unitColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (widget.onTap != null) {
                  _controller.reverse().then((_) {
                    Navigator.of(context).pop();
                    widget.onTap!();
                  });
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_open,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Bài học mới đã mở khóa!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.lessonTitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
