import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/checkout_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/favourites_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/secure_storage_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = ApiClient();
    final secureStorage = SecureStorageService();
    final storage = StorageService();
    final authService = AuthService(apiClient, secureStorage, storage);
    final productService = ProductService(apiClient);
    final categoryService = CategoryService(apiClient);
    final cartService = CartService(storage, productService);
    final checkoutService = CheckoutService();
    final favouriteService = FavouriteService(storage);
    final favouriteController = FavouriteController(favouriteService);

    Get.put<SecureStorageService>(secureStorage, permanent: true);
    Get.put<StorageService>(storage, permanent: true);
    Get.put<ApiClient>(apiClient, permanent: true);
    Get.put<AuthService>(authService, permanent: true);
    Get.put<ProductService>(productService, permanent: true);
    Get.put<CategoryService>(categoryService, permanent: true);
    Get.put<CartService>(cartService, permanent: true);
    Get.put<CheckoutService>(checkoutService, permanent: true);
    Get.put<FavouriteService>(favouriteService, permanent: true);
    Get.put<FavouriteController>(favouriteController, permanent: true);
  }
}
