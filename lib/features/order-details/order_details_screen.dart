import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';
import 'package:magna_data_ai_ecommerce/features/my-orders/widgets/order_status_badge.dart';
import 'package:magna_data_ai_ecommerce/features/my-orders/widgets/order_timeline.dart';
import 'package:magna_data_ai_ecommerce/features/order-details/order_details_controller.dart';

class OrderDetailsScreen extends GetView<OrderDetailsController> {
  const OrderDetailsScreen({super.key});

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
          'Order Details',
          style: TextStyle(color: navy, fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        final order = controller.order.value;
        if (order == null) {
          final error = controller.errorMessage.value;
          if (error != null) {
            return ErrorView(message: error, onRetry: controller.reload);
          }
          return const LoadingView();
        }
        return RefreshIndicator(
          onRefresh: controller.reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              if (controller.isLoading.value)
                const LinearProgressIndicator(minHeight: 2),
              _buildHeader(order),
              const SizedBox(height: 14),
              _buildTracking(order),
              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildUpdates(order),
              ],
              const SizedBox(height: 14),
              _buildItems(order),
              if (order.hasDetail) ...[
                const SizedBox(height: 14),
                _buildSummary(order),
                const SizedBox(height: 14),
                _buildAddresses(order),
                if (order.customerNote.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _InfoCard(
                    icon: Icons.sticky_note_2_outlined,
                    title: 'Your note',
                    child: Text(
                      order.customerNote,
                      style: const TextStyle(color: muted, height: 1.5),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(StoreOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.number}',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed on ${order.longDate}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  order.money(order.total),
                  style: const TextStyle(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          OrderStatusBadge(status: order.status, label: order.displayStatus),
        ],
      ),
    );
  }

  Widget _buildTracking(StoreOrder order) {
    return _InfoCard(
      icon: Icons.local_shipping_outlined,
      title: 'Order tracking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.status.isNegative)
            _StatusBanner(status: order.status, label: order.displayStatus)
          else
            OrderTimeline(currentStep: order.progressStep),
          for (final shipment in order.tracking) ...[
            const SizedBox(height: 16),
            _ShipmentTile(
              shipment: shipment,
              onCopy: () => controller.copyTracking(shipment.number),
              onTrack: shipment.link.isEmpty
                  ? null
                  : () => controller.openTracking(shipment.link),
            ),
            if (!order.status.isNegative) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.orderTracking, arguments: order.id),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('View tracking details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OrderDetailsScreen.primary,
                    side: const BorderSide(color: OrderDetailsScreen.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUpdates(StoreOrder order) {
    return _InfoCard(
      icon: Icons.notifications_none_rounded,
      title: 'Updates from the store',
      child: Column(
        children: [
          for (final note in order.notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 8, color: primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.note,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatOrderDate(note.date, withTime: true),
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItems(StoreOrder order) {
    return _InfoCard(
      icon: Icons.shopping_bag_outlined,
      title: 'Items',
      child: Column(
        children: [
          for (var i = 0; i < order.items.length; i++) ...[
            if (i > 0) const Divider(height: 24, color: border),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: AppNetworkImage(
                    url: order.items[i].imageUrl,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.items[i].name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty ${order.items[i].quantity}'
                        '${order.items[i].sku.isEmpty ? '' : '  |  SKU ${order.items[i].sku}'}',
                        style: const TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.money(order.items[i].total),
                  style: const TextStyle(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(StoreOrder order) {
    return _InfoCard(
      icon: Icons.receipt_long_outlined,
      title: 'Payment summary',
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: order.money(order.subtotal)),
          if (order.discountTotal > 0)
            _SummaryRow(
              label: 'Discount',
              value: '-${order.money(order.discountTotal)}',
            ),
          _SummaryRow(
            label: order.shippingMethod.isEmpty
                ? 'Shipping'
                : 'Shipping (${order.shippingMethod})',
            value: order.money(order.shippingTotal),
          ),
          if (order.taxTotal > 0)
            _SummaryRow(label: 'Tax', value: order.money(order.taxTotal)),
          const Divider(height: 24, color: border),
          _SummaryRow(
            label: 'Total',
            value: order.money(order.total),
            bold: true,
          ),
          if (order.paymentMethodTitle.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SummaryRow(label: 'Paid with', value: order.paymentMethodTitle),
          ],
        ],
      ),
    );
  }

  Widget _buildAddresses(StoreOrder order) {
    return Column(
      children: [
        if (!order.shipping.isEmpty)
          _InfoCard(
            icon: Icons.location_on_outlined,
            title: 'Shipping address',
            child: _AddressLines(lines: order.shipping.lines),
          ),
        if (!order.shipping.isEmpty && !order.billing.isEmpty)
          const SizedBox(height: 14),
        if (!order.billing.isEmpty)
          _InfoCard(
            icon: Icons.badge_outlined,
            title: 'Billing address',
            child: _AddressLines(lines: order.billing.lines),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: OrderDetailsScreen.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: OrderDetailsScreen.primary),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: OrderDetailsScreen.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.label});

  final OrderStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This order is $label.',
              style: TextStyle(
                color: status.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentTile extends StatelessWidget {
  const _ShipmentTile({
    required this.shipment,
    required this.onCopy,
    required this.onTrack,
  });

  final OrderTracking shipment;
  final VoidCallback onCopy;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OrderDetailsScreen.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shipment.provider.isEmpty ? 'Shipment' : shipment.provider,
                  style: const TextStyle(
                    color: OrderDetailsScreen.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  shipment.number,
                  style: const TextStyle(
                    color: OrderDetailsScreen.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (shipment.shippedAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Shipped ${formatOrderDate(shipment.shippedAt)}',
                    style: const TextStyle(
                      color: OrderDetailsScreen.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: OrderDetailsScreen.muted,
          ),
          if (onTrack != null)
            FilledButton(
              onPressed: onTrack,
              style: FilledButton.styleFrom(
                backgroundColor: OrderDetailsScreen.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Track'),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? OrderDetailsScreen.navy : OrderDetailsScreen.muted,
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _AddressLines extends StatelessWidget {
  const _AddressLines({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              lines[i],
              style: TextStyle(
                color: i == 0
                    ? OrderDetailsScreen.navy
                    : OrderDetailsScreen.muted,
                fontSize: 13,
                height: 1.4,
                fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
