import 'dart:math' as math;

import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/auth/forget-password/forget_password_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ForgotPasswordController>()
        ? Get.find<ForgotPasswordController>()
        : Get.put(ForgotPasswordController());

    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    const background = Color(0xFFF7F9FC);
    const textColor = Color(0xFF111827);
    const mutedColor = Color(0xFF687386);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const Positioned.fill(child: _RecoveryBackground()),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Row(
                    children: [
                      _BackButton(
                        onTap: () => Flexify.back(),
                        color: textColor,
                      ),
                      const Spacer(),
                      const _SecurityStatus(),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            const _RecoveryIllustration(),
                            const SizedBox(height: 20),
                            const Text(
                              'Recover your account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Enter the email connected to your account.\n'
                              'We’ll help you get back in securely.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 14,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B2840)
                                        .withValues(alpha: 0.065),
                                    blurRadius: 35,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel(
                                    icon: Icons.alternate_email_rounded,
                                    label: 'Account email',
                                  ),
                                  const SizedBox(height: 9),
                                  TextField(
                                    controller: controller.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: 'you@example.com',
                                      icon: Icons.email_outlined,
                                      primary: primary,
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.055),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: primary.withValues(alpha: 0.09),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: primary.withValues(
                                              alpha: 0.10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.verified_user_outlined,
                                            color: primary,
                                            size: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text(
                                            'Your account information stays '
                                            'protected throughout the recovery process.',
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontSize: 11.5,
                                              height: 1.45,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Obx(
                                    () => SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [primary, secondary],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            17,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primary.withValues(
                                                alpha: 0.22,
                                              ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 9),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: controller.isLoading.value
                                              ? null
                                              : controller.sendResetCode,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(17),
                                            ),
                                          ),
                                          child: controller.isLoading.value
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.2,
                                                      ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Send Reset Link',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    SizedBox(width: 9),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: Colors.white,
                                                      size: 19,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Remember your password?',
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Flexify.go(
                                      const LoginScreen(),
                                      animation: FlexifyRouteAnimations.blur,
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'SECURE ACCOUNT RECOVERY • AI COMMERCE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.22),
                                fontSize: 7.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color primary,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF687386).withValues(alpha: 0.52),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, size: 19, color: const Color(0xFF687386)),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE7EBF2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: primary.withValues(alpha: 0.65),
          width: 1.4,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _BackButton({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back_rounded, color: color, size: 20),
        ),
      ),
    );
  }
}

class _SecurityStatus extends StatelessWidget {
  const _SecurityStatus();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF27C88A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27C88A).withValues(alpha: 0.30),
                  blurRadius: 7,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'SECURE',
            style: TextStyle(
              color: Color(0xFF687386),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FieldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF687386)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF263247),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RecoveryIllustration extends StatefulWidget {
  const _RecoveryIllustration();

  @override
  State<_RecoveryIllustration> createState() => _RecoveryIllustrationState();
}

class _RecoveryIllustrationState extends State<_RecoveryIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * math.pi * 2;

        return SizedBox(
          width: 270,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: t * 0.25,
                child: Container(
                  width: 156,
                  height: 156,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.09),
                      width: 1,
                    ),
                  ),
                ),
              ),

              Transform.rotate(
                angle: -t * 0.18,
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: secondary.withValues(alpha: 0.10),
                      width: 1,
                    ),
                  ),
                ),
              ),

              CustomPaint(
                size: const Size(270, 190),
                painter: _RecoveryNetworkPainter(
                  animation: t,
                  primary: primary,
                  secondary: secondary,
                ),
              ),
              Positioned(
                left: 17,
                top: 70,
                child: _FloatingNode(
                  icon: Icons.email_outlined,
                  color: primary,
                  scale: 1 + math.sin(t) * 0.035,
                ),
              ),

              // ─────────────────────────────
              // RIGHT SECURITY NODE
              // ─────────────────────────────
              Positioned(
                right: 16,
                top: 42,
                child: _FloatingNode(
                  icon: Icons.verified_user_outlined,
                  color: secondary,
                  scale: 1 + math.cos(t * 1.1) * 0.035,
                ),
              ),

              // ─────────────────────────────
              // BOTTOM DATA NODE
              // ─────────────────────────────
              Positioned(
                right: 39,
                bottom: 17,
                child: _SmallDataNode(
                  color: const Color(0xFF20C9E8),
                  scale: 1 + math.sin(t * 1.3) * 0.06,
                ),
              ),

              // ─────────────────────────────
              // CENTRAL AI CORE
              // ─────────────────────────────
              Transform.scale(
                scale: 1 + math.sin(t * 1.2) * 0.025,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.20),
                        blurRadius: 35,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ],
                  ),
                ),
              ),

              // ─────────────────────────────
              // FLOATING SPARKS
              // ─────────────────────────────
              Positioned(
                top: 15,
                left: 78,
                child: _Spark(
                  color: primary,
                  opacity: 0.45 + math.sin(t) * 0.15,
                ),
              ),

              Positioned(
                bottom: 12,
                left: 67,
                child: _Spark(
                  color: secondary,
                  opacity: 0.35 + math.cos(t) * 0.15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FLOATING NODE
// ═══════════════════════════════════════════════════════════

class _FloatingNode extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double scale;

  const _FloatingNode({
    required this.icon,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SMALL DATA NODE
// ═══════════════════════════════════════════════════════════

class _SmallDataNode extends StatelessWidget {
  final Color color;
  final double scale;

  const _SmallDataNode({required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Container(
          margin: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.30), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SPARK
// ═══════════════════════════════════════════════════════════

class _Spark extends StatelessWidget {
  final Color color;
  final double opacity;

  const _Spark({required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 13,
      color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// NETWORK PAINTER
// ═══════════════════════════════════════════════════════════

class _RecoveryNetworkPainter extends CustomPainter {
  final double animation;
  final Color primary;
  final Color secondary;

  _RecoveryNetworkPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primary.withValues(alpha: 0.13);

    final points = [
      Offset(40, 92),
      Offset(230, 64),
      Offset(198, 153),
      Offset(76, 35),
    ];

    for (final point in points) {
      canvas.drawLine(center, point, paint);
    }

    for (var i = 0; i < points.length; i++) {
      final pulse = 2.2 + math.sin(animation * 1.2 + i) * 0.8;

      final nodePaint = Paint()
        ..color = (i.isEven ? primary : secondary).withValues(alpha: 0.35);

      canvas.drawCircle(points[i], pulse, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RecoveryNetworkPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// ═══════════════════════════════════════════════════════════
// BACKGROUND
// ═══════════════════════════════════════════════════════════

class _RecoveryBackground extends StatefulWidget {
  const _RecoveryBackground();

  @override
  State<_RecoveryBackground> createState() => _RecoveryBackgroundState();
}

class _RecoveryBackgroundState extends State<_RecoveryBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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

        return CustomPaint(painter: _RecoveryBackgroundPainter(animation: t));
      },
    );
  }
}

class _RecoveryBackgroundPainter extends CustomPainter {
  final double animation;

  _RecoveryBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.05 + math.sin(animation) * 30,
        size.height * 0.08 + math.cos(animation) * 20,
      ),
      190,
      const Color(0xFF4C8DFF),
      0.09,
    );

    _drawOrb(
      canvas,
      Offset(
        size.width * 0.96 + math.cos(animation * 0.7) * 28,
        size.height * 0.58 + math.sin(animation) * 35,
      ),
      220,
      const Color(0xFF8B6CFF),
      0.075,
    );

    _drawOrb(
      canvas,
      Offset(
        size.width * 0.75 + math.sin(animation * 1.1) * 25,
        size.height * 0.03,
      ),
      140,
      const Color(0xFF20C9E8),
      0.06,
    );
  }

  void _drawOrb(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RecoveryBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
