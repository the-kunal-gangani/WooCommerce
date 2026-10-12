import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/order_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/store_order.dart';

enum OrdersError { none, auth, unavailable, other }

class OrdersController extends GetxController {
  OrdersController(this._service, this._auth);

  final OrderService _service;
  final AuthService _auth;

  static const int _perPage = 10;
  static const List<(String, String)> filters = [
    ('All', ''),
    ('Processing', 'processing'),
    ('On hold', 'on-hold'),
    ('Completed', 'completed'),
    ('Cancelled', 'cancelled'),
  ];

  final orders = <StoreOrder>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final error = OrdersError.none.obs;
  final errorMessage = ''.obs;
  final status = ''.obs;
  final signedIn = false.obs;
  final scrollController = ScrollController();

  int _page = 1;
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    signedIn.value = _auth.isLoggedIn;
    scrollController.addListener(_onScroll);
    ever(_auth.user, (_) {
      signedIn.value = _auth.isLoggedIn;
      if (signedIn.value) {
        refreshList();
      } else {
        orders.clear();
      }
    });
    if (signedIn.value) {
      refreshList();
    }
  }

  void selectStatus(String value) {
    if (status.value == value) {
      return;
    }
    status.value = value;
    refreshList();
  }

  Future<void> refreshList() async {
    if (!signedIn.value) {
      return;
    }
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;
    _page = 1;
    error.value = OrdersError.none;
    isLoading.value = true;
    hasMore.value = true;
    try {
      final result = await _service.fetchOrders(
        page: 1,
        perPage: _perPage,
        status: status.value,
        cancelToken: token,
      );
      orders.assignAll(result.items);
      hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      _handleError(e);
    } finally {
      if (_cancelToken == token) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      return;
    }
    isLoadingMore.value = true;
    try {
      final next = _page + 1;
      final result = await _service.fetchOrders(
        page: next,
        perPage: _perPage,
        status: status.value,
        cancelToken: _cancelToken,
      );
      _page = next;
      orders.addAll(result.items);
      hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      if (e.type != ApiErrorType.cancelled) {
        Get.snackbar('Could not load more', e.message);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void openOrder(StoreOrder order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void _handleError(ApiException e) {
    if (e.type == ApiErrorType.cancelled) {
      return;
    }
    errorMessage.value = e.message;
    if (e.type == ApiErrorType.unauthorized ||
        e.type == ApiErrorType.forbidden) {
      error.value = OrdersError.auth;
    } else if (e.type == ApiErrorType.notFound && e.code == 'rest_no_route') {
      error.value = OrdersError.unavailable;
    } else {
      error.value = OrdersError.other;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      loadMore();
    }
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
