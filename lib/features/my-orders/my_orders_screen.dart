import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';
import 'package:magna_data_ai_ecommerce/features/my-orders/orders_controller.dart';
import 'package:magna_data_ai_ecommerce/features/my-orders/widgets/order_status_badge.dart';

class MyOrdersScreen extends GetView<OrdersController> {
  const MyOrdersScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const border = Color(0xFFE6EAF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: navy),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: navy, fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    if (!controller.signedIn.value) {
      return _MessageState(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to see your orders',
        message: 'Your order history and tracking are linked to your account.',
        actionLabel: 'Sign in',
        onAction: controller.goToLogin,
      );
    }

    final kind = controller.error.value;
    final orders = controller.orders.toList();
    final loading = controller.isLoading.value;
    final loadingMore = controller.isLoadingMore.value;

    Widget content;
    if (loading && orders.isEmpty) {
      content = const LoadingView();
    } else if (kind == OrdersError.unavailable) {
      content = _MessageState(
        icon: Icons.construction_rounded,
        title: 'Order history is not available yet',
        message: 'The store has not enabled order history for the app.',
        actionLabel: 'Try again',
        onAction: controller.refreshList,
      );
    } else if (kind == OrdersError.auth) {
      content = _MessageState(
        icon: Icons.lock_clock_outlined,
        title: 'Please sign in again',
        message: 'Your session could not be verified.',
        actionLabel: 'Sign in',
        onAction: controller.goToLogin,
      );
    } else if (kind == OrdersError.other && orders.isEmpty) {
      content = ErrorView(
        message: controller.errorMessage.value,
        onRetry: controller.refreshList,
      );
    } else if (orders.isEmpty) {
      content = _MessageState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders found',
        message: 'Orders you place while signed in will appear here.',
        actionLabel: 'Start shopping',
        onAction: () => Get.back(),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: controller.refreshList,
        child: ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: orders.length + (loadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= orders.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final order = orders[index];
            return _OrderCard(
              order: order,
              onTap: () => controller.openOrder(order),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        _buildFilters(),
        if (loading && orders.isNotEmpty)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildFilters() {
    final selected = controller.status.value;
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: OrdersController.filters.length,
        itemBuilder: (context, index) {
          final (label, slug) = OrdersController.filters[index];
          final isSelected = selected == slug;
          return GestureDetector(
            onTap: () => controller.selectStatus(slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? primary : border),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF596579),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final StoreOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbs = order.items.take(3).toList();
    final extra = order.items.length - thumbs.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: MyOrdersScreen.border),
            boxShadow: [
              BoxShadow(
                color: MyOrdersScreen.navy.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.number}',
                          style: const TextStyle(
                            color: MyOrdersScreen.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.shortDate,
                          style: const TextStyle(
                            color: MyOrdersScreen.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusBadge(
                    status: order.status,
                    label: order.displayStatus,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final item in thumbs)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: AppNetworkImage(
                          url: item.imageUrl,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (extra > 0)
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+$extra',
                        style: const TextStyle(
                          color: MyOrdersScreen.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: MyOrdersScreen.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      color: MyOrdersScreen.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.money(order.total),
                    style: const TextStyle(
                      color: MyOrdersScreen.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9AA4B2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF4FF), Color(0xFFF1EEFF)],
                ),
              ),
              child: Icon(icon, size: 38, color: MyOrdersScreen.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MyOrdersScreen.navy,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MyOrdersScreen.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: MyOrdersScreen.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
