import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/product_card.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView();
        }
        final categories = controller.categories.toList();
        final popular = controller.popular.toList();
        final onSale = controller.onSale.toList();
        final banners = controller.bannerProducts;
        final selectedId = controller.selectedCategoryId.value;
        final loadingProducts = controller.isProductsLoading.value;
        final error = controller.errorMessage.value;
        final popularTitle = controller.popularTitle;
        if (error != null && popular.isEmpty && categories.isEmpty) {
          return ErrorView(message: error, onRetry: controller.loadHome);
        }
        return RefreshIndicator(
          color: primary,
          backgroundColor: Colors.white,
          onRefresh: controller.loadHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              if (banners.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 178,
                        autoPlay: banners.length > 1,
                        enlargeCenterPage: true,
                        viewportFraction: 0.91,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        autoPlayInterval: const Duration(seconds: 4),
                      ),
                      items: banners.map(_buildBannerCard).toList(),
                    ),
                  ),
                ),
              if (categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildCategorySection(categories, selectedId),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildSectionHeader(
                    title: popularTitle,
                    subtitle: 'Picked for your shopping journey',
                    icon: Icons.auto_awesome_rounded,
                    actionLabel: controller.showAllPopular.value
                        ? 'Show less'
                        : 'See all',
                    onSeeAllTap: controller.togglePopular,
                  ),
                ),
              ),
              if (loadingProducts)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: primary,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                sliver: _buildPopularGrid(
                  controller.showAllPopular.value
                      ? popular
                      : popular.take(2).toList(),
                  loadingProducts,
                ),
              ),
              if (onSale.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: _buildSectionHeader(
                      title: 'Trending Deals',
                      subtitle: 'Limited-time picks',
                      icon: Icons.local_offer_outlined,
                      actionLabel: controller.showAllOnSale.value
                          ? 'Show less'
                          : 'See all',
                      onSeeAllTap: controller.toggleOnSale,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildOnSaleList(
                    controller.showAllOnSale.value
                        ? onSale
                        : onSale.take(2).toList(),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Discover',
                      style: TextStyle(
                        color: navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [primary, violet],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.18),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Obx(() {
                  final city = controller.city.value;
                  final isLoading = controller.isLocationLoading.value;

                  return GestureDetector(
                    onTap: isLoading ? null : controller.selectLocation,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isLoading
                                ? 'Detecting your location...'
                                : city.isEmpty
                                ? 'Your shopping destination'
                                : city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          isLoading
                              ? Icons.sync_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: muted,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          _buildHeaderAction(
            icon: Icons.shopping_bag_outlined,
            onTap: controller.openCart,
            showBadge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE7EBF1)),
                boxShadow: [
                  BoxShadow(
                    color: navy.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: navy, size: 21),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            right: -2,
            top: -3,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: violet,
                shape: BoxShape.circle,
                border: Border.all(color: background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: controller.openSearch,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE7EBF1)),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.045),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xFF7C8798),
                size: 22,
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Search products, brands & more',
                  style: TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.openFilters,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 17,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard(Product product) {
    return Container(
      width: double.infinity,
      height: 178,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF6D4AFF)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.prices.formatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (product.imageUrl != null)
            SizedBox(
              width: 100,
              height: 120,
              child: AppNetworkImage(
                url: product.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    List<ProductCategory> categories,
    int selectedId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Explore categories',
            style: TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              final id = index == 0 ? 0 : categories[index - 1].id;
              final label = index == 0 ? 'All' : categories[index - 1].name;
              final isSelected = selectedId == id;
              return GestureDetector(
                onTap: () => controller.selectCategory(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(right: 9),
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? primary : const Color(0xFFE4E9F0),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF596579),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onSeeAllTap,
    String actionLabel = 'See all',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.12),
                  violet.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSeeAllTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGrid(List<Product> products, bool loading) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 140,
          child: loading
              ? const LoadingView()
              : const EmptyView(message: 'No products in this category yet'),
        ),
      );
    }
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => controller.openProduct(product),
        );
      }, childCount: products.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
    );
  }

  Widget _buildOnSaleList(List<Product> products) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 165,
              child: ProductCard(
                product: product,
                onTap: () => controller.openProduct(product),
              ),
            ),
          );
        },
      ),
    );
  }
}
