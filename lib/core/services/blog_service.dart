import 'package:dio/dio.dart';

import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/data/models/blog_post.dart';

class BlogService {
  BlogService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  // Leave BLOG_BASE_URL empty until the separate WordPress site is hosted.
  static const String _blogBaseUrl = String.fromEnvironment(
    'BLOG_BASE_URL',
    defaultValue: '',
  );

  static const int _mockCategoryId = 1;

  bool get isMockMode => _blogBaseUrl.trim().isEmpty;

  String get _apiBaseUrl {
    final base = _blogBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$base/wp-json/wp/v2/';
  }

  static const List<BlogPost> _mockPosts = [
    BlogPost(
      id: 1,
      title: 'How to Choose the Right Products for Your Lifestyle',
      slug: 'choose-products-for-your-lifestyle',
      excerpt:
          'A practical guide to choosing products that fit your daily needs, '
          'preferences, and budget.',
      content:
          'Choosing the right product starts with understanding your needs. '
          'Consider how you plan to use it, which features matter most, '
          'and how it fits your budget.\n\n'
          'Compare product specifications, review the materials and build '
          'quality, and consider the long-term value before making a decision.\n\n'
          'A thoughtful purchase is one that solves a real problem and '
          'continues to serve you well over time.',
      publishedAt: null,
      authorName: 'Magna Editorial',
      categoryIds: [_mockCategoryId],
      categoryNames: ['Shopping Guides'],
    ),
    BlogPost(
      id: 2,
      title: 'A Smarter Approach to Online Shopping',
      slug: 'smarter-online-shopping',
      excerpt:
          'Learn how to compare options, evaluate product details, and '
          'make more informed online purchases.',
      content:
          'Online shopping gives you access to a wide range of products, '
          'but making a good choice requires more than looking at the price.\n\n'
          'Read the product description carefully, check the specifications, '
          'and understand the delivery and return policies before placing '
          'an order.\n\n'
          'Keep your requirements in mind while comparing products. '
          'The best option is the one that offers the right balance of '
          'quality, usefulness, and price.',
      publishedAt: null,
      authorName: 'Magna Editorial',
      categoryIds: [_mockCategoryId],
      categoryNames: ['Tips & Advice'],
    ),
    BlogPost(
      id: 3,
      title: 'What to Look for Before Buying a New Product',
      slug: 'what-to-check-before-buying',
      excerpt:
          'Use this simple checklist to evaluate features, quality, '
          'compatibility, and value before you buy.',
      content:
          'Before buying a new product, start by listing the features '
          'you actually need. This helps you avoid paying for features '
          'you are unlikely to use.\n\n'
          'Check dimensions, compatibility, materials, warranty details, '
          'and any care or maintenance requirements.\n\n'
          'Finally, compare similar products and review the available '
          'purchase and support information. Taking a few extra minutes '
          'can help you make a more confident decision.',
      publishedAt: null,
      authorName: 'Magna Editorial',
      categoryIds: [_mockCategoryId],
      categoryNames: ['Buying Guides'],
    ),
  ];

  Future<List<BlogPost>> getPosts({
    int page = 1,
    int perPage = 10,
    String? search,
    int? categoryId,
  }) async {
    if (isMockMode) {
      return _getMockPosts(
        page: page,
        perPage: perPage,
        search: search,
        categoryId: categoryId,
      );
    }

    try {
      final response = await _dio.get<dynamic>(
        '${_apiBaseUrl}posts',
        queryParameters: {
          '_embed': '',
          'page': page,
          'per_page': perPage,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (search?.trim().isNotEmpty ?? false)
  'search': search!.trim(),
        },
      );

      final data = response.data;

      if (data is! List) {
        throw const FormatException('Unexpected WordPress posts response.');
      }

      return data
          .whereType<Map>()
          .map(
            (item) =>
                BlogPost.fromWordPressJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioError(error));
    } on FormatException {
      rethrow;
    }
  }

  Future<BlogPost> getPostById(int id) async {
    if (isMockMode) {
      return _mockPosts.firstWhere(
        (post) => post.id == id,
        orElse: () => throw Exception('Blog post not found.'),
      );
    }

    try {
      final response = await _dio.get<dynamic>(
        '${_apiBaseUrl}posts/$id',
        queryParameters: {'_embed': ''},
      );

      final data = response.data;

      if (data is! Map) {
        throw const FormatException('Unexpected WordPress post response.');
      }

      return BlogPost.fromWordPressJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw Exception(_readDioError(error));
    } on FormatException {
      rethrow;
    }
  }

  Future<List<BlogPost>> getRelatedPosts({
    required int postId,
    int? categoryId,
    int limit = 3,
  }) async {
    final posts = await getPosts(
      page: 1,
      perPage: limit + 1,
      categoryId: categoryId,
    );

    return posts.where((post) => post.id != postId).take(limit).toList();
  }

  List<BlogPost> _getMockPosts({
    required int page,
    required int perPage,
    String? search,
    int? categoryId,
  }) {
    final query = search?.trim().toLowerCase() ?? '';

    var filtered = _mockPosts.where((post) {
      final matchesSearch =
          query.isEmpty ||
          post.title.toLowerCase().contains(query) ||
          post.excerpt.toLowerCase().contains(query) ||
          post.content.toLowerCase().contains(query);

      final matchesCategory =
          categoryId == null || post.categoryIds.contains(categoryId);

      return matchesSearch && matchesCategory;
    }).toList();

    final start = (page - 1) * perPage;

    if (start >= filtered.length || start < 0 || perPage <= 0) {
      return [];
    }

    final end = (start + perPage).clamp(0, filtered.length);

    filtered = filtered.sublist(start, end);

    return filtered;
  }

  String _readDioError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final message = responseData['message']?.toString();

      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    return error.message ?? 'Unable to load blog content.';
  }
}
