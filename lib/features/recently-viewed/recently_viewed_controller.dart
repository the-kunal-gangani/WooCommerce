import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/recently_viewed_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class RecentlyViewedController extends GetxController {
  RecentlyViewedController(this._recentlyViewedService);

  final RecentlyViewedService _recentlyViewedService;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentlyViewed();
  }

  Future<void> loadRecentlyViewed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final List<Product> result = _recentlyViewedService.getRecentlyViewed();
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Unable to load recently viewed products.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearRecentlyViewed() async {
    try {
      await _recentlyViewedService.clearRecentlyViewed();
      products.clear();
      errorMessage.value = '';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not clear recently viewed products.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
