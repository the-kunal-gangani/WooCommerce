import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_attribute.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_image.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController(this._service);

  final ProductService _service;

  final product = Rxn<Product>();
  final variations = <int, Product>{}.obs;
  final selection = <String, String>{}.obs;
  final selectedImageIndex = 0.obs;
  final quantity = 1.obs;
  final isFavorite = false.obs;
  final errorMessage = RxnString();

  /// Products shown in "You might also like".
  final relatedProducts = <Product>[].obs;

  int _productId = 0;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

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

      // Load products belonging to the same category.
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

    if (current.categories.isEmpty) {
      return;
    }

    try {
      final categoryId = current.categories.first.id;

      final result = await _service.fetchProducts(
        page: 1,
        perPage: 7,
        category: categoryId.toString(),
      );

      final products = result.items
          .where((item) => item.id != current.id)
          .take(6)
          .toList();

      relatedProducts.assignAll(products);

      printLog(
        'related products loaded for category '
        '$categoryId: ${relatedProducts.length}',
      );
    } on ApiException catch (e) {
      printLog('related products failed: $e');

      relatedProducts.clear();
    } catch (e) {
      printLog('related products unexpected error: $e');

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
  }

  void incrementQuantity() {
    final max = product.value?.addToCart.maximum ?? 9999;

    if (quantity.value < max) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    final min = product.value?.addToCart.minimum ?? 1;

    if (quantity.value > min) {
      quantity.value--;
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void addToCart() {
    final p = product.value;

    if (p == null) {
      return;
    }

    if (p.isVariable) {
      final missing = variationAttributes.firstWhereOrNull(
        (a) => !selection.containsKey(a.name),
      );

      if (missing != null) {
        Get.snackbar('Select an option', 'Please choose ${missing.name}');
        return;
      }

      if (selectedVariation == null) {
        Get.snackbar('Unavailable', 'This combination is not available');
        return;
      }
    }

    Get.snackbar(
      'Added to Cart',
      'Item successfully added to your shopping cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
}
