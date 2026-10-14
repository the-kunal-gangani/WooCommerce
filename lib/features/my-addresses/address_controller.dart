import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/address_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/saved_address.dart';

class AddressController extends GetxController {
  AddressController(this._service);

  final AddressService _service;

  final addresses = <SavedAddress>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final selectedType = 'shipping'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    isLoading.value = true;

    try {
      addresses.assignAll(await _service.getAddresses());
    } catch (error) {
      _showError(error, 'Unable to load addresses.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveAddress({
    int? id,
    required Map<String, dynamic> payload,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      if (id == null) {
        await _service.createAddress(payload);
      } else {
        await _service.updateAddress(id, payload);
      }

      await loadAddresses();
      Get.back();
      Get.snackbar(
        'Success',
        id == null ? 'Address added.' : 'Address updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      _showError(error, 'Unable to save address.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setDefault(SavedAddress address) async {
    try {
      await _service.setDefaultAddress(address.id);
      await loadAddresses();

      Get.snackbar(
        'Success',
        'Default ${address.addressType} address updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error, 'Unable to update the default address.');
    }
  }

  Future<void> deleteAddress(SavedAddress address) async {
    try {
      await _service.deleteAddress(address.id);
      await loadAddresses();

      Get.snackbar(
        'Success',
        'Address deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error, 'Unable to delete address.');
    }
  }

  void _showError(Object error, String fallback) {
    var message = fallback;

    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['detail'] is String) {
        message = data['detail'] as String;
      } else if (error.response == null) {
        message = 'Unable to connect to the server. Check your network.';
      }
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}
