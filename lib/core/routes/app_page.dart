import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/splash/splash_screen.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
  ];
}
