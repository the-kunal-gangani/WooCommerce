import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/data/models/cart_item.dart';
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
      final cartItem = CartItem(
        productId: product.id,
        variationId: variationId,
        name: product.name,
        price: product.prices.price,
        quantity: quantity.value,
        imageUrl: product.imageUrl,
        sku: product.sku,
        currencySymbol: product.prices.currencySymbol,
        minorUnit: product.prices.minorUnit,
      );

      await _cart.addItem(item: cartItem);

      return true;
    } finally {
      isAdding.value = false;
    }
  }

  void reset() {
    quantity.value = 1;
  }
}
