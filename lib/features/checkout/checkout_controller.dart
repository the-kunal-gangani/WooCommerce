import 'package:flexify/flexify.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/order-confirmation/order_confirmation_screen.dart';

class CheckoutController extends GetxController {
  void orderConfirmation() {
    Flexify.go(OrderConfirmationScreen());
  }
}
