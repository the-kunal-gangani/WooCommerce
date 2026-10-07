import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';

import '../../core/network/api_client.dart';

class CategoryService {
  CategoryService(this._client);

  final ApiClient _client;

  Future<List<ProductCategory>> fetchCategories({
    int page = 1,
    int perPage = 100,
  }) async {
    final response = await _client.get<dynamic>(
      '${AppConfig.storeApiPath}/products/categories',
      query: {'page': page, 'per_page': perPage},
    );

    final data = response.data;

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((e) => ProductCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
