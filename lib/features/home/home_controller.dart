import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/location_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/recently_viewed_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/unified_category.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';

class HomeController extends GetxController {
  HomeController(
    this._magnaProducts,
    this._serverboatProducts,
    this._magnaCategories,
    this._serverboatCategories,
    this._locationService,
    this._recentlyViewedService,
  );

  final ProductService _magnaProducts;
  final ProductService _serverboatProducts;
  final CategoryService _magnaCategories;
  final CategoryService _serverboatCategories;
  final LocationService _locationService;
  final RecentlyViewedService _recentlyViewedService;

  final selectedTab = 0.obs;
  final categories = <UnifiedCategory>[].obs;
  final selectedCategorySlug = ''.obs;
  final featured = <Product>[].obs;
  final popular = <Product>[].obs;
  final onSale = <Product>[].obs;
  final isLoading = true.obs;
  final isProductsLoading = false.obs;
  final errorMessage = RxnString();
  final selectedSort = 'popularity'.obs;
  final selectedOrder = 'desc'.obs;
  final saleOnly = false.obs;
  final inStockOnly = false.obs;
  final recentlyViewed = <Product>[].obs;
  final showAllPopular = false.obs;
  final showAllOnSale = false.obs;
  final minPrice = 0.0.obs;
  final maxPrice = 100000.0.obs;
  int _popularRequest = 0;
  RxString get city => _locationService.city;
  RxBool get isLocationLoading => _locationService.isLoading;

  void togglePopular() {
    showAllPopular.toggle();
  }

  void toggleOnSale() {
    showAllOnSale.toggle();
  }

  void openRecentlyViewed() {
    Get.toNamed(AppRoutes.recentlyViewed, arguments: recentlyViewed.toList());
  }

  Future<void> selectLocation() async {
    final result = await _locationService.detectCity();
    if (result == null) {
      Get.snackbar(
        'Location unavailable',
        'We could not determine your city. Please check location permission.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF111827),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void resetFilters() {
    selectedSort.value = 'popularity';
    selectedOrder.value = 'desc';
    saleOnly.value = false;
    inStockOnly.value = false;
    minPrice.value = 0;
    maxPrice.value = 100000;
  }

  void openFilters() {
    Get.toNamed(
      AppRoutes.productList,
      arguments: const ProductListArgs(title: 'All Products'),
    );
  }

  Future<void> applyFilters() async {
    final request = ++_popularRequest;
    isProductsLoading.value = true;
    errorMessage.value = null;
    final result = await _guard(_fetchPopular());
    if (request != _popularRequest) return;
    if (result != null) {
      popular.assignAll(result);
    }
    isProductsLoading.value = false;
  }

  List<Product> get bannerProducts {
    final source = featured.isNotEmpty ? featured : popular;
    return source.where((product) => product.imageUrl != null).take(3).toList();
  }

  String get popularTitle {
    final slug = selectedCategorySlug.value;
    if (slug.isEmpty) return 'Popular Products';
    final match = categories.firstWhereOrNull(
      (category) => category.slug == slug,
    );
    return match?.name ?? 'Popular Products';
  }

  UnifiedCategory? get selectedCategory {
    final slug = selectedCategorySlug.value;
    if (slug.isEmpty) return null;
    return categories.firstWhereOrNull((category) => category.slug == slug);
  }

  Future<void> loadHome() async {
    if (popular.isEmpty && categories.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = null;
    final results = await (
      _guard(_fetchCategories()),
      _guard(_fetchPopular()),
      _guard(_fetchProducts(perPage: 3, featured: true)),
      _guard(_fetchProducts(perPage: 10, onSale: true)),
    ).wait;
    final categoryResult = results.$1;
    final popularResult = results.$2;
    final featuredResult = results.$3;
    final saleResult = results.$4;
    if (categoryResult != null) {
      categories.assignAll(categoryResult);
    }
    if (popularResult != null) {
      popular.assignAll(popularResult);
    }
    if (featuredResult != null) {
      featured.assignAll(featuredResult);
    }
    if (saleResult != null) {
      onSale.assignAll(saleResult);
    }
    if (categoryResult != null || popularResult != null) {
      errorMessage.value = null;
    }
    isLoading.value = false;
  }

  Future<List<UnifiedCategory>> _fetchCategories() async {
    final results = await (
      _magnaCategories.fetchCategories(perPage: 50),
      _serverboatCategories.fetchCategories(perPage: 50),
    ).wait;
    return UnifiedCategory.merge(magna: results.$1, serverboat: results.$2);
  }

  Future<void> selectCategory(String slug) async {
    if (selectedCategorySlug.value == slug) return;
    selectedCategorySlug.value = slug;
    final request = ++_popularRequest;
    isProductsLoading.value = true;
    errorMessage.value = null;
    final result = await _guard(_fetchPopular());
    if (request != _popularRequest) return;
    if (result != null) {
      popular.assignAll(result);
    }
    isProductsLoading.value = false;
  }

  void openProduct(Product product) {
    Get.toNamed(AppRoutes.productDetails, arguments: product);
    _recordView(product);
  }

  void openCart() {
    Get.toNamed(AppRoutes.cart);
  }

  void openSearch() {
    Get.toNamed(
      AppRoutes.productList,
      arguments: const ProductListArgs(title: 'Search', searchMode: true),
    );
  }

  void openPopular() {
    Get.toNamed(
      AppRoutes.productList,
      arguments: ProductListArgs(
        title: popularTitle,
        orderBy: 'popularity',
        order: 'desc',
      ),
    );
  }

  void openOnSale() {
    Get.toNamed(
      AppRoutes.productList,
      arguments: const ProductListArgs(title: 'On Sale', onSale: true),
    );
  }

  Future<List<Product>> _fetchPopular() {
    return _fetchProducts(
      perPage: 6,
      orderBy: selectedSort.value,
      order: selectedOrder.value,
      onSale: saleOnly.value ? true : null,
      minPrice: minPrice.value > 0 ? minPrice.value.toInt() : null,
      maxPrice: maxPrice.value < 100000 ? maxPrice.value.toInt() : null,
    );
  }

  Future<List<Product>> _fetchProducts({
    required int perPage,
    bool? featured,
    bool? onSale,
    String? orderBy,
    String? order,
    int? minPrice,
    int? maxPrice,
  }) async {
    final category = selectedCategory;
    final magnaCategoryId = category?.magnaCategoryId;
    final serverboatCategoryId = category?.serverboatCategoryId;
    final Future<PagedResult<Product>> magnaFuture =
        category != null && magnaCategoryId == null
        ? Future.value(
            const PagedResult<Product>(
              items: [],
              total: 0,
              totalPages: 0,
              page: 1,
            ),
          )
        : _magnaProducts.fetchProducts(
            perPage: perPage,
            category: magnaCategoryId?.toString(),
            featured: featured,
            onSale: onSale,
            orderBy: orderBy,
            order: order,
            minPrice: minPrice,
            maxPrice: maxPrice,
          );
    final Future<PagedResult<Product>> serverboatFuture =
        category != null && serverboatCategoryId == null
        ? Future.value(
            const PagedResult<Product>(
              items: [],
              total: 0,
              totalPages: 0,
              page: 1,
            ),
          )
        : _serverboatProducts.fetchProducts(
            perPage: perPage,
            category: serverboatCategoryId?.toString(),
            featured: featured,
            onSale: onSale,
            orderBy: orderBy,
            order: order,
            minPrice: minPrice,
            maxPrice: maxPrice,
          );
    final results = await (magnaFuture, serverboatFuture).wait;
    // Alternate stores so one store does not dominate the home grid.
    return _interleave(results.$1.items, results.$2.items);
  }

  List<Product> _interleave(List<Product> magna, List<Product> serverboat) {
    final combined = <Product>[];
    final maxLength = magna.length > serverboat.length
        ? magna.length
        : serverboat.length;
    for (var i = 0; i < maxLength; i++) {
      if (i < magna.length) {
        combined.add(magna[i]);
      }
      if (i < serverboat.length) {
        combined.add(serverboat[i]);
      }
    }
    return combined;
  }

  Future<T?> _guard<T>(Future<T> future) async {
    try {
      return await future;
    } on ApiException catch (e) {
      errorMessage.value ??= e.message;
      return null;
    } catch (e) {
      errorMessage.value ??= 'Something went wrong while loading products.';
      debugPrint('Home loading error: $e');
      return null;
    }
  }

  Future<void> _recordView(Product product) async {
    final updated = [
      product,
      ...recentlyViewed.where(
        (p) => p.id != product.id || p.source != product.source,
      ),
    ].take(10).toList();
    recentlyViewed.assignAll(updated);
    try {
      await _recentlyViewedService.addProduct(product);
    } catch (e) {
      debugPrint('recently viewed save failed: $e');
    }
  }
}
