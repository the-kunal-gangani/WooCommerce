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
    final cancelled = order.status.isNegative;
    final shipped = controller.hasShipmentDate;
    final completed = controller.isCompleted;

    final placedDate = order.createdAt;
    final shippedDate = controller.shipmentDate;

    final steps = [
      _TimelineStep(
        title: 'Order placed',
        description: 'Your order was created successfully.',
        date: placedDate == null
            ? null
            : formatOrderDate(placedDate, withTime: true),
        complete: placedDate != null,
      ),
      _TimelineStep(
        title: 'In transit',
        description: shipped
            ? 'Shipment information has been recorded.'
            : 'Shipment confirmation is not available yet.',
        date: shippedDate == null
            ? null
            : formatOrderDate(shippedDate, withTime: true),
        complete: shipped,
      ),
      _TimelineStep(
        title: 'Order completed',
        description: completed
            ? 'WooCommerce marks this order as completed.'
            : 'Waiting for order completion.',
        date: null,
        complete: completed,
      ),
    ];

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
            'Tracking updates',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Follow the latest available order information.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          if (cancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.status.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Order status: ${order.displayStatus}. '
                'The standard delivery timeline may not apply.',
                style: TextStyle(
                  color: order.status.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (var i = 0; i < steps.length; i++)
            _buildTimelineStep(steps[i], isLast: i == steps.length - 1),
          if (completed)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Note: completed does not include a recorded delivery time.',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(_TimelineStep step, {required bool isLast}) {
    final color = step.complete ? _blue : const Color(0xFFD8DEE9);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: step.complete
                        ? _blue.withValues(alpha: 0.10)
                        : const Color(0xFFF1F4F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: step.complete ? _blue : _border),
                  ),
                  child: Icon(
                    step.complete ? Icons.check_rounded : Icons.circle_outlined,
                    color: color,
                    size: 17,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 54),
                      color: step.complete
                          ? _blue.withValues(alpha: 0.35)
                          : _border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 26, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: step.complete ? _navy : _muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      step.date!,
                      style: const TextStyle(
                        color: _blue,
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

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    required this.description,
    required this.date,
    required this.complete,
  });

  final String title;
  final String description;
  final String? date;
  final bool complete;
}
