import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/blog_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/blog_post.dart';

class BlogController extends GetxController {
  BlogController(this._blogService);
  final BlogService _blogService;
  final RxList<BlogPost> posts = <BlogPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxnInt selectedCategoryId = RxnInt();
  final ScrollController scrollController = ScrollController();

  /// A list of available blog categories.
  final List<BlogCategory> categories = const [
    BlogCategory(id: null, name: 'All'),
    BlogCategory(id: 1, name: 'Shopping Guides'),
    BlogCategory(id: 2, name: 'Tips & Advice'),
    BlogCategory(id: 3, name: 'Buying Guides'),
  ];
  static const int _pageSize = 10;

  int _currentPage = 1;
  Timer? _searchDebounce;
  bool _requestInProgress = false;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    // Start loading before the user reaches the bottom.
    if (position.pixels >= position.maxScrollExtent - 300) {
      loadMorePosts();
    }
  }

  /// Loads the first page, replacing the existing list.
  Future<void> loadPosts() async {
    if (_requestInProgress) return;
    _requestInProgress = true;
    isLoading.value = true;
    errorMessage.value = '';
    _currentPage = 1;
    hasMore.value = true;

    try {
      final result = await _blogService.getPosts(
        page: _currentPage,
        perPage: _pageSize,
        search: searchQuery.value,
        categoryId: selectedCategoryId.value,
      );
      posts.assignAll(result);
      hasMore.value = result.length >= _pageSize;
      _currentPage = 1;
    } catch (error) {
      errorMessage.value = _friendlyError(error);
    } finally {
      isLoading.value = false;
      _requestInProgress = false;
    }
  }

  /// Refreshes the current list from the first page.
  Future<void> refreshPosts() async {
    await loadPosts();
  }

  /// Debounces search input to avoid sending a request for every keystroke.
  void searchPosts(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => loadPosts(),
    );
  }

  /// Applies or clears the category filter.
  Future<void> selectCategory(int? categoryId) async {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    await loadPosts();
  }

  /// Loads the next page when more posts may be available.
  Future<void> loadMorePosts() async {
    if (_requestInProgress ||
        isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value) {
      return;
    }
    _requestInProgress = true;
    isLoadingMore.value = true;
    try {
      final nextPage = _currentPage + 1;
      final result = await _blogService.getPosts(
        page: nextPage,
        perPage: _pageSize,
        search: searchQuery.value,
        categoryId: selectedCategoryId.value,
      );
      if (result.isEmpty) {
        hasMore.value = false;
        return;
      }
      posts.addAll(result);
      _currentPage = nextPage;
      hasMore.value = result.length >= _pageSize;
    } catch (error) {
      errorMessage.value = _friendlyError(error);
    } finally {
      isLoadingMore.value = false;
      _requestInProgress = false;
    }
  }

  /// Clears search and category filters.
  Future<void> clearFilters() async {
    _searchDebounce?.cancel();
    searchQuery.value = '';
    selectedCategoryId.value = null;
    await loadPosts();
  }

  /// Loads a single article for the detail screen.
  Future<BlogPost> getPostDetails(int postId) {
    return _blogService.getPostById(postId);
  }

  /// Loads related articles for a specific blog post.
  Future<List<BlogPost>> getRelatedPosts(BlogPost post, {int limit = 3}) {
    final categoryId = post.categoryIds.isNotEmpty
        ? post.categoryIds.first
        : null;
    return _blogService.getRelatedPosts(
      postId: post.id,
      categoryId: categoryId,
      limit: limit,
    );
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}

class BlogCategory {
  /// Creates a new blog category.
  const BlogCategory({required this.id, required this.name});

  /// The unique identifier for the category.
  final int? id;
  final String name;
}
