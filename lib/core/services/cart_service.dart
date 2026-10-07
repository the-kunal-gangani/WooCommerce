import 'dart:math';

import 'package:get/get.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../network/api_exception.dart';
import '../services/product_services.dart';
import '../services/storage_services.dart';
import '../utils/logger.dart';

class CartService extends GetxService {
  CartService(this._storage, this._productService);

  final StorageService _storage;
  final ProductService _productService;

  static const String _storageKey = 'cart_items';

  final items = <CartItem>[].obs;
  bool _isRefreshing = false;
  bool get isEmpty => items.isEmpty;
  bool get hasItems => items.isNotEmpty;

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  int get subtotalMinor {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  double get subtotal {
    if (items.isEmpty) return 0;
    final minorUnit = items.first.minorUnit;
    final divisor = pow(10, minorUnit);
    return subtotalMinor / divisor;
  }

  bool get isRefreshing => _isRefreshing;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  /// Compatibility method for AddToCartController.
  ///
  /// This allows the controller to do:
  ///
  ///   cart.addProduct(
  ///     product,
  ///     quantity: 2,
  ///     variationId: 123,
  ///   );
  ///
  /// For a variation, the latest variation data is fetched from WooCommerce
  /// before creating the CartItem.
  Future<bool> addProduct(
    Product product, {
    int quantity = 1,
    int? variationId,
    Map<String, String> variationSelections = const {},
  }) async {
    if (quantity <= 0) {
      return false;
    }

    Product activeProduct = product;

    // -----------------------------------------------------------------------
    // Resolve variation
    // -----------------------------------------------------------------------

    if (variationId != null) {
      try {
        final variations = await _productService.fetchVariations(product.id);

        final variation = variations.firstWhereOrNull(
          (item) => item.id == variationId,
        );
        if (variation == null) {
          printLog(
            'Cart: variation $variationId not found for product ${product.id}',
          );
          return false;
        }
        activeProduct = variation;
      } on ApiException catch (e) {
        printLog('Cart: failed to load variation $variationId: ${e.message}');
        return false;
      }
    }
    if (!activeProduct.canBuy) {
      return false;
    }
    final rules = product.addToCart;
    var finalQuantity = quantity;
    if (product.soldIndividually) {
      finalQuantity = 1;
    }
    finalQuantity = max(rules.minimum, finalQuantity);
    finalQuantity = min(rules.maximum, finalQuantity);
    final step = max(1, rules.multipleOf);
    if (step > 1) {
      finalQuantity = (finalQuantity ~/ step) * step;
      if (finalQuantity < rules.minimum) {
        finalQuantity = rules.minimum;
      }
    }
    final cartItem = CartItem(
      productId: product.id,
      variationId: variationId,
      name: product.name,
      price: activeProduct.prices.price,
      quantity: finalQuantity,
      imageUrl: activeProduct.imageUrl ?? product.imageUrl,
      sku: activeProduct.sku.isNotEmpty ? activeProduct.sku : product.sku,
      variationSelections: Map<String, String>.from(variationSelections),
      currencySymbol: activeProduct.prices.currencySymbol,
      minorUnit: activeProduct.prices.minorUnit,
    );
    await addItem(item: cartItem);
    return true;
  }

  Future<void> addItem({required CartItem item}) async {
    final index = items.indexWhere(
      (existing) => existing.lineKey == item.lineKey,
    );
    if (index == -1) {
      items.add(item);
    } else {
      final existing = items[index];
      final newQuantity = existing.quantity + item.quantity;
      items[index] = existing.copyWith(quantity: newQuantity);
    }
    await _persist();
    printLog(
      'Cart: added ${item.name}, '
      'quantity=${item.quantity}, '
      'cartItems=${items.length}',
    );
  }

  Future<void> increaseQuantity(
    CartItem item, {
    int maximum = 9999,
    int multipleOf = 1,
  }) async {
    final index = _indexOf(item);
    if (index == -1) return;
    final current = items[index];
    final step = max(1, multipleOf);
    final newQuantity = min(maximum, current.quantity + step);
    if (newQuantity == current.quantity) {
      return;
    }
    items[index] = current.copyWith(quantity: newQuantity);
    await _persist();
  }

  Future<void> decreaseQuantity(
    CartItem item, {
    int minimum = 1,
    int multipleOf = 1,
  }) async {
    final index = _indexOf(item);
    if (index == -1) return;
    final current = items[index];
    final step = max(1, multipleOf);
    final newQuantity = max(minimum, current.quantity - step);
    if (newQuantity == current.quantity) {
      return;
    }
    items[index] = current.copyWith(quantity: newQuantity);
    await _persist();
  }

  Future<void> setQuantity(
    CartItem item,
    int quantity, {
    int minimum = 1,
    int maximum = 9999,
    int multipleOf = 1,
  }) async {
    final index = _indexOf(item);
    if (index == -1) return;
    if (quantity <= 0) {
      await removeItem(item);
      return;
    }
    final step = max(1, multipleOf);
    var newQuantity = quantity;
    newQuantity = max(minimum, newQuantity);
    newQuantity = min(maximum, newQuantity);
    if (step > 1) {
      newQuantity = (newQuantity ~/ step) * step;
      if (newQuantity < minimum) {
        newQuantity = minimum;
      }
    }
    items[index] = items[index].copyWith(quantity: newQuantity);
    await _persist();
  }

  Future<void> removeItem(CartItem item) async {
    items.removeWhere((existing) => existing.lineKey == item.lineKey);
    await _persist();
    printLog('Cart: removed ${item.name}');
  }

  Future<void> clearCart() async {
    items.clear();
    await _persist();
    printLog('Cart: cleared');
  }

  /// Similar to FluxStore's refreshCartProducts().
  ///
  /// It makes sure that:
  /// - deleted products are removed
  /// - current prices are used
  /// - current images are used
  /// - current SKU is used
  /// - current stock is checked
  /// - variations are refreshed
  ///
  /// One failed product does not destroy the entire cart.
  Future<void> refreshCartProducts() async {
    if (_isRefreshing || items.isEmpty) {
      return;
    }
    _isRefreshing = true;
    try {
      final snapshot = List<CartItem>.from(items);
      final variationParentIds = snapshot
          .where((item) => item.variationId != null)
          .map((item) => item.productId)
          .toSet();
      final variationMap = <int, List<Product>>{};
      for (final productId in variationParentIds) {
        try {
          final variations = await _productService.fetchVariations(productId);
          variationMap[productId] = variations;
        } on ApiException catch (e) {
          printLog(
            'Cart: failed to refresh variations '
            'for product $productId: ${e.message}',
          );
        } catch (e) {
          printLog(
            'Cart: unexpected variation refresh error '
            'for product $productId: $e',
          );
        }
      }
      for (final item in snapshot) {
        try {
          final product = await _productService.fetchProduct(item.productId);
          if (item.variationId == null) {
            if (!product.canBuy) {
              printLog(
                'Cart: removing unavailable product '
                '${item.productId}',
              );
              await removeItem(item);
              continue;
            }
            final updatedItem = item.copyWith(
              name: product.name,
              price: product.prices.price,
              imageUrl: product.imageUrl,
              sku: product.sku,
              currencySymbol: product.prices.currencySymbol,
              minorUnit: product.prices.minorUnit,
            );
            _replaceItem(item, updatedItem);
            continue;
          }
          final variation = variationMap[item.productId]?.firstWhereOrNull(
            (variation) => variation.id == item.variationId,
          );
          if (variation == null) {
            printLog(
              'Cart: removing missing variation '
              '${item.variationId}',
            );
            await removeItem(item);
            continue;
          }
          if (!variation.canBuy) {
            printLog(
              'Cart: removing unavailable variation '
              '${item.variationId}',
            );
            await removeItem(item);
            continue;
          }
          final updatedItem = item.copyWith(
            name: product.name,
            price: variation.prices.price,
            imageUrl: variation.imageUrl ?? product.imageUrl,
            sku: variation.sku.isNotEmpty ? variation.sku : product.sku,
            currencySymbol: variation.prices.currencySymbol,
            minorUnit: variation.prices.minorUnit,
          );
          _replaceItem(item, updatedItem);
        } on ApiException catch (e) {
          // ---------------------------------------------------------------
          // Important:
          // Do NOT remove the item just because the refresh failed.
          // This follows the FluxStore behavior of keeping the cart usable.
          // ---------------------------------------------------------------

          printLog(
            'Cart: failed to refresh ${item.productId}: '
            '${e.message}',
          );
        } catch (e) {
          printLog(
            'Cart: unexpected refresh error '
            '${item.productId}: $e',
          );
        }
      }
      await _persist();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<String?> validateCart() async {
    if (items.isEmpty) {
      return 'Your cart is empty.';
    }
    await refreshCartProducts();
    if (items.isEmpty) {
      return 'Your cart is empty.';
    }
    return null;
  }

  int _indexOf(CartItem item) {
    return items.indexWhere((existing) => existing.lineKey == item.lineKey);
  }

  void _replaceItem(CartItem oldItem, CartItem newItem) {
    final index = _indexOf(oldItem);
    if (index == -1) return;
    items[index] = newItem;
  }

  void _loadCart() {
    try {
      final raw = _storage.read<dynamic>(_storageKey);
      if (raw is! List) {
        return;
      }
      final loaded = <CartItem>[];
      for (final value in raw) {
        if (value is Map) {
          try {
            loaded.add(CartItem.fromJson(Map<String, dynamic>.from(value)));
          } catch (e) {
            printLog('Cart: failed to restore item: $e');
          }
        }
      }
      items.assignAll(loaded);
      printLog('Cart: restored ${items.length} items');
    } catch (e) {
      printLog('Cart: failed to load cart: $e');
    }
  }

  Future<void> _persist() async {
    await _storage.write(
      _storageKey,
      items.map((item) => item.toJson()).toList(),
    );
  }
}
