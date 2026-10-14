import 'package:dio/dio.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/saved_address.dart';

class AddressService {
  AddressService(this._apiClient, this._authService);

  final ApiClient _apiClient;
  final AuthService _authService;

  Options get _authOptions {
    final token = _authService.accessToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please log in to manage your addresses.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<SavedAddress>> getAddresses({String? addressType}) async {
    final response = await _apiClient.get(
      '/addresses',
      query: {if (addressType != null) 'address_type': addressType},
      options: _authOptions,
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = data['items'] as List<dynamic>;

    return items
        .map(
          (item) =>
              SavedAddress.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<SavedAddress> createAddress(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/addresses',
      data: payload,
      options: _authOptions,
    );

    return SavedAddress.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<SavedAddress> updateAddress(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      '/addresses/$id',
      data: payload,
      options: _authOptions,
    );

    return SavedAddress.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteAddress(int id) async {
    await _apiClient.delete('/addresses/$id', options: _authOptions);
  }

  Future<SavedAddress> setDefaultAddress(int id) async {
    final response = await _apiClient.put(
      '/addresses/$id/default',
      options: _authOptions,
    );

    return SavedAddress.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
