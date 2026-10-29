import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/data/models/blog_post.dart';
import 'package:magna_data_ai_ecommerce/features/blog/blog_controller.dart';

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key});
  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _navy = Color(0xFF111827);
  static const Color _muted = Color(0xFF687386);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE7EBF2);
  static const Color _violet = Color(0xFF6D4AFF);

  late final BlogController _controller;
  late final Future<BlogPost> _postFuture;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<BlogController>();
    final argument = Get.arguments;
    final postId = argument is int
        ? argument
        : int.tryParse(argument?.toString() ?? '');
    if (postId == null) {
      _postFuture = Future<BlogPost>.error(Exception('Invalid article ID.'));
    } else {
      final cachedPost = _controller.posts
          .where((post) => post.id == postId)
          .firstOrNull;
      _postFuture = cachedPost != null
          ? Future<BlogPost>.value(cachedPost)
          : _controller.getPostDetails(postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: FutureBuilder<BlogPost>(
          future: _postFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _buildError(
                snapshot.error?.toString() ?? 'Article not found.',
              );
            }
            return _buildArticle(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        _buildTopBar(),
        const Expanded(
          child: Center(child: CircularProgressIndicator(color: _blue)),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: _blue.withAlpha(15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.article_outlined,
                      color: _blue,
                      size: 35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Unable to open article',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _navy,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    message.replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Go back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticle(BlogPost post) {
    final title = _plainText(post.title);
    final content = _plainText(post.content);
    final excerpt = _plainText(post.excerpt);
    final category = post.categoryNames.isNotEmpty
        ? post.categoryNames.first
        : 'MAGNA JOURNAL';

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeaturedImage(post.featuredImageUrl),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _blue.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.9,
                  ),
                ),
                if (excerpt.isNotEmpty && excerpt != title) ...[
                  const SizedBox(height: 14),
                  Text(
                    excerpt,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _buildAuthorRow(post),
                const SizedBox(height: 22),
                const Divider(color: _border, height: 1),
                const SizedBox(height: 25),
                if (content.isNotEmpty)
                  SelectableText(
                    content,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 15,
                      height: 1.85,
                    ),
                  )
                else
                  const Text(
                    'No article content is available.',
                    style: TextStyle(color: _muted, fontSize: 14),
                  ),
                const SizedBox(height: 32),
                _buildEndOfArticle(),
                const SizedBox(height: 32),
                _buildRelatedArticles(post),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedArticles(BlogPost currentPost) {
    final relatedPosts = _controller.posts
        .where((post) => post.id != currentPost.id)
        .take(3)
        .toList();

    if (relatedPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Continue Reading',
          style: TextStyle(
            color: _navy,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'More ideas and guides from Magna Journal.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 18),
        ...relatedPosts.map(_buildRelatedArticleCard),
      ],
    );
  }

  Widget _buildRelatedArticleCard(BlogPost post) {
    final category = post.categoryNames.isNotEmpty
        ? post.categoryNames.first
        : 'MAGNA JOURNAL';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.toNamed('/blogDetails', arguments: post.id);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: _buildRelatedArticleImage(post.featuredImageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _plainText(post.title),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: _muted,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _readingTime(post.content),
                            style: const TextStyle(color: _muted, fontSize: 11),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: _blue,
                            size: 17,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedArticleImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _imagePlaceholder();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          color: const Color(0xFFEEF2FF),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: _blue, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 12),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: _border),
            ),
            child: IconButton(
              tooltip: 'Go back',
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded, color: _navy),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Magna Journal',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text('Article', style: TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: _blue,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: SizedBox(
        width: double.infinity,
        height: 240,
        child: imageUrl == null || imageUrl.trim().isEmpty
            ? _imagePlaceholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _imagePlaceholder();
                },
              ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEEF2FF),
      alignment: Alignment.center,
      child: const Icon(Icons.auto_stories_rounded, size: 55, color: _violet),
    );
  }

  Widget _buildAuthorRow(BlogPost post) {
    final avatar = post.authorAvatarUrl;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _blue.withAlpha(15),
          backgroundImage: avatar != null && avatar.trim().isNotEmpty
              ? NetworkImage(avatar)
              : null,
          onBackgroundImageError: avatar != null && avatar.trim().isNotEmpty
              ? (exception, stackTrace) {}
              : null,
          child: avatar == null || avatar.trim().isEmpty
              ? const Icon(Icons.person_rounded, color: _blue)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatDate(post.publishedAt),
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule_rounded, color: _muted, size: 15),
              const SizedBox(width: 5),
              Text(
                _readingTime(post.content),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndOfArticle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: _blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thanks for reading',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Discover more ideas and guides in Magna Journal.',
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _plainText(String html) {
    return html
        .replaceAll(RegExp(r'<(script|style)[^>]*>.*?</\1>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8216;', '‘')
        .replaceAll('&#8220;', '“')
        .replaceAll('&#8221;', '”')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'MAGNA EDITORIAL';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _readingTime(String content) {
    final text = _plainText(content);
    final words = text.isEmpty ? 0 : text.split(' ').length;
    final minutes = (words / 200).ceil();
    return '${minutes < 1 ? 1 : minutes} min read';
  }
}
