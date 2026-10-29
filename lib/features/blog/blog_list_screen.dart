import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/data/models/blog_post.dart';
import 'package:magna_data_ai_ecommerce/features/blog/blog_controller.dart';

class BlogListScreen extends GetView<BlogController> {
  BlogListScreen({super.key});

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _navy = Color(0xFF111827);
  static const Color _muted = Color(0xFF687386);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE7EBF2);
  static const Color _violet = Color(0xFF6D4AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryFilters()),
            SliverToBoxAdapter(child: _buildSectionHeader()),
            Obx(() {
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: _blue)),
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.posts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                );
              }

              if (controller.posts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                );
              }

              final posts = controller.posts.toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _FeaturedBlogCard(
                          post: posts.first,
                          onTap: () => _openPost(posts.first),
                        ),
                      );
                    }

                    final postIndex = index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _BlogArticleCard(
                        post: posts[postIndex],
                        onTap: () => _openPost(posts[postIndex]),
                      ),
                    );
                  }, childCount: posts.length),
                ),
              );
            }),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoadingMore.value) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 28),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _blue,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.posts.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: TextButton.icon(
                      onPressed: controller.loadMorePosts,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry loading articles'),
                    ),
                  );
                }

                return const SizedBox(height: 12);
              }),
            ),
          ],
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  void _openPost(BlogPost post) {
    Get.toNamed('/blog-details', arguments: post.id);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _blue.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: _blue,
              size: 25,
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
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: _navy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ideas, inspiration & buying guides',
                  style: TextStyle(fontSize: 12.5, color: _muted),
                ),
              ],
            ),
          ),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: IconButton(
              tooltip: 'Refresh articles',
              onPressed: controller.refreshPosts,
              icon: const Icon(Icons.refresh_rounded, color: _navy, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _navy.withAlpha(8),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchPosts,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 14, color: _navy),
          decoration: InputDecoration(
            hintText: 'Search articles, tips and guides...',
            hintStyle: const TextStyle(color: _muted, fontSize: 13),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: _muted,
              size: 23,
            ),
            suffixIcon: Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.searchPosts('');
                  controller.clearFilters();
                },
                icon: const Icon(Icons.close_rounded, color: _muted, size: 20),
              );
            }),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 43,
      child: Obx(() {
        final selectedId = controller.selectedCategoryId.value;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final selected = category.id == selectedId;

            return InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => controller.selectCategory(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 17),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _blue : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: selected ? _blue : _border),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : _muted,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 15),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Explore articles',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: _navy,
              ),
            ),
          ),
          Obx(() {
            final count = controller.posts.length;

            return Text(
              '$count ${count == 1 ? 'article' : 'articles'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
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
                Icons.menu_book_rounded,
                size: 35,
                color: _blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No articles found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another search or choose a different category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: _muted),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: controller.clearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: _muted),
            const SizedBox(height: 16),
            const Text(
              'Unable to load articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: controller.loadPosts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  static String _plainText(String html) {
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

  static String _formatDate(DateTime? date) {
    if (date == null) return 'EDITORIAL';

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

  static String _readingTime(String content) {
    final text = _plainText(content);
    final words = text.isEmpty ? 0 : text.split(' ').length;
    final minutes = (words / 200).ceil();

    return '${minutes < 1 ? 1 : minutes} min read';
  }

  static Widget _imagePlaceholder({double iconSize = 32}) {
    return Container(
      color: const Color(0xFFEEF2FF),
      alignment: Alignment.center,
      child: Icon(Icons.auto_stories_rounded, color: _violet, size: iconSize),
    );
  }

  static Widget _articleImage(
    String? url, {
    required double height,
    required double width,
    double iconSize = 32,
  }) {
    if (url == null || url.trim().isEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: _imagePlaceholder(iconSize: iconSize),
      );
    }

    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: height,
          width: width,
          child: _imagePlaceholder(iconSize: iconSize),
        );
      },
    );
  }
}

class _FeaturedBlogCard extends StatelessWidget {
  const _FeaturedBlogCard({required this.post, required this.onTap});

  final BlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = BlogListScreen._plainText(post.title);
    final excerpt = BlogListScreen._plainText(post.excerpt);
    final category = post.categoryNames.isNotEmpty
        ? post.categoryNames.first
        : 'Featured';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: BlogListScreen._border),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  BlogListScreen._articleImage(
                    post.featuredImageUrl,
                    height: 205,
                    width: double.infinity,
                    iconSize: 43,
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: BlogListScreen._blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BlogListScreen._blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BlogListScreen._navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        excerpt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BlogListScreen._muted,
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    ],
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: BlogListScreen._muted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            post.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: BlogListScreen._muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: BlogListScreen._muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          BlogListScreen._readingTime(post.content),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: BlogListScreen._muted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: BlogListScreen._blue,
                          size: 19,
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
    );
  }
}

class _BlogArticleCard extends StatelessWidget {
  const _BlogArticleCard({required this.post, required this.onTap});

  final BlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = BlogListScreen._plainText(post.title);
    final excerpt = BlogListScreen._plainText(post.excerpt);
    final category = post.categoryNames.isNotEmpty
        ? post.categoryNames.first
        : 'Article';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: BlogListScreen._border),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: BlogListScreen._articleImage(
                  post.featuredImageUrl,
                  height: 124,
                  width: 112,
                  iconSize: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BlogListScreen._blue,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: BlogListScreen._navy,
                        height: 1.35,
                      ),
                    ),
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: BlogListScreen._muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            BlogListScreen._formatDate(post.publishedAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: BlogListScreen._muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: BlogListScreen._blue,
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
    );
  }
}
