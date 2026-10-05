import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';

class CategoryService {
  CategoryService(this._client);
  final ApiClient _client;

  Future<PagedResult<Map<String, dynamic>>> fetchCategories({
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
        if (parent != null) 'parent': parent,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PagedResult.fromResponse(
      response,
      page: page,
      parse: (json) => json,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllCategories({
    bool hideEmpty = true,
  }) async {
    final all = <Map<String, dynamic>>[];
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
