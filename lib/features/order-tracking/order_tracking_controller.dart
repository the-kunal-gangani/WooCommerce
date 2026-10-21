import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/order_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';

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
    final tracking = order.value?.tracking ?? [];

    for (final item in tracking) {
      if (item.shippedAt != null) {
        return item.shippedAt;
      }
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
    } catch (_) {
      errorMessage.value = 'Unable to load tracking details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrder() => loadOrder();
}
