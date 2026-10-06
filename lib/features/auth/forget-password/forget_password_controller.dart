import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_screen.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  void sendResetCode() {
    final email = emailController.text.trim();
    Get.lazyPut<LoginController>(() => LoginController());

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Password reset code sent to $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 1), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Flexify.goRemoveAll(
            const LoginScreen(),
            animation: FlexifyRouteAnimations.blur,
            duration: const Duration(milliseconds: 600),
          );
        });
      });
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
