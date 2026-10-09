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
    if (stored == null) {
      return [];
    }
    return stored.map(_fromStorageJson).whereType<Product>().toList();
  }

  Future<void> addProduct(Product product) async {
    final products = getRecentlyViewed();
    products.removeWhere((item) => item.id == product.id);
    products.insert(0, product);
    await _storage.write(
      _storageKey,
      products.take(_maxProducts).map((item) => item.toJson()).toList(),
    );
  }

  Future<void> clearRecentlyViewed() async {
    await _storage.remove(_storageKey);
  }

  Product? _fromStorageJson(dynamic item) {
    try {
      if (item is String) {
        final decoded = jsonDecode(item);
        return Product.fromJson(Map<String, dynamic>.from(decoded as Map));
      }
      return Product.fromJson(Map<String, dynamic>.from(item as Map));
    } catch (_) {
      return null;
    }
  }
}
