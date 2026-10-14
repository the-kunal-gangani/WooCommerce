import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._authService);

  final AuthService _authService;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  final isSaving = false.obs;

  static const Color primary = Color(0xFF2563EB);

  String get email => _authService.user.value?.email ?? '';

  @override
  void onInit() {
    super.onInit();

    final currentUser = _authService.user.value;

    fullNameController.text = currentUser?.fullName ?? '';
    phoneController.text = currentUser?.phone ?? '';
  }

  String? validateFullName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name.';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters.';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    final digits = phone.replaceAll(RegExp(r'[\s()+-]'), '');

    if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;

    try {
      await _authService.updateProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      // Show success notification.
      Get.snackbar(
        'Profile Updated',
        'Your details have been updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFECFDF3),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      // Close Edit Profile and return to User Profile.
      Get.back(result: true);
    } on ApiException catch (error) {
      Get.snackbar(
        'Update Failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF1F2),
        colorText: const Color(0xFFBE123C),
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Something Went Wrong',
        'Unable to update your profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF1F2),
        colorText: const Color(0xFFBE123C),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
