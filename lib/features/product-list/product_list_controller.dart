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

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  final query = ''.obs;

  final scrollController = ScrollController();
  final searchField = TextEditingController();

  int _page = 1;
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
      if (e.type != ApiErrorType.cancelled) errorMessage.value = e.message;
    } finally {
      if (_cancelToken == token) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
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

  void _onScroll() {
    if (!scrollController.hasClients) return;
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
