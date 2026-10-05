import 'package:flutter/widgets.dart';
import 'package:flexify/flexify.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_screen.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _onboardingKey = 'has_completed_onboarding';

  void completeOnboarding() {
    _storage.write(_onboardingKey, true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.put(LoginController());

      Flexify.goRemoveAll(
        const LoginScreen(),
        animation: FlexifyRouteAnimations.blur,
        duration: const Duration(milliseconds: 800),
      );
    });
  }

  bool get isFirstLaunch => _storage.read<bool>(_onboardingKey) != true;
}
