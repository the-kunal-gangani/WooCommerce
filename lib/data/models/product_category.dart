import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';

import 'product_image.dart';

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.parent = 0,
    this.description = '',
    this.count = 0,
    this.image,
    this.permalink = '',
  });

  final int id;
  final String name;
  final String slug;
  final int parent;
  final String description;
  final int count;
  final ProductImage? image;
  final String permalink;

  bool get isRoot => parent == 0;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final imageJson = asMap(json['image']);
    return ProductCategory(
      id: asInt(json['id']),
      name: stripHtml(asString(json['name'])),
      slug: asString(json['slug']),
      parent: asInt(json['parent']),
      description: stripHtml(asString(json['description'])),
      count: asInt(json['count']),
      image: imageJson == null ? null : ProductImage.fromJson(imageJson),
      permalink: asString(json['permalink'] ?? json['link']),
    );
  }
}
