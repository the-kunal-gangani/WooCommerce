import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';
import 'package:magna_data_ai_ecommerce/features/order-tracking/order_tracking_controller.dart';

class OrderTrackingScreen extends GetView<OrderTrackingController> {
  const OrderTrackingScreen({super.key});

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _navy = Color(0xFF111827);
  static const Color _muted = Color(0xFF687386);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _violet = Color(0xFF6D4AFF);
  static const Color _border = Color(0xFFE5EAF2);
  static const Color _green = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: _navy),
        ),
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: _blue));
        }

        if (controller.order.value == null) {
          return _buildError();
        }

        final order = controller.order.value!;

        return RefreshIndicator(
          color: _blue,
          onRefresh: controller.refreshOrder,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _buildOrderHeader(order),
              const SizedBox(height: 20),
              _buildTimeline(order),
              const SizedBox(height: 20),
              _buildShipmentDetails(order),
              const SizedBox(height: 20),
              _buildItems(order),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_shipping_outlined, size: 52, color: _muted),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value.isEmpty
                  ? 'Tracking details are unavailable.'
                  : controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _navy, fontSize: 15),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: controller.loadOrder,
              style: FilledButton.styleFrom(backgroundColor: _blue),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(StoreOrder order) {
    final negative = order.status.isNegative;
    final completed = order.status == OrderStatus.completed;
    final statusColor = negative
        ? order.status.color
        : completed
        ? _green
        : _blue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: _blue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order number',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${order.number}',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  order.displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: _border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  'Order date',
                  order.shortDate.isEmpty ? 'Unavailable' : order.shortDate,
                ),
              ),
              Expanded(
                child: _summaryValue('Total amount', order.money(order.total)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: _navy,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(StoreOrder order) {
    const blue = Color(0xFF2563EB);
    const green = Color(0xFF15803D);
    const red = Color(0xFFB91C1C);
    const violet = Color(0xFF6D4AFF);
    // const amber = Color(0xFFB45309);
    const muted = Color(0xFF9CA3AF);
    const textColor = Color(0xFF111827);
    const secondary = Color(0xFF687386);
    const border = Color(0xFFE5EAF2);

    final status = order.status;

    final shipmentDates = order.tracking
        .where((item) => item.shippedAt != null)
        .map((item) => item.shippedAt!)
        .toList();

    final DateTime? shipmentDate = shipmentDates.isEmpty
        ? null
        : shipmentDates.first;

    final steps = <_OrderTimelineStep>[
      _OrderTimelineStep(
        title: 'Order placed',
        description: 'Your order has been received.',
        date: _formatTimelineDate(order.createdAt),
        state: _TimelineStepState.completed,
        icon: Icons.receipt_long_outlined,
      ),
    ];

    switch (status) {
      case OrderStatus.pending:
        steps.add(
          _OrderTimelineStep(
            title: 'Payment pending',
            description: 'Your order is awaiting payment confirmation.',
            state: _TimelineStepState.current,
            icon: Icons.payments_outlined,
          ),
        );
        break;

      case OrderStatus.processing:
        steps.add(
          _OrderTimelineStep(
            title: 'Order processing',
            description: 'We are preparing your order.',
            state: _TimelineStepState.current,
            icon: Icons.inventory_2_outlined,
          ),
        );
        if (order.tracking.isNotEmpty) {
          steps.add(
            _OrderTimelineStep(
              title: 'Shipment information available',
              description: 'Tracking details have been added. Check the carrier for the latest shipment updates.',
              date: shipmentDate?.let(_formatTimelineDate),
              state: _TimelineStepState.information,
              icon: Icons.local_shipping_outlined,
            ),
          );
        } else {
          steps.add(
            _OrderTimelineStep(
              title: 'Shipment pending',
              description: 'Tracking details will appear when available.',
              state: _TimelineStepState.upcoming,
              icon: Icons.local_shipping_outlined,
            ),
          );
        }
        break;
      case OrderStatus.onHold:
        steps.add(
          _OrderTimelineStep(
            title: 'Order on hold',
            description: 'Processing is temporarily paused. Please check back for updates.',
            state: _TimelineStepState.current,
            icon: Icons.pause_circle_outline,
          ),
        );
        break;
      case OrderStatus.completed:
        steps.add(
          _OrderTimelineStep(
            title: 'Order completed',
            description: 'WooCommerce has marked this order as completed.',
            state: _TimelineStepState.completed,
            icon: Icons.check_circle_outline,
          ),
        );
        break;

      case OrderStatus.cancelled:
        steps.add(
          _OrderTimelineStep(
            title: 'Order cancelled',
            description: 'This order has been cancelled.',
            state: _TimelineStepState.negative,
            icon: Icons.cancel_outlined,
          ),
        );
        break;
      case OrderStatus.failed:
        steps.add(
          _OrderTimelineStep(
            title: 'Order failed',
            description: 'The order could not be completed. Contact support if you need assistance.',
            state: _TimelineStepState.negative,
            icon: Icons.error_outline,
          ),
        );
        break;
      case OrderStatus.refunded:
        steps.add(
          _OrderTimelineStep(
            title: 'Order refunded',
            description: 'WooCommerce has marked this order as refunded.',
            state: _TimelineStepState.refund,
            icon: Icons.currency_exchange,
          ),
        );
        break;

      case OrderStatus.unknown:
        steps.add(
          _OrderTimelineStep(
            title: order.statusLabel.isNotEmpty
                ? order.statusLabel
                : 'Status unavailable',
            description: 'We could not determine the next step for this order.',
            state: _TimelineStepState.information,
            icon: Icons.info_outline,
          ),
        );
        break;
    }

    Color colorFor(_TimelineStepState state) {
      switch (state) {
        case _TimelineStepState.completed:
          return green;
        case _TimelineStepState.current:
          return blue;
        case _TimelineStepState.information:
          return violet;
        case _TimelineStepState.negative:
          return red;
        case _TimelineStepState.refund:
          return violet;
        case _TimelineStepState.upcoming:
          return muted;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order timeline',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Updates based on your current order status.',
            style: TextStyle(fontSize: 12, color: secondary),
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < steps.length; i++)
            _buildTimelineStep(
              step: steps[i],
              color: colorFor(steps[i].state),
              isLast: i == steps.length - 1,
              connectorColor: border,
            ),
          if (status == OrderStatus.completed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No confirmed delivery timestamp is available in the current order data.',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required _OrderTimelineStep step,
    required Color color,
    required bool isLast,
    required Color connectorColor,
  }) {
    const secondary = Color(0xFF687386);
    const navy = Color(0xFF111827);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Icon(step.icon, size: 17, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: connectorColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: secondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      step.date!,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimelineDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  Widget _buildShipmentDetails(StoreOrder order) {
    final tracking = order.tracking
        .where(
          (item) =>
              item.number.isNotEmpty ||
              item.provider.isNotEmpty ||
              item.link.isNotEmpty,
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipment details',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (tracking.isEmpty)
            const Text(
              'Courier and tracking information will appear here when '
              'the store records shipment details.',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
            )
          else
            for (var i = 0; i < tracking.length; i++) ...[
              if (i > 0) const Divider(height: 24, color: _border),
              _trackingItem(tracking[i]),
            ],
        ],
      ),
    );
  }

  Widget _trackingItem(OrderTracking tracking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tracking.provider.isNotEmpty)
          _detailRow('Courier', tracking.provider),
        if (tracking.number.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tracking number',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        tracking.number,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy tracking number',
                      onPressed: () => controller.copyTracking(tracking.number),
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 17,
                        color: _blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        if (tracking.shippedAt != null) ...[
          const SizedBox(height: 12),
          _detailRow(
            'Shipment date',
            formatOrderDate(tracking.shippedAt, withTime: true),
          ),
        ],
        if (tracking.link.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.openTracking(tracking.link),
              icon: const Icon(Icons.open_in_new_rounded, size: 17),
              label: const Text('Track shipment'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: _navy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItems(StoreOrder order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items in this order',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < order.items.length; i++) ...[
            if (i > 0) const Divider(height: 24, color: _border),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: _violet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stripHtml(order.items[i].name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Qty: ${order.items[i].quantity}',
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.money(order.items[i].total),
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// class _TimelineStep {
//   const _TimelineStep({
//     required this.title,
//     required this.description,
//     required this.date,
//     required this.complete,
//   });

//   final String title;
//   final String description;
//   final String? date;
//   final bool complete;
// }

enum _TimelineStepState {
  completed,
  current,
  information,
  upcoming,
  negative,
  refund,
}

class _OrderTimelineStep {
  const _OrderTimelineStep({
    required this.title,
    required this.description,
    required this.state,
    required this.icon,
    this.date,
  });

  final String title;
  final String description;
  final String? date;
  final _TimelineStepState state;
  final IconData icon;
}
