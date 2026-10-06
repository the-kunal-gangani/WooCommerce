import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class FavouriteController extends GetxController {
  FavouriteController(this._storageService);

  final StorageService _storageService;

  static const String _storageKey = 'favourite_products';

  final favourites = <Product>[].obs;

  final isLoading = false.obs;

  int get count => favourites.length;

  bool get isEmpty => favourites.isEmpty;

  @override
  void onInit() {
    super.onInit();
    loadFavourites();
  }

  /// Returns true if the product is already in favourites.
  bool isFavourite(int productId) {
    return favourites.any((product) => product.id == productId);
  }

  /// Add a product to favourites.
  Future<void> addFavourite(Product product) async {
    if (isFavourite(product.id)) {
      return;
    }

    favourites.insert(0, product);

    await _saveFavourites();
  }

  /// Remove a product from favourites.
  Future<void> removeFavourite(int productId) async {
    favourites.removeWhere((product) => product.id == productId);

    await _saveFavourites();
  }

  /// Toggle favourite state.
  Future<void> toggleFavourite(Product product) async {
    if (isFavourite(product.id)) {
      await removeFavourite(product.id);
    } else {
      await addFavourite(product);
    }
  }

  /// Remove all favourites.
  Future<void> clearFavourites() async {
    favourites.clear();

    await _storageService.remove(_storageKey);
  }

  /// Load favourites from GetStorage.
  Future<void> loadFavourites() async {
    try {
      isLoading.value = true;

      final stored = _storageService.read<List<dynamic>>(_storageKey);

      if (stored == null || stored.isEmpty) {
        favourites.clear();
        return;
      }

      final loaded = <Product>[];

      for (final item in stored) {
        if (item is! Map) {
          continue;
        }

        try {
          final json = Map<String, dynamic>.from(item);

          loaded.add(Product.fromJson(json));
        } catch (_) {
          // Ignore invalid favourite entries.
        }
      }

      favourites.assignAll(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  /// Save favourites to GetStorage.
  Future<void> _saveFavourites() async {
    final data = favourites.map(_productToJson).toList();

    await _storageService.write(_storageKey, data);
  }

  /// Convert Product into JSON that Product.fromJson()
  /// can read back later.
  Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'parent': product.parent,
      'name': product.name,
      'slug': product.slug,
      'type': product.type,
      'permalink': product.permalink,
      'sku': product.sku,
      'short_description': product.shortDescription,
      'description': product.description,

      'on_sale': product.onSale,

      'prices': {
        'price': product.prices.price,
        'regular_price': product.prices.regularPrice,
        'sale_price': product.prices.salePrice,
        'currency_code': product.prices.currencyCode,
        'currency_symbol': product.prices.currencySymbol,
        'currency_minor_unit': product.prices.minorUnit,
        'currency_decimal_separator': product.prices.decimalSeparator,
        'currency_thousand_separator': product.prices.thousandSeparator,
        'currency_prefix': product.prices.prefix,
        'currency_suffix': product.prices.suffix,

        if (product.prices.range != null)
          'price_range': {
            'min_amount': product.prices.range!.min,
            'max_amount': product.prices.range!.max,
          },
      },

      'average_rating': product.averageRating,
      'review_count': product.reviewCount,

      'images': product.images.map((image) {
        return {
          'id': image.id,
          'src': image.src,
          'thumbnail': image.thumbnail,
          'name': image.name,
          'alt': image.alt,
        };
      }).toList(),

      'categories': product.categories.map((category) {
        return {
          'id': category.id,
          'name': category.name,
          'slug': category.slug,
          'parent': category.parent,
          'description': category.description,
          'count': category.count,
          'permalink': category.permalink,

          if (category.image != null)
            'image': {
              'id': category.image!.id,
              'src': category.image!.src,
              'thumbnail': category.image!.thumbnail,
              'name': category.image!.name,
              'alt': category.image!.alt,
            },
        };
      }).toList(),

      'tags': product.tags.map((tag) {
        return {'id': tag.id, 'name': tag.name, 'slug': tag.slug};
      }).toList(),

      'attributes': product.attributes.map((attribute) {
        return {
          'id': attribute.id,
          'name': attribute.name,
          'taxonomy': attribute.taxonomy,
          'has_variations': attribute.hasVariations,
          'terms': attribute.terms.map((term) {
            return {'id': term.id, 'name': term.name, 'slug': term.slug};
          }).toList(),
        };
      }).toList(),

      'variations': product.variations.map((variation) {
        return {
          'id': variation.id,
          'attributes': variation.attributes.map((attribute) {
            return {'name': attribute.name, 'value': attribute.value};
          }).toList(),
        };
      }).toList(),

      'has_options': product.hasOptions,
      'is_purchasable': product.isPurchasable,
      'is_in_stock': product.isInStock,
      'is_on_backorder': product.isOnBackorder,
      'low_stock_remaining': product.lowStockRemaining,
      'sold_individually': product.soldIndividually,

      'add_to_cart': {
        'minimum': product.addToCart.minimum,
        'maximum': product.addToCart.maximum,
        'multiple_of': product.addToCart.multipleOf,
      },
    };
  }
}
