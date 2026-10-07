import 'package:get/get.dart';

import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/product_services.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_services.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);

    Get.put<StorageService>(StorageService(), permanent: true);

    Get.put<ApiClient>(ApiClient(), permanent: true);

    Get.put<AuthService>(
      AuthService(
        Get.find<ApiClient>(),
        Get.find<SecureStorageService>(),
        Get.find<StorageService>(),
      ),
      permanent: true,
    );

    Get.put<ProductService>(
      ProductService(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<CategoryService>(
      CategoryService(Get.find<ApiClient>()),
      permanent: true,
    );
  }
}
