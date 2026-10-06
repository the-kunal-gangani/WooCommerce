import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  final AuthService _auth = Get.find<AuthService>();

  Future<void> sendResetCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _auth.requestPasswordReset(email);
    } on ApiException catch (e) {
      printLog('reset request failed: $e');
      final transient =
          e.type == ApiErrorType.network ||
          e.type == ApiErrorType.timeout ||
          e.type == ApiErrorType.server;
      if (transient) {
        Get.snackbar(
          'Something went wrong',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }
    }
    isLoading.value = false;

    Get.offNamed(AppRoutes.resetPassword, arguments: email);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
