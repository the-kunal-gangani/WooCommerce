import 'dart:math' as math;

import 'package:flutter/material.dart';

class _OnboardingIllustration extends StatefulWidget {
  const _OnboardingIllustration({required this.page});

  final int page;

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _particleController.dispose();

    super.dispose();
  }

  double _float(double offset) {
    return math.sin((_floatController.value * math.pi * 2) + offset) * 6;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatController,
          _pulseController,
          _rotateController,
          _particleController,
        ]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ------------------------------------------------------------
              // Ambient glow
              // ------------------------------------------------------------
              Positioned(
                top: 35,
                left: 35,
                child: _GlowOrb(
                  size: 150,
                  color: const Color(0xFF4F7CFF),
                  opacity: 0.11,
                ),
              ),

              Positioned(
                bottom: 25,
                right: 25,
                child: _GlowOrb(
                  size: 170,
                  color: const Color(0xFF8B5CF6),
                  opacity: 0.10,
                ),
              ),

              // ------------------------------------------------------------
              // Decorative particles
              // ------------------------------------------------------------
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlesPainter(
                    progress: _particleController.value,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Rotating network / connection lines
              // ------------------------------------------------------------
              Positioned.fill(
                child: Transform.rotate(
                  angle: _rotateController.value * math.pi * 2,
                  child: CustomPaint(painter: _ConnectionPainter()),
                ),
              ),

              // ------------------------------------------------------------
              // Search floating element
              // ------------------------------------------------------------
              Positioned(
                top: 42 + _float(0.3),
                left: 18,
                child: _FloatingMiniCard(
                  icon: Icons.search_rounded,
                  iconColor: const Color(0xFF4F7CFF),
                  backgroundColor: const Color(0xFFEFF4FF),
                  size: 52,
                ),
              ),

              // ------------------------------------------------------------
              // Favorite floating element
              // ------------------------------------------------------------
              Positioned(
                top: 25 + _float(1.7),
                right: 20,
                child: _FloatingMiniCard(
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFEC4899),
                  backgroundColor: const Color(0xFFFFF0F7),
                  size: 48,
                ),
              ),

              // ------------------------------------------------------------
              // Headphones product
              // ------------------------------------------------------------
              Positioned(
                left: 10,
                bottom: 48 + _float(1.2),
                child: _ProductCard(
                  icon: Icons.headphones_rounded,
                  title: 'Audio',
                  iconColor: const Color(0xFF6366F1),
                  backgroundColor: const Color(0xFFF1F0FF),
                  rotation: -0.08,
                ),
              ),

              // ------------------------------------------------------------
              // Watch product
              // ------------------------------------------------------------
              Positioned(
                right: 8,
                bottom: 43 + _float(3.0),
                child: _ProductCard(
                  icon: Icons.watch_rounded,
                  title: 'Watch',
                  iconColor: const Color(0xFF06B6D4),
                  backgroundColor: const Color(0xFFEAFBFF),
                  rotation: 0.08,
                ),
              ),

              // ------------------------------------------------------------
              // Shoes product
              // ------------------------------------------------------------
              Positioned(
                right: 45,
                top: 118 + _float(2.3),
                child: _ProductCard(
                  icon: Icons.directions_run_rounded,
                  title: 'Style',
                  iconColor: const Color(0xFF8B5CF6),
                  backgroundColor: const Color(0xFFF5EEFF),
                  rotation: 0.06,
                  small: true,
                ),
              ),

              // ------------------------------------------------------------
              // CENTRAL SHOPPING CARD
              // ------------------------------------------------------------
              Transform.translate(
                offset: Offset(0, _float(0)),
                child: _MainShoppingCard(pulse: _pulseController.value),
              ),

              // ------------------------------------------------------------
              // AI NODE
              // ------------------------------------------------------------
              Positioned(
                bottom: 23,
                child: _AiNode(pulse: _pulseController.value),
              ),

              // ------------------------------------------------------------
              // Tiny sparkle decorations
              // ------------------------------------------------------------
              Positioned(
                top: 94 + _float(2.0),
                left: 92,
                child: _Sparkle(size: 17, color: const Color(0xFF4F7CFF)),
              ),

              Positioned(
                bottom: 98 + _float(1.0),
                right: 93,
                child: _Sparkle(size: 13, color: const Color(0xFF8B5CF6)),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// MAIN SHOPPING CARD
// ============================================================================

class _MainShoppingCard extends StatelessWidget {
  const _MainShoppingCard({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final scale = 1 + (pulse * 0.018);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 155,
        height: 185,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F7CFF).withValues(alpha: 0.10),
              blurRadius: 35,
              spreadRadius: 2,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: const Color(0xFF687386).withValues(alpha: 0.65),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Product image area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF1F5FF), Color(0xFFF7F2FF)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 14,
                            color: Color(0xFF687386),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.shopping_bag_rounded,
                        size: 48,
                        color: Color(0xFF4F7CFF),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Smart Pick',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '98%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F7CFF),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT CARD
// ============================================================================

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.backgroundColor,
    required this.rotation,
    this.small = false,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final Color backgroundColor;
  final double rotation;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final width = small ? 72.0 : 82.0;
    final height = small ? 78.0 : 88.0;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: small ? 34 : 39,
              height: small ? 34 : 39,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: small ? 18 : 21),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: small ? 8 : 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// AI NODE
// ============================================================================

class _AiNode extends StatelessWidget {
  const _AiNode({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final scale = 1 + (pulse * 0.12);

    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4F7CFF)
                  .withValues(alpha: 0.055 + (pulse * 0.04)),
            ),
          ),

          // Outer ring
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4F7CFF),
                  Color(0xFF8B5CF6),
                  Color(0xFF06B6D4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F7CFF).withValues(alpha: 0.20),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF5B63E8),
                size: 23,
              ),
            ),
          ),

          // Small orbiting dot
          Positioned(
            top: 4,
            right: 7,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF06B6D4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FLOATING MINI CARD
// ============================================================================

class _FloatingMiniCard extends StatelessWidget {
  const _FloatingMiniCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.size,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.60,
          height: size * 0.60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: size * 0.30, color: iconColor),
        ),
      ),
    );
  }
}

// ============================================================================
// SPARKLE
// ============================================================================

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome_rounded, size: size, color: color);
  }
}

// ============================================================================
// GLOW ORB
// ============================================================================

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CONNECTION LINES
// ============================================================================

class _ConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // ------------------------------------------------------------
    // Left connection
    // ------------------------------------------------------------

    paint.color = const Color(0xFF4F7CFF).withValues(alpha: 0.18);

    final leftPath = Path()
      ..moveTo(center.dx - 35, center.dy + 10)
      ..quadraticBezierTo(
        center.dx - 95,
        center.dy - 5,
        center.dx - 125,
        center.dy - 55,
      );

    canvas.drawPath(leftPath, paint);

    // ------------------------------------------------------------
    // Right connection
    // ------------------------------------------------------------

    paint.color = const Color(0xFF8B5CF6).withValues(alpha: 0.17);

    final rightPath = Path()
      ..moveTo(center.dx + 35, center.dy + 10)
      ..quadraticBezierTo(
        center.dx + 95,
        center.dy - 10,
        center.dx + 125,
        center.dy - 55,
      );

    canvas.drawPath(rightPath, paint);

    // ------------------------------------------------------------
    // Bottom-left connection
    // ------------------------------------------------------------

    paint.color = const Color(0xFF06B6D4).withValues(alpha: 0.15);

    final bottomLeft = Path()
      ..moveTo(center.dx - 20, center.dy + 55)
      ..quadraticBezierTo(
        center.dx - 85,
        center.dy + 85,
        center.dx - 115,
        center.dy + 55,
      );

    canvas.drawPath(bottomLeft, paint);

    // ------------------------------------------------------------
    // Bottom-right connection
    // ------------------------------------------------------------

    final bottomRight = Path()
      ..moveTo(center.dx + 20, center.dy + 55)
      ..quadraticBezierTo(
        center.dx + 85,
        center.dy + 85,
        center.dx + 115,
        center.dy + 55,
      );

    canvas.drawPath(bottomRight, paint);

    // ------------------------------------------------------------
    // Connection nodes
    // ------------------------------------------------------------

    final nodes = [
      Offset(center.dx - 125, center.dy - 55),
      Offset(center.dx + 125, center.dy - 55),
      Offset(center.dx - 115, center.dy + 55),
      Offset(center.dx + 115, center.dy + 55),
    ];

    for (var i = 0; i < nodes.length; i++) {
      final nodePaint = Paint()
        ..color = [
          const Color(0xFF4F7CFF),
          const Color(0xFF8B5CF6),
          const Color(0xFF06B6D4),
          const Color(0xFF4F7CFF),
        ][i].withValues(alpha: 0.55);

      canvas.drawCircle(nodes[i], 3, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// PARTICLES
// ============================================================================

class _ParticlesPainter extends CustomPainter {
  const _ParticlesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final particles = [
      _Particle(
        x: 0.17,
        y: 0.23,
        radius: 2.0,
        color: const Color(0xFF4F7CFF),
        phase: 0,
      ),
      _Particle(
        x: 0.82,
        y: 0.29,
        radius: 1.7,
        color: const Color(0xFF8B5CF6),
        phase: 1.5,
      ),
      _Particle(
        x: 0.27,
        y: 0.78,
        radius: 1.5,
        color: const Color(0xFF06B6D4),
        phase: 3,
      ),
      _Particle(
        x: 0.76,
        y: 0.72,
        radius: 2.1,
        color: const Color(0xFF4F7CFF),
        phase: 4,
      ),
      _Particle(
        x: 0.10,
        y: 0.48,
        radius: 1.2,
        color: const Color(0xFF8B5CF6),
        phase: 2,
      ),
      _Particle(
        x: 0.91,
        y: 0.50,
        radius: 1.3,
        color: const Color(0xFF06B6D4),
        phase: 5,
      ),
    ];

    for (final particle in particles) {
      final movement = math.sin(progress * math.pi * 2 + particle.phase);

      final position = Offset(
        size.width * particle.x,
        size.height * particle.y + movement * 5,
      );

      final opacity = 0.25 + ((movement + 1) / 2) * 0.45;

      final paint = Paint()..color = particle.color.withValues(alpha: opacity);

      canvas.drawCircle(position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.phase,
  });

  final double x;
  final double y;
  final double radius;
  final Color color;
  final double phase;
}
