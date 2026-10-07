import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

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

class ProductListController extends GetxController {
  ProductListController(this._service, this.args);

  final ProductService _service;
  final ProductListArgs args;

  static const int _perPage = 20;
  static const int _suggestionCount = 6;

  final products = <Product>[].obs;
  final suggestions = <Product>[].obs;

  final isLoading = false.obs;
  final isLoadingSuggestions = false.obs;
  final isLoadingMore = false.obs;

  final hasMore = true.obs;
  final errorMessage = RxnString();

  final query = ''.obs;

  final showSuggestions = false.obs;

  final scrollController = ScrollController();
  final searchField = TextEditingController();
  final searchFocusNode = FocusNode();

  int _page = 1;

  CancelToken? _cancelToken;
  CancelToken? _suggestionCancelToken;

  @override
  void onInit() {
    super.onInit();

    query.value = args.initialQuery;
    searchField.text = args.initialQuery;

    searchFocusNode.addListener(_onFocusChanged);
    scrollController.addListener(_onScroll);

    debounce(
      query,
      (_) => _onQueryChanged(),
      time: const Duration(milliseconds: 350),
    );

    if (args.searchMode) {
      if (args.initialQuery.trim().isNotEmpty) {
        refreshList();
      }
    } else {
      refreshList();
    }
  }

  // ===========================================================================
  // FOCUS
  // ===========================================================================

  void _onFocusChanged() {
    if (!args.searchMode) return;

    if (searchFocusNode.hasFocus) {
      showSuggestions.value = true;

      // When the field is empty, show current/popular products.
      if (query.value.trim().isEmpty) {
        loadSuggestions();
      } else {
        loadSuggestions(query: query.value.trim());
      }
    } else {
      // Small delay allows a suggestion tap to complete before hiding.
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!searchFocusNode.hasFocus) {
          showSuggestions.value = false;
        }
      });
    }
  }

  // ===========================================================================
  // QUERY
  // ===========================================================================

  void _onQueryChanged() {
    if (!args.searchMode) return;

    final value = query.value.trim();

    showSuggestions.value = true;

    if (value.isEmpty) {
      products.clear();
      hasMore.value = false;
      loadSuggestions();
      return;
    }

    loadSuggestions(query: value);
    refreshList();
  }

  // ===========================================================================
  // SUGGESTIONS
  // ===========================================================================

  Future<void> loadSuggestions({String? query}) async {
    if (!args.searchMode) return;

    _suggestionCancelToken?.cancel();

    final token = CancelToken();
    _suggestionCancelToken = token;

    isLoadingSuggestions.value = true;

    try {
      final result = await _service.fetchProducts(
        page: 1,
        perPage: _suggestionCount,
        search: query?.trim().isEmpty == true ? null : query?.trim(),
        orderBy: 'popularity',
        order: 'desc',
        cancelToken: token,
      );

      if (token.isCancelled) return;

      suggestions.assignAll(result.items);
    } on ApiException catch (e) {
      if (e.type != ApiErrorType.cancelled) {
        // Don't replace the entire search screen with an error
        // just because autocomplete failed.
        debugPrint('Suggestion error: ${e.message}');
      }
    } finally {
      if (_suggestionCancelToken == token) {
        isLoadingSuggestions.value = false;
      }
    }
  }

  // ===========================================================================
  // SELECT SUGGESTION
  // ===========================================================================

  Future<void> selectSuggestion(Product product) async {
    final name = product.name.trim();

    if (name.isEmpty) return;

    // Put product name inside search field.
    searchField.text = name;

    searchField.selection = TextSelection.fromPosition(
      TextPosition(offset: searchField.text.length),
    );

    query.value = name;

    // Hide autocomplete.
    showSuggestions.value = false;

    // Remove keyboard focus.
    searchFocusNode.unfocus();

    // Search immediately.
    await refreshList();
  }

  // ===========================================================================
  // SEARCH RESULTS
  // ===========================================================================

  Future<void> refreshList() async {
    _cancelToken?.cancel();

    final token = CancelToken();
    _cancelToken = token;

    _page = 1;
    errorMessage.value = null;

    final searchQuery = query.value.trim();

    if (args.searchMode && searchQuery.isEmpty) {
      products.clear();
      hasMore.value = false;
      isLoading.value = false;
      return;
    }

    hasMore.value = true;
    isLoading.value = true;

    try {
      final result = await _fetch(1, token);

      if (token.isCancelled) return;

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
    if (isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value ||
        products.isEmpty) {
      return;
    }

    final token = _cancelToken;

    isLoadingMore.value = true;

    try {
      final nextPage = _page + 1;

      final result = await _fetch(nextPage, token);

      if (token?.isCancelled == true) return;

      _page = nextPage;

      products.addAll(result.items);
      hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      if (e.type != ApiErrorType.cancelled) {
        Get.snackbar(
          'Could not load more',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<PagedResult<Product>> _fetch(int page, CancelToken? token) {
    return _service.fetchProducts(
      page: page,
      perPage: _perPage,
      search: args.searchMode ? query.value.trim() : null,
      category: args.categoryId?.toString(),
      onSale: args.onSale,
      featured: args.featured,
      orderBy: args.orderBy,
      order: args.order,
      cancelToken: token,
    );
  }

  // ===========================================================================
  // CLEAR SEARCH
  // ===========================================================================

  void clearSearch() {
    searchField.clear();
    query.value = '';

    searchFocusNode.requestFocus();

    showSuggestions.value = true;

    loadSuggestions();
  }

  // ===========================================================================
  // SCROLL
  // ===========================================================================

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      loadMore();
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void onClose() {
    _cancelToken?.cancel();
    _suggestionCancelToken?.cancel();

    scrollController.dispose();
    searchField.dispose();
    searchFocusNode.dispose();

    super.onClose();
  }
}
