import 'dart:math';

import 'package:magna_data_ai_ecommerce/core/utils/json_utils.dart';

class PriceRange {
  const PriceRange({required this.min, required this.max});

  final int min;
  final int max;
}

class PriceInfo {
  const PriceInfo({
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.currencyCode,
    required this.currencySymbol,
    required this.minorUnit,
    required this.decimalSeparator,
    required this.thousandSeparator,
    required this.prefix,
    required this.suffix,
    this.range,
  });

  final int price;
  final int regularPrice;
  final int salePrice;
  final String currencyCode;
  final String currencySymbol;
  final int minorUnit;
  final String decimalSeparator;
  final String thousandSeparator;
  final String prefix;
  final String suffix;
  final PriceRange? range;

  factory PriceInfo.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    final rangeJson = asMap(data['price_range']);
    return PriceInfo(
      price: asInt(data['price']),
      regularPrice: asInt(data['regular_price']),
      salePrice: asInt(data['sale_price']),
      currencyCode: asString(data['currency_code'], 'USD'),
      currencySymbol: asString(data['currency_symbol'], r'$'),
      minorUnit: asInt(data['currency_minor_unit'], 2),
      decimalSeparator: asString(data['currency_decimal_separator'], '.'),
      thousandSeparator: asString(data['currency_thousand_separator'], ','),
      prefix: asString(data['currency_prefix']),
      suffix: asString(data['currency_suffix']),
      range: rangeJson == null
          ? null
          : PriceRange(
              min: asInt(rangeJson['min_amount']),
              max: asInt(rangeJson['max_amount']),
            ),
    );
  }

  static const empty = PriceInfo(
    price: 0,
    regularPrice: 0,
    salePrice: 0,
    currencyCode: 'USD',
    currencySymbol: r'$',
    minorUnit: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    prefix: r'$',
    suffix: '',
  );

  double get value => price / pow(10, minorUnit);

  bool get hasDiscount => salePrice > 0 && salePrice < regularPrice;

  int get discountPercent {
    if (!hasDiscount || regularPrice == 0) return 0;
    return (((regularPrice - salePrice) / regularPrice) * 100).round();
  }

  String get formatted => format(price);

  String get formattedRegular => format(regularPrice);

  String get formattedRange {
    final r = range;
    if (r == null) return formatted;
    return '${format(r.min)} - ${format(r.max)}';
  }

  String format(int minor) {
    final negative = minor < 0;
    final absolute = minor.abs();
    final divisor = pow(10, minorUnit).toInt();
    final whole = absolute ~/ divisor;
    final fraction = absolute % divisor;
    final grouped = _group(whole.toString());
    final fractionPart = minorUnit > 0
        ? '$decimalSeparator${fraction.toString().padLeft(minorUnit, '0')}'
        : '';
    return '${negative ? '-' : ''}$prefix$grouped$fractionPart$suffix';
  }

  String _group(String digits) {
    if (thousandSeparator.isEmpty || digits.length <= 3) return digits;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(thousandSeparator);
      }
    }
    return buffer.toString();
  }
}
