class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.total,
    required this.currencySymbol,
    required this.itemCount,
    required this.productNames,
  });

  final int id;
  final String orderNumber;
  final String date;
  final String status;
  final String total;
  final String currencySymbol;
  final int itemCount;
  final List<String> productNames;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = json['line_items'];

    final lineItems = rawItems is List
        ? rawItems.whereType<Map>().toList()
        : <Map>[];

    final productNames = lineItems
        .map((item) => (item['name'] ?? 'Product').toString())
        .toList();

    final itemCount = lineItems.fold<int>(
      0,
      (sum, item) => sum + (_parseInt(item['quantity']) ?? 0),
    );

    final currency = (json['currency'] ?? 'INR').toString().toUpperCase();

    return OrderSummary(
      id: _parseInt(json['id']) ?? 0,
      orderNumber: (json['number'] ?? json['id'] ?? '').toString(),
      date: _formatDate(json['date_created'] ?? json['date_created_gmt']),
      status: _formatStatus((json['status'] ?? 'pending').toString()),
      total: (json['total'] ?? '0.00').toString(),
      currencySymbol: _currencySymbol(currency),
      itemCount: itemCount,
      productNames: productNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': orderNumber,
      'date_created': date,
      'status': status,
      'total': total,
      'currency_symbol': currencySymbol,
      'item_count': itemCount,
      'product_names': productNames,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Date unavailable';
    }

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

    final date = parsed.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    // final month = date.month.toString().padLeft(2, '0');

    const months = [
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

    return '$day ${months[date.month - 1]} ${date.year}';
  }

  static String _formatStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String _currencySymbol(String currency) {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return '$currency ';
    }
  }
}
