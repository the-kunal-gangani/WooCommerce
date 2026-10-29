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

  // static const int _mockCategoryId = 1;

  bool get isMockMode => _blogBaseUrl.trim().isEmpty;

  String get _apiBaseUrl {
    final base = _blogBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$base/wp-json/wp/v2/';
  }

  final List<BlogPost> _mockPosts = [
    BlogPost(
      id: 101,
      title: 'How to Choose the Right Products for Your Needs',
      slug: 'how-to-choose-the-right-products',
      content: '''
      Finding the right product can be challenging with so many options available.
      Start by identifying your needs, comparing product features, checking reviews,
      and setting a realistic budget before making your purchase.
    ''',
      excerpt: 'Learn how to evaluate product features, compare options, and make informed purchasing decisions.',
      publishedAt: DateTime(2026, 10, 10),
      featuredImageUrl: '',
      authorName: 'Magna Editorial Team',
      authorAvatarUrl: '',
      categoryIds: [1],
      categoryNames: ['Shopping Guides'],
      permalink: '',
      commentCount: 0,
    ),
    BlogPost(
      id: 102,
      title: '5 Tips for a Better Online Shopping Experience',
      slug: 'tips-for-better-online-shopping',
      content: '''
      Online shopping becomes easier when you plan your purchases carefully.
      Compare prices, read customer reviews, check delivery details, understand
      return policies, and always review your order before completing payment.
    ''',
      excerpt: 'Discover five practical tips to make online shopping easier, safer, and more convenient.',
      publishedAt: DateTime(2026, 10, 15),
      featuredImageUrl: '',
      authorName: 'Magna Editorial Team',
      authorAvatarUrl: '',
      categoryIds: [2],
      categoryNames: ['Tips & Advice'],
      permalink: '',
      commentCount: 0,
    ),
    BlogPost(
      id: 103,
      title: 'A Practical Guide to Comparing Products Before Buying',
      slug: 'guide-to-comparing-products',
      content: '''
      Comparing products helps you find the best fit for your requirements.
      Consider specifications, quality, durability, warranty, customer feedback,
      and overall value rather than choosing based on price alone.
    ''',
      excerpt: 'Understand which factors matter most when comparing products and deciding what to buy.',
      publishedAt: DateTime(2026, 10, 20),
      featuredImageUrl: '',
      authorName: 'Magna Editorial Team',
      authorAvatarUrl: '',
      categoryIds: [3],
      categoryNames: ['Buying Guides'],
      permalink: '',
      commentCount: 0,
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
      final trimmedSearch = search?.trim();
      final response = await _dio.get<dynamic>(
        '${_apiBaseUrl}posts',
        queryParameters: {
          '_embed': '',
          'page': page,
          'per_page': perPage,
          if (trimmedSearch != null && trimmedSearch.isNotEmpty)
            'search': trimmedSearch,
          'categories': ?categoryId,
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
    if (limit <= 0) return [];
    final relatedPosts = <int, BlogPost>{};
    // Prioritize posts from the same category.
    if (categoryId != null) {
      final categoryPosts = await getPosts(
        page: 1,
        perPage: limit + 1,
        categoryId: categoryId,
      );
      for (final post in categoryPosts) {
        if (post.id != postId) {
          relatedPosts.putIfAbsent(post.id, () => post);
        }
        if (relatedPosts.length >= limit) break;
      }
    }
    // Fill any remaining slots with other recent posts.
    if (relatedPosts.length < limit) {
      final fallbackPosts = await getPosts(
        page: 1,
        perPage: (limit * 3 + 1).clamp(10, 100).toInt(),
      );
      for (final post in fallbackPosts) {
        if (post.id != postId) {
          relatedPosts.putIfAbsent(post.id, () => post);
        }
        if (relatedPosts.length >= limit) break;
      }
    }
    // Category matches remain first, followed by fallback posts.
    return relatedPosts.values.take(limit).toList();
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
