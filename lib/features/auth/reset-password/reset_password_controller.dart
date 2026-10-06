import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';

class ResetPasswordController extends GetxController {
  final String email = Get.arguments is String ? Get.arguments as String : '';

  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final resendSeconds = 30.obs;

  final AuthService _auth = Get.find<AuthService>();
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    if (email.isEmpty) {
      Get.offNamed(AppRoutes.forgetPassword);
      return;
    }
    _startCooldown();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> resetPassword() async {
    final code = codeController.text.trim();
    final password = passwordController.text;

    if (code.isEmpty) {
      _error('Please enter the code from your email');
      return;
    }
    if (password.length < 8) {
      _error('Password must be at least 8 characters');
      return;
    }
    if (password != confirmPasswordController.text) {
      _error('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      await _auth.resetPassword(
        email: email,
        code: code,
        newPassword: password,
      );
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Password updated',
        'You can now sign in with your new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      _error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (resendSeconds.value > 0) return;
    _startCooldown();
    try {
      await _auth.requestPasswordReset(email);
      Get.snackbar(
        'Code sent',
        'Check your inbox for a new code',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    resendSeconds.value = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  void _error(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    _timer?.cancel();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
