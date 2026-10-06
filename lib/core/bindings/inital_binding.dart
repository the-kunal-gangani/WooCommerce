import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/secure_storage_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    String? token() =>
        Get.isRegistered<AuthService>() ? Get.find<AuthService>().token : null;

    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
    Get.put<ApiClient>(ApiClient(tokenProvider: token), permanent: true);
    Get.put<ApiClient>(
      ApiClient(baseUrl: '${AppConfig.baseUrl}/wp-json', tokenProvider: token),
      tag: 'wp',
      permanent: true,
    );
    Get.put<AuthService>(
      AuthService(
        Get.find<ApiClient>(tag: 'wp'),
        Get.find<SecureStorageService>(),
        Get.find<StorageService>(),
      ),
      permanent: true,
    );
    Get.lazyPut<ProductService>(
      () => ProductService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CategoryService>(
      () => CategoryService(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}
