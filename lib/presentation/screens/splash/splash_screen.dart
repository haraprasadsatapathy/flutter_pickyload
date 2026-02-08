import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../services/local/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _textController;
  late AnimationController _flowerController;
  late AnimationController _rotationController;

  late Animation<double> _bounceAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _flowerBloomAnimation;

  @override
  void initState() {
    super.initState();

    // Bounce animation for logo
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Pulse animation for logo glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Flower bloom animation
    _flowerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _flowerBloomAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flowerController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Continuous rotation for flower
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Start animations in sequence
    _startAnimations();

    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  void _startAnimations() async {
    _bounceController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _flowerController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _textController.forward();
    }
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = StorageService.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      context.go('/role-selection');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _textController.dispose();
    _flowerController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              Theme.of(context).colorScheme.secondary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with flower animation
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _bounceAnimation,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _pulseAnimation,
                        _flowerBloomAnimation,
                        _rotationController,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: SizedBox(
                            width: 320,
                            height: 320,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Flower petals layers
                                _buildFlowerLayer(
                                  petalCount: 12,
                                  radius: 145,
                                  petalSize: 22,
                                  colors: [
                                    Colors.pink.shade200,
                                    Colors.pink.shade300,
                                  ],
                                  rotationOffset: _rotationController.value * 2 * math.pi * 0.3,
                                  bloomDelay: 0.0,
                                ),
                                _buildFlowerLayer(
                                  petalCount: 10,
                                  radius: 130,
                                  petalSize: 18,
                                  colors: [
                                    Colors.purple.shade200,
                                    Colors.purple.shade300,
                                  ],
                                  rotationOffset: -_rotationController.value * 2 * math.pi * 0.2 + (math.pi / 10),
                                  bloomDelay: 0.1,
                                ),
                                _buildFlowerLayer(
                                  petalCount: 8,
                                  radius: 118,
                                  petalSize: 15,
                                  colors: [
                                    Colors.white,
                                    Colors.pink.shade100,
                                  ],
                                  rotationOffset: _rotationController.value * 2 * math.pi * 0.15 + (math.pi / 8),
                                  bloomDelay: 0.2,
                                ),
                                // Glowing ring
                                _buildGlowingRing(),
                                // Logo
                                _buildLogo(),
                                // Floating particles
                                ..._buildFloatingParticles(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // App name
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: const Text(
                      'pickyload',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: const Text(
                      'No More Empty Returns',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowerLayer({
    required int petalCount,
    required double radius,
    required double petalSize,
    required List<Color> colors,
    required double rotationOffset,
    required double bloomDelay,
  }) {
    final adjustedBloom = ((_flowerBloomAnimation.value - bloomDelay) / (1 - bloomDelay)).clamp(0.0, 1.0);

    return Transform.rotate(
      angle: rotationOffset,
      child: CustomPaint(
        size: const Size(320, 320),
        painter: FlowerPetalsPainter(
          petalCount: petalCount,
          radius: radius,
          petalSize: petalSize,
          colors: colors,
          bloomProgress: adjustedBloom,
          pulseValue: _pulseAnimation.value,
        ),
      ),
    );
  }

  Widget _buildGlowingRing() {
    final bloom = _flowerBloomAnimation.value;

    return Container(
      width: 210 * bloom,
      height: 210 * bloom,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4 * bloom * _pulseAnimation.value),
            blurRadius: 30 * _pulseAnimation.value,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.pink.shade200.withValues(alpha: 0.3 * bloom),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
            // Shimmer effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned(
                  left: _shimmerAnimation.value * 90,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    final bloom = _flowerBloomAnimation.value;
    if (bloom < 0.5) return [];

    final particleOpacity = ((bloom - 0.5) * 2).clamp(0.0, 1.0);
    final random = math.Random(42);
    final particles = <Widget>[];

    for (int i = 0; i < 16; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = 100 + random.nextDouble() * 55;
      final size = 3 + random.nextDouble() * 5;
      final rotationSpeed = (random.nextDouble() - 0.5) * 0.5;

      final x = 160 + math.cos(angle + _rotationController.value * 2 * math.pi * rotationSpeed) * distance * bloom;
      final y = 160 + math.sin(angle + _rotationController.value * 2 * math.pi * rotationSpeed) * distance * bloom;

      final color = [
        Colors.white,
        Colors.pink.shade100,
        Colors.purple.shade100,
        Colors.amber.shade100,
      ][i % 4];

      particles.add(
        Positioned(
          left: x - size / 2,
          top: y - size / 2,
          child: Container(
            width: size * _pulseAnimation.value,
            height: size * _pulseAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: particleOpacity * 0.8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: particleOpacity * 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

/// Custom painter for beautiful flower petals
class FlowerPetalsPainter extends CustomPainter {
  final int petalCount;
  final double radius;
  final double petalSize;
  final List<Color> colors;
  final double bloomProgress;
  final double pulseValue;

  FlowerPetalsPainter({
    required this.petalCount,
    required this.radius,
    required this.petalSize,
    required this.colors,
    required this.bloomProgress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bloomProgress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < petalCount; i++) {
      final angle = (2 * math.pi / petalCount) * i;
      final delayedProgress = ((bloomProgress * 1.3) - (i * 0.03)).clamp(0.0, 1.0);

      if (delayedProgress <= 0) continue;

      _drawPetal(canvas, center, angle, delayedProgress);
    }
  }

  void _drawPetal(Canvas canvas, Offset center, double angle, double progress) {
    final petalRadius = radius * progress;
    final currentPetalSize = petalSize * progress * pulseValue;

    final petalCenter = Offset(
      center.dx + math.cos(angle) * petalRadius,
      center.dy + math.sin(angle) * petalRadius,
    );

    // Create gradient for petal
    final gradient = RadialGradient(
      colors: [
        colors[0].withValues(alpha: 0.9 * progress),
        colors[1].withValues(alpha: 0.6 * progress),
        colors[1].withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: petalCenter, radius: currentPetalSize * 1.5),
      );

    canvas.save();
    canvas.translate(petalCenter.dx, petalCenter.dy);
    canvas.rotate(angle + math.pi / 2);

    // Draw petal shape - more rounded and natural
    final path = Path();
    final width = currentPetalSize * 0.7;
    final height = currentPetalSize * 1.2;

    path.moveTo(0, -height);
    path.cubicTo(
      width * 1.2, -height * 0.6,
      width * 1.2, height * 0.3,
      0, height * 0.5,
    );
    path.cubicTo(
      -width * 1.2, height * 0.3,
      -width * 1.2, -height * 0.6,
      0, -height,
    );

    canvas.drawPath(path, paint);

    // Add subtle inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final highlightPath = Path();
    highlightPath.moveTo(0, -height * 0.8);
    highlightPath.quadraticBezierTo(
      width * 0.5, 0,
      0, height * 0.3,
    );

    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FlowerPetalsPainter oldDelegate) {
    return oldDelegate.bloomProgress != bloomProgress ||
        oldDelegate.pulseValue != pulseValue;
  }
}
