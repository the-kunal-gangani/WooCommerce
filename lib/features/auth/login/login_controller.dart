import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flexify/flexify.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/features/auth/forget-password/forget_password_screen.dart';
import 'package:magna_data_ai_ecommerce/features/auth/register/register_screen.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  final AuthService _auth = Get.find<AuthService>();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    try {
      await _auth.login(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } on ApiException catch (e) {
      Get.snackbar(
        'Login failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRegisterScreen() {
    Flexify.goRemoveAll(
      const RegisterScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }

  void navigateToForgetPasswordScreen() {
    Flexify.goRemoveAll(
      const ForgotPasswordScreen(),
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
