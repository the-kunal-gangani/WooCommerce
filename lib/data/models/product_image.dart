import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';

class ProductImage {
  const ProductImage({
    required this.id,
    required this.src,
    required this.thumbnail,
    required this.name,
    required this.alt,
  });

  final int id;
  final String src;
  final String thumbnail;
  final String name;
  final String alt;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    final src = asString(json['src']);
    final thumbnail = asString(json['thumbnail']);
    return ProductImage(
      id: asInt(json['id']),
      src: src,
      thumbnail: thumbnail.isEmpty ? src : thumbnail,
      name: asString(json['name']),
      alt: asString(json['alt']),
    );
  }
}
