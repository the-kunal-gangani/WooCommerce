import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/order_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingController extends GetxController {
  OrderTrackingController(this._orderService);
  final OrderService _orderService;
  final order = Rxn<StoreOrder>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  int orderId = 0;
  bool get hasShipmentDate =>
      order.value?.tracking.any((item) => item.shippedAt != null) ?? false;
  DateTime? get shipmentDate {
    for (final item in order.value?.tracking ?? <OrderTracking>[]) {
      if (item.shippedAt != null) return item.shippedAt;
    }
    return null;
  }

  bool get isCompleted => order.value?.status == OrderStatus.completed;
  bool get isCancelled => order.value?.status.isNegative ?? false;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is int) {
      orderId = arguments;
    } else if (arguments is Map) {
      orderId = int.tryParse('${arguments['orderId'] ?? ''}') ?? 0;
    }
    if (orderId <= 0) {
      errorMessage.value = 'Invalid order ID.';
      isLoading.value = false;
      return;
    }
    loadOrder();
  }

  Future<void> loadOrder() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      order.value = await _orderService.fetchOrder(orderId);
    } on ApiException catch (e) {
      errorMessage.value = e.type == ApiErrorType.notFound
          ? 'We could not find this order.'
          : e.message;
    } catch (_) {
      errorMessage.value = 'Unable to load tracking details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrder() => loadOrder();

  Future<void> copyTracking(String number) async {
    if (number.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: number));
    Get.snackbar(
      'Copied',
      'Tracking number copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> openTracking(String link) async {
    final uri = Uri.tryParse(link.trim());
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      Get.snackbar(
        'Tracking unavailable',
        'The tracking link is invalid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        Get.snackbar(
          'Tracking unavailable',
          'Could not open the carrier tracking page.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Tracking unavailable',
        'Could not open the carrier tracking page.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
