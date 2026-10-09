import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';

class FilterTerm {
  const FilterTerm({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
  });

  final int id;
  final String name;
  final String slug;
  final int count;

  factory FilterTerm.fromJson(Map<String, dynamic> json) {
    return FilterTerm(
      id: asInt(json['id']),
      name: stripHtml(asString(json['name'])),
      slug: asString(json['slug']),
      count: asInt(json['count']),
    );
  }
}

class FilterAttribute {
  const FilterAttribute({
    required this.id,
    required this.name,
    required this.taxonomy,
    this.terms = const [],
  });

  final int id;
  final String name;
  final String taxonomy;
  final List<FilterTerm> terms;

  factory FilterAttribute.fromJson(Map<String, dynamic> json) {
    return FilterAttribute(
      id: asInt(json['id']),
      name: stripHtml(asString(json['name'])),
      taxonomy: asString(json['taxonomy']),
    );
  }

  FilterAttribute copyWith({List<FilterTerm>? terms}) {
    return FilterAttribute(
      id: id,
      name: name,
      taxonomy: taxonomy,
      terms: terms ?? this.terms,
    );
  }
}
