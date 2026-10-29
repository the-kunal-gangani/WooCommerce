class BlogPost {
  const BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    required this.publishedAt,
    this.featuredImageUrl,
    this.authorName = 'Magna Editorial',
    this.authorAvatarUrl,
    this.categoryIds = const [],
    this.categoryNames = const [],
    this.permalink,
    this.commentCount = 0,
  });

  final int id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final DateTime? publishedAt;
  final String? featuredImageUrl;
  final String authorName;
  final String? authorAvatarUrl;
  final List<int> categoryIds;
  final List<String> categoryNames;
  final String? permalink;
  final int commentCount;

  factory BlogPost.fromWordPressJson(Map<String, dynamic> json) {
    final embedded = _asMap(json['_embedded']);

    final mediaList = _asList(embedded?['wp:featuredmedia']);
    final media = mediaList.isNotEmpty ? _asMap(mediaList.first) : null;

    final mediaDetails = _asMap(media?['media_details']);
    final sizes = _asMap(mediaDetails?['sizes']);
    final largeSize = _asMap(sizes?['large']);

    final authorList = _asList(embedded?['author']);
    final author = authorList.isNotEmpty ? _asMap(authorList.first) : null;

    final avatarUrls = _asMap(author?['avatar_urls']);

    final categories = _asList(embedded?['wp:term'])
        .expand((group) => _asList(group))
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['taxonomy'] == 'category')
        .toList();

    final categoryIds = _asList(json['categories'])
        .map((value) => value is num ? value.toInt() : int.tryParse('$value'))
        .whereType<int>()
        .toList();

    final categoryNames = categories
        .map((item) => (item['name'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toList();

    return BlogPost(
      id: _toInt(json['id']),
      title: _rendered(json['title']),
      slug: (json['slug'] ?? '').toString(),
      content: _rendered(json['content']),
      excerpt: _rendered(json['excerpt']),
      publishedAt: DateTime.tryParse((json['date'] ?? '').toString()),
      featuredImageUrl: _firstNonEmpty([
        largeSize?['source_url'],
        media?['source_url'],
        json['featured_image_url'],
      ]),
      authorName:
          _firstNonEmpty([author?['name'], json['author_name']]) ??
          'Magna Editorial',
      authorAvatarUrl: _firstNonEmpty([avatarUrls?['48'], avatarUrls?['96']]),
      categoryIds: categoryIds,
      categoryNames: categoryNames,
      permalink: _firstNonEmpty([json['link']]),
      commentCount: _toInt(json['comment_count']),
    );
  }

  static String _rendered(dynamic value) {
    if (value is Map) {
      return (value['rendered'] ?? '').toString();
    }

    return (value ?? '').toString();
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static List<dynamic> _asList(dynamic value) {
    return value is List ? value : const <dynamic>[];
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse('$value') ?? 0;
  }

  static String? _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }
}
