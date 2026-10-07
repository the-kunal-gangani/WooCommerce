import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/favourites_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class FavouriteController extends GetxController {
  FavouriteController(this._favourites);

  final FavouriteService _favourites;

  RxList<Product> get favourites => _favourites.favourites;

  bool isFavourite(int productId) {
    return _favourites.isFavourite(productId);
  }

  Future<void> toggleFavourite(Product product) {
    return _favourites.toggleFavourite(product);
  }

  Future<void> removeFavourite(int productId) {
    return _favourites.removeFavourite(productId);
  }

  Future<void> clearFavourites() {
    return _favourites.clearFavourites();
  }

  void openProduct(Product product) {
    Get.toNamed(AppRoutes.productDetails, arguments: product);
  }
}
