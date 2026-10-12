import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/order_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsController extends GetxController {
  OrderDetailsController(this._service, Object? arguments)
    : _arguments = arguments;

  final OrderService _service;
  final Object? _arguments;

  final order = Rxn<StoreOrder>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  int _orderId = 0;

  @override
  void onInit() {
    super.onInit();
    final args = _arguments;
    if (args is StoreOrder) {
      order.value = args;
      _orderId = args.id;
    } else if (args is int) {
      _orderId = args;
    } else {
      errorMessage.value = 'We could not find this order.';
      return;
    }
    _load();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      order.value = await _service.fetchOrder(_orderId);
    } on ApiException catch (e) {
      if (order.value == null) {
        errorMessage.value = e.type == ApiErrorType.notFound
            ? 'We could not find this order.'
            : e.message;
      } else {
        Get.snackbar(
          'Showing limited details',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> copyTracking(String number) async {
    await Clipboard.setData(ClipboardData(text: number));
    Get.snackbar(
      'Copied',
      'Tracking number copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> openTracking(String link) async {
    final uri = Uri.tryParse(link);
    final valid =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    if (!valid) {
      Get.snackbar(
        'Tracking unavailable',
        'The tracking link is not valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar(
        'Tracking unavailable',
        'Could not open the tracking page.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
