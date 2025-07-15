import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ===============================================
// QUIZ EFFECTS WIDGET - HIỆU ỨNG ĐẶC BIỆT CHO QUIZ
// ===============================================

class QuizTransitionEffects extends StatefulWidget {
  final Widget child;
  final bool triggerAnimation;
  final bool isCorrect;
  final VoidCallback? onAnimationComplete;

  const QuizTransitionEffects({
    super.key,
    required this.child,
    this.triggerAnimation = false,
    this.isCorrect = true,
    this.onAnimationComplete,
  });

  @override
  State<QuizTransitionEffects> createState() => _QuizTransitionEffectsState();
}

class _QuizTransitionEffectsState extends State<QuizTransitionEffects>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _correctController;
  late AnimationController _incorrectController;
  late AnimationController _particleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _correctScaleAnimation;
  late Animation<double> _incorrectShakeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Slide transition animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Correct answer animation
    _correctController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _correctScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _correctController,
      curve: Curves.elasticOut,
    ));

    // Incorrect answer shake animation
    _incorrectController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _incorrectShakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _incorrectController,
      curve: Curves.elasticIn,
    ));

    // Particle animation for celebration
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(QuizTransitionEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerAnimation && !oldWidget.triggerAnimation) {
      _triggerFeedbackAnimation();
    }
  }

  void _triggerFeedbackAnimation() {
    if (widget.isCorrect) {
      _playCorrectAnimation();
    } else {
      _playIncorrectAnimation();
    }
  }

  void _playCorrectAnimation() {
    HapticFeedback.heavyImpact();
    _correctController.forward().then((_) {
      _correctController.reverse();
      _particleController.forward().then((_) {
        widget.onAnimationComplete?.call();
        _particleController.reset();
      });
    });
  }

  void _playIncorrectAnimation() {
    HapticFeedback.mediumImpact();
    _incorrectController.forward().then((_) {
      _incorrectController.reverse().then((_) {
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _correctController.dispose();
    _incorrectController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with animations
        AnimatedBuilder(
          animation: Listenable.merge([
            _correctController,
            _incorrectController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _correctScaleAnimation.value,
              child: Transform.translate(
                offset: Offset(
                  _incorrectShakeAnimation.value *
                      10 *
                      math.sin(_incorrectController.value * math.pi * 8),
                  0,
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: widget.child,
                ),
              ),
            );
          },
        ),

        // Particle effects for correct answers
        if (widget.isCorrect)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticleEffectPainter(_particleAnimation.value),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

// ===============================================
// PARTICLE EFFECT PAINTER
// ===============================================

class ParticleEffectPainter extends CustomPainter {
  final double progress;
  final List<Particle> particles;

  ParticleEffectPainter(this.progress) : particles = _generateParticles();

  static List<Particle> _generateParticles() {
    final random = math.Random();
    return List.generate(20, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 8 + 4,
        color: [
          Colors.amber,
          Colors.orange,
          Colors.green,
          Colors.blue,
          Colors.purple,
        ][random.nextInt(5)],
        speedX: (random.nextDouble() - 0.5) * 2,
        speedY: random.nextDouble() * -2 - 1,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = particle.color.withOpacity(opacity);

      final x = particle.x * size.width + particle.speedX * progress * 100;
      final y = particle.y * size.height + particle.speedY * progress * 100;
      final radius = particle.size * progress;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speedX;
  final double speedY;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speedX,
    required this.speedY,
  });
}

// ===============================================
// DUOLINGO-STYLE PROGRESS INDICATOR
// ===============================================

class DuolingoProgressIndicator extends StatefulWidget {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  const DuolingoProgressIndicator({
    super.key,
    required this.progress,
    this.primaryColor = const Color(0xFF58CC02),
    this.backgroundColor = const Color(0xFFE5E5E5),
  });

  @override
  State<DuolingoProgressIndicator> createState() =>
      _DuolingoProgressIndicatorState();
}

class _DuolingoProgressIndicatorState extends State<DuolingoProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DuolingoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: 12,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.primaryColor,
                        widget.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ===============================================
// DUOLINGO-STYLE BUTTON
// ===============================================

class DuolingoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isEnabled;
  final bool isLoading;

  const DuolingoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFF58CC02),
    this.textColor = Colors.white,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  State<DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown:
                widget.isEnabled ? (_) => _pressController.forward() : null,
            onTapUp:
                widget.isEnabled ? (_) => _pressController.reverse() : null,
            onTapCancel:
                widget.isEnabled ? () => _pressController.reverse() : null,
            onTap:
                widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: widget.isEnabled
                    ? LinearGradient(
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey[400]!,
                          Colors.grey[300]!,
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: widget.backgroundColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
                border: Border.all(
                  color: widget.isEnabled
                      ? widget.backgroundColor.withOpacity(0.1)
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.textColor),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.isEnabled
                              ? widget.textColor
                              : Colors.grey[600],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }
}

// ===============================================
// QUIZ COMPLETION ANIMATION
// ===============================================

class QuizCompletionAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const QuizCompletionAnimation({
    super.key,
    required this.child,
    this.trigger = false,
  });

  @override
  State<QuizCompletionAnimation> createState() =>
      _QuizCompletionAnimationState();
}

class _QuizCompletionAnimationState extends State<QuizCompletionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(QuizCompletionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _celebrationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * math.pi,
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }
}
