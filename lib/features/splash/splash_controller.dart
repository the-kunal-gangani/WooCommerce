import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_controller.dart';

class SplashController extends GetxController {
  final GetStorage _storage = GetStorage();

  @override
  Future<void> onReady() async {
    super.onReady();
    await Future<void>.delayed(const Duration(seconds: 2));
    final completed =
        _storage.read<bool>(OnboardingController.onboardingKey) ?? false;
    Get.offAllNamed(completed ? AppRoutes.home : AppRoutes.onboarding);
  }
}
