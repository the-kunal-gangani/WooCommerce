import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';

import 'price_info.dart';
import 'product_attribute.dart';
import 'product_category.dart';
import 'product_image.dart';

class ProductTag {
  const ProductTag({required this.id, required this.name, required this.slug});

  final int id;
  final String name;
  final String slug;

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      id: asInt(json['id']),
      name: stripHtml(asString(json['name'])),
      slug: asString(json['slug']),
    );
  }
}

class AddToCartRules {
  const AddToCartRules({
    required this.minimum,
    required this.maximum,
    required this.multipleOf,
  });

  final int minimum;
  final int maximum;
  final int multipleOf;

  factory AddToCartRules.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return AddToCartRules(
      minimum: asInt(data['minimum'], 1),
      maximum: asInt(data['maximum'], 9999),
      multipleOf: asInt(data['multiple_of'], 1),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.parent,
    required this.name,
    required this.slug,
    required this.type,
    required this.permalink,
    required this.sku,
    required this.shortDescription,
    required this.description,
    required this.onSale,
    required this.prices,
    required this.averageRating,
    required this.reviewCount,
    required this.images,
    required this.categories,
    required this.tags,
    required this.attributes,
    required this.variations,
    required this.hasOptions,
    required this.isPurchasable,
    required this.isInStock,
    required this.isOnBackorder,
    required this.lowStockRemaining,
    required this.soldIndividually,
    required this.addToCart,
  });

  final int id;
  final int parent;
  final String name;
  final String slug;
  final String type;
  final String permalink;
  final String sku;
  final String shortDescription;
  final String description;
  final bool onSale;
  final PriceInfo prices;
  final double averageRating;
  final int reviewCount;
  final List<ProductImage> images;
  final List<ProductCategory> categories;
  final List<ProductTag> tags;
  final List<ProductAttribute> attributes;
  final List<VariationRef> variations;
  final bool hasOptions;
  final bool isPurchasable;
  final bool isInStock;
  final bool isOnBackorder;
  final int? lowStockRemaining;
  final bool soldIndividually;
  final AddToCartRules addToCart;

  factory Product.fromJson(Map<String, dynamic> json) {
    final lowStock = json['low_stock_remaining'];
    return Product(
      id: asInt(json['id']),
      parent: asInt(json['parent']),
      name: stripHtml(asString(json['name'])),
      slug: asString(json['slug']),
      type: asString(json['type'], 'simple'),
      permalink: asString(json['permalink']),
      sku: asString(json['sku']),
      shortDescription: asString(json['short_description']),
      description: asString(json['description']),
      onSale: asBool(json['on_sale']),
      prices: PriceInfo.fromJson(asMap(json['prices'])),
      averageRating: asDouble(json['average_rating']),
      reviewCount: asInt(json['review_count']),
      images: asList(json['images'], ProductImage.fromJson),
      categories: asList(json['categories'], ProductCategory.fromJson),
      tags: asList(json['tags'], ProductTag.fromJson),
      attributes: asList(json['attributes'], ProductAttribute.fromJson),
      variations: asList(json['variations'], VariationRef.fromJson),
      hasOptions: asBool(json['has_options']),
      isPurchasable: asBool(json['is_purchasable'], true),
      isInStock: asBool(json['is_in_stock'], true),
      isOnBackorder: asBool(json['is_on_backorder']),
      lowStockRemaining: lowStock == null ? null : asInt(lowStock),
      soldIndividually: asBool(json['sold_individually']),
      addToCart: AddToCartRules.fromJson(asMap(json['add_to_cart'])),
    );
  }

  bool get isVariable => type == 'variable';

  bool get isVariation => type == 'variation';

  bool get hasDiscount => onSale && prices.hasDiscount;

  String? get imageUrl => images.isEmpty ? null : images.first.src;

  String? get thumbnailUrl => images.isEmpty ? null : images.first.thumbnail;

  String get plainShortDescription => stripHtml(shortDescription);

  String get plainDescription => stripHtml(description);

  bool get canBuy => isPurchasable && (isInStock || isOnBackorder);

  bool get isLowStock => lowStockRemaining != null && lowStockRemaining! > 0;

  String get priceLabel => isVariable && prices.range != null
      ? prices.formattedRange
      : prices.formatted;

  ProductCategory? get primaryCategory =>
      categories.isEmpty ? null : categories.first;
}
