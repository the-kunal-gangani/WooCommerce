import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/checkout_services.dart';

import '../../core/services/cart_service.dart';
import '../../data/models/checkout_address.dart';
import '../../data/models/checkout_data.dart';
import '../order-confirmation/order_confirmation_screen.dart';

class CheckoutController extends GetxController {
  CheckoutController(this._cart, this._checkoutService);

  final CartService _cart;
  final CheckoutService _checkoutService;

  final addressFormKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();

  final RxBool saveAddress = false.obs;

  final RxString selectedPaymentMethod = 'cod'.obs;

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderController = TextEditingController();

  final RxBool savePaymentMethod = false.obs;

  final RxString selectedShippingMethod = 'standard'.obs;
  static const int standardShippingMinor = 0;
  static const int expressShippingMinor = 1500;

  int get shippingFeeMinor {
    return selectedShippingMethod.value == 'express'
        ? expressShippingMinor
        : standardShippingMinor;
  }

  final couponController = TextEditingController();
  final RxBool couponApplied = false.obs;
  final RxString appliedCoupon = ''.obs;

  static const int temporaryCouponDiscountMinor = 2500;

  int get discountMinor {
    return couponApplied.value ? temporaryCouponDiscountMinor : 0;
  }

  final RxBool isPlacingOrder = false.obs;
  final RxBool showCardDetails = false.obs;
  int get subtotalMinor => _cart.subtotalMinor;
  int get totalMinor {
    final total = subtotalMinor + shippingFeeMinor - discountMinor;
    return total < 0 ? 0 : total;
  }

  String get currencySymbol {
    if (_cart.items.isNotEmpty) {
      return _cart.items.first.currencySymbol;
    }
    return '₹';
  }

  int get minorUnit {
    if (_cart.items.isNotEmpty) {
      return _cart.items.first.minorUnit;
    }
    return 2;
  }

  double get subtotal {
    return subtotalMinor / _minorUnitDivisor;
  }

  double get shippingFee {
    return shippingFeeMinor / _minorUnitDivisor;
  }

  double get discount {
    return discountMinor / _minorUnitDivisor;
  }

  double get total {
    return totalMinor / _minorUnitDivisor;
  }

  int get _minorUnitDivisor {
    var divisor = 1;
    for (var i = 0; i < minorUnit; i++) {
      divisor *= 10;
    }
    return divisor;
  }

  void selectShippingMethod(String method) {
    if (method != 'standard' && method != 'express') {
      return;
    }
    selectedShippingMethod.value = method;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    showCardDetails.value = method == 'card';
  }

  void applyCoupon() {
    final code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar(
        'Coupon',
        'Please enter a coupon code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (code != 'MAGNA25') {
      couponApplied.value = false;
      appliedCoupon.value = '';
      Get.snackbar(
        'Invalid coupon',
        'This coupon is not valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    couponApplied.value = true;
    appliedCoupon.value = code;
    Get.snackbar(
      'Coupon applied',
      'Your coupon has been applied.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeCoupon() {
    couponApplied.value = false;
    appliedCoupon.value = '';
    couponController.clear();
  }

  bool _validateAddress() {
    final form = addressFormKey.currentState;
    if (form == null) {
      return false;
    }
    return form.validate();
  }

  bool _validatePayment() {
    if (selectedPaymentMethod.value == 'cod') {
      return true;
    }
    if (selectedPaymentMethod.value == 'paypal') {
      return true;
    }
    if (selectedPaymentMethod.value == 'card') {
      if (cardNumberController.text.trim().isEmpty ||
          expiryController.text.trim().isEmpty ||
          cvvController.text.trim().isEmpty ||
          cardHolderController.text.trim().isEmpty) {
        Get.snackbar(
          'Payment details',
          'Please complete your card details.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> placeOrder() async {
    if (isPlacingOrder.value) {
      return;
    }
    if (_cart.items.isEmpty) {
      Get.snackbar(
        'Cart is empty',
        'Add at least one product before checkout.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!_validateAddress()) {
      return;
    }
    if (!_validatePayment()) {
      return;
    }
    isPlacingOrder.value = true;
    try {
      final address = CheckoutAddress(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        address1: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postcode: postalCodeController.text.trim(),
      );
      final checkoutData = CheckoutData(
        address: address,
        items: List.unmodifiable(_cart.items),
        paymentMethod: selectedPaymentMethod.value,
        shippingMethod: selectedShippingMethod.value,
        couponCode: couponApplied.value ? appliedCoupon.value : null,
      );
      await _checkoutService.placeOrder(checkoutData);
      Get.off(() => const OrderConfirmationScreen());
    } on UnimplementedError catch (e) {
      Get.snackbar(
        'Checkout not connected',
        e.message ?? 'Checkout backend is not configured yet.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Unable to place order',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void toggleSaveAddress(bool? value) {
    saveAddress.value = value ?? false;
  }

  void toggleSavePayment(bool? value) {
    savePaymentMethod.value = value ?? false;
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
