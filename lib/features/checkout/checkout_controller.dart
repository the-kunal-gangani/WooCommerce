import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  static const int temporaryCouponDiscountMinor = 2500;
  final couponController = TextEditingController();
  final RxBool couponApplied = false.obs;
  final RxString appliedCoupon = ''.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxBool showCardDetails = false.obs;
  final Razorpay _razorpay = Razorpay();
  CheckoutData? _pendingCheckoutData;
  Map<String, dynamic>? _createdOrder;
  int get subtotalMinor => _cart.subtotalMinor;
  int get shippingFeeMinor => selectedShippingMethod.value == 'express'
      ? expressShippingMinor
      : standardShippingMinor;
  int get discountMinor =>
      couponApplied.value ? temporaryCouponDiscountMinor : 0;
  int get totalMinor {
    final value = subtotalMinor + shippingFeeMinor - discountMinor;
    return value < 0 ? 0 : value;
  }

  String get currencySymbol =>
      _cart.items.isNotEmpty ? _cart.items.first.currencySymbol : '₹';

  int get minorUnit => _cart.items.isNotEmpty ? _cart.items.first.minorUnit : 2;

  int get _minorUnitDivisor {
    var divisor = 1;
    for (var i = 0; i < minorUnit; i++) {
      divisor *= 10;
    }
    return divisor;
  }

  double get subtotal => subtotalMinor / _minorUnitDivisor;
  double get shippingFee => shippingFeeMinor / _minorUnitDivisor;
  double get discount => discountMinor / _minorUnitDivisor;
  double get total => totalMinor / _minorUnitDivisor;

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
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

  void selectShippingMethod(String method) {
    if (method == 'standard' || method == 'express') {
      selectedShippingMethod.value = method;
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    showCardDetails.value = false;
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
      'Your coupon has been selected. The server must validate it '
          'and calculate the actual discount.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeCoupon() {
    couponApplied.value = false;
    appliedCoupon.value = '';
    couponController.clear();
  }

  bool _validateAddress() {
    return addressFormKey.currentState?.validate() ?? false;
  }

  bool _validatePayment() {
    switch (selectedPaymentMethod.value) {
      case 'cod':
      case 'card':
        return true;
      case 'phonepe':
        return true;
      default:
        Get.snackbar(
          'Payment unavailable',
          'Please select a supported payment method.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
    }
  }

  Future<void> placeOrder() async {
    if (isPlacingOrder.value) return;
    if (_cart.items.isEmpty) {
      Get.snackbar(
        'Cart is empty',
        'Add at least one product before checkout.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!_validateAddress() || !_validatePayment()) return;
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
      if (selectedPaymentMethod.value == 'card') {
        _pendingCheckoutData = null;
        _createdOrder = null;
        final result = await _checkoutService.createRazorpayOrder(checkoutData);
        final key = result['key_id']?.toString();
        final razorpayOrderId = result['razorpay_order_id']?.toString();
        final amount = result['amount'];
        if (key == null ||
            key.isEmpty ||
            razorpayOrderId == null ||
            razorpayOrderId.isEmpty ||
            amount == null) {
          throw Exception('The server returned incomplete payment details.');
        }
        _pendingCheckoutData = checkoutData;
        _createdOrder = Map<String, dynamic>.from(result);
        try {
          _razorpay.open({
            'key': key,
            'order_id': razorpayOrderId,
            'amount': amount,
            'currency': result['currency'] ?? 'INR',
            'name': 'Magna Data Store',
            'description': 'Order payment',
            'prefill': {'contact': phoneController.text.trim()},
            'theme': {'color': '#2563EB'},
          });
        } catch (_) {
          _pendingCheckoutData = null;
          _createdOrder = null;
          rethrow;
        }
        return;
      }
      if (selectedPaymentMethod.value == 'phonepe') {
        final result = await _checkoutService.createPhonePePayment(
          checkoutData,
        );
        final orderId = int.tryParse(
          result['woocommerce_order_id']?.toString() ?? '',
        );
        final phonePeOrderId = result['phonepe_order_id']?.toString();
        final phonePeToken = result['phonepe_token']?.toString();
        final merchantId =
            (result['merchant_id'] ?? AppConfig.phonePeMerchantId).toString();
        if (orderId == null ||
            phonePeOrderId == null ||
            phonePeOrderId.isEmpty ||
            phonePeToken == null ||
            phonePeToken.isEmpty ||
            merchantId.isEmpty) {
          throw Exception('The server returned incomplete PhonePe details.');
        }
        final flowId = 'magna$orderId';
        final initialized = await PhonePePaymentSdk.init(
          AppConfig.phonePeEnvironment,
          merchantId,
          flowId,
          false,
        );
        if (!initialized) {
          throw Exception('PhonePe SDK initialization failed.');
        }
        final request = jsonEncode({
          'orderId': phonePeOrderId,
          'merchantId': merchantId,
          'token': phonePeToken,
          'paymentMode': {'type': 'PAY_PAGE'},
        });
        final sdkResponse = await PhonePePaymentSdk.startTransaction(
          request,
          AppConfig.phonePeAppSchema,
        );
        final sdkStatus = sdkResponse?['status']?.toString().toUpperCase();
        // The backend, not the SDK result alone, determines the final status.
        final status = await _pollPhonePePaymentStatus(orderId);
        if (status == null) {
          Get.snackbar(
            'Payment confirmation pending',
            'We could not confirm the payment with the server. '
                'Please check your order history before trying again.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 6),
          );
          return;
        }
        final paymentStatus = status['payment_status']
            ?.toString()
            .toLowerCase();
        if (paymentStatus == 'paid') {
          await _cart.clearCart();
          Get.off(
            () => OrderConfirmationScreen(
              checkoutData: checkoutData,
              createdOrder: Map<String, dynamic>.from(result),
              paymentResult: Map<String, dynamic>.from(status),
            ),
          );
          return;
        }
        if (paymentStatus == 'failed') {
          Get.snackbar(
            'Payment failed',
            'The server confirmed that this payment failed. '
                'Review your order before trying another payment.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
          return;
        }
        final message = sdkStatus == 'INTERRUPTED'
            ? 'The payment flow was interrupted, but the final payment '
                  'status is not yet confirmed.'
            : 'The final payment status is not yet confirmed. '
                  'Please check your order history before trying again.';
        Get.snackbar(
          'Payment confirmation pending',
          message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6),
        );
        return;
      }
      if (selectedPaymentMethod.value == 'cod') {
        await _checkoutService.placeOrder(checkoutData);
        await _cart.clearCart();
        Get.offNamed(
          AppRoutes.orderConfirmation,
          arguments: {
            'checkoutData': checkoutData,
            'createdOrder': <String, dynamic>{},
            'paymentResult': <String, dynamic>{
              'status': 'pending',
              'method': 'cod',
            },
          },
        );
      }
    } on UnimplementedError catch (error) {
      Get.snackbar(
        'Checkout not connected',
        error.message ?? 'This checkout method is not implemented yet.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (error) {
      Get.snackbar(
        'Unable to continue checkout',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final razorpayOrderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (razorpayOrderId == null || paymentId == null || signature == null) {
      Get.snackbar(
        'Verification pending',
        'Payment details are incomplete. Check the order status '
            'before trying again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      final result = await _checkoutService.verifyRazorpayPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature,
      );
      if (result['status']?.toString().toLowerCase() != 'paid') {
        Get.snackbar(
          'Payment confirmation pending',
          'The server has not confirmed this payment yet. '
              'Please do not pay again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return;
      }
      final checkoutData = _pendingCheckoutData;
      final createdOrder = _createdOrder;
      if (checkoutData == null || createdOrder == null) {
        Get.snackbar(
          'Order details unavailable',
          'Payment was verified, but checkout details are unavailable. '
              'Please contact support before attempting another payment.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return;
      }
      await _cart.clearCart();
      Get.off(
        () => OrderConfirmationScreen(
          checkoutData: checkoutData,
          createdOrder: Map<String, dynamic>.from(createdOrder),
          paymentResult: Map<String, dynamic>.from(result),
        ),
      );
    } catch (_) {
      Get.snackbar(
        'Verification pending',
        'We could not confirm the payment yet. Check the order status '
            'before retrying.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<Map<String, dynamic>?> _pollPhonePePaymentStatus(int orderId) async {
    const maxAttempts = 12;
    Map<String, dynamic>? lastStatus;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(seconds: 5));
      }

      try {
        final status = await _checkoutService.getPhonePePaymentStatus(orderId);

        lastStatus = status;

        final paymentStatus = status['payment_status']
            ?.toString()
            .toLowerCase();

        if (paymentStatus == 'paid' || paymentStatus == 'failed') {
          return status;
        }
      } catch (_) {
        // A temporary network or server error does not prove
        // that the payment failed. Continue checking.
      }
    }

    return lastStatus;
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment not completed',
      response.message ??
          'Payment was not completed. Check your order status '
              'before attempting another payment.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External wallet',
      response.walletName ?? 'Wallet selected',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleSaveAddress(bool? value) {
    saveAddress.value = value ?? false;
  }

  void toggleSavePayment(bool? value) {
    savePaymentMethod.value = value ?? false;
  }
}
