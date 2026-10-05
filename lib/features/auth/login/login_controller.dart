import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flexify/flexify.dart';
import 'package:magna_data_ai_ecommerce/features/auth/register/register_screen.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_screen.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      isLoading.value = false;
      Flexify.goRemoveAll(
        const HomeScreen(),
        animation: FlexifyRouteAnimations.blur,
        duration: const Duration(milliseconds: 800),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to log in. Please check your credentials.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void navigateToRegisterScreen() {
    Flexify.goRemoveAll(
      const RegisterScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
