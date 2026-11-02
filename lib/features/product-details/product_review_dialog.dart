import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_review_service.dart';
import 'package:rating_dialog/rating_dialog.dart';

Future<void> showProductReviewDialog({
  required BuildContext context,
  required int productId,
  required String productName,
  required ProductReviewService reviewService,
  VoidCallback? onSubmittedSuccessfully,
}) async {
  final dialog = RatingDialog(
    initialRating: 0,
    title: const Text(
      'Rate this product',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF111827),
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    ),
    message: Text(
      'How was your experience with $productName?',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF687386), fontSize: 14),
    ),
    starColor: const Color(0xFF2563EB),
    starSize: 36,
    submitButtonText: 'Submit Review',
    commentHint: 'Share your experience (optional)',
    enableComment: true,
    showCloseButton: true,
    force: false,
    onCancelled: () {},
    onSubmitted: (response) async {
      if (response.rating < 1 || response.rating > 5) {
        Get.snackbar(
          'Rating required',
          'Please select a star rating.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      try {
        final result = await reviewService.submitReview(
          productId: productId,
          rating: response.rating,
          review: response.comment,
        );
        final reviewData = result['review'];
        final status = reviewData is Map
            ? reviewData['status']?.toString()
            : 'pending';
        Get.snackbar(
          status == 'approved' ? 'Review published' : 'Review submitted',
          result['message']?.toString() ??
              'Thank you for sharing your feedback!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF111827),
          colorText: Colors.white,
        );
        onSubmittedSuccessfully?.call();
      } on DioException catch (error) {
        final data = error.response?.data;
        final message = data is Map ? data['message']?.toString() : null;
        Get.snackbar(
          'Unable to submit review',
          message ?? 'Please check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {
        Get.snackbar(
          'Something went wrong',
          'Your review could not be submitted. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    },
  );
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => dialog,
  );
}
