import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';

class SplashController extends GetxController {
  final GetStorage _storage = GetStorage();

  static const String onboardingKey = 'has_completed_onboarding';

  @override
  Future<void> onReady() async {
    super.onReady();
    await Future<void>.delayed(const Duration(seconds: 2));
    final completed = _storage.read<bool>(onboardingKey) ?? false;
    Get.offAllNamed(completed ? AppRoutes.home : AppRoutes.onboarding);
  }

  void completeOnboarding() {
    _storage.write(onboardingKey, true);
    Get.offAllNamed(AppRoutes.home);
  }
}
