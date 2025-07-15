import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class CompletionCelebrationDialog extends StatefulWidget {
  final int lessonId;
  final bool isCore;
  final int xpGained;
  final Color unitColor;
  final String lessonTitle;
  final VoidCallback onContinue;

  const CompletionCelebrationDialog({
    super.key,
    required this.lessonId,
    required this.isCore,
    required this.xpGained,
    required this.unitColor,
    required this.lessonTitle,
    required this.onContinue,
  });

  @override
  State<CompletionCelebrationDialog> createState() =>
      _CompletionCelebrationDialogState();
}

class _CompletionCelebrationDialogState
    extends State<CompletionCelebrationDialog> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _starsController;
  late AnimationController _xpController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _starsAnimation;
  late Animation<double> _xpSlideAnimation;
  late Animation<double> _xpScaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main celebration animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Stars animation
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // XP animation
    _xpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation for button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Setup animations
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6),
    ));

    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeOutBack,
    ));

    _xpSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.elasticOut,
    ));

    _xpScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: const Interval(0.2, 1.0, curve: Curves.bounceOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Start main animation
    _mainController.forward();

    // Delay and start stars
    await Future.delayed(const Duration(milliseconds: 300));
    _starsController.forward();

    // Delay and start XP animation
    await Future.delayed(const Duration(milliseconds: 500));
    _xpController.forward();

    // Start pulse animation for button
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _starsController.dispose();
    _xpController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _starsController,
        _xpController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.unitColor.withOpacity(0.95),
                  widget.unitColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stars background
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      // Animated stars
                      ...List.generate(8, (index) {
                        return AnimatedBuilder(
                          animation: _starsAnimation,
                          builder: (context, child) {
                            final angle = (index * 45) * (3.14159 / 180);
                            final radius = 60 * _starsAnimation.value;
                            final x = 100 + radius * math.cos(angle);
                            final y = 100 + radius * math.sin(angle);

                            return Positioned(
                              left: x,
                              top: y,
                              child: Transform.scale(
                                scale: _starsAnimation.value,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16 + (index % 3) * 4,
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      // Main celebration icon
                      Center(
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isCore ? Icons.school : Icons.psychology,
                              size: 60,
                              color: widget.unitColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Success text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Tuyệt vời!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bạn đã hoàn thành\n"${widget.lessonTitle}"',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // XP Gained Animation
                Transform.translate(
                  offset: Offset(0, _xpSlideAnimation.value),
                  child: Transform.scale(
                    scale: _xpScaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[600],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.xpGained} XP',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.unitColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Continue button with pulse animation
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        widget.onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: widget.unitColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Tiếp tục học!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
