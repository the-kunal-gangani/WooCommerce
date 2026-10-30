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
  static const String _productCacheKey = 'smart_wishlist_product_cache';

  final RxList<Product> products = <Product>[].obs;
  final RxSet<int> productIds = <int>{}.obs;

  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  int get count => productIds.length;
  bool get isEmpty => productIds.isEmpty;

  bool contains(int productId) => productIds.contains(productId);

  /// Loads saved IDs and cached product details first.
  /// Cached products remain available if the network is unavailable.
  /// Call refreshWishlist() to explicitly retry fetching product details.
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
      final cachedProducts = _readCachedProducts();
      // Display cached product details immediately.
      products.assignAll(
        ids.map((id) => cachedProducts[id]).whereType<Product>().toList(),
      );
      // Fetch fresh product details without discarding the cached version
      // when a request fails.
      await _refreshProducts(ids, cachedProducts);
      _isInitialized = true;
    } finally {
      _isLoading = false;
    }
  }

  /// Explicitly retries loading details for all saved product IDs.
  Future<void> refreshWishlist() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final storedIds = _storageService.read<List<dynamic>>(_storageKey) ?? [];
      final ids = storedIds
          .map((value) => int.tryParse(value.toString()))
          .whereType<int>()
          .where((id) => id > 0)
          .toSet();
      productIds.assignAll(ids);
      final cachedProducts = _readCachedProducts();
      // Keep cached products visible while refreshing.
      products.assignAll(
        ids.map((id) => cachedProducts[id]).whereType<Product>().toList(),
      );
      await _refreshProducts(ids, cachedProducts);
      _isInitialized = true;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _refreshProducts(
    Set<int> ids,
    Map<int, Product> cachedProducts,
  ) async {
    final refreshedProducts = <int, Product>{};
    // Retain cached details for products that cannot be fetched.
    refreshedProducts.addAll(cachedProducts);
    for (final id in ids) {
      try {
        final product = await _productService.fetchProduct(id);
        if (product.id == id) {
          refreshedProducts[id] = product;
        }
      } catch (e) {
        debugPrint('Wishlist: unable to refresh product $id: $e');
      }
    }
    // Only show products that are actually saved in the wishlist.
    final orderedProducts = ids
        .map((id) => refreshedProducts[id])
        .whereType<Product>()
        .toList();
    products.assignAll(orderedProducts);
    await _persistProductCache();
  }

  Future<void> addProduct(Product product) async {
    await loadWishlist();
    if (product.id <= 0 || productIds.contains(product.id)) return;
    productIds.add(product.id);
    if (!products.any((item) => item.id == product.id)) {
      products.add(product);
    }
    await _persistIds();
    await _persistProductCache();
  }

  Future<void> removeProduct(int productId) async {
    await loadWishlist();
    productIds.remove(productId);
    products.removeWhere((product) => product.id == productId);
    await _persistIds();
    await _persistProductCache();
  }

  Future<void> clearWishlist() async {
    await loadWishlist();
    productIds.clear();
    products.clear();
    await _storageService.remove(_storageKey);
    await _storageService.remove(_productCacheKey);
  }

  Map<int, Product> _readCachedProducts() {
    final cachedData =
        _storageService.read<List<dynamic>>(_productCacheKey) ?? [];
    final result = <int, Product>{};
    for (final entry in cachedData) {
      if (entry is! Map) continue;
      try {
        final json = Map<String, dynamic>.from(entry);
        final product = Product.fromJson(json);
        if (product.id > 0) {
          result[product.id] = product;
        }
      } catch (e) {
        debugPrint('Wishlist: unable to read cached product: $e');
      }
    }
    return result;
  }

  Future<void> _persistIds() async {
    final ids = productIds.toList()..sort();
    await _storageService.write(_storageKey, ids);
  }

  Future<void> _persistProductCache() async {
    final savedIds = productIds;
    final snapshots = products
        .where((product) => savedIds.contains(product.id))
        .map((product) => product.toJson())
        .toList();
    await _storageService.write(_productCacheKey, snapshots);
  }
}
