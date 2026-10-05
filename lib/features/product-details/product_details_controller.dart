import 'package:flexify/flexify.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_screen.dart';

class ProductDetailsController extends GetxController {
  final selectedImageIndex = 0.obs;
  final quantity = 1.obs;
  final selectedColorIndex = 0.obs;
  final selectedSizeIndex = 0.obs;
  final isFavorite = false.obs;
  final RxDouble basePrice = 299.99.obs;

  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
  }

  void selectSize(int index) {
    selectedSizeIndex.value = index;
  }

  double get totalPrice => basePrice.value * quantity.value;

  void goToProductDetails() {
    Flexify.goRemoveAll(
      const ProductDetailsScreen(),
      animation: FlexifyRouteAnimations.blur,
      duration: const Duration(milliseconds: 800),
    );
  }
}
