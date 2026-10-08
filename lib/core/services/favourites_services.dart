import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class FavouriteService extends GetxService {
  FavouriteService(this._storage);

  final StorageService _storage;

  static const String _storageKey = 'favourite_products';

  final favourites = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavourites();
  }

  bool isFavourite(int productId) {
    return favourites.any((product) => product.id == productId);
  }

  Future<void> toggleFavourite(Product product) async {
    if (isFavourite(product.id)) {
      await removeFavourite(product.id);
    } else {
      await addFavourite(product);
    }
  }

  Future<void> addFavourite(Product product) async {
    if (isFavourite(product.id)) return;

    favourites.add(product);
    await _persist();
  }

  Future<void> removeFavourite(int productId) async {
    favourites.removeWhere((product) => product.id == productId);

    await _persist();
  }

  Future<void> clearFavourites() async {
    favourites.clear();
    await _persist();
  }

  Future<void> _loadFavourites() async {
    final data = _storage.read<List<dynamic>>(_storageKey);

    if (data == null || data.isEmpty) return;

    try {
      final products = data
          .map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();

      favourites.assignAll(products);
    } catch (e) {
      favourites.clear();
    }
  }

  Future<void> _persist() async {
    final data = favourites.map(_productToJson).toList();

    await _storage.write(_storageKey, data);
  }

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
        'price_range': product.prices.range,
      },

      'average_rating': product.averageRating,
      'review_count': product.reviewCount,

      'images': product.images
          .map(
            (image) => {
              'id': image.id,
              'src': image.src,
              'thumbnail': image.thumbnail,
              'name': image.name,
              'alt': image.alt,
            },
          )
          .toList(),

      'categories': product.categories
          .map(
            (category) => {
              'id': category.id,
              'name': category.name,
              'slug': category.slug,
              'link': category.permalink,
            },
          )
          .toList(),

      'tags': product.tags
          .map((tag) => {'id': tag.id, 'name': tag.name, 'slug': tag.slug})
          .toList(),

      'attributes': product.attributes
          .map(
            (attribute) => {
              'id': attribute.id,
              'name': attribute.name,
              'taxonomy': attribute.taxonomy,
              'has_variations': attribute.hasVariations,
              'terms': attribute.terms
                  .map(
                    (term) => {
                      'id': term.id,
                      'name': term.name,
                      'slug': term.slug,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),

      'variations': product.variations
          .map(
            (variation) => {
              'id': variation.id,
              'attributes': variation.attributes
                  .map(
                    (attribute) => {
                      'name': attribute.name,
                      'value': attribute.value,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),

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
