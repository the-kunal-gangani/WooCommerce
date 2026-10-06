import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/order-confirmation/order_confirmation_screen.dart';

class CheckoutController extends GetxController {
  final addressFormKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();

  final RxBool saveAddress = false.obs;
  final RxString selectedPaymentMethod = 'card'.obs;

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderController = TextEditingController();

  final RxBool savePaymentMethod = false.obs;
  final RxString selectedShippingMethod = 'standard'.obs;

  final double standardShipping = 0.0;
  final double expressShipping = 15.0;
  final couponController = TextEditingController();
  final RxBool couponApplied = false.obs;

  final RxBool isPlacingOrder = false.obs;
  final RxBool showCardDetails = true.obs;

  // ------------------------------------------------------------
  // Temporary cart values
  //
  // These are temporary ONLY for UI development.
  // They will later come from the cart/backend.
  // ------------------------------------------------------------

  final RxDouble subtotal = 588.98.obs;
  final RxDouble tax = 47.12.obs;

  double get shippingFee {
    return selectedShippingMethod.value == 'express'
        ? expressShipping
        : standardShipping;
  }

  double get discount {
    return couponApplied.value ? 25.0 : 0.0;
  }

  double get total {
    return subtotal.value + shippingFee + tax.value - discount;
  }

  void toggleSaveAddress(bool? value) {
    saveAddress.value = value ?? false;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;

    showCardDetails.value = method == 'card';
  }

  void toggleSavePayment(bool? value) {
    savePaymentMethod.value = value ?? false;
  }

  void selectShippingMethod(String method) {
    selectedShippingMethod.value = method;
  }

  void applyCoupon() {
    final coupon = couponController.text.trim();

    if (coupon.isEmpty) {
      Get.snackbar(
        'Coupon',
        'Please enter a coupon code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (coupon.toUpperCase() == 'MAGNA25') {
      couponApplied.value = true;

      Get.snackbar(
        'Coupon Applied',
        'You saved \$25.00 on this order.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    couponApplied.value = false;

    Get.snackbar(
      'Invalid Coupon',
      'This coupon is not valid.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeCoupon() {
    couponApplied.value = false;
    couponController.clear();
  }

  Future<void> placeOrder() async {
    if (!addressFormKey.currentState!.validate()) {
      return;
    }

    if (selectedPaymentMethod.value == 'card') {
      if (cardNumberController.text.trim().isEmpty ||
          expiryController.text.trim().isEmpty ||
          cvvController.text.trim().isEmpty) {
        Get.snackbar(
          'Payment Details',
          'Please complete your card details.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isPlacingOrder.value = true;

    // Temporary local processing.
    // Backend integration will replace this later.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    isPlacingOrder.value = false;

    Flexify.go(OrderConfirmationScreen());
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();

    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    cardHolderController.dispose();

    couponController.dispose();

    super.onClose();
  }
}
