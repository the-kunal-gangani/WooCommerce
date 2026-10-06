import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paged_result.dart';

class CategoryService {
  CategoryService(this._client);

  final ApiClient _client;

  Future<PagedResult<ProductCategory>> fetchCategories({
    int page = 1,
    int perPage = 100,
    int? parent,
    String? search,
    bool hideEmpty = true,
  }) async {
    final response = await _client.get<dynamic>(
      '/products/categories',
      query: {
        'page': page,
        'per_page': perPage,
        'hide_empty': hideEmpty,
        'parent': ?parent,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PagedResult.fromResponse(
      response,
      page: page,
      parse: ProductCategory.fromJson,
    );
  }

  Future<List<ProductCategory>> fetchAllCategories({
    bool hideEmpty = true,
  }) async {
    final all = <ProductCategory>[];
    var page = 1;
    while (true) {
      final result = await fetchCategories(page: page, hideEmpty: hideEmpty);
      all.addAll(result.items);
      if (!result.hasMore) break;
      page++;
    }
    return all;
  }
}
