import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/data/models/app_notifications.dart';

class NotificationsController extends GetxController {
  static const String _storageKey = 'magna_app_notifications';

  final GetStorage _storage = GetStorage();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  final RxString selectedFilter = 'all'.obs;

  bool get hasUnread =>
      notifications.any((notification) => !notification.isRead);

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  List<AppNotification> get filteredNotifications {
    final filtered = notifications.where((notification) {
      switch (selectedFilter.value) {
        case 'unread':
          return !notification.isRead;
        case 'orders':
          return notification.type == 'order';
        case 'offers':
          return notification.type == 'offer';
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    final saved = _storage.read<List<dynamic>>(_storageKey);

    if (saved != null) {
      try {
        notifications.assignAll(
          saved.map(
            (item) => AppNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          ),
        );
      } catch (_) {
        notifications.clear();
      }
      return;
    }
    final now = DateTime.now();

    notifications.assignAll([
      AppNotification(
        id: 'demo_welcome',
        title: 'Welcome to Magna Data Store',
        message: 'Discover products and enjoy a smarter shopping experience.',
        type: 'general',
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      AppNotification(
        id: 'demo_order',
        title: 'Order updates in one place',
        message: 'When order notifications are connected, you will see updates here.',
        type: 'order',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'demo_offer',
        title: 'Offers and promotions',
        message: 'Promotional notifications will appear here when available.',
        type: 'offer',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ]);

    _persistNotifications();
  }

  Future<void> _persistNotifications() async {
    await _storage.write(
      _storageKey,
      notifications.map((item) => item.toJson()).toList(),
    );
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((item) => item.id == id);

    if (index == -1 || notifications[index].isRead) return;

    notifications[index] = notifications[index].copyWith(isRead: true);

    await _persistNotifications();
  }

  Future<void> markAllAsRead() async {
    if (!hasUnread) return;

    notifications.assignAll(
      notifications.map((item) => item.copyWith(isRead: true)),
    );

    await _persistNotifications();
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((item) => item.id == id);
    await _persistNotifications();
  }

  Future<void> clearAll() async {
    notifications.clear();
    await _persistNotifications();
  }

  Future<void> addNotification(AppNotification notification) async {
    notifications.removeWhere((item) => item.id == notification.id);
    notifications.add(notification);
    await _persistNotifications();
  }
}
