import 'package:flexify/flexify.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/add-to-cart/add_to_cart_screen.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_screen.dart';

class HomeController extends GetxController {
  void navigateToRegisterScreen() {
    Flexify.goRemoveAll(
      const ProductDetailsScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }

  void navigateToCartPage() {
    Flexify.goRemoveAll(
      const AddToCartScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }
}
