import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';


class AttributeTerm {
  const AttributeTerm({
    required this.id,
    required this.name,
    required this.slug,
  });

  final int id;
  final String name;
  final String slug;

  factory AttributeTerm.fromJson(Map<String, dynamic> json) {
    return AttributeTerm(
      id: asInt(json['id']),
      name: stripHtml(asString(json['name'])),
      slug: asString(json['slug']),
    );
  }
}

class ProductAttribute {
  const ProductAttribute({
    required this.id,
    required this.name,
    required this.taxonomy,
    required this.hasVariations,
    required this.terms,
  });

  final int id;
  final String name;
  final String taxonomy;
  final bool hasVariations;
  final List<AttributeTerm> terms;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: asInt(json['id']),
      name: stripHtml(asString(json['name'])),
      taxonomy: asString(json['taxonomy']),
      hasVariations: asBool(json['has_variations']),
      terms: asList(json['terms'], AttributeTerm.fromJson),
    );
  }
}

class VariationAttribute {
  const VariationAttribute({required this.name, required this.value});

  final String name;
  final String value;

  factory VariationAttribute.fromJson(Map<String, dynamic> json) {
    return VariationAttribute(
      name: asString(json['name']),
      value: asString(json['value']),
    );
  }
}

class VariationRef {
  const VariationRef({required this.id, required this.attributes});

  final int id;
  final List<VariationAttribute> attributes;

  factory VariationRef.fromJson(Map<String, dynamic> json) {
    return VariationRef(
      id: asInt(json['id']),
      attributes: asList(json['attributes'], VariationAttribute.fromJson),
    );
  }

  bool matches(Map<String, String> selection) {
    if (selection.isEmpty) return false;
    for (final entry in selection.entries) {
      final attribute = attributes.where((a) => a.name == entry.key);
      if (attribute.isEmpty) continue;
      final value = attribute.first.value;
      if (value.isNotEmpty && value != entry.value) return false;
    }
    return true;
  }
}
