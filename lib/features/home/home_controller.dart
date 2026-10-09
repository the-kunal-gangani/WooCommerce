import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/recently_viewed_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/core/services/location_service.dart';

class HomeController extends GetxController {
  HomeController(
    this._products,
    this._categories,
    this._locationService,
    this._recentlyViewedService,
  );

  final ProductService _products;
  final CategoryService _categories;
  final LocationService _locationService;
  final RecentlyViewedService _recentlyViewedService;

  final selectedTab = 0.obs;
  final categories = <ProductCategory>[].obs;
  final selectedCategoryId = 0.obs;
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

  void togglePopular() {
    showAllPopular.toggle();
  }

  void toggleOnSale() {
    showAllOnSale.toggle();
  }

  void openRecentlyViewed() {
    Get.toNamed(AppRoutes.recentlyViewed, arguments: recentlyViewed.toList());
  }

  final minPrice = 0.0.obs;
  final maxPrice = 100000.0.obs;

  RxString get city => _locationService.city;
  RxBool get isLocationLoading => _locationService.isLoading;

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

  int _popularRequest = 0;
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
    if (request != _popularRequest) {
      return;
    }
    if (result != null) {
      popular.assignAll(result.items);
    }
    isProductsLoading.value = false;
  }

  List<Product> get bannerProducts {
    final source = featured.isNotEmpty ? featured : popular;
    return source.where((p) => p.imageUrl != null).take(3).toList();
  }

  String get popularTitle {
    final id = selectedCategoryId.value;
    if (id == 0) return 'Popular Products';
    final match = categories.firstWhereOrNull((c) => c.id == id);
    return match?.name ?? 'Popular Products';
  }

  Future<void> loadHome() async {
    if (popular.isEmpty && categories.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = null;
    final results = await (
      _guard(_categories.fetchCategories(perPage: 50)),
      _guard(_fetchPopular()),
      _guard(_products.fetchProducts(perPage: 3, featured: true)),
      _guard(_products.fetchProducts(perPage: 10, onSale: true)),
    ).wait;
    final categoryResult = results.$1;
    final popularResult = results.$2;
    final featuredResult = results.$3;
    final saleResult = results.$4;
    if (categoryResult != null) {
      categories.assignAll(categoryResult);
    }
    if (popularResult != null) {
      popular.assignAll(popularResult.items);
    }
    if (featuredResult != null) {
      featured.assignAll(featuredResult.items);
    }
    if (saleResult != null) {
      onSale.assignAll(saleResult.items);
    }
    if (categoryResult != null || popularResult != null) {
      errorMessage.value = null;
    }
    isLoading.value = false;
  }

  Future<void> selectCategory(int id) async {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;
    final request = ++_popularRequest;
    isProductsLoading.value = true;
    final result = await _guard(_fetchPopular());
    if (request != _popularRequest) return;
    if (result != null) {
      popular.assignAll(result.items);
    }
    isProductsLoading.value = false;
  }

  Future<void> openProduct(Product product) async {
    await _recentlyViewedService.addProduct(product);
    recentlyViewed.assignAll(_recentlyViewedService.getRecentlyViewed());

    Get.toNamed(AppRoutes.productDetails, arguments: product);
  }

  void openCart() {
    Get.toNamed(AppRoutes.cart);
  }

  void openSearch() {
    debugPrint('openSearch tapped');
    Get.toNamed(
      AppRoutes.productList,
      arguments: const ProductListArgs(title: 'Search', searchMode: true),
    );
  }

  void openPopular() {
    final id = selectedCategoryId.value;
    Get.toNamed(
      AppRoutes.productList,
      arguments: ProductListArgs(
        title: popularTitle,
        categoryId: id == 0 ? null : id,
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

  Future<PagedResult<Product>> _fetchPopular() {
    final id = selectedCategoryId.value;
    return _products.fetchProducts(
      perPage: 6,
      category: id == 0 ? null : '$id',
      orderBy: selectedSort.value,
      order: selectedOrder.value,
      onSale: saleOnly.value ? true : null,
      minPrice: minPrice.value > 0 ? minPrice.value.toInt() : null,
      maxPrice: maxPrice.value < 100000 ? maxPrice.value.toInt() : null,
    );
  }

  Future<T?> _guard<T>(Future<T> future) async {
    try {
      return await future;
    } on ApiException catch (e) {
      errorMessage.value ??= e.message;
      return null;
    }
  }
}
