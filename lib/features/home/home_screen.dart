import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/product_card.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFAFAFAF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Row(
              children: [
                Text(
                  'Discover',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black),
            onPressed: controller.openSearch,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: controller.openCart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Obx(
        () => SnakeNavigationBar.color(
          behaviour: SnakeBarBehaviour.floating,
          snakeShape: SnakeShape.circle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          snakeViewColor: primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: controller.selectedTab.value,
          onTap: (index) => controller.selectedTab.value = index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();

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
          onRefresh: controller.loadHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (banners.isNotEmpty) ...[
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 170,
                      autoPlay: banners.length > 1,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items: banners.map(_buildBanner).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                if (categories.isNotEmpty) ...[
                  _buildCategoryChips(categories, selectedId, primary),
                  const SizedBox(height: 20),
                ],
                _buildSectionHeader(popularTitle, controller.openPopular),
                if (loadingProducts)
                  const LinearProgressIndicator(minHeight: 2),
                _buildPopularGrid(popular, loadingProducts),
                if (onSale.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('On Sale', controller.openOnSale),
                  _buildOnSaleList(onSale),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBanner(Product product) {
    final subtitle = product.hasDiscount
        ? '${product.prices.discountPercent}% OFF'
        : product.priceLabel;

    return GestureDetector(
      onTap: () => controller.openProduct(product),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: product.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 100, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => controller.openProduct(product),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
    List<ProductCategory> categories,
    int selectedId,
    Color primary,
  ) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final id = index == 0 ? 0 : categories[index - 1].id;
          final label = index == 0 ? 'All' : categories[index - 1].name;
          final isSelected = selectedId == id;
          return GestureDetector(
            onTap: () => controller.selectCategory(id),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primary : Colors.grey.shade300,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularGrid(List<Product> products, bool loading) {
    if (products.isEmpty) {
      return SizedBox(
        height: 140,
        child: loading
            ? const LoadingView()
            : const EmptyView(message: 'No products in this category yet'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => controller.openProduct(product),
          );
        },
      ),
    );
  }

  Widget _buildOnSaleList(List<Product> products) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildSectionHeader(String title, VoidCallback onSeeAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: onSeeAllTap,
            child: const Text(
              'See All',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
