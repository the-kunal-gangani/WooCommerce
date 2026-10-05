import 'package:flexify/flexify.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_screen.dart';

import '../../core/network/api_exception.dart';
import '../../core/utils/logger.dart';

class SplashController extends GetxController {
  SplashController(this._products);

  final ProductService _products;

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
    await Future.delayed(const Duration(seconds: 2));
    navigateToHomeScreen();
  }

  void navigateToHomeScreen() {
    Flexify.goRemoveAll(
      const HomeScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(seconds: 3),
    );
  }
}
