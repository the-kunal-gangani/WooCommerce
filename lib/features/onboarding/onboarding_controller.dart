import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();

  static const String onboardingKey = 'has_completed_onboarding';

  bool get isFirstLaunch => _storage.read<bool>(onboardingKey) != true;

  void completeOnboarding() {
    _storage.write(onboardingKey, true);
    Get.offAllNamed(AppRoutes.home);
  }
}
