import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_category.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';

class CategoriesScreen extends GetView<HomeController> {
  const CategoriesScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE5EAF1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: Obx(() {
        final categories = controller.categories.toList();

        if (controller.isLoading.value && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }

        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: primary,
          backgroundColor: Colors.white,
          onRefresh: controller.loadHome,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              return _buildCategoryCard(categories[index]);
            },
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Explore products by category',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: _iconButton(
            icon: Icons.search_rounded,
            onTap: controller.openSearch,
          ),
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: navy, size: 19),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ProductCategory category) {
    final imageUrl = category.image?.src;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.productList,
          arguments: ProductListArgs(
            title: category.name,
            categoryId: category.id,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: 0.045),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -22,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withValues(alpha: 0.10),
                      primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Center(child: _buildCategoryImage(imageUrl))),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${category.count} products',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: primary,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.10),
              violet.withValues(alpha: 0.10),
            ],
          ),
        ),
        child: const Icon(Icons.category_rounded, color: primary, size: 32),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF1F5FF),
            ),
            child: const Icon(Icons.category_rounded, color: primary, size: 30),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.12),
                    violet.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No categories available',
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'We couldn\'t find any product categories right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: controller.loadHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
