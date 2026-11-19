import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';

class SearchDiscoveryController extends GetxController {
  SearchDiscoveryController(this._magnaService, this._serverboatService);

  final ProductService _magnaService;
  final ProductService _serverboatService;

  final query = ''.obs;
  final recommendations = <Product>[].obs;
  final searchResults = <Product>[].obs;
  final isRecommendationsLoading = false.obs;
  final isSearchLoading = false.obs;
  final recommendationsFailed = false.obs;
  final searchError = RxnString();

  static const popularSearches = <String>[
    'Shirt',
    'Dress',
    'Shoes',
    'Bag',
  ];

  Timer? _debounceTimer;
  CancelToken? _searchCancelToken;

  @override
  void onInit() {
    super.onInit();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    isRecommendationsLoading.value = true;
    recommendationsFailed.value = false;
    recommendations.clear();

    try {
      final featured = await Future.wait([
        _safeFeatured(_magnaService),
        _safeFeatured(_serverboatService),
      ]);
      var combined = _unique([featured[0], featured[1]]);

      if (combined.isEmpty) {
        final popular = await Future.wait([
          _safePopular(_magnaService),
          _safePopular(_serverboatService),
        ]);
        combined = _unique([popular[0], popular[1]]);
      }

      recommendations.assignAll(combined.take(10).toList());
      recommendationsFailed.value = combined.isEmpty;
    } finally {
      isRecommendationsLoading.value = false;
    }
  }

  Future<List<Product>> _safeFeatured(ProductService service) async {
    try {
      final result = await service.fetchProducts(
        page: 1,
        perPage: 10,
        featured: true,
      );
      return result.items;
    } catch (_) {
      return const [];
    }
  }

  Future<List<Product>> _safePopular(ProductService service) async {
    try {
      final result = await service.fetchProducts(
        page: 1,
        perPage: 10,
        orderBy: 'popularity',
        order: 'desc',
      );
      return result.items;
    } catch (_) {
      return const [];
    }
  }

  void onQueryChanged(String value) {
    query.value = value;
    _debounceTimer?.cancel();
    _searchCancelToken?.cancel('Search query changed');

    if (value.trim().isEmpty) {
      searchResults.clear();
      searchError.value = null;
      isSearchLoading.value = false;
      return;
    }

    isSearchLoading.value = true;
    searchError.value = null;
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      search(value.trim());
    });
  }

  Future<void> search(String value) async {
    final token = CancelToken();
    _searchCancelToken = token;
    isSearchLoading.value = true;
    searchError.value = null;

    try {
      final results = await Future.wait([
        _safeSearch(_magnaService, value, token),
        _safeSearch(_serverboatService, value, token),
      ]);

      if (token.isCancelled) return;
      final combined = _unique([results[0], results[1]]);
      searchResults.assignAll(combined.take(20).toList());
      if (combined.isEmpty) {
        searchError.value = 'No matching products found.';
      }
    } finally {
      if (identical(_searchCancelToken, token)) {
        isSearchLoading.value = false;
      }
    }
  }

  Future<List<Product>> _safeSearch(
    ProductService service,
    String value,
    CancelToken token,
  ) async {
    try {
      final result = await service.fetchProducts(
        page: 1,
        perPage: 10,
        search: value,
        cancelToken: token,
      );
      return result.items;
    } catch (_) {
      return const [];
    }
  }

  List<Product> _unique(List<List<Product>> groups) {
    final seen = <String>{};
    final result = <Product>[];
    for (final group in groups) {
      for (final product in group) {
        if (seen.add('${product.source.name}:${product.id}')) {
          result.add(product);
        }
      }
    }
    return result;
  }

  void submitSearch([String? value]) {
    final searchValue = (value ?? query.value).trim();
    if (searchValue.isEmpty) return;
    Get.toNamed(
      AppRoutes.productList,
      arguments: ProductListArgs(
        title: 'Search',
        searchMode: true,
        initialQuery: searchValue,
      ),
    );
  }

  void openProduct(Product product) {
    Get.toNamed(AppRoutes.productDetails, arguments: product);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _searchCancelToken?.cancel('Search screen closed');
    super.onClose();
  }
}
