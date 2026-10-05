// ignore_for_file: use_null_aware_elements

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paged_result.dart';

class ProductService {
  ProductService(this._client);

  final ApiClient _client;

  Future<PagedResult<Map<String, dynamic>>> fetchProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? category,
    String? tag,
    String? orderBy,
    String? order,
    bool? onSale,
    bool? featured,
    int? minPrice,
    int? maxPrice,
    String? stockStatus,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<dynamic>(
      '/products',
      query: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
        if (orderBy != null) 'orderby': orderBy,
        if (order != null) 'order': order,
        if (onSale != null) 'on_sale': onSale,
        if (featured != null) 'featured': featured,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (stockStatus != null) 'stock_status': stockStatus,
      },
      cancelToken: cancelToken,
    );
    return PagedResult.fromResponse(
      response,
      page: page,
      parse: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchProduct(int id) async {
    final response = await _client.get<dynamic>('/products/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchVariations(int parentId) async {
    final response = await _client.get<dynamic>(
      '/products',
      query: {'type': 'variation', 'parent': parentId, 'per_page': 100},
    );
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
