import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';
import 'package:magna_data_ai_ecommerce/data/models/filter_attribute.dart';
import 'package:magna_data_ai_ecommerce/data/models/price_info.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_filter.dart';

class ProductListArgs {
  const ProductListArgs({
    this.title = 'Products',
    this.categoryId,
    this.onSale,
    this.featured,
    this.orderBy,
    this.order,
    this.searchMode = false,
    this.initialQuery = '',
  });

  final String title;
  final int? categoryId;
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
  ProductListController(this._service, this._categoryService, this.args)
    : baseFilter = ProductFilter.fromArgs(
        categoryId: args.categoryId,
        onSale: args.onSale,
        featured: args.featured,
        orderBy: args.orderBy,
        order: args.order,
      );

  final ProductService _service;
  final CategoryService _categoryService;
  final ProductListArgs args;
  final ProductFilter baseFilter;

  static const int _perPage = 20;

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  final query = ''.obs;

  final categories = <ProductCategory>[].obs;
  final attributes = <FilterAttribute>[].obs;
  final priceBounds = Rxn<PriceBounds>();
  final isLoadingOptions = false.obs;
  final optionsFailed = false.obs;

  late final Rx<ProductFilter> filter = Rx<ProductFilter>(baseFilter);

  final scrollController = ScrollController();
  final searchField = TextEditingController();

  int _page = 1;
  bool _optionsLoaded = false;
  CancelToken? _cancelToken;

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

    final (attributeResult, categoryResult, boundsResult) = await (
      _guard(_service.fetchFilterAttributes()),
      _guard(_categoryService.fetchAllCategories()),
      _guard(_service.fetchPriceBounds(categoryIds: baseFilter.categoryIds)),
    ).wait;

    if (attributeResult != null) {
      attributes.assignAll(attributeResult);
    }
    if (categoryResult != null) {
      categories.assignAll(
        categoryResult.where((c) => c.slug != 'uncategorized'),
      );
    }
    if (boundsResult != null) {
      priceBounds.value = boundsResult;
    }

    final failed =
        attributeResult == null &&
        categoryResult == null &&
        boundsResult == null;
    optionsFailed.value = failed;
    _optionsLoaded = !failed;
    isLoadingOptions.value = false;
  }

  Future<void> refreshList() async {
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;
    _page = 1;
    errorMessage.value = null;

    if (args.searchMode && query.value.trim().isEmpty) {
      products.clear();
      hasMore.value = false;
      isLoading.value = false;
      return;
    }

    hasMore.value = true;
    isLoading.value = true;
    try {
      final result = await _fetch(1, token);
      products.assignAll(result.items);
      hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      if (e.type != ApiErrorType.cancelled) {
        errorMessage.value = e.message;
      }
    } finally {
      if (_cancelToken == token) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      return;
    }
    final token = _cancelToken;
    isLoadingMore.value = true;
    try {
      final next = _page + 1;
      final result = await _fetch(next, token);
      _page = next;
      products.addAll(result.items);
      hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      if (e.type != ApiErrorType.cancelled) {
        Get.snackbar('Could not load more', e.message);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<PagedResult<Product>> _fetch(int page, CancelToken? token) {
    return _service.fetchProductsFiltered(
      filter: filter.value,
      page: page,
      perPage: _perPage,
      search: args.searchMode ? query.value.trim() : null,
      cancelToken: token,
    );
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
    final match = categories.firstWhereOrNull((c) => c.id == id);
    return match?.name ?? 'Category';
  }

  String _termLabel(String taxonomy, int termId) {
    for (final attribute in attributes) {
      if (attribute.taxonomy != taxonomy) {
        continue;
      }
      for (final term in attribute.terms) {
        if (term.id == termId) {
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
