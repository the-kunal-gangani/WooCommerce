import 'package:get/get.dart';

import '../../data/models/product.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'product_services.dart';

class WishlistService extends GetxService {
  WishlistService(this._api, this._productService);

  final ApiClient _api;
  final ProductService _productService;

  final RxList<Product> products = <Product>[].obs;
  final RxSet<int> productIds = <int>{}.obs;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int get count => productIds.length;
  bool get isEmpty => productIds.isEmpty;

  bool contains(int productId) => productIds.contains(productId);

  /// Loads saved IDs from WordPress, then fetches current product details.
  Future<void> loadWishlist() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final response = await _api.get<dynamic>('wishlist');
      final data = response.data;

      if (data is! Map) {
        throw const FormatException('Invalid wishlist response.');
      }

      final rawIds = data['product_ids'];
      if (rawIds is! List) {
        throw const FormatException('Wishlist product IDs are missing.');
      }

      final ids = rawIds
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
        } on ApiException catch (e) {
          // Keep the saved ID if product details temporarily cannot load.
          // This prevents a temporary API error from deleting wishlist data.
          print('Wishlist: unable to load product $id: ${e.message}');
        } catch (e) {
          print('Wishlist: unexpected error loading product $id: $e');
        }
      }

      products.assignAll(loadedProducts);
    } finally {
      _isLoading = false;
    }
  }

  /// Adds a product on the server before updating the local state.
  Future<void> addProduct(Product product) async {
    if (productIds.contains(product.id)) return;

    final response = await _api.post<dynamic>(
      'wishlist/items',
      data: {'product_id': product.id},
    );

    _applyResponse(response.data);

    if (!products.any((item) => item.id == product.id)) {
      products.add(product);
    }
  }

  /// Removes a product on the server before updating the local state.
  Future<void> removeProduct(int productId) async {
    final response = await _api.delete<dynamic>('wishlist/items/$productId');

    _applyResponse(response.data);

    products.removeWhere((product) => product.id == productId);
  }

  Future<void> clearWishlist() async {
    final response = await _api.delete<dynamic>('wishlist');

    _applyResponse(response.data);
    products.clear();
  }

  void _applyResponse(dynamic response) {
    if (response is! Map || response['product_ids'] is! List) {
      throw const FormatException('Invalid wishlist API response.');
    }

    final ids = (response['product_ids'] as List)
        .map((value) => int.tryParse(value.toString()))
        .whereType<int>()
        .where((id) => id > 0)
        .toSet();

    productIds.assignAll(ids);
  }
}
