import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) {
    Get.find<OnboardingController>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const background = Color(0xFFF7F9FC);
    const textColor = Color(0xFF111827);
    const mutedColor = Color(0xFF687386);

    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    final pageDecoration = PageDecoration(
      pageColor: background,
      titleTextStyle: const TextStyle(
        color: textColor,
        fontSize: 27,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      bodyTextStyle: const TextStyle(
        color: mutedColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      titlePadding: const EdgeInsets.only(top: 32, left: 28, right: 28),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      imagePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      imageFlex: 5,
      bodyFlex: 3,
    );

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: background,
          allowImplicitScrolling: true,
          infiniteAutoScroll: false,

          // ─────────────────────────────────────────
          // PAGES
          // ─────────────────────────────────────────
          pages: [
            PageViewModel(
              title: 'Discover Smarter Shopping',
              body: 'Explore products that match your needs, preferences, and lifestyle — all in one intelligent marketplace.',
              image: _OnboardingIllustration(
                primary: primary,
                secondary: secondary,
                icon: Icons.search_rounded,
                number: '01',
                label: 'DISCOVER',
                variant: _IllustrationVariant.search,
              ),
              decoration: pageDecoration,
            ),

            PageViewModel(
              title: 'Shopping That Understands You',
              body: 'Our AI learns what matters to you and helps you discover products and deals that actually make sense.',
              image: _OnboardingIllustration(
                primary: primary,
                secondary: secondary,
                icon: Icons.auto_awesome_rounded,
                number: '02',
                label: 'INTELLIGENCE',
                variant: _IllustrationVariant.ai,
              ),
              decoration: pageDecoration,
            ),

            PageViewModel(
              title: 'Safe. Simple. Seamless.',
              body: 'A smooth checkout experience with secure payments designed to keep your shopping journey effortless.',
              image: _OnboardingIllustration(
                primary: primary,
                secondary: secondary,
                icon: Icons.verified_user_rounded,
                number: '03',
                label: 'SECURITY',
                variant: _IllustrationVariant.security,
              ),
              decoration: pageDecoration,
            ),

            PageViewModel(
              title: 'From Our Store to Your Door',
              body: 'Stay connected with your order from dispatch to doorstep with real-time delivery updates.',
              image: _OnboardingIllustration(
                primary: primary,
                secondary: secondary,
                icon: Icons.local_shipping_rounded,
                number: '04',
                label: 'DELIVERY',
                variant: _IllustrationVariant.delivery,
              ),
              decoration: pageDecoration,
            ),
          ],

          // ─────────────────────────────────────────
          // NAVIGATION
          // ─────────────────────────────────────────
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),

          showSkipButton: true,
          skipOrBackFlex: 0,
          nextFlex: 0,

          skip: const Text(
            'Skip',
            style: TextStyle(
              color: mutedColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),

          next: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          done: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primary, secondary],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 7),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ],
            ),
          ),

          // ─────────────────────────────────────────
          // INDICATORS
          // ─────────────────────────────────────────
          dotsDecorator: DotsDecorator(
            size: const Size(7, 7),
            spacing: const EdgeInsets.symmetric(horizontal: 4),
            color: const Color(0xFFD8DEE9),
            activeSize: const Size(25, 7),
            activeColor: primary,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ILLUSTRATION TYPES
// ═══════════════════════════════════════════════════════════

enum _IllustrationVariant { search, ai, security, delivery }

// ═══════════════════════════════════════════════════════════
// ONBOARDING ILLUSTRATION
// ═══════════════════════════════════════════════════════════

class _OnboardingIllustration extends StatefulWidget {
  final Color primary;
  final Color secondary;
  final IconData icon;
  final String number;
  final String label;
  final _IllustrationVariant variant;

  const _OnboardingIllustration({
    required this.primary,
    required this.secondary,
    required this.icon,
    required this.number,
    required this.label,
    required this.variant,
  });

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _rotateController,
        _pulseController,
      ]),
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 7;

        final pulse = 1 + (_pulseController.value * 0.025);

        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: Transform.scale(
            scale: pulse,
            child: SizedBox(
              width: 320,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ───────────────────────────────────
                  // AMBIENT GLOW
                  // ───────────────────────────────────

                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.primary.withValues(alpha: 0.13),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: widget.secondary.withValues(alpha: 0.10),
                          blurRadius: 100,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // ───────────────────────────────────
                  // DECORATIVE ORBITS
                  // ───────────────────────────────────
                  Transform.rotate(
                    angle: _rotateController.value * math.pi * 2,
                    child: CustomPaint(
                      size: const Size(265, 265),
                      painter: _OnboardingOrbitPainter(
                        primary: widget.primary,
                        secondary: widget.secondary,
                      ),
                    ),
                  ),

                  // ───────────────────────────────────
                  // CENTRAL CARD
                  // ───────────────────────────────────
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      color: Colors.white.withValues(alpha: 0.92),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primary.withValues(alpha: 0.12),
                          blurRadius: 35,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [widget.primary, widget.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.primary.withValues(alpha: 0.28),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 40),
                      ),
                    ),
                  ),

                  // ───────────────────────────────────
                  // NUMBER
                  // ───────────────────────────────────
                  Positioned(
                    top: 22,
                    left: 38,
                    child: _SmallBadge(
                      text: widget.number,
                      color: widget.primary,
                    ),
                  ),

                  // ───────────────────────────────────
                  // LABEL
                  // ───────────────────────────────────
                  Positioned(
                    bottom: 16,
                    right: 28,
                    child: _SmallLabel(
                      text: widget.label,
                      color: widget.secondary,
                    ),
                  ),

                  // ───────────────────────────────────
                  // FLOATING ELEMENTS
                  // ───────────────────────────────────
                  Positioned(
                    top: 58,
                    right: 35,
                    child: _Particle(color: widget.secondary, size: 8),
                  ),

                  Positioned(
                    bottom: 62,
                    left: 40,
                    child: _Particle(color: widget.primary, size: 6),
                  ),

                  Positioned(
                    top: 105,
                    left: 18,
                    child: _Particle(color: const Color(0xFF20B8D8), size: 4),
                  ),
                ],
              ),
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

class _OnboardingOrbitPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _OnboardingOrbitPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = SweepGradient(
        colors: [
          primary.withValues(alpha: 0.0),
          primary.withValues(alpha: 0.45),
          secondary.withValues(alpha: 0.45),
          secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 250, height: 105),
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 105, height: 250),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OnboardingOrbitPainter oldDelegate) {
    return false;
  }
}

// ═══════════════════════════════════════════════════════════
// SMALL BADGE
// ═══════════════════════════════════════════════════════════

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 12),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SMALL LABEL
// ═══════════════════════════════════════════════════════════

class _SmallLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PARTICLE
// ═══════════════════════════════════════════════════════════

class _Particle extends StatelessWidget {
  final Color color;
  final double size;

  const _Particle({required this.color, required this.size});

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
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
