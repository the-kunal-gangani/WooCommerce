import 'filter_attribute.dart';
import 'product.dart';

class UnifiedFilterTerm {
  const UnifiedFilterTerm({
    required this.name,
    required this.slug,
    this.magnaTermId,
    this.serverboatTermId,
  });

  final String name;
  final String slug;
  final int? magnaTermId;
  final int? serverboatTermId;

  int? idFor(ProductSource source) {
    switch (source) {
      case ProductSource.magna:
        return magnaTermId;
      case ProductSource.serverboat:
        return serverboatTermId;
    }
  }
}

class UnifiedFilterAttribute {
  const UnifiedFilterAttribute({
    required this.name,
    required this.taxonomy,
    required this.terms,
    this.magnaAttributeId,
    this.serverboatAttributeId,
  });

  final String name;
  final String taxonomy;
  final int? magnaAttributeId;
  final int? serverboatAttributeId;
  final List<UnifiedFilterTerm> terms;

  int? idFor(ProductSource source) {
    switch (source) {
      case ProductSource.magna:
        return magnaAttributeId;
      case ProductSource.serverboat:
        return serverboatAttributeId;
    }
  }

  static List<UnifiedFilterAttribute> merge({
    required List<FilterAttribute> magna,
    required List<FilterAttribute> serverboat,
  }) {
    final merged = <String, UnifiedFilterAttribute>{};

    void add(List<FilterAttribute> attributes, ProductSource source) {
      for (final attribute in attributes) {
        final taxonomy = attribute.taxonomy.trim().toLowerCase();
        if (taxonomy.isEmpty) continue;

        final existing = merged[taxonomy];
        final terms = <String, UnifiedFilterTerm>{
          for (final term in existing?.terms ?? [])
            term.slug.toLowerCase(): term,
        };

        for (final term in attribute.terms) {
          final slug = term.slug.trim().toLowerCase();
          if (slug.isEmpty) continue;

          final previous = terms[slug];
          terms[slug] = UnifiedFilterTerm(
            name: previous?.name ?? term.name,
            slug: slug,
            magnaTermId: source == ProductSource.magna
                ? term.id
                : previous?.magnaTermId,
            serverboatTermId: source == ProductSource.serverboat
                ? term.id
                : previous?.serverboatTermId,
          );
        }

        merged[taxonomy] = UnifiedFilterAttribute(
          name: existing?.name ?? attribute.name,
          taxonomy: taxonomy,
          magnaAttributeId: source == ProductSource.magna
              ? attribute.id
              : existing?.magnaAttributeId,
          serverboatAttributeId: source == ProductSource.serverboat
              ? attribute.id
              : existing?.serverboatAttributeId,
          terms: terms.values.toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            ),
        );
      }
    }

    add(magna, ProductSource.magna);
    add(serverboat, ProductSource.serverboat);

    final result = merged.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return result;
  }
}
