import 'package:flutter/foundation.dart';
import 'package:magna_data_ai_ecommerce/data/models/price_info.dart';

enum ProductSort {
  popularity('Popularity', 'Popularity', 'popularity', 'desc'),
  newest('Newest', 'Newest', 'date', 'desc'),
  priceLowHigh('Price: Low to High', 'Price ↑', 'price', 'asc'),
  priceHighLow('Price: High to Low', 'Price ↓', 'price', 'desc'),
  rating('Rating', 'Rating', 'rating', 'desc'),
  nameAsc('Name: A to Z', 'A-Z', 'title', 'asc'),
  nameDesc('Name: Z to A', 'Z-A', 'title', 'desc');

  const ProductSort(this.label, this.shortLabel, this.orderBy, this.order);

  final String label;
  final String shortLabel;
  final String orderBy;
  final String order;

  static ProductSort fromWoo(String? orderBy, String? order) {
    switch (orderBy) {
      case 'date':
        return ProductSort.newest;
      case 'price':
        return order == 'asc'
            ? ProductSort.priceLowHigh
            : ProductSort.priceHighLow;
      case 'rating':
        return ProductSort.rating;
      case 'title':
        return order == 'desc' ? ProductSort.nameDesc : ProductSort.nameAsc;
      default:
        return ProductSort.popularity;
    }
  }
}

class PriceBounds {
  const PriceBounds({
    required this.min,
    required this.max,
    required this.currency,
  });

  final int min;
  final int max;
  final PriceInfo currency;

  bool get isUsable => max > min;
}

class ProductFilter {
  const ProductFilter({
    this.categoryIds = const <int>{},
    this.minPrice,
    this.maxPrice,
    this.onSale = false,
    this.featured = false,
    this.attributeTerms = const <String, Set<int>>{},
    this.sort = ProductSort.popularity,
  });

  factory ProductFilter.fromArgs({
    int? categoryId,
    bool? onSale,
    bool? featured,
    String? orderBy,
    String? order,
  }) {
    return ProductFilter(
      categoryIds: categoryId == null ? const <int>{} : {categoryId},
      onSale: onSale ?? false,
      featured: featured ?? false,
      sort: ProductSort.fromWoo(orderBy, order),
    );
  }

  final Set<int> categoryIds;
  final int? minPrice;
  final int? maxPrice;
  final bool onSale;
  final bool featured;
  final Map<String, Set<int>> attributeTerms;
  final ProductSort sort;

  static const Object _unset = Object();

  bool get hasPrice => minPrice != null || maxPrice != null;

  ProductFilter copyWith({
    Set<int>? categoryIds,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    bool? onSale,
    bool? featured,
    Map<String, Set<int>>? attributeTerms,
    ProductSort? sort,
  }) {
    return ProductFilter(
      categoryIds: categoryIds ?? this.categoryIds,
      minPrice: identical(minPrice, _unset) ? this.minPrice : minPrice as int?,
      maxPrice: identical(maxPrice, _unset) ? this.maxPrice : maxPrice as int?,
      onSale: onSale ?? this.onSale,
      featured: featured ?? this.featured,
      attributeTerms: attributeTerms ?? this.attributeTerms,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toQuery() {
    final query = <String, dynamic>{
      'orderby': sort.orderBy,
      'order': sort.order,
    };
    if (categoryIds.isNotEmpty) {
      query['category'] = categoryIds.join(',');
    }
    if (onSale) {
      query['on_sale'] = true;
    }
    if (featured) {
      query['featured'] = true;
    }
    if (minPrice != null) {
      query['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      query['max_price'] = maxPrice;
    }
    var index = 0;
    for (final entry in attributeTerms.entries) {
      query['attributes[$index][attribute]'] = entry.key;
      query['attributes[$index][operator]'] = 'in';
      var termIndex = 0;
      for (final termId in entry.value) {
        query['attributes[$index][term_id][$termIndex]'] = termId;
        termIndex++;
      }
      index++;
    }
    if (index > 0) {
      query['attribute_relation'] = 'and';
    }
    return query;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ProductFilter) {
      return false;
    }
    if (minPrice != other.minPrice ||
        maxPrice != other.maxPrice ||
        onSale != other.onSale ||
        featured != other.featured ||
        sort != other.sort) {
      return false;
    }
    if (!setEquals(categoryIds, other.categoryIds)) {
      return false;
    }
    if (attributeTerms.length != other.attributeTerms.length) {
      return false;
    }
    for (final entry in attributeTerms.entries) {
      final otherTerms = other.attributeTerms[entry.key];
      if (otherTerms == null || !setEquals(entry.value, otherTerms)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    minPrice,
    maxPrice,
    onSale,
    featured,
    sort,
    Object.hashAllUnordered(categoryIds),
    Object.hashAllUnordered(
      attributeTerms.entries.map(
        (e) => Object.hash(e.key, Object.hashAllUnordered(e.value)),
      ),
    ),
  );
}
