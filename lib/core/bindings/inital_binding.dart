import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_controller.dart';

import '../network/api_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.lazyPut<ProductService>(
      () => ProductService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CategoryService>(
      () => CategoryService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.put<FavouriteController>(
      FavouriteController(Get.find<StorageService>()),
      permanent: true,
    );
  }
}
