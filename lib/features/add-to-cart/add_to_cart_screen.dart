import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE6EAF0);

  @override
  Widget build(BuildContext context) {
    void goToCheckout() {
      Get.toNamed(AppRoutes.checkout);
    }

    final List<Map<String, dynamic>> cartItems = [
      {
        'name': 'Wireless Headphones',
        'color': 'Navy Blue',
        'price': 199.99,
        'quantity': 1,
        'icon': Icons.headphones_rounded,
      },
      {
        'name': 'Ergonomic Mechanical Keyboard',
        'color': 'Matte Black',
        'price': 149.50,
        'quantity': 2,
        'icon': Icons.keyboard_rounded,
      },
      {
        'name': 'Smart Fitness Watch',
        'color': 'Silver',
        'price': 89.99,
        'quantity': 1,
        'icon': Icons.watch_rounded,
      },
    ];
    const double subtotal = 588.98;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shopping Cart',
              style: TextStyle(
                color: navy,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Review your selected items',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildCheckoutBar(subtotal: subtotal, onCheckout: goToCheckout),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${cartItems.length} items in your cart',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome_rounded, color: violet, size: 17),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCartItem(item),
            ),
          ),
          const SizedBox(height: 8),
          _buildOrderSummary(subtotal),
          const SizedBox(height: 20),
          _buildSmartHint(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item['icon'] as IconData, color: primary, size: 34),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item['color'] as String,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(item['price'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _QuantityButton(icon: Icons.add_rounded, onTap: () {}),
              const SizedBox(height: 3),
              Text(
                '${item['quantity']}',
                style: const TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              _QuantityButton(icon: Icons.remove_rounded, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 9),
          const _SummaryRow(
            label: 'Delivery',
            value: 'Free',
            valueColor: Color(0xFF15803D),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: border),
          ),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.06),
            violet.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: violet,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your selected items are ready for checkout.',
              style: TextStyle(
                color: Color(0xFF4B5565),
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar({
    required double subtotal,
    required VoidCallback onCheckout,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [primary, violet]),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 17),
                    SizedBox(width: 7),
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = CartScreen.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CartScreen.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F6F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 15, color: CartScreen.muted),
        ),
      ),
    );
  }
}
