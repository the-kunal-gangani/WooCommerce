import 'package:get/get.dart';

import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/category_service.dart';
import '../services/product_services.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_services.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ---------------------------------------------------------
    // Core services
    // ---------------------------------------------------------

    final apiClient = ApiClient();
    final secureStorage = SecureStorageService();
    final storage = StorageService();

    Get.put<SecureStorageService>(secureStorage, permanent: true);

    Get.put<StorageService>(storage, permanent: true);

    Get.put<ApiClient>(apiClient, permanent: true);

    // ---------------------------------------------------------
    // Application services
    // ---------------------------------------------------------

    final authService = AuthService(apiClient, secureStorage, storage);

    final productService = ProductService(apiClient);

    final categoryService = CategoryService(apiClient);

    final cartService = CartService(storage, productService);

    Get.put<AuthService>(authService, permanent: true);

    Get.put<ProductService>(productService, permanent: true);

    Get.put<CategoryService>(categoryService, permanent: true);

    Get.put<CartService>(cartService, permanent: true);
  }
}
