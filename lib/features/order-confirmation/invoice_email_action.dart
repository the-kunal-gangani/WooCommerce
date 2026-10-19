import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/checkout_services.dart';

class InvoiceEmailAction extends StatefulWidget {
  const InvoiceEmailAction({super.key, required this.orderId});

  final int? orderId;

  @override
  State<InvoiceEmailAction> createState() => _InvoiceEmailActionState();
}

class _InvoiceEmailActionState extends State<InvoiceEmailAction> {
  bool _isSending = false;

  static const primary = Color(0xFF2563EB);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const border = Color(0xFFE5EAF1);

  Future<void> _emailInvoice() async {
    final orderId = widget.orderId;

    if (_isSending) return;

    if (orderId == null) {
      Get.snackbar(
        'Invoice unavailable',
        'The WooCommerce order ID could not be found.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await CheckoutService().emailInvoice(orderId);

      if (!mounted) return;

      Get.snackbar(
        'Invoice emailed',
        'Your invoice has been sent to the billing email address '
            'saved with your order.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } catch (error) {
      if (!mounted) return;

      Get.snackbar(
        'Unable to email invoice',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: primary, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your invoice',
                  style: TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Get a PDF invoice sent to the billing email address '
            'associated with this order.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _emailInvoice,
              icon: _isSending
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.email_outlined, size: 18),
              label: Text(_isSending ? 'Sending invoice...' : 'Email Invoice'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primary.withValues(alpha: 0.65),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (widget.orderId == null) ...[
            const SizedBox(height: 8),
            const Text(
              'The order ID is missing. Please check the order response.',
              style: TextStyle(color: Color(0xFFB45309), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
