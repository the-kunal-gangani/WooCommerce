import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isAvailable = true,
    this.badge,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isAvailable;
  final String? badge;
}

class PaymentMethodsController extends GetxController {
  static const String _storageKey = 'preferred_payment_method';

  final GetStorage _storage = GetStorage();

  final RxBool isLoading = false.obs;
  final RxString selectedMethodId = 'online'.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PaymentMethodOption> paymentMethods = <PaymentMethodOption>[
    const PaymentMethodOption(
      id: 'online',
      title: 'Online Payment',
      description: 'Pay online using the options available at checkout.',
      icon: Icons.account_balance_wallet_outlined,
      badge: 'Recommended',
    ),
    const PaymentMethodOption(
      id: 'cod',
      title: 'Cash on Delivery',
      description: 'Pay when your order arrives, if supported.',
      icon: Icons.local_shipping_outlined,
    ),
  ].obs;

  PaymentMethodOption? get selectedMethod {
    for (final method in paymentMethods) {
      if (method.id == selectedMethodId.value) {
        return method;
      }
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _restoreSelectedMethod();
  }

  void _restoreSelectedMethod() {
    final savedMethod = _storage.read<String>(_storageKey);

    if (savedMethod != null &&
        paymentMethods.any(
          (method) => method.id == savedMethod && method.isAvailable,
        )) {
      selectedMethodId.value = savedMethod;
    }
  }

  Future<void> selectMethod(PaymentMethodOption method) async {
    if (!method.isAvailable) {
      Get.snackbar(
        'Unavailable',
        '${method.title} is currently unavailable.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _storage.write(_storageKey, method.id);
      selectedMethodId.value = method.id;

      Get.snackbar(
        'Payment preference saved',
        '${method.title} saved as your preferred option.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Unable to save',
        'Your payment preference could not be saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void retry() {
    errorMessage.value = '';
  }
}
