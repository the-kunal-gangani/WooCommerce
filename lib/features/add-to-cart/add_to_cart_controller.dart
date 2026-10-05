import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddToCartController extends GetxController {
  final String productName = 'Premium Wireless Headphones';
  final double basePrice = 199.99;
  final List<String> availableColors = ['Black', 'Silver', 'Navy Blue'];
  var selectedColor = 'Black'.obs;
  var quantity = 1.obs;

  double get totalPrice => basePrice * quantity.value;

  void selectColor(String color) {
    selectedColor.value = color;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    Get.snackbar(
      'Added to Cart',
      '${quantity.value}x $productName (${selectedColor.value}) added.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
