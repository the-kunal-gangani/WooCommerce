import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';

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
  ];
}
