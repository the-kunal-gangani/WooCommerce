import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';

class HomeDataService extends GetxService {
  HomeDataService(this._products, this._categories);

  final ProductService _products;
  final CategoryService _categories;

  final categories = <ProductCategory>[].obs;
  final popular = <Product>[].obs;
  final featured = <Product>[].obs;
  final onSale = <Product>[].obs;

  bool loaded = false;

  Future<void> preload() async {
    if (loaded) return;
    final results = await (
      _categories.fetchCategories(perPage: 50),
      _products.fetchProducts(perPage: 6, orderBy: 'popularity', order: 'desc'),
      _products.fetchProducts(perPage: 3, featured: true),
      _products.fetchProducts(perPage: 10, onSale: true),
    ).wait;
    categories.assignAll(results.$1);
    popular.assignAll(results.$2.items);
    featured.assignAll(results.$3.items);
    onSale.assignAll(results.$4.items);
    loaded = true;
  }
}
