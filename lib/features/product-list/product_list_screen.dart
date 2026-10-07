import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/product_card.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';

class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  static const Color background = Color(0xFFF7F9FC);
  static const Color navy = Color(0xFF111827);
  static const Color muted = Color(0xFF687386);
  static const Color primary = Color(0xFF2563EB);
  static const Color violet = Color(0xFF6D4AFF);

  @override
  Widget build(BuildContext context) {
    final args = controller.args;

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(args),
      body: Obx(() {
        final query = controller.query.value.trim();
        final products = controller.products.toList();
        if (args.searchMode && controller.showSuggestions.value) {
          return _buildSearchSuggestions();
        }
        if (args.searchMode && query.isEmpty) {
          return const SizedBox.shrink();
        }
        if (controller.isLoading.value && products.isEmpty) {
          return const LoadingView();
        }
        final error = controller.errorMessage.value;

        if (error != null && products.isEmpty) {
          return ErrorView(message: error, onRetry: controller.refreshList);
        }
        if (products.isEmpty) {
          return _buildNoResults(query);
        }

        return RefreshIndicator(
          color: primary,
          backgroundColor: Colors.white,
          onRefresh: controller.refreshList,
          child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 20, 18, 16),
                  child: _buildResultsHeader(query),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];

                    return ProductCard(
                      product: product,
                      onTap: () => Get.toNamed(
                        AppRoutes.productDetails,
                        arguments: product,
                      ),
                    );
                  }, childCount: products.length),
                ),
              ),

              if (controller.isLoadingMore.value)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(ProductListArgs args) {
    return AppBar(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: navy),
      ),
      titleSpacing: 0,
      title: args.searchMode
          ? _buildSearchField()
          : Text(
              args.title,
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: controller.showSuggestions.value
              ? primary.withValues(alpha: 0.35)
              : const Color(0xFFE2E7EF),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchField,
        focusNode: controller.searchFocusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          color: navy,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: primary,
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: TextStyle(
            color: const Color(0xFF9AA4B2),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: primary, size: 20),
          suffixIcon: Obx(() {
            if (controller.query.value.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Clear',
              onPressed: controller.clearSearch,
              icon: Icon(Icons.close_rounded, color: muted, size: 19),
            );
          }),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        ),
        onTap: () {
          controller.showSuggestions.value = true;

          if (controller.suggestions.isEmpty) {
            controller.loadSuggestions(query: controller.query.value.trim());
          }
        },
        onChanged: (value) {
          controller.query.value = value;
        },
        onSubmitted: (_) {
          controller.showSuggestions.value = false;
          controller.searchFocusNode.unfocus();
          controller.refreshList();
        },
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Material(
      color: background,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: primary, size: 17),
                SizedBox(width: 8),
                Text(
                  controller.query.value.trim().isEmpty
                      ? 'Recommended products'
                      : 'Matching products',
                  style: TextStyle(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final suggestions = controller.suggestions.toList();
              if (controller.isLoadingSuggestions.value &&
                  suggestions.isEmpty) {
                return _buildSuggestionLoader();
              }
              if (suggestions.isEmpty) {
                return _buildNoSuggestions();
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 2, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildSuggestionItem(suggestions[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Product product) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () {
          controller.selectSuggestion(product);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 76,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE6EAF0)),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildSuggestionImage(product),
              SizedBox(width: 12),
              Expanded(child: _buildSuggestionDetails(product)),
              SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.north_west_rounded, color: primary, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionImage(Product product) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(11),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppNetworkImage(url: product.imageUrl),
    );
  }

  Widget _buildSuggestionDetails(Product product) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: navy,
            fontSize: 13,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5),
        Text(
          product.priceLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: primary,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: const CircularProgressIndicator(strokeWidth: 2.3),
          ),
          SizedBox(height: 12),
          Text(
            'Finding products...',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSuggestions() {
    final query = controller.query.value.trim();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, color: primary, size: 28),
            ),
            SizedBox(height: 14),
            Text(
              query.isEmpty ? 'No products available' : 'No matching products',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (query.isNotEmpty) ...[
              SizedBox(height: 5),
              Text(
                'Try searching for something else.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(String query) {
    final count = controller.products.length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search results',
                style: TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Results for "$query"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '$count found',
            style: TextStyle(
              color: primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, color: primary, size: 32),
            ),
            SizedBox(height: 18),
            Text(
              'No products found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Nothing matches "$query".\nTry another product name.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
