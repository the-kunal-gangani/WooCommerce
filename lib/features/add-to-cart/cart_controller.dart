import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/cart_service.dart';
import '../../data/models/cart_item.dart';

class CartController extends GetxController {
  CartController(this._cart);

  final CartService _cart;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();

  RxList<CartItem> get items => _cart.items;

  bool get isEmpty => _cart.isEmpty;

  bool get hasItems => _cart.hasItems;

  int get itemCount => _cart.itemCount;

  int get subtotalMinor => _cart.subtotalMinor;

  double get subtotal => _cart.subtotal;

  bool get isBusy => isLoading.value || isRefreshing.value;

  @override
  void onInit() {
    super.onInit();
    refreshCart();
  }

  Future<void> refreshCart() async {
    if (isRefreshing.value) {
      return;
    }
    if (_cart.isEmpty) {
      errorMessage.value = null;
      return;
    }
    isRefreshing.value = true;
    errorMessage.value = null;
    try {
      await _cart.refreshCartProducts();
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Unable to refresh your cart.';
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> increaseQuantity(CartItem item) async {
    await _cart.increaseQuantity(item);
  }

  Future<void> decreaseQuantity(CartItem item) async {
    await _cart.decreaseQuantity(item);
  }

  Future<void> setQuantity(CartItem item, int quantity) async {
    await _cart.setQuantity(item, quantity);
  }

  Future<void> removeItem(CartItem item) async {
    await _cart.removeItem(item);
  }

  Future<bool> clearCart() async {
    if (_cart.isEmpty) {
      return true;
    }

    final confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Clear cart?'),
            content: const Text('All products will be removed from your cart.'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(result: false);
                },
                child: const Text('Keep'),
              ),
              FilledButton(
                onPressed: () {
                  Get.back(result: true);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return false;
    }
    await _cart.clearCart();
    return true;
  }

  Future<void> checkout() async {
    if (isLoading.value) {
      return;
    }
    if (_cart.isEmpty) {
      Get.snackbar(
        'Cart is empty',
        'Add a product before checking out.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final validation = await _cart.validateCart();
      if (validation != null) {
        Get.snackbar(
          'Checkout unavailable',
          validation,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_cart.isEmpty) {
        Get.snackbar(
          'Cart is empty',
          'There are no available products to checkout.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      Get.toNamed(AppRoutes.checkout);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Checkout unavailable',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Unable to proceed to checkout.';
      Get.snackbar(
        'Checkout unavailable',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void continueShopping() {
    Get.back();
  }

  void clearError() {
    errorMessage.value = null;
  }
}
