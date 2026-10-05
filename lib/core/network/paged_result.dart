import 'package:dio/dio.dart';

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.total,
    required this.totalPages,
    required this.page,
  });

  final List<T> items;
  final int total;
  final int totalPages;
  final int page;

  bool get hasMore => page < totalPages;

  factory PagedResult.fromResponse(
    Response<dynamic> response, {
    required int page,
    required T Function(Map<String, dynamic> json) parse,
  }) {
    final data = response.data;
    final list = data is List ? data : const [];
    final items = list
        .whereType<Map>()
        .map((e) => parse(Map<String, dynamic>.from(e)))
        .toList();
    return PagedResult<T>(
      items: items,
      total:
          int.tryParse(response.headers.value('x-wp-total') ?? '') ??
          items.length,
      totalPages:
          int.tryParse(response.headers.value('x-wp-totalpages') ?? '') ?? 1,
      page: page,
    );
  }
}
