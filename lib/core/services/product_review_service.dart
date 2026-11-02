import '../../core/network/api_client.dart';

class ProductReviewService {
  ProductReviewService(this._apiClient);
  final ApiClient _apiClient;

  Future<Map<String, dynamic>> submitReview({
    required int productId,
    required double rating,
    required String review,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      'wp-json/magna/v1/products/$productId/reviews',
      data: {'rating': rating.round(), 'review': review.trim()},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('The server returned an empty response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> fetchReviews({
    required int productId,
    int page = 1,
    int perPage = 10,
    String sort = 'newest',
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      'wp-json/magna/v1/products/$productId/reviews',
      query: {'page': page, 'per_page': perPage, 'sort': sort},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('The server returned an empty response.');
    }
    return data;
  }
}
