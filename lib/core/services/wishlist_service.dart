import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';

import '../../data/models/product.dart';
import 'product_services.dart';

class WishlistService extends GetxService {
  WishlistService(this._productService, this._storageService);

  final ProductService _productService;
  final StorageService _storageService;

  static const String _storageKey = 'smart_wishlist_product_ids';

  final RxList<Product> products = <Product>[].obs;
  final RxSet<int> productIds = <int>{}.obs;

  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  int get count => productIds.length;
  bool get isEmpty => productIds.isEmpty;

  bool contains(int productId) => productIds.contains(productId);

  Future<void> loadWishlist() async {
    if (_isLoading || _isInitialized) return;

    _isLoading = true;

    try {
      final storedIds = _storageService.read<List<dynamic>>(_storageKey) ?? [];

      final ids = storedIds
          .map((value) => int.tryParse(value.toString()))
          .whereType<int>()
          .where((id) => id > 0)
          .toSet();

      productIds.assignAll(ids);

      final loadedProducts = <Product>[];

      for (final id in ids) {
        try {
          final product = await _productService.fetchProduct(id);
          loadedProducts.add(product);
        } catch (e) {
          // Retain the saved ID if product details cannot be fetched.
          debugPrint('Wishlist: unable to load product $id: $e');
        }
      }

      products.assignAll(loadedProducts);
      _isInitialized = true;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addProduct(Product product) async {
    await loadWishlist();

    if (productIds.contains(product.id)) return;

    productIds.add(product.id);

    if (!products.any((item) => item.id == product.id)) {
      products.add(product);
    }

    await _persistIds();
  }

  Future<void> removeProduct(int productId) async {
    await loadWishlist();

    productIds.remove(productId);
    products.removeWhere((product) => product.id == productId);

    await _persistIds();
  }

  Future<void> clearWishlist() async {
    await loadWishlist();

    productIds.clear();
    products.clear();

    await _storageService.remove(_storageKey);
  }

  Future<void> _persistIds() async {
    final ids = productIds.toList()..sort();
    await _storageService.write(_storageKey, ids);
  }
}
