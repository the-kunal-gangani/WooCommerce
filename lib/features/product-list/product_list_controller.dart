import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';
import 'package:magna_data_ai_ecommerce/data/models/filter_attribute.dart';
import 'package:magna_data_ai_ecommerce/data/models/price_info.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_filter.dart';
import 'package:magna_data_ai_ecommerce/data/models/unified_category.dart';
import 'package:magna_data_ai_ecommerce/data/models/unified_filter_attribute.dart';

class ProductListArgs {
  const ProductListArgs({
    this.title = 'Products',
    this.categoryId,
    this.categorySlug,
    this.magnaCategoryId,
    this.serverboatCategoryId,
    this.onSale,
    this.featured,
    this.orderBy,
    this.order,
    this.searchMode = false,
    this.initialQuery = '',
  });

  final String title;
  final int? categoryId;
  final String? categorySlug;
  final int? magnaCategoryId;
  final int? serverboatCategoryId;
  final bool? onSale;
  final bool? featured;
  final String? orderBy;
  final String? order;
  final bool searchMode;
  final String initialQuery;
}

class ActiveFilterChip {
  const ActiveFilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;
}

class ProductListController extends GetxController {
  ProductListController(
    this._service,
    this._categoryService,
    this.args, {
    ProductService? serverboatService,
    CategoryService? serverboatCategoryService,
  }) : _serverboatService = serverboatService ?? _service,
       _serverboatCategoryService =
           serverboatCategoryService ?? _categoryService,
       baseFilter = ProductFilter.fromArgs(
         onSale: args.onSale,
         featured: args.featured,
         orderBy: args.orderBy,
         order: args.order,
       ) {
    final slug = args.categorySlug?.trim().toLowerCase();
    if (slug != null && slug.isNotEmpty) {
      selectedCategorySlugs.add(slug);
    }
  }

  final ProductService _service;
  final CategoryService _categoryService;
  final ProductService _serverboatService;
  final CategoryService _serverboatCategoryService;

  ProductService get serverboatService => _serverboatService;
  CategoryService get serverboatCategoryService => _serverboatCategoryService;
  final ProductListArgs args;
  final ProductFilter baseFilter;

  static const int _perPage = 10;

  int _magnaPage = 1;
  int _serverboatPage = 1;

  bool _magnaHasMore = true;
  bool _serverboatHasMore = true;

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  final query = ''.obs;

  final RxList<UnifiedCategory> categories = <UnifiedCategory>[].obs;
  final RxList<UnifiedFilterAttribute> attributes =
      <UnifiedFilterAttribute>[].obs;
  final RxSet<String> selectedCategorySlugs = <String>{}.obs;
  final RxMap<String, Set<String>> selectedAttributeTerms =
      <String, Set<String>>{}.obs;
  final priceBounds = Rxn<PriceBounds>();
  final isLoadingOptions = false.obs;
  final optionsFailed = false.obs;

  late final Rx<ProductFilter> filter = Rx<ProductFilter>(baseFilter);

  final scrollController = ScrollController();
  final searchField = TextEditingController();

  bool _optionsLoaded = false;
  CancelToken? _cancelToken;

  Set<int> _categoryIdsFor(ProductSource source) {
    final ids = <int>{};

    // Preserve the category supplied when opening a category page.
    final argumentId = source == ProductSource.magna
        ? args.magnaCategoryId
        : args.serverboatCategoryId;
    if (argumentId != null) {
      ids.add(argumentId);
    }

    for (final slug in selectedCategorySlugs) {
      final category = categories.firstWhereOrNull((item) => item.slug == slug);

      final id = category?.categoryIdFor(source);
      if (id != null) ids.add(id);
    }

    return ids;
  }

  Map<String, Set<int>> _attributeIdsFor(ProductSource source) {
    final result = <String, Set<int>>{};

    for (final entry in selectedAttributeTerms.entries) {
      final attribute = attributes.firstWhereOrNull(
        (item) => item.taxonomy == entry.key,
      );

      if (attribute == null || attribute.idFor(source) == null) {
        continue;
      }

      final ids = <int>{};

      for (final slug in entry.value) {
        final term = attribute.terms.firstWhereOrNull(
          (item) => item.slug == slug,
        );

        final id = term?.idFor(source);
        if (id != null) ids.add(id);
      }

      if (ids.isNotEmpty) {
        result[entry.key] = ids;
      }
    }

    return result;
  }

  ProductFilter _filterFor(ProductSource source) {
    return filter.value.copyWith(
      categoryIds: _categoryIdsFor(source),
      attributeTerms: _attributeIdsFor(source),
    );
  }

  @override
  void onInit() {
    super.onInit();
    query.value = args.initialQuery;
    searchField.text = args.initialQuery;
    scrollController.addListener(_onScroll);
    debounce(
      query,
      (_) => refreshList(),
      time: const Duration(milliseconds: 400),
    );
    if (!args.searchMode || args.initialQuery.isNotEmpty) {
      refreshList();
    }
  }

  List<ActiveFilterChip> get activeChips {
    final current = filter.value;
    final chips = <ActiveFilterChip>[];
    for (final id in current.categoryIds) {
      if (baseFilter.categoryIds.contains(id)) {
        continue;
      }
      chips.add(
        ActiveFilterChip(
          label: _categoryName(id),
          onRemove: () => applyFilter(
            filter.value.copyWith(
              categoryIds: {...filter.value.categoryIds}..remove(id),
            ),
          ),
        ),
      );
    }
    if (current.hasPrice) {
      chips.add(
        ActiveFilterChip(
          label: _priceLabel(current),
          onRemove: () => applyFilter(
            filter.value.copyWith(minPrice: null, maxPrice: null),
          ),
        ),
      );
    }
    if (current.onSale && !baseFilter.onSale) {
      chips.add(
        ActiveFilterChip(
          label: 'On Sale',
          onRemove: () => applyFilter(filter.value.copyWith(onSale: false)),
        ),
      );
    }
    if (current.featured && !baseFilter.featured) {
      chips.add(
        ActiveFilterChip(
          label: 'Featured',
          onRemove: () => applyFilter(filter.value.copyWith(featured: false)),
        ),
      );
    }
    for (final entry in current.attributeTerms.entries) {
      for (final termId in entry.value) {
        chips.add(
          ActiveFilterChip(
            label: _termLabel(entry.key, termId),
            onRemove: () {
              final terms = {
                for (final e in filter.value.attributeTerms.entries)
                  e.key: {...e.value},
              };
              terms[entry.key]?.remove(termId);
              if (terms[entry.key]?.isEmpty ?? false) {
                terms.remove(entry.key);
              }
              applyFilter(filter.value.copyWith(attributeTerms: terms));
            },
          ),
        );
      }
    }
    return chips;
  }

  void applyFilter(ProductFilter next) {
    if (next == filter.value) {
      return;
    }
    filter.value = next;
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
    refreshList();
  }

  void clearFilters() {
    clearUnifiedSelections();
    applyFilter(baseFilter.copyWith(sort: filter.value.sort));
  }

  Future<void> loadFilterOptions({bool force = false}) async {
    if (isLoadingOptions.value) {
      return;
    }
    if (_optionsLoaded && !force) {
      return;
    }
    isLoadingOptions.value = true;
    optionsFailed.value = false;
    final results = await (
      _guard(_service.fetchFilterAttributes()),
      _guard(_serverboatService.fetchFilterAttributes()),
      _guard(_categoryService.fetchCategories()),
      _guard(_serverboatCategoryService.fetchCategories()),
      _guard(
        _service.fetchPriceBounds(
          categoryIds: _categoryIdsFor(ProductSource.magna),
        ),
      ),
      _guard(
        _serverboatService.fetchPriceBounds(
          categoryIds: _categoryIdsFor(ProductSource.serverboat),
        ),
      ),
    ).wait;
    final magnaAttributes = results.$1 ?? <FilterAttribute>[];
    final serverboatAttributes = results.$2 ?? <FilterAttribute>[];
    final magnaCategories = results.$3 ?? <ProductCategory>[];
    final serverboatCategories = results.$4 ?? <ProductCategory>[];
    final magnaBounds = results.$5;
    final serverboatBounds = results.$6;
    attributes.assignAll(
      UnifiedFilterAttribute.merge(
        magna: magnaAttributes,
        serverboat: serverboatAttributes,
      ),
    );
    categories.assignAll(
      UnifiedCategory.merge(
        magna: magnaCategories
            .where((category) => category.slug != 'uncategorized')
            .toList(),
        serverboat: serverboatCategories
            .where((category) => category.slug != 'uncategorized')
            .toList(),
      ),
    );
    if (magnaBounds != null || serverboatBounds != null) {
      final availableBounds = [
        ?magnaBounds,
        ?serverboatBounds,
      ];
      priceBounds.value = PriceBounds(
        min: availableBounds
            .map((bounds) => bounds.min)
            .reduce((a, b) => a < b ? a : b),
        max: availableBounds
            .map((bounds) => bounds.max)
            .reduce((a, b) => a > b ? a : b),
        currency: magnaBounds?.currency ?? serverboatBounds!.currency,
      );
    }
    final failed =
        results.$1 == null &&
        results.$2 == null &&
        results.$3 == null &&
        results.$4 == null &&
        results.$5 == null &&
        results.$6 == null;
    optionsFailed.value = failed;
    _optionsLoaded = !failed;
    isLoadingOptions.value = false;
  }

  void applyUnifiedSelections({
    required ProductFilter nextFilter,
    required Set<String> categorySlugs,
    required Map<String, Set<String>> attributeSlugs,
  }) {
    selectedCategorySlugs.assignAll(categorySlugs);
    selectedAttributeTerms.assignAll({
      for (final entry in attributeSlugs.entries)
        entry.key: Set<String>.from(entry.value),
    });
    applyFilter(
      nextFilter.copyWith(
        categoryIds: <int>{},
        attributeTerms: <String, Set<int>>{},
      ),
    );
  }

  void clearUnifiedSelections() {
    selectedCategorySlugs.clear();
    selectedAttributeTerms.clear();
  }

  Future<void> refreshList() async {
    _cancelToken?.cancel('Product list refreshed');
    final token = CancelToken();
    _cancelToken = token;

    isLoading.value = true;
    errorMessage.value = null;

    _magnaPage = 1;
    _serverboatPage = 1;
    _magnaHasMore = true;
    _serverboatHasMore = true;

    hasMore.value = true;
    products.clear();

    if (args.searchMode && query.value.trim().isEmpty) {
      hasMore.value = false;
      isLoading.value = false;
      return;
    }

    try {
      final results = await Future.wait([
        _fetchFromStore(
          service: _service,
          source: ProductSource.magna,
          page: 1,
          cancelToken: token,
        ),
        _fetchFromStore(
          service: _serverboatService,
          source: ProductSource.serverboat,
          page: 1,
          cancelToken: token,
        ),
      ]);

      if (token.isCancelled) return;

      final magnaResult = results[0];
      final serverboatResult = results[1];

      if (magnaResult == null && serverboatResult == null) {
        errorMessage.value = 'Unable to load products. Please try again.';
        return;
      }

      if (magnaResult != null) {
        _magnaHasMore = magnaResult.hasMore;
      }

      if (serverboatResult != null) {
        _serverboatHasMore = serverboatResult.hasMore;
      }

      final combined = [
        ...?magnaResult?.items,
        ...?serverboatResult?.items,
      ];

      products.assignAll(_uniqueProducts(combined));

      hasMore.value = _magnaHasMore || _serverboatHasMore;
    } finally {
      if (identical(_cancelToken, token)) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore.value) {
      return;
    }

    final token = _cancelToken;
    if (token == null || token.isCancelled) return;

    isLoadingMore.value = true;

    try {
      final futures = <Future<PagedResult<Product>?>>[];

      if (_magnaHasMore) {
        futures.add(
          _fetchFromStore(
            service: _service,
            source: ProductSource.magna,
            page: _magnaPage + 1,
            cancelToken: token,
          ),
        );
      }

      if (_serverboatHasMore) {
        futures.add(
          _fetchFromStore(
            service: _serverboatService,
            source: ProductSource.serverboat,
            page: _serverboatPage + 1,
            cancelToken: token,
          ),
        );
      }

      final results = await Future.wait(futures);

      if (token.isCancelled) return;

      var resultIndex = 0;
      final newProducts = <Product>[];

      if (_magnaHasMore) {
        final result = results[resultIndex++];

        if (result != null) {
          _magnaPage++;
          _magnaHasMore = result.hasMore;
          newProducts.addAll(result.items);
        } else {
          _magnaHasMore = true;
        }
      }

      if (_serverboatHasMore) {
        final result = results[resultIndex++];

        if (result != null) {
          _serverboatPage++;
          _serverboatHasMore = result.hasMore;
          newProducts.addAll(result.items);
        } else {
          _serverboatHasMore = true;
        }
      }

      if (newProducts.isNotEmpty) {
        final merged = _uniqueProducts([
          ...products,
          ...newProducts,
        ]);

        products.assignAll(merged);
      }

      hasMore.value = _magnaHasMore || _serverboatHasMore;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<PagedResult<Product>?> _fetchFromStore({
    required ProductService service,
    required ProductSource source,
    required int page,
    CancelToken? cancelToken,
  }) async {
    try {
      return await service.fetchProductsFiltered(
        filter: _filterFor(source),
        page: page,
        perPage: _perPage,
        search: query.value.trim().isEmpty ? null : query.value.trim(),
        cancelToken: cancelToken,
      );
    } catch (_) {
      return null;
    }
  }

  List<Product> _uniqueProducts(Iterable<Product> items) {
    final seen = <String>{};
    final result = <Product>[];

    for (final product in items) {
      final key = '${product.source.name}:${product.id}';

      if (seen.add(key)) {
        result.add(product);
      }
    }

    return result;
  }

  Future<T?> _guard<T>(Future<T> future) async {
    try {
      return await future;
    } catch (e) {
      printLog('filter options failed: $e');
      return null;
    }
  }

  String _categoryName(int id) {
    final match = categories.firstWhereOrNull(
      (c) => c.magnaCategoryId == id || c.serverboatCategoryId == id,
    );
    return match?.name ?? 'Category';
  }

  String _termLabel(String taxonomy, int termId) {
    for (final attribute in attributes) {
      if (attribute.taxonomy != taxonomy) {
        continue;
      }
      for (final term in attribute.terms) {
        if (term.magnaTermId == termId || term.serverboatTermId == termId) {
          return term.name;
        }
      }
    }
    return 'Option';
  }

  String _priceLabel(ProductFilter current) {
    final bounds = priceBounds.value;
    final currency =
        bounds?.currency ??
        (products.isNotEmpty ? products.first.prices : PriceInfo.empty);
    final low = current.minPrice ?? bounds?.min;
    final high = current.maxPrice ?? bounds?.max;
    if (low != null && high != null) {
      return '${_compact(currency, low)} - ${_compact(currency, high)}';
    }
    if (low != null) {
      return 'From ${_compact(currency, low)}';
    }
    return 'Up to ${_compact(currency, high ?? 0)}';
  }

  String _compact(PriceInfo currency, int minor) {
    final value = minor / pow(10, currency.minorUnit);
    final text = value >= 1000 ? '${_trim(value / 1000)}k' : _trim(value);
    return '${currency.prefix}$text${currency.suffix}';
  }

  String _trim(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      loadMore();
    }
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    scrollController.dispose();
    searchField.dispose();
    super.onClose();
  }
}
