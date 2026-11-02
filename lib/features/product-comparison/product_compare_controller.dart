import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class ProductCompareController extends GetxController {
  ProductCompareController(this._productService, this._storage);

  final ProductService _productService;
  final GetStorage _storage;

  static const String _storageKey = 'product_comparison_ids';
  static const int maxProducts = 2;

  final RxList<int> productIds = <int>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int get count => productIds.length;
  bool get isEmpty => productIds.isEmpty;
  bool get isFull => productIds.length >= maxProducts;
  bool contains(int productId) => productIds.contains(productId);

  @override
  void onInit() {
    super.onInit();
    _restoreSelection();
  }

  void _restoreSelection() {
    final saved = _storage.read<List<dynamic>>(_storageKey) ?? [];
    final ids = saved
        .map((value) => value is int ? value : int.tryParse('$value'))
        .whereType<int>()
        .where((id) => id > 0)
        .toSet()
        .take(maxProducts)
        .toList();
    productIds.assignAll(ids);
  }

  Future<bool> addProduct(Product product) async {
    if (contains(product.id)) {
      Get.snackbar(
        'Already added',
        'This product is already in your comparison.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (isFull) {
      Get.snackbar(
        'Comparison limit reached',
        'You can compare up to $maxProducts products at a time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    productIds.add(product.id);
    products.add(product);
    await _saveSelection();
    Get.snackbar(
      'Added to comparison',
      '${product.name} has been added.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    return true;
  }

  Future<void> removeProduct(int productId) async {
    productIds.remove(productId);
    products.removeWhere((product) => product.id == productId);
    await _saveSelection();
  }

  Future<void> clearComparison() async {
    productIds.clear();
    products.clear();
    await _saveSelection();
  }

  Future<void> _saveSelection() async {
    await _storage.write(_storageKey, productIds.toList());
  }

  Future<void> loadComparisonProducts() async {
    if (productIds.isEmpty) {
      products.clear();
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final ids = List<int>.from(productIds);
      final loadedProducts = <Product>[];
      for (final id in ids) {
        try {
          final product = await _productService.fetchProduct(id);
          loadedProducts.add(product);
        } catch (_) {
          // Keep the remaining products available if one cannot load.
        }
      }
      products.assignAll(loadedProducts);
      if (loadedProducts.isEmpty && ids.isNotEmpty) {
        errorMessage.value = 'Unable to load comparison products.';
      }
    } catch (_) {
      errorMessage.value = 'Unable to load comparison products.';
    } finally {
      isLoading.value = false;
    }
  }
}
