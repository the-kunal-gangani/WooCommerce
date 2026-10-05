import 'package:flexify/flexify.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_screen.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_screen.dart';

import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';

class SplashController extends GetxController {
  SplashController(this._products);

  final ProductService _products;
  final GetStorage _storage = GetStorage();

  static const String onboardingKey = 'has_completed_onboarding';

  @override
  Future<void> onReady() async {
    super.onReady();

    try {
      final result = await _products.fetchProducts(perPage: 3);
      printLog(
        'total=${result.total} first=${result.items.firstOrNull?['name']}',
      );
    } on ApiException catch (e) {
      printLog(e);
    }

    // Delay briefly to allow splash animations to finish
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has already seen onboarding
    final bool hasCompletedOnboarding =
        _storage.read<bool>(onboardingKey) ?? false;

    if (hasCompletedOnboarding) {
      navigateToHomeScreen();
    } else {
      navigateToOnboarding();
    }
  }

  void navigateToOnboarding() {
    Flexify.goRemoveAll(
      const OnboardingScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }

  void navigateToHomeScreen() {
    Flexify.goRemoveAll(
      const HomeScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }

  /// Called when user finishes onboarding on OnboardingScreen
  void completeOnboarding() {
    _storage.write(onboardingKey, true);
    navigateToHomeScreen();
  }
}
