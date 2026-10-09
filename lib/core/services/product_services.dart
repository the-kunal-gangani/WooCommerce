import 'package:dio/dio.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';
import 'package:magna_data_ai_ecommerce/data/models/price_info.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paged_result.dart';

import 'package:magna_data_ai_ecommerce/data/models/filter_attribute.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_filter.dart';

class ProductService {
  ProductService(this._client);

  final ApiClient _client;

  Future<PagedResult<Product>> fetchProducts({
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
      '${AppConfig.storeApiPath}/products',
      query: {
        'page': page,
        'per_page': perPage,

        if (search != null && search.isNotEmpty) 'search': search,

        if (category != null && category.isNotEmpty) 'category': category,

        if (tag != null && tag.isNotEmpty) 'tag': tag,

        if (orderBy != null && orderBy.isNotEmpty) 'orderby': orderBy,

        if (order != null && order.isNotEmpty) 'order': order,

        'on_sale': ?onSale,
        'featured': ?featured,
        'min_price': ?minPrice,
        'max_price': ?maxPrice,
        'stock_status': ?stockStatus,
      },
      cancelToken: cancelToken,
    );

    return PagedResult.fromResponse(
      response,
      page: page,
      parse: Product.fromJson,
    );
  }

  Future<Product> fetchProduct(int id) async {
    final response = await _client.get<dynamic>(
      '${AppConfig.storeApiPath}/products/$id',
    );

    return Product.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<Product>> fetchVariations(int parentId) async {
    final response = await _client.get<dynamic>(
      '${AppConfig.storeApiPath}/products',
      query: {'type': 'variation', 'parent': parentId, 'per_page': 100},
    );

    final data = response.data;

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PagedResult<Product>> fetchProductsFiltered({
    required ProductFilter filter,
    int page = 1,
    int perPage = 20,
    String? search,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<dynamic>(
      '${AppConfig.storeApiPath}/products',
      query: {
        'page': page,
        'per_page': perPage,
        ...filter.toQuery(),
        if (search != null && search.isNotEmpty) 'search': search,
      },
      cancelToken: cancelToken,
    );

    return PagedResult.fromResponse(
      response,
      page: page,
      parse: Product.fromJson,
    );
  }

  Future<List<FilterAttribute>> fetchFilterAttributes() async {
    final response = await _client.get<dynamic>('/products/attributes');
    final data = response.data;
    if (data is! List) {
      return const [];
    }
    final attributes = data
        .whereType<Map>()
        .map((e) => FilterAttribute.fromJson(Map<String, dynamic>.from(e)))
        .where((a) => a.taxonomy.isNotEmpty)
        .toList();
    final withTerms = await Future.wait(
      attributes.map((attribute) async {
        final terms = await fetchAttributeTerms(attribute.id);
        return attribute.copyWith(terms: terms);
      }),
    );
    return withTerms.where((a) => a.terms.isNotEmpty).toList();
  }

  Future<List<FilterTerm>> fetchAttributeTerms(int attributeId) async {
    final response = await _client.get<dynamic>(
      '/products/attributes/$attributeId/terms',
      query: {'per_page': 100},
    );
    final data = response.data;
    if (data is! List) {
      return const [];
    }
    return data
        .whereType<Map>()
        .map((e) => FilterTerm.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.count > 0)
        .toList();
  }

  Future<PriceBounds?> fetchPriceBounds({
    Set<int> categoryIds = const {},
  }) async {
    final response = await _client.get<dynamic>(
      '/products/collection-data',
      query: {
        'calculate_price_range': true,
        if (categoryIds.isNotEmpty) 'category': categoryIds.join(','),
      },
    );
    final range = asMap(asMap(response.data)?['price_range']);
    if (range == null) {
      return null;
    }
    final min = int.tryParse('${range['min_price']}');
    final max = int.tryParse('${range['max_price']}');
    if (min == null || max == null) {
      return null;
    }
    return PriceBounds(min: min, max: max, currency: PriceInfo.fromJson(range));
  }
}
