import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class RecentlyViewedService {
  RecentlyViewedService(this._storage);

  final GetStorage _storage;
  static const String _storageKey = 'recently_viewed_products';
  static const int _maxProducts = 10;

  List<Product> getRecentlyViewed() {
    final stored = _storage.read<List<dynamic>>(_storageKey);
    if (stored == null) return [];
    final products = <Product>[];
    for (final item in stored) {
      try {
        if (item is Map) {
          products.add(Product.fromJson(Map<String, dynamic>.from(item)));
        } else if (item is String) {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            products.add(Product.fromJson(decoded));
          }
        }
      } catch (_) {
        // Ignore malformed entries instead of breaking the Home screen.
      }
    }

    return products;
  }

  Future<void> clearRecentlyViewed() async {
    await _storage.remove(_storageKey);
  }

  Future<void> addProduct(Product product) async {
    final products = getRecentlyViewed();
    products.removeWhere((item) => item.id == product.id);
    products.insert(0, product);
    final limitedProducts = products.take(_maxProducts).toList();
    await _storage.write(
      _storageKey,
      limitedProducts.map(_toStorageJson).toList(),
    );
  }

  Map<String, dynamic> _toStorageJson(Product product) {
    throw UnimplementedError(
      'Add a matching Product JSON serializer before saving products.',
    );
  }
}
