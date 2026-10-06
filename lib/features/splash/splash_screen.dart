import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/features/splash/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // ─────────────────────────────────────────────
          // BACKGROUND
          // ─────────────────────────────────────────────

          const Positioned.fill(child: _AnimatedBackground()),

          // ─────────────────────────────────────────────
          // SOFT VIGNETTE / DEPTH
          // ─────────────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      const Color(0xFFEEF2F9).withValues(alpha: 0.30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // CONTENT
          // ─────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated AI commerce mark
                  _AnimatedCommerceLogo(
                    primaryColor: colorScheme.primary,
                    secondaryColor: colorScheme.secondary,
                  ),

                  const SizedBox(height: 42),

                  // Brand
                  _AnimatedBrandName(appName: AppConfig.appName),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'INTELLIGENT COMMERCE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF172033).withValues(alpha: 0.58),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.8,
                    ),
                  ),

                  const SizedBox(height: 46),

                  // Loading animation
                  SpinKitThreeBounce(
                    size: 16,
                    itemBuilder: (context, index) {
                      final colors = [
                        colorScheme.primary,
                        colorScheme.secondary,
                        const Color(0xFF20B8D8),
                      ];

                      return DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[index],
                          boxShadow: [
                            BoxShadow(
                              color: colors[index].withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Preparing your experience...',
                    style: TextStyle(
                      color: const Color(0xFF172033).withValues(alpha: 0.42),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // BOTTOM BRANDING
          // ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Text(
              'POWERED BY AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF172033).withValues(alpha: 0.25),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ANIMATED BACKGROUND
// ═══════════════════════════════════════════════════════════

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * math.pi * 2;

        return CustomPaint(painter: _BackgroundPainter(animation: t));
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;

  _BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // ─────────────────────────────────────────────
    // SOFT BLUE ORB
    // ─────────────────────────────────────────────

    final blueX = size.width * 0.15 + math.sin(animation) * size.width * 0.08;

    final blueY =
        size.height * 0.18 + math.cos(animation * 0.8) * size.height * 0.06;

    final bluePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF4C8DFF).withValues(alpha: 0.18),
              const Color(0xFF4C8DFF).withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(blueX, blueY), radius: 220),
          );

    canvas.drawCircle(Offset(blueX, blueY), 220, bluePaint);

    // ─────────────────────────────────────────────
    // VIOLET ORB
    // ─────────────────────────────────────────────

    final purpleX =
        size.width * 0.88 + math.cos(animation * 0.7) * size.width * 0.08;

    final purpleY =
        size.height * 0.70 + math.sin(animation * 0.9) * size.height * 0.08;

    final purplePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF8B6CFF).withValues(alpha: 0.15),
              const Color(0xFF8B6CFF).withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(purpleX, purpleY), radius: 260),
          );

    canvas.drawCircle(Offset(purpleX, purpleY), 260, purplePaint);

    // ─────────────────────────────────────────────
    // CYAN ORB
    // ─────────────────────────────────────────────

    final cyanX =
        size.width * 0.80 + math.sin(animation * 1.2) * size.width * 0.06;

    final cyanY =
        size.height * 0.15 + math.cos(animation * 0.6) * size.height * 0.05;

    final cyanPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF20C9E8).withValues(alpha: 0.10),
              const Color(0xFF20C9E8).withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(cyanX, cyanY), radius: 180),
          );

    canvas.drawCircle(Offset(cyanX, cyanY), 180, cyanPaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// ═══════════════════════════════════════════════════════════
// MAIN AI COMMERCE LOGO
// ═══════════════════════════════════════════════════════════

class _AnimatedCommerceLogo extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const _AnimatedCommerceLogo({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_AnimatedCommerceLogo> createState() => _AnimatedCommerceLogoState();
}

class _AnimatedCommerceLogoState extends State<_AnimatedCommerceLogo>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _pulseController,
        _entryController,
      ]),
      builder: (context, child) {
        final scale = Curves.easeOutBack.transform(_entryController.value);

        final pulse = 1 + (_pulseController.value * 0.035);

        return Transform.scale(
          scale: scale * pulse,
          child: SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ─────────────────────────────────────
                // OUTER GLOW
                // ─────────────────────────────────────

                Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.18),
                        blurRadius: 55,
                        spreadRadius: 12,
                      ),
                      BoxShadow(
                        color: widget.secondaryColor.withValues(alpha: 0.12),
                        blurRadius: 70,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),

                // ─────────────────────────────────────
                // ROTATING ORBIT
                // ─────────────────────────────────────
                Transform.rotate(
                  angle: _rotationController.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(175, 175),
                    painter: _OrbitPainter(
                      primary: widget.primaryColor,
                      secondary: widget.secondaryColor,
                    ),
                  ),
                ),

                // ─────────────────────────────────────
                // INNER CIRCLE
                // ─────────────────────────────────────
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.88),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.16),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [widget.primaryColor, widget.secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withValues(alpha: 0.30),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // ─────────────────────────────────────
                // FLOATING DOTS
                // ─────────────────────────────────────
                Positioned(
                  top: 12,
                  right: 27,
                  child: _FloatingDot(color: widget.secondaryColor, size: 7),
                ),

                Positioned(
                  bottom: 24,
                  left: 18,
                  child: _FloatingDot(color: widget.primaryColor, size: 5),
                ),

                Positioned(
                  top: 54,
                  left: 8,
                  child: _FloatingDot(color: const Color(0xFF20B8D8), size: 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ORBIT PAINTER
// ═══════════════════════════════════════════════════════════

class _OrbitPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _OrbitPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final rect = Rect.fromCenter(center: center, width: 145, height: 70);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        colors: [
          primary.withValues(alpha: 0.0),
          primary.withValues(alpha: 0.55),
          secondary.withValues(alpha: 0.55),
          secondary.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    canvas.drawOval(rect, paint);

    final secondRect = Rect.fromCenter(center: center, width: 70, height: 145);

    canvas.drawOval(secondRect, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return false;
  }
}

// ═══════════════════════════════════════════════════════════
// FLOATING DOT
// ═══════════════════════════════════════════════════════════

class _FloatingDot extends StatelessWidget {
  final Color color;
  final double size;

  const _FloatingDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BRAND NAME REVEAL
// ═══════════════════════════════════════════════════════════

class _AnimatedBrandName extends StatefulWidget {
  final String appName;

  const _AnimatedBrandName({required this.appName});

  @override
  State<_AnimatedBrandName> createState() => _AnimatedBrandNameState();
}

class _AnimatedBrandNameState extends State<_AnimatedBrandName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _controller.forward();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - animation.value)),
            child: Text(
              widget.appName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.4,
              ),
            ),
          ),
        );
      },
    );
  }
}
