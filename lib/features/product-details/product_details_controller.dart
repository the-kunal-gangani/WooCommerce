import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';
import 'package:magna_data_ai_ecommerce/data/models/cart_item.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_attribute.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_image.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController(this._service, this._cart, [Object? arguments])
    : _arguments = arguments;

  final ProductService _service;
  final CartService _cart;
  final Object? _arguments;

  final product = Rxn<Product>();
  final variations = <int, Product>{}.obs;
  final selection = <String, String>{}.obs;
  final selectedImageIndex = 0.obs;
  final quantity = 1.obs;
  final isFavorite = false.obs;
  final errorMessage = RxnString();
  final relatedProducts = <Product>[].obs;
  int _productId = 0;

  @override
  void onInit() {
    super.onInit();
    final args = _arguments;
    if (args is Product) {
      product.value = args;
      _productId = args.id;
      quantity.value = args.addToCart.minimum;
    } else if (args is int) {
      _productId = args;
    } else {
      errorMessage.value = 'Product not found.';
      return;
    }
    _load();
  }

  Future<void> reload() {
    errorMessage.value = null;
    return _load();
  }

  Future<void> _load() async {
    try {
      final fresh = await _service.fetchProduct(_productId);
      product.value = fresh;
      if (quantity.value < fresh.addToCart.minimum) {
        quantity.value = fresh.addToCart.minimum;
      }
      await loadRelatedProducts(fresh);
    } on ApiException catch (e) {
      if (product.value == null) {
        errorMessage.value = e.message;
      }
    }
    final current = product.value;
    if (current != null && current.isVariable) {
      await _loadVariations(current.id);
    }
  }

  /// Loads products from the same category as [current].
  ///
  /// The current product itself is excluded from the results.
  /// Maximum 6 products are displayed.
  Future<void> loadRelatedProducts(Product current) async {
    relatedProducts.clear();
    final categoryIds = current.categories
        .where((c) => c.slug != 'uncategorized')
        .map((c) => c.id)
        .toSet();
    if (categoryIds.isEmpty) return;
    try {
      final result = await _service.fetchProducts(
        page: 1,
        perPage: 13,
        category: categoryIds.join(','),
      );
      final products = result.items
          .where((product) => product.id != current.id)
          .take(12)
          .toList();
      relatedProducts.assignAll(products);
      printLog('Current: ${current.name} (${current.id})');
      printLog(
        'Related: ${products.map((p) => '${p.name} (${p.id})').join(', ')}',
      );
    } on ApiException catch (e) {
      printLog('related products failed: $e');
      relatedProducts.clear();
    }
  }

  Future<void> _loadVariations(int parentId) async {
    try {
      final list = await _service.fetchVariations(parentId);
      variations.assignAll({for (final v in list) v.id: v});
      printLog('variations loaded for $parentId: ${list.length}');
    } on ApiException catch (e) {
      printLog('variations failed for $parentId: $e');
    }
  }

  List<ProductAttribute> get variationAttributes {
    final p = product.value;
    if (p == null) {
      return const [];
    }
    return p.attributes.where((a) => a.hasVariations).toList();
  }

  bool get isSelectionComplete {
    final attributes = variationAttributes;
    return attributes.isNotEmpty &&
        attributes.every((a) => selection.containsKey(a.name));
  }

  Product? get selectedVariation {
    final p = product.value;
    if (p == null || !p.isVariable || !isSelectionComplete) {
      return null;
    }
    final ref = p.variations.firstWhereOrNull((v) => v.matches(selection));
    if (ref == null) {
      return null;
    }
    return variations[ref.id];
  }

  Product? get activeProduct => selectedVariation ?? product.value;

  List<ProductImage> get images {
    final variation = selectedVariation;
    if (variation != null && variation.images.isNotEmpty) {
      return variation.images;
    }
    return product.value?.images ?? const [];
  }

  String get unitPriceLabel => activeProduct?.priceLabel ?? '';

  int get unitPriceMinor {
    final active = activeProduct;
    if (active == null) {
      return 0;
    }
    return active.prices.range?.min ?? active.prices.price;
  }

  String get totalLabel {
    final p = product.value;
    if (p == null) {
      return '';
    }
    return p.prices.format(unitPriceMinor * quantity.value);
  }

  bool get canBuy => activeProduct?.canBuy ?? false;

  String get stockLabel {
    final active = activeProduct;
    if (active == null) {
      return '';
    }
    if (active.isOnBackorder) {
      return 'Available on backorder';
    }
    if (!active.isInStock) {
      return 'Out of stock';
    }
    if (active.isLowStock) {
      return 'Only ${active.lowStockRemaining} left';
    }
    return 'In stock';
  }

  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  void selectOption(String attributeName, String termSlug) {
    selection[attributeName] = termSlug;
    selectedImageIndex.value = 0;
    final active = activeProduct;
    if (active == null) return;
    _normalizeQuantity(active);
  }

  void _normalizeQuantity(Product active) {
    final min = active.addToCart.minimum;
    final max = active.addToCart.maximum;
    if (quantity.value < min) {
      quantity.value = min;
    } else if (quantity.value > max) {
      quantity.value = max;
    }
  }

  String get totalPriceLabel {
    final active = activeProduct;
    if (active == null) {
      return '';
    }
    final totalMinor = active.prices.price * quantity.value;
    return active.prices.format(totalMinor);
  }

  void incrementQuantity() {
    quantity.value = quantity.value + 1;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value = quantity.value - 1;
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  Future<void> addToCart() async {
    final p = product.value;
    if (p == null) {
      return;
    }
    final active = activeProduct;
    if (active == null) {
      return;
    }
    if (p.isVariable) {
      final missing = variationAttributes.firstWhereOrNull(
        (attribute) => !selection.containsKey(attribute.name),
      );
      if (missing != null) {
        Get.snackbar(
          'Select an option',
          'Please choose ${missing.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (selectedVariation == null) {
        Get.snackbar(
          'Unavailable',
          'This combination is not available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    if (!active.canBuy) {
      Get.snackbar(
        'Unavailable',
        'This product is currently unavailable.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final cartItem = CartItem(
      productId: p.id,
      variationId: selectedVariation?.id,
      name: p.name,
      price: unitPriceMinor,
      quantity: quantity.value,
      imageUrl: active.imageUrl ?? p.imageUrl,
      sku: active.sku.isNotEmpty ? active.sku : p.sku,
      variationSelections: Map<String, String>.from(selection),
      currencySymbol: active.prices.currencySymbol,
      minorUnit: active.prices.minorUnit,
    );
    await _cart.addItem(item: cartItem);
    Get.snackbar(
      'Added to Cart',
      '${p.name} has been added to your cart.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }
}
