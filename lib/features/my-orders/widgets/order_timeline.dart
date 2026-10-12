import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.currentStep});

  final int currentStep;

  static const primary = Color(0xFF2563EB);
  static const border = Color(0xFFE1E6EE);
  static const List<(String, IconData)> _steps = [
    ('Placed', Icons.receipt_long_rounded),
    ('Processing', Icons.autorenew_rounded),
    ('Shipped', Icons.local_shipping_outlined),
    ('Delivered', Icons.inventory_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: _TimelineStep(
              label: _steps[i].$1,
              icon: _steps[i].$2,
              done: i <= currentStep,
              leftActive: i <= currentStep,
              rightActive: i < currentStep,
              isFirst: i == 0,
              isLast: i == _steps.length - 1,
            ),
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.done,
    required this.leftActive,
    required this.rightActive,
    required this.isFirst,
    required this.isLast,
  });

  final String label;
  final IconData icon;
  final bool done;
  final bool leftActive;
  final bool rightActive;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 38,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  color: isFirst
                      ? Colors.transparent
                      : (leftActive
                            ? OrderTimeline.primary
                            : OrderTimeline.border),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? OrderTimeline.primary : Colors.white,
                  border: Border.all(
                    color: done ? OrderTimeline.primary : OrderTimeline.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  done ? Icons.check_rounded : icon,
                  size: 18,
                  color: done ? Colors.white : const Color(0xFF9AA4B2),
                ),
              ),
              Expanded(
                child: Container(
                  height: 3,
                  color: isLast
                      ? Colors.transparent
                      : (rightActive
                            ? OrderTimeline.primary
                            : OrderTimeline.border),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: done ? const Color(0xFF111827) : const Color(0xFF9AA4B2),
            fontSize: 11,
            fontWeight: done ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
