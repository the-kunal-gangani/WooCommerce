import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'checkout_controller.dart';

class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF7F9FC);
  static const Color navy = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF687386);
  static const Color primary = Color(0xFF2563EB);
  static const Color violet = Color(0xFF6D4AFF);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color border = Color(0xFFE5EAF1);
  static const Color softBlue = Color(0xFFEFF6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: Form(
        key: controller.addressFormKey,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 22),

                _buildSectionTitle(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery address',
                  subtitle: 'Where should we deliver your order?',
                ),

                const SizedBox(height: 12),

                _buildAddressCard(context),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  icon: Icons.local_shipping_outlined,
                  title: 'Shipping method',
                  subtitle: 'Choose how you want your order delivered',
                ),

                const SizedBox(height: 12),

                _buildShippingCard(),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Payment method',
                  subtitle: 'Select your preferred payment option',
                ),

                const SizedBox(height: 12),

                _buildPaymentCard(context),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  icon: Icons.local_offer_outlined,
                  title: 'Promo code',
                  subtitle: 'Have a discount code?',
                ),

                const SizedBox(height: 12),

                _buildCouponCard(),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order summary',
                  subtitle: 'Review your order before placing it',
                ),

                const SizedBox(height: 12),

                _buildSummaryCard(),

                const SizedBox(height: 24),

                _buildSecurityNote(),
              ],
            ),
          ),
        ),
      ),

      // Important:
      // This is intentionally outside any Obx.
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ===========================================================================
  // APP BAR
  // ===========================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 18,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkout',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Complete your purchase',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 18),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: primary,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF5F8FF), Color(0xFFF8F6FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primary, violet]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost there',
                  style: TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Review your details and place your order securely.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Icon(icon, size: 17, color: primary),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 10.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ADDRESS
  // ===========================================================================

  Widget _buildAddressCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: controller.fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }

              return null;
            },
          ),

          const SizedBox(height: 13),

          _buildTextField(
            controller: controller.phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }

              if (value.trim().length < 7) {
                return 'Enter a valid phone number';
              }

              return null;
            },
          ),

          const SizedBox(height: 13),

          _buildTextField(
            controller: controller.addressController,
            label: 'Street Address',
            hint: 'House number, street, apartment...',
            icon: Icons.home_outlined,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }

              return null;
            },
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.cityController,
                  label: 'City',
                  hint: 'City',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: _buildTextField(
                  controller: controller.stateController,
                  label: 'State',
                  hint: 'State',
                  icon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _buildTextField(
            controller: controller.postalCodeController,
            label: 'Postal Code',
            hint: 'Postal / ZIP code',
            icon: Icons.markunread_mailbox_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter postal code';
              }

              return null;
            },
          ),

          const SizedBox(height: 7),

          // Only this small widget listens to saveAddress.
          Obx(
            () => _buildCheckbox(
              context: context,
              value: controller.saveAddress.value,
              onChanged: controller.toggleSaveAddress,
              title: 'Save this address for future orders',
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SHIPPING
  // ===========================================================================

  Widget _buildShippingCard() {
    return _card(
      child: Column(
        children: [
          _buildShippingOption(
            title: 'Standard Delivery',
            subtitle: '3–5 business days',
            price: 'Free',
            icon: Icons.local_shipping_outlined,
            value: 'standard',
          ),

          const SizedBox(height: 10),

          _buildShippingOption(
            title: 'Express Delivery',
            subtitle: '1–2 business days',
            price: '\$15.00',
            icon: Icons.bolt_rounded,
            value: 'express',
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption({
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required String value,
  }) {
    return Obx(() {
      final selected = controller.selectedShippingMethod.value == value;

      return InkWell(
        onTap: () => controller.selectShippingMethod(value),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? softBlue : const Color(0xFFFAFBFD),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? primary : border,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.10)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? primary : textSecondary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                price,
                style: TextStyle(
                  color: selected ? primary : navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(width: 9),

              _RadioIndicator(selected: selected),
            ],
          ),
        ),
      );
    });
  }

  // ===========================================================================
  // PAYMENT
  // ===========================================================================

  Widget _buildPaymentCard(BuildContext context) {
    return _card(
      child: Column(
        children: [
          _buildPaymentOption(
            value: 'card',
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, RuPay and more',
            icon: Icons.credit_card_rounded,
          ),

          const SizedBox(height: 10),

          _buildPaymentOption(
            value: 'paypal',
            title: 'PayPal',
            subtitle: 'Pay securely with your PayPal account',
            icon: Icons.account_balance_wallet_outlined,
          ),

          const SizedBox(height: 10),

          _buildPaymentOption(
            value: 'cod',
            title: 'Cash on Delivery',
            subtitle: 'Pay when your order arrives',
            icon: Icons.payments_outlined,
          ),

          // Only this area listens to selectedPaymentMethod.
          Obx(() {
            if (controller.selectedPaymentMethod.value != 'card') {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _buildCardDetails(context),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Obx(() {
      final selected = controller.selectedPaymentMethod.value == value;

      return InkWell(
        onTap: () => controller.selectPaymentMethod(value),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? softBlue : const Color(0xFFFAFBFD),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? primary : border,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.10)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? primary : textSecondary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              _RadioIndicator(selected: selected),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCardDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 15, color: primary),
              SizedBox(width: 6),
              Text(
                'Card details',
                style: TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _buildTextField(
            controller: controller.cardHolderController,
            label: 'Card Holder',
            hint: 'Name on card',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 12),

          _buildTextField(
            controller: controller.cardNumberController,
            label: 'Card Number',
            hint: '1234 5678 9012 3456',
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.expiryController,
                  label: 'Expiry',
                  hint: 'MM/YY',
                  icon: Icons.calendar_today_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildTextField(
                  controller: controller.cvvController,
                  label: 'CVV',
                  hint: '123',
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Only this checkbox listens to savePaymentMethod.
          Obx(
            () => _buildCheckbox(
              context: context,
              value: controller.savePaymentMethod.value,
              onChanged: controller.toggleSavePayment,
              title: 'Save this payment method',
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // COUPON
  // ===========================================================================

  Widget _buildCouponCard() {
    return _card(
      child: Obx(() {
        final applied = controller.couponApplied.value;

        if (applied) {
          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFBF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coupon applied',
                      style: TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Discount has been applied to your order.',
                      style: TextStyle(color: textSecondary, fontSize: 10.5),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: controller.removeCoupon,
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.couponController,
                label: 'Coupon Code',
                hint: 'Enter code',
                icon: Icons.confirmation_number_outlined,
                textCapitalization: TextCapitalization.characters,
              ),
            ),

            const SizedBox(width: 10),

            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // SUMMARY
  // ===========================================================================

  Widget _buildSummaryCard() {
    return _card(
      child: Obx(() {
        final subtotal = controller.subtotal.value;
        final tax = controller.tax.value;
        final shipping = controller.shippingFee;
        final discount = controller.discount;
        final couponApplied = controller.couponApplied.value;
        final total = controller.total;

        return Column(
          children: [
            _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),

            const SizedBox(height: 11),

            _buildSummaryRow(
              'Shipping',
              shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 11),

            _buildSummaryRow('Tax', '\$${tax.toStringAsFixed(2)}'),

            if (couponApplied) ...[
              const SizedBox(height: 11),
              _buildSummaryRow(
                'Discount',
                '-\$${discount.toStringAsFixed(2)}',
                valueColor: const Color(0xFF16A34A),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: border),
            ),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      color: navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color valueColor = navy,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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

  // ===========================================================================
  // SECURITY NOTE
  // ===========================================================================

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 15,
          color: primary.withValues(alpha: 0.75),
        ),

        const SizedBox(width: 6),

        const Flexible(
          child: Text(
            'Your checkout information is handled securely.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM BAR
  // ===========================================================================

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                final total = controller.total;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(width: 12),

            Obx(() {
              final isLoading = controller.isPlacingOrder.value;

              return SizedBox(
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [primary, violet]),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.20),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : controller.placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded, size: 16),
                              SizedBox(width: 7),
                              Text(
                                'Place Order',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF263247),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            color: navy,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFA0A8B5),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),

            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, size: 17, color: textSecondary),
            ),

            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),

            filled: true,
            fillColor: const Color(0xFFFAFBFD),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primary, width: 1.3),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.3,
              ),
            ),

            errorStyle: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CHECKBOX
  // ===========================================================================

  Widget _buildCheckbox({
    required BuildContext context,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          side: const BorderSide(color: Color(0xFFCBD2DC), width: 1.2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: primary,
        title: Text(
          title,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CARD
  // ===========================================================================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ==============================================================================
// RADIO INDICATOR
// ==============================================================================

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? CheckoutScreen.primary : const Color(0xFFCBD2DC),
          width: 1.5,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: CheckoutScreen.primary,
          ),
        ),
      ),
    );
  }
}
