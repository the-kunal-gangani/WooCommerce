import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
  }
}
