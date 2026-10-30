import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/core/locallization/language_controller.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/services/address_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/blog_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/checkout_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/favourites_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/location_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/order_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/recently_viewed_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/secure_storage_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/wishlist_service.dart';
import 'package:magna_data_ai_ecommerce/features/blog/blog_controller.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_controller.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';
import 'package:magna_data_ai_ecommerce/features/wishlist/wishlist_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final blogService = BlogService();
    final blogController = BlogController(blogService);
    final apiClient = ApiClient();
    final secureStorage = SecureStorageService();
    final storage = StorageService();
    final getStorage = GetStorage();
    late final AuthService authService;
    final wpApiClient = ApiClient(
      baseUrl: '${AppConfig.baseUrl}${AppConfig.magnaApiPath}/',
      tokenProvider: () async => authService.accessToken,
    );
    authService = AuthService(wpApiClient, secureStorage, storage);
    Get.put<ApiClient>(apiClient, permanent: true);
    Get.put<ApiClient>(wpApiClient, tag: 'wordpress', permanent: true);
    Get.put<Dio>(wpApiClient.dio, tag: 'wordpress', permanent: true);
    Get.put<SecureStorageService>(secureStorage, permanent: true);
    Get.put<StorageService>(storage, permanent: true);
    Get.put<AuthService>(authService, permanent: true);
    final locationService = LocationService(storage);
    final addressService = AddressService(wpApiClient, authService);
    final productService = ProductService(apiClient);
    final categoryService = CategoryService(apiClient);
    final cartService = CartService(storage, productService);
    final checkoutService = CheckoutService();
    final favouriteService = FavouriteService(storage);
    final recentlyViewedService = RecentlyViewedService(getStorage);
    final favouriteController = FavouriteController(favouriteService);
    final orderService = OrderService(wpApiClient);
    final homeController = HomeController(
      productService,
      categoryService,
      locationService,
      recentlyViewedService,
    );

    Get.put<LocationService>(locationService, permanent: true);
    Get.put<ProductService>(productService, permanent: true);
    Get.put<CategoryService>(categoryService, permanent: true);
    Get.put<CartService>(cartService, permanent: true);
    Get.put<CheckoutService>(checkoutService, permanent: true);
    Get.put<FavouriteService>(favouriteService, permanent: true);
    Get.put<FavouriteController>(favouriteController, permanent: true);
    Get.put<HomeController>(homeController, permanent: true);
    Get.put<RecentlyViewedService>(recentlyViewedService, permanent: true);
    Get.put<OrderService>(orderService, permanent: true);
    Get.put<AddressService>(addressService, permanent: true);
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.put<BlogService>(blogService, permanent: true);
    Get.put<BlogController>(blogController, permanent: true);
    Get.put<WishlistService>(
      WishlistService(
        Get.find<ApiClient>(tag: 'wordpress'),
        Get.find<ProductService>(),
      ),
      permanent: true,
    );
    Get.lazyPut<WishlistController>(
      () => WishlistController(
        Get.find<WishlistService>(),
        Get.find<AuthService>(),
        Get.find<CartService>(),
      ),
      fenix: true,
    );
  }
}
