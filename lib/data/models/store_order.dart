import 'package:flutter/material.dart';
import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';
import 'package:magna_data_ai_ecommerce/data/models/price_info.dart';

enum OrderStatus {
  pending(
    'pending',
    'Pending payment',
    Color(0xFFF59E0B),
    Icons.schedule_rounded,
  ),
  processing(
    'processing',
    'Processing',
    Color(0xFF2563EB),
    Icons.autorenew_rounded,
  ),
  onHold(
    'on-hold',
    'On hold',
    Color(0xFFEA580C),
    Icons.pause_circle_outline_rounded,
  ),
  completed(
    'completed',
    'Completed',
    Color(0xFF15803D),
    Icons.check_circle_outline_rounded,
  ),
  cancelled('cancelled', 'Cancelled', Color(0xFFD92D20), Icons.cancel_outlined),
  refunded('refunded', 'Refunded', Color(0xFF6D4AFF), Icons.undo_rounded),
  failed('failed', 'Failed', Color(0xFFD92D20), Icons.error_outline_rounded),
  unknown('', 'Unknown', Color(0xFF687386), Icons.help_outline_rounded);

  const OrderStatus(this.slug, this.label, this.color, this.icon);

  final String slug;
  final String label;
  final Color color;
  final IconData icon;

  static OrderStatus fromSlug(String slug) {
    return OrderStatus.values.firstWhere(
      (s) => s.slug == slug,
      orElse: () => OrderStatus.unknown,
    );
  }

  bool get isNegative =>
      this == OrderStatus.cancelled ||
      this == OrderStatus.failed ||
      this == OrderStatus.refunded;
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.variationId,
    required this.name,
    required this.quantity,
    required this.subtotal,
    required this.total,
    required this.sku,
    required this.imageUrl,
  });

  final int id;
  final int productId;
  final int variationId;
  final String name;
  final int quantity;
  final int subtotal;
  final int total;
  final String sku;
  final String? imageUrl;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final image = asString(json['image']);
    return OrderItem(
      id: asInt(json['id']),
      productId: asInt(json['product_id']),
      variationId: asInt(json['variation_id']),
      name: stripHtml(asString(json['name'])),
      quantity: asInt(json['quantity'], 1),
      subtotal: asInt(json['subtotal']),
      total: asInt(json['total']),
      sku: asString(json['sku']),
      imageUrl: image.isEmpty ? null : image,
    );
  }
}

class OrderTracking {
  const OrderTracking({
    required this.provider,
    required this.number,
    required this.link,
    this.shippedAt,
  });

  final String provider;
  final String number;
  final String link;
  final DateTime? shippedAt;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      provider: asString(json['provider']),
      number: asString(json['number']),
      link: asString(json['link']),
      shippedAt: DateTime.tryParse(asString(json['date_shipped'])),
    );
  }
}

class OrderNote {
  const OrderNote({required this.id, required this.note, this.date});

  final int id;
  final String note;
  final DateTime? date;

  factory OrderNote.fromJson(Map<String, dynamic> json) {
    return OrderNote(
      id: asInt(json['id']),
      note: asString(json['note']),
      date: DateTime.tryParse(asString(json['date'])),
    );
  }
}

class OrderAddress {
  const OrderAddress({
    this.firstName = '',
    this.lastName = '',
    this.company = '',
    this.address1 = '',
    this.address2 = '',
    this.city = '',
    this.state = '',
    this.postcode = '',
    this.country = '',
    this.email = '',
    this.phone = '',
  });

  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String email;
  final String phone;

  factory OrderAddress.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return OrderAddress(
      firstName: asString(data['first_name']),
      lastName: asString(data['last_name']),
      company: asString(data['company']),
      address1: asString(data['address_1']),
      address2: asString(data['address_2']),
      city: asString(data['city']),
      state: asString(data['state']),
      postcode: asString(data['postcode']),
      country: asString(data['country']),
      email: asString(data['email']),
      phone: asString(data['phone']),
    );
  }

  String get name => '$firstName $lastName'.trim();

  bool get isEmpty => name.isEmpty && address1.isEmpty && city.isEmpty;

  List<String> get lines {
    final cityLine = [
      city,
      state,
      postcode,
    ].where((e) => e.isNotEmpty).join(', ');
    return [
      name,
      company,
      address1,
      address2,
      cityLine,
      country,
      phone,
    ].where((e) => e.isNotEmpty).toList();
  }
}

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatOrderDate(DateTime? value, {bool withTime = false}) {
  final d = value?.toLocal();
  if (d == null) {
    return '';
  }
  final date = '${d.day} ${_months[d.month - 1]} ${d.year}';
  if (!withTime) {
    return date;
  }
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  return '$date, $hour:$minute $period';
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.currency,
    required this.total,
    required this.subtotal,
    required this.discountTotal,
    required this.shippingTotal,
    required this.taxTotal,
    required this.itemCount,
    required this.items,
    required this.tracking,
    required this.paymentMethodTitle,
    required this.shippingMethod,
    required this.customerNote,
    required this.billing,
    required this.shipping,
    required this.notes,
    required this.hasDetail,
  });

  final int id;
  final String number;
  final OrderStatus status;
  final String statusLabel;
  final DateTime? createdAt;
  final PriceInfo currency;
  final int total;
  final int subtotal;
  final int discountTotal;
  final int shippingTotal;
  final int taxTotal;
  final int itemCount;
  final List<OrderItem> items;
  final List<OrderTracking> tracking;
  final String paymentMethodTitle;
  final String shippingMethod;
  final String customerNote;
  final OrderAddress billing;
  final OrderAddress shipping;
  final List<OrderNote> notes;
  final bool hasDetail;

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    return StoreOrder(
      id: asInt(json['id']),
      number: asString(json['number'], asString(json['id'])),
      status: OrderStatus.fromSlug(asString(json['status'])),
      statusLabel: asString(json['status_label']),
      createdAt: DateTime.tryParse(asString(json['date_created'])),
      currency: PriceInfo.fromJson(asMap(json['currency'])),
      total: asInt(json['total']),
      subtotal: asInt(json['subtotal']),
      discountTotal: asInt(json['discount_total']),
      shippingTotal: asInt(json['shipping_total']),
      taxTotal: asInt(json['tax_total']),
      itemCount: asInt(json['item_count']),
      items: asList(json['items'], OrderItem.fromJson),
      tracking: asList(json['tracking'], OrderTracking.fromJson),
      paymentMethodTitle: asString(json['payment_method_title']),
      shippingMethod: asString(json['shipping_method']),
      customerNote: asString(json['customer_note']),
      billing: OrderAddress.fromJson(asMap(json['billing'])),
      shipping: OrderAddress.fromJson(asMap(json['shipping'])),
      notes: asList(json['notes'], OrderNote.fromJson),
      hasDetail: json.containsKey('billing'),
    );
  }

  String get displayStatus =>
      statusLabel.isNotEmpty ? statusLabel : status.label;
  String get shortDate => formatOrderDate(createdAt);
  String get longDate => formatOrderDate(createdAt, withTime: true);
  String money(int minor) => currency.format(minor);

  int get progressStep {
    switch (status) {
      case OrderStatus.completed:
        return 3;
      case OrderStatus.processing:
        return tracking.isNotEmpty ? 2 : 1;
      case OrderStatus.onHold:
        return 1;
      default:
        return 0;
    }
  }
}
