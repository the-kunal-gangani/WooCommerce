import 'package:get/get.dart';
import '../../core/services/cart_service.dart';
import '../../data/models/product.dart';

class AddToCartController extends GetxController {
  AddToCartController(this._cart);
  final CartService _cart;
  final quantity = 1.obs;
  final isAdding = false.obs;

  void setQuantity(int value) {
    if (value < 1) return;
    quantity.value = value;
  }

  void increase(Product product) {
    final maximum = product.addToCart.maximum;
    if (quantity.value >= maximum) {
      return;
    }
    quantity.value++;
  }

  void decrease(Product product) {
    final minimum = product.addToCart.minimum;
    if (quantity.value <= minimum) {
      return;
    }
    quantity.value--;
  }

  Future<bool> addToCart(Product product, {int? variationId}) async {
    if (!product.canBuy) {
      return false;
    }
    isAdding.value = true;
    try {
      return await _cart.addProduct(
        product,
        quantity: quantity.value,
        variationId: variationId,
      );
    } finally {
      isAdding.value = false;
    }
  }

  void reset() {
    quantity.value = 1;
  }
}
