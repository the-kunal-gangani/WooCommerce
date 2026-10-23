import 'package:dio/dio.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/network/paged_result.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';

class OrderService {
  OrderService(this._client);

  final ApiClient _client;

  Future<PagedResult<StoreOrder>> fetchOrders({
    int page = 1,
    int perPage = 10,
    String? status,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<dynamic>(
      '/orders',
      query: {
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
      },
      cancelToken: cancelToken,
    );
    final body = Map<String, dynamic>.from(response.data as Map);
    final rawItems = body['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => StoreOrder.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <StoreOrder>[];

    return PagedResult<StoreOrder>(
      items: items,
      total: int.tryParse('${body['total']}') ?? items.length,
      totalPages: int.tryParse('${body['total_pages']}') ?? 1,
      page: page,
    );
  }

  Future<StoreOrder> fetchOrder(int id) async {
    final response = await _client.get<dynamic>('/orders/$id');
    return StoreOrder.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
