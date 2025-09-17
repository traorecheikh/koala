import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modern animated logo widget with glassmorphism effect
class ModernAnimatedLogo extends StatefulWidget {
  final double size;
  final Duration animationDuration;
  final bool showPulse;

  const ModernAnimatedLogo({
    Key? key,
    this.size = 120,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.showPulse = true,
  }) : super(key: key);

  @override
  State<ModernAnimatedLogo> createState() => _ModernAnimatedLogoState();
}

class _ModernAnimatedLogoState extends State<ModernAnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _scaleController.forward();
    _rotationController.repeat();
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale:
              _scaleAnimation.value *
              (widget.showPulse ? _pulseAnimation.value : 1.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow effect
              Container(
                width: widget.size.w + 40,
                height: widget.size.w + 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.3),
                      theme.colorScheme.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Rotating background
              Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: widget.size.w + 20,
                  height: widget.size.w + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // Main logo container with glassmorphism
              Container(
                width: widget.size.w,
                height: widget.size.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: Image.asset(
                      'assets/images/koala.png',
                      width: widget.size.w - 32,
                      height: widget.size.w - 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Highlight effect
              Positioned(
                top: 15.h,
                left: 20.w,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
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
