import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_screen.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_screen.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_controller.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_screen.dart';

import '../../features/splash/splash_controller.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder.put(
        () => SplashController(Get.find<ProductService>()),
      ),
    ),

    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder.put(() => OnboardingController()),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder.put(() => LoginController()),
    ),

    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
  ];
}
