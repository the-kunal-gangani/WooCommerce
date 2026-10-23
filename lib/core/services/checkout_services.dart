import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/models/checkout_data.dart';

class CheckoutService {
  CheckoutService() : _dio = Get.find<Dio>(tag: 'wordpress');
  final Dio _dio;

  Future<Map<String, dynamic>> createRazorpayOrder(CheckoutData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/payments/create-order',
        data: data.toJson(),
      );
      final result = response.data;
      if (result == null ||
          result['razorpay_order_id'] == null ||
          result['key_id'] == null ||
          result['amount'] == null ||
          result['subtotal'] == null ||
          result['shipping_total'] == null ||
          result['total_tax'] == null ||
          result['total'] == null) {
        throw Exception(
          'The server returned incomplete payment or order totals.',
        );
      }
      return result;
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? (error.response!.data as Map)['detail']?.toString()
          : null;
      throw Exception(message ?? 'Unable to initialize payment.');
    }
  }

  Future<void> emailInvoice(int orderId) async {
    try {
      await _dio.post<Map<String, dynamic>>('/payments/$orderId/invoice/email');
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['detail']?.toString() : null;
      throw Exception(
        message ?? 'Unable to email the invoice. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/payments/verify',
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? (error.response!.data as Map)['detail']?.toString()
          : null;
      throw Exception(message ?? 'Unable to verify payment.');
    }
  }

  Future<void> placeOrder(CheckoutData data) async {
    throw UnimplementedError(
      'The COD order endpoint has not been implemented yet.',
    );
  }
}
