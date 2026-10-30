import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter/widgets.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/wishlist_service.dart';
import '../../data/models/product.dart';

class WishlistController extends GetxController {
  WishlistController(
    this._wishlistService,
    this._authService,
    this._cartService,
  );

  final WishlistService _wishlistService;
  final AuthService _authService;
  final CartService _cartService;

  final isLoading = false.obs;
  final isMutating = <int>{}.obs;
  final errorMessage = RxnString();

  List<Product> get products => _wishlistService.products;
  int get count => _wishlistService.count;
  bool contains(int productId) => _wishlistService.contains(productId);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        loadWishlist();
      }
    });
  }

  Future<void> loadWishlist() async {
    if (!_requireLogin()) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _wishlistService.loadWishlist();
    } catch (e) {
      errorMessage.value = 'Unable to load your wishlist. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct(Product product) async {
    if (!_requireLogin()) return;
    if (contains(product.id) || isMutating.contains(product.id)) return;

    isMutating.add(product.id);

    try {
      await _wishlistService.addProduct(product);
      _showMessage('Added to wishlist', product.name);
    } catch (e) {
      _showMessage(
        'Could not save product',
        'Please check your connection and try again.',
      );
    } finally {
      isMutating.remove(product.id);
    }
  }

  Future<void> removeProduct(Product product) async {
    if (!_requireLogin()) return;
    if (isMutating.contains(product.id)) return;
    isMutating.add(product.id);
    try {
      await _wishlistService.removeProduct(product.id);
      _showMessage('Removed from wishlist', product.name);
    } catch (e) {
      _showMessage('Could not remove product', 'Please try again.');
    } finally {
      isMutating.remove(product.id);
    }
  }

  Future<void> clearWishlist() async {
    if (!_requireLogin()) return;
    if (products.isEmpty) return;
    final confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Clear wishlist?'),
            content: const Text(
              'All saved products will be removed from your wishlist.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Keep items'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Clear wishlist'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    isLoading.value = true;
    try {
      await _wishlistService.clearWishlist();
      _showMessage('Wishlist cleared', 'Your saved products were removed.');
    } catch (e) {
      _showMessage('Could not clear wishlist', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(Product product) async {
    if (!_requireLogin()) return;
    if (!product.canBuy) {
      _showMessage(
        'Product unavailable',
        'This product cannot currently be added to your cart.',
      );
      return;
    }

    try {
      final added = await _cartService.addProduct(product);

      if (added) {
        _showMessage('Added to cart', product.name);
      } else {
        _showMessage(
          'Could not add to cart',
          'Check product availability and any required variations.',
        );
      }
    } catch (e) {
      _showMessage('Could not add to cart', 'Please try again.');
    }
  }

  void openProduct(Product product) {
    Get.toNamed(AppRoutes.productDetails, arguments: product);
  }

  bool _requireLogin() {
    if (_authService.isLoggedIn) return true;

    Get.snackbar(
      'Sign in required',
      'Sign in to access your synchronized wishlist.',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.login),
        child: const Text('Sign in'),
      ),
    );

    return false;
  }

  void _showMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
