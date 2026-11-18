import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_image.dart';

class UnifiedCategory {
  const UnifiedCategory({
    required this.name,
    required this.slug,
    this.count = 0,
    this.image,
    this.magnaCategoryId,
    this.serverboatCategoryId,
  });

  final String name;
  final String slug;
  final int count;
  final ProductImage? image;

  // These IDs belong to their respective stores.
  final int? magnaCategoryId;
  final int? serverboatCategoryId;

  int? categoryIdFor(ProductSource source) {
    switch (source) {
      case ProductSource.magna:
        return magnaCategoryId;
      case ProductSource.serverboat:
        return serverboatCategoryId;
    }
  }

  static List<UnifiedCategory> merge({
    required List<ProductCategory> magna,
    required List<ProductCategory> serverboat,
  }) {
    final merged = <String, UnifiedCategory>{};

    void addCategories(List<ProductCategory> categories, ProductSource source) {
      for (final category in categories) {
        final slug = category.slug.trim().toLowerCase();
        if (slug.isEmpty) continue;
        final existing = merged[slug];
        if (existing == null) {
          merged[slug] = UnifiedCategory(
            name: category.name,
            slug: slug,
            count: category.count,
            image: category.image,
            magnaCategoryId: source == ProductSource.magna ? category.id : null,
            serverboatCategoryId: source == ProductSource.serverboat
                ? category.id
                : null,
          );
          continue;
        }
        merged[slug] = UnifiedCategory(
          name: existing.name,
          slug: slug,
          count: existing.count + category.count,
          image: existing.image ?? category.image,
          magnaCategoryId: source == ProductSource.magna
              ? category.id
              : existing.magnaCategoryId,
          serverboatCategoryId: source == ProductSource.serverboat
              ? category.id
              : existing.serverboatCategoryId,
        );
      }
    }

    addCategories(magna, ProductSource.magna);
    addCategories(serverboat, ProductSource.serverboat);
    final result = merged.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }
}
