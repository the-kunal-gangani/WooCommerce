import 'dart:math' as math;

import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_screen.dart';
import 'package:magna_data_ai_ecommerce/features/auth/register/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<RegisterController>()
        ? Get.find<RegisterController>()
        : Get.put(RegisterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            const _RegisterBackground(),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  _TopBar(onBack: () => Flexify.back()),
                  const SizedBox(height: 2),
                  const _RegisterIllustration(),
                  const SizedBox(height: 6),
                  const _RegisterHeader(),
                  const SizedBox(height: 20),
                  _RegisterForm(controller: controller),
                  const SizedBox(height: 22),
                  _LoginPrompt(),
                  const SizedBox(height: 20),
                  const Text(
                    'CREATE YOUR AI SHOPPING PROFILE',
                    style: TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECF2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111827).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF263247),
                size: 20,
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFDCEBFF)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 13,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 6),
              Text(
                'AI COMMERCE',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Join a smarter shopping experience built around you.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF687386).withValues(alpha: 0.95),
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final RegisterController controller;

  const _RegisterForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.055),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FormSectionTitle(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Set up your profile',
            subtitle: 'A few details and you are ready to shop.',
          ),
          const SizedBox(height: 22),
          const _FieldLabel(icon: Icons.badge_outlined, label: 'FULL NAME'),
          const SizedBox(height: 8),
          _RegisterTextField(
            controller: controller.nameController,
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 17),
          const _FieldLabel(
            icon: Icons.alternate_email_rounded,
            label: 'EMAIL ADDRESS',
          ),
          const SizedBox(height: 8),
          _RegisterTextField(
            controller: controller.emailController,
            hintText: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 17),
          const _FieldLabel(
            icon: Icons.lock_outline_rounded,
            label: 'PASSWORD',
          ),
          const SizedBox(height: 8),
          Obx(
            () => _RegisterTextField(
              controller: controller.passwordController,
              hintText: 'Create a secure password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                splashRadius: 20,
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF7B8798),
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          const _FieldLabel(
            icon: Icons.verified_user_outlined,
            label: 'CONFIRM PASSWORD',
          ),
          const SizedBox(height: 8),
          Obx(
            () => _RegisterTextField(
              controller: controller.confirmPasswordController,
              hintText: 'Re-enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !controller.isConfirmPasswordVisible.value,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                onPressed: controller.toggleConfirmPasswordVisibility,
                splashRadius: 20,
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF7B8798),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9EDF3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your account credentials are protected and used only to keep your shopping experience secure.',
                    style: TextStyle(
                      color: Color(0xFF687386),
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _RegisterButton(
              isLoading: controller.isLoading.value,
              onPressed: controller.isLoading.value
                  ? null
                  : controller.register,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FormSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8993A3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _RegisterTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: Color(0xFF172033),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: const Color(0xFF2563EB),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9AA4B2),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF7B8798)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF5B7CFA), width: 1.4),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _RegisterButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF6D4AFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4D68F5).withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    key: ValueKey('button'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: Color(0xFF7B8798),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () {
            Flexify.go(
              const LoginScreen(),
              animation: FlexifyRouteAnimations.blur,
              duration: const Duration(milliseconds: 600),
            );
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterIllustration extends StatefulWidget {
  const _RegisterIllustration();

  @override
  State<_RegisterIllustration> createState() => _RegisterIllustrationState();
}

class _RegisterIllustrationState extends State<_RegisterIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final rotation = _controller.value * math.pi * 2;
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 78),
                painter: _RegisterNetworkPainter(progress: _controller.value),
              ),
              Positioned(
                left: 75,
                top: 27,
                child: _TinyNode(icon: Icons.person_outline_rounded),
              ),
              Positioned(
                right: 75,
                top: 20,
                child: _TinyNode(
                  icon: Icons.auto_awesome_rounded,
                  accent: true,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF6D4AFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B6EF5).withValues(alpha: 0.20),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 18,
                      color: Color(0xFF4E63E8),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                child: Transform.rotate(
                  angle: rotation,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 10,
                    color: Color(0xFF6D4AFF),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TinyNode extends StatelessWidget {
  final IconData icon;
  final bool accent;

  const _TinyNode({required this.icon, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 14,
        color: accent ? const Color(0xFF6D4AFF) : const Color(0xFF2563EB),
      ),
    );
  }
}

class _RegisterNetworkPainter extends CustomPainter {
  final double progress;

  _RegisterNetworkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF7C8DF7).withValues(alpha: 0.16);
    final nodes = [
      Offset(38, 68),
      Offset(size.width - 38, 52),
      Offset(64, 150),
      Offset(size.width - 64, 145),
    ];
    for (final node in nodes) {
      canvas.drawLine(center, node, paint);
    }
    final pulsePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5B6EF5).withValues(alpha: 0.30);
    final pulseOffset = Offset(
      center.dx + math.cos(progress * math.pi * 2) * 44,
      center.dy + math.sin(progress * math.pi * 2) * 28,
    );
    canvas.drawCircle(pulseOffset, 3, pulsePaint);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF7C3AED).withValues(alpha: 0.20);
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final radius = 70.0 + math.sin(progress * math.pi * 2 + i) * 5;
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius * 0.55,
      );
      canvas.drawCircle(offset, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RegisterNetworkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _RegisterBackground extends StatefulWidget {
  const _RegisterBackground();

  @override
  State<_RegisterBackground> createState() => _RegisterBackgroundState();
}

class _RegisterBackgroundState extends State<_RegisterBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          return Stack(
            children: [
              Positioned(
                top: -100 + math.sin(value * math.pi * 2) * 20,
                left: -80,
                child: _GlowOrb(
                  size: 250,
                  color: const Color(0xFF5B8DEF),
                  opacity: 0.075,
                ),
              ),
              Positioned(
                top: 150 + math.cos(value * math.pi * 2) * 25,
                right: -120,
                child: _GlowOrb(
                  size: 280,
                  color: const Color(0xFF8B5CF6),
                  opacity: 0.06,
                ),
              ),
              Positioned(
                bottom: -130,
                left: 80,
                child: _GlowOrb(
                  size: 260,
                  color: const Color(0xFF22C7E8),
                  opacity: 0.045,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

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
