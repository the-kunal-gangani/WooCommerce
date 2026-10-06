import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  // static const border = Color(0xFFE6EAF0);

  // Temporary local favourites.
  //
  // Replace this with your actual favourite controller/service
  // when that part of the backend is connected.
  final List<Product> _favourites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const _AmbientBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _favourites.isEmpty
                      ? _buildEmptyState()
                      : _buildFavouriteList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favourites',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _favourites.isEmpty
                      ? 'Your saved products'
                      : '${_favourites.length} saved ${_favourites.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          if (_favourites.isNotEmpty)
            _HeaderButton(
              icon: Icons.delete_sweep_rounded,
              onTap: _clearFavourites,
            ),
        ],
      ),
    );
  }

  Widget _buildFavouriteList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      itemCount: _favourites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final product = _favourites[index];

        return _FavouriteProductCard(
          product: product,
          onTap: () {
            Get.toNamed(AppRoutes.productDetails, arguments: product.id);
          },
          onRemove: () {
            _removeFavourite(index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            _EmptyFavouriteVisual(),

            const SizedBox(height: 30),

            const Text(
              'Nothing saved yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: navy,
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Save products you love and find them here '
              'whenever you want to come back.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),

            const SizedBox(height: 26),

            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primary, violet]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Explore products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFavourite(int index) {
    final removed = _favourites[index];

    setState(() {
      _favourites.removeAt(index);
    });

    Get.snackbar(
      'Removed from favourites',
      removed.name,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: navy,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
    );
  }

  void _clearFavourites() {
    if (_favourites.isEmpty) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Clear favourites?',
          style: TextStyle(color: navy, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'All saved products will be removed from your favourites.',
          style: TextStyle(color: muted, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              'Cancel',
              style: TextStyle(color: muted, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();

              setState(() {
                _favourites.clear();
              });
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: primary, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteProductCard extends StatelessWidget {
  const _FavouriteProductCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const navy = Color(0xFF111827);
  // static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const border = Color(0xFFE6EAF0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildImage(),

              const SizedBox(width: 14),

              Expanded(child: _buildDetails()),

              const SizedBox(width: 8),

              _RemoveButton(onTap: onRemove),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'favourite_product_${product.id}',
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(17),
        ),
        clipBehavior: Clip.antiAlias,
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? Image.network(
                product.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const _ImagePlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  );
                },
              )
            : const _ImagePlaceholder(),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (product.onSale)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'SALE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

            const Spacer(),

            if (product.averageRating > 0)
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    product.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 9),

        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: navy,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          product.priceLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: navy,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              product.canBuy
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              size: 13,
              color: product.canBuy
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
            const SizedBox(width: 5),
            Text(
              product.canBuy ? 'Available' : 'Out of stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: product.canBuy
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            Icons.favorite_rounded,
            size: 19,
            color: Color(0xFFE11D48),
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: const Color(0xFFE6EAF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF111827)),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 32,
        color: Color(0xFFB7BFCC),
      ),
    );
  }
}

class _EmptyFavouriteVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF2563EB).withValues(alpha: 0.12),
                const Color(0xFF6D4AFF).withValues(alpha: 0.04),
                Colors.transparent,
              ],
            ),
          ),
        ),

        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE6EAF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            size: 42,
            color: Color(0xFF6D4AFF),
          ),
        ),

        Positioned(
          top: 16,
          right: 10,
          child: _MiniDot(color: Color(0xFF2563EB)),
        ),

        Positioned(
          bottom: 17,
          left: 9,
          child: _MiniDot(color: Color(0xFF6D4AFF)),
        ),
      ],
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6D4AFF).withValues(alpha: 0.075),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 270,
            left: -130,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.055),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
