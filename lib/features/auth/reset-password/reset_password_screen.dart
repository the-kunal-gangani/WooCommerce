import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/auth/reset-password/reset_password_controller.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE5EAF1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          _buildAmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                    child: Column(
                      children: [
                        _buildSecurityHeader(),
                        const SizedBox(height: 24),
                        _buildResetForm(),
                      ],
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

  Widget _buildAmbientBackground() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.10),
                    primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    violet.withValues(alpha: 0.07),
                    violet.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: Get.back,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: navy,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Reset Password',
            style: TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: 0.14),
                violet.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(color: primary.withValues(alpha: 0.10)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: primary,
                  size: 29,
                ),
              ),
              Positioned(
                right: 4,
                top: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: violet,
                    shape: BoxShape.circle,
                    border: Border.all(color: background, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Create a new password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Enter the verification code sent to\n${controller.email}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: muted,
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Verification code'),
          const SizedBox(height: 8),
          TextField(
            controller: controller.codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.oneTimeCode],
            decoration: _decoration(
              label: 'Enter reset code',
              icon: Icons.password_rounded,
            ),
          ),
          const SizedBox(height: 17),
          _buildFieldLabel('New password'),
          const SizedBox(height: 8),
          Obx(
            () => TextField(
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                label: 'Create a new password',
                icon: Icons.lock_outline_rounded,
                suffix: _visibilityButton(
                  visible: controller.isPasswordVisible.value,
                  onTap: controller.togglePasswordVisibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          _buildFieldLabel('Confirm password'),
          const SizedBox(height: 8),
          Obx(
            () => TextField(
              controller: controller.confirmPasswordController,
              obscureText: !controller.isConfirmPasswordVisible.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.resetPassword(),
              decoration: _decoration(
                label: 'Re-enter your password',
                icon: Icons.lock_outline_rounded,
                suffix: _visibilityButton(
                  visible: controller.isConfirmPasswordVisible.value,
                  onTap: controller.toggleConfirmPasswordVisibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildPasswordHint(),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.resetPassword,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primary,
                  disabledBackgroundColor: primary.withValues(alpha: 0.55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Obx(() {
              final seconds = controller.resendSeconds.value;
              return TextButton(
                onPressed: seconds == 0 ? controller.resendCode : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                    children: [
                      const TextSpan(text: 'Didn\'t receive the code? '),
                      TextSpan(
                        text: seconds == 0
                            ? 'Resend code'
                            : 'Resend in ${seconds}s',
                        style: TextStyle(
                          color: seconds == 0 ? primary : muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: navy,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildPasswordHint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: primary,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'Use a strong password that you haven\'t used before.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _visibilityButton({
    required bool visible,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 20,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: muted,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA4B2),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7C8798)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}
