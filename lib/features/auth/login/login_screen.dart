import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  void registerAccount(BuildContext context) {
    final controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());

    controller.navigateToRegisterScreen();
  }

  void forgetPassword(BuildContext context) {
    final controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());

    controller.navigateToForgetPasswordScreen();
  }

  @override
  Widget build(BuildContext context) {
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
          // ═════════════════════════════════════════════
          // AMBIENT BACKGROUND
          // ═════════════════════════════════════════════

          const Positioned.fill(child: _LoginBackground()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        // ═════════════════════════════════
                        // BRAND / AI MARK
                        // ═════════════════════════════════

                        const _LoginBrandMark(),

                        const SizedBox(height: 28),

                        // ═════════════════════════════════
                        // HEADER
                        // ═════════════════════════════════
                        const Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),

                        const SizedBox(height: 9),

                        Text(
                          'Sign in to continue your intelligent\nshopping experience.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ═════════════════════════════════
                        // LOGIN CARD
                        // ═════════════════════════════════
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B2840)
                                    .withValues(alpha: 0.07),
                                blurRadius: 35,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ─────────────────────────
                              // EMAIL
                              // ─────────────────────────

                              const _FieldLabel(
                                icon: Icons.alternate_email_rounded,
                                label: 'Email address',
                              ),

                              const SizedBox(height: 9),

                              TextFormField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }

                                  if (!GetUtils.isEmail(value.trim())) {
                                    return 'Please enter a valid email address';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 19),

                              // ─────────────────────────
                              // PASSWORD
                              // ─────────────────────────
                              const _FieldLabel(
                                icon: Icons.lock_outline_rounded,
                                label: 'Password',
                              ),

                              const SizedBox(height: 9),

                              Obx(
                                () => TextFormField(
                                  controller: controller.passwordController,
                                  obscureText:
                                      !controller.isPasswordVisible.value,
                                  textInputAction: TextInputAction.done,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration:
                                      _inputDecoration(
                                        hint: 'Enter your password',
                                        icon: Icons.lock_outline_rounded,
                                        primary: primary,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          onPressed: controller
                                              .togglePasswordVisibility,
                                          icon: Icon(
                                            controller.isPasswordVisible.value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: mutedColor,
                                          ),
                                        ),
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }

                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }

                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 9),

                              // ─────────────────────────
                              // REMEMBER + FORGOT
                              // ─────────────────────────
                              Row(
                                children: [
                                  Obx(
                                    () => SizedBox(
                                      height: 38,
                                      width: 38,
                                      child: Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: controller.toggleRememberMe,
                                        activeColor: primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 3),

                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const Spacer(),

                                  TextButton(
                                    onPressed: () {
                                      forgetPassword(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // ─────────────────────────
                              // SIGN IN BUTTON
                              // ─────────────────────────
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
                                      borderRadius: BorderRadius.circular(17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(
                                            alpha: 0.23,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 9),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : controller.login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            17,
                                          ),
                                        ),
                                      ),
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(width: 9),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
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

                        const SizedBox(height: 24),

                        // ═════════════════════════════════
                        // SIGN UP
                        // ═════════════════════════════════
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: mutedColor, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                registerAccount(context);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(left: 5),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Create account',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ═════════════════════════════════
                        // BRAND FOOTER
                        // ═════════════════════════════════
                        Text(
                          '${AppConfig.appName.toUpperCase()} • AI COMMERCE',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.24),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        color: const Color(0xFF687386).withValues(alpha: 0.55),
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
        borderSide: BorderSide(color: const Color(0xFFE7EBF2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: primary.withValues(alpha: 0.65),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE57373)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.3),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FIELD LABEL
// ═══════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════
// BRAND MARK
// ═══════════════════════════════════════════════════════════

class _LoginBrandMark extends StatefulWidget {
  const _LoginBrandMark();

  @override
  State<_LoginBrandMark> createState() => _LoginBrandMarkState();
}

class _LoginBrandMarkState extends State<_LoginBrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
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
        return SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _controller.value * math.pi * 2,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                ),
              ),

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              Positioned(
                top: 6,
                right: 9,
                child: _BrandDot(color: secondary, size: 7),
              ),

              Positioned(
                bottom: 11,
                left: 5,
                child: _BrandDot(color: primary, size: 5),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BRAND DOT
// ═══════════════════════════════════════════════════════════

class _BrandDot extends StatelessWidget {
  final Color color;
  final double size;

  const _BrandDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
// ANIMATED BACKGROUND
// ═══════════════════════════════════════════════════════════

class _LoginBackground extends StatefulWidget {
  const _LoginBackground();

  @override
  State<_LoginBackground> createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<_LoginBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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

        return CustomPaint(painter: _LoginBackgroundPainter(animation: t));
      },
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  final double animation;

  _LoginBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.05 + math.sin(animation) * 35,
        size.height * 0.10 + math.cos(animation) * 20,
      ),
      190,
      const Color(0xFF4C8DFF),
      0.10,
    );

    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.95 + math.cos(animation * 0.7) * 30,
        size.height * 0.65 + math.sin(animation) * 35,
      ),
      220,
      const Color(0xFF8B6CFF),
      0.08,
    );

    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.80 + math.sin(animation * 1.2) * 25,
        size.height * 0.05,
      ),
      140,
      const Color(0xFF20C9E8),
      0.07,
    );
  }

  void _drawOrb(
    Canvas canvas,
    Size size,
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
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
