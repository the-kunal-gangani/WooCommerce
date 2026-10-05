import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _onboardingKey = 'has_completed_onboarding';

  void completeOnboarding() {
    _storage.write(_onboardingKey, true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.login);
    });
  }

  bool get isFirstLaunch => _storage.read<bool>(_onboardingKey) != true;
}
