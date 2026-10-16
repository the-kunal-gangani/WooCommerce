import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/app_notifications.dart';
import 'package:magna_data_ai_ecommerce/features/notifications/notifications_controller.dart';

import 'package:magna_data_ai_ecommerce/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  const storageKey = 'magna_app_notifications';
  final box = GetStorage();
  final id =
      message.messageId ??
      'fcm_${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
  final raw = box.read<dynamic>(storageKey);
  final history = raw is List
      ? raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : <Map<String, dynamic>>[];
  if (history.any((item) => item['id'] == id)) return;
  history.insert(0, {
    'id': id,
    'title':
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Notification',
    'message':
        message.notification?.body ?? message.data['body']?.toString() ?? '',
    'type': message.data['type']?.toString() ?? 'general',
    'createdAt': (message.sentTime ?? DateTime.now()).toIso8601String(),
    'isRead': false,
  });
  if (history.length > 100) {
    history.removeRange(100, history.length);
  }
  await box.write(storageKey, history);
  debugPrint('Background FCM message saved: $id');
}

class PushNotificationService extends GetxService {
  static const String _preferenceKey = 'push_notifications_enabled';
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GetStorage _storage = GetStorage();
  final RxBool notificationsEnabled = false.obs;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool _initialized = false;
  Future<PushNotificationService> initialize() async {
    if (_initialized) return this;
    _initialized = true;
    notificationsEnabled.value = _storage.read<bool>(_preferenceKey) ?? false;
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      if (kDebugMode) {
        debugPrint('FCM token refreshed.');
      }
      if (notificationsEnabled.value) {
        _registerTokenWithBackend();
      }
    });
    if (notificationsEnabled.value) {
      await _enableNotifications(requestPermission: true);
    }
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && notificationsEnabled.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }
    return this;
  }

  Future<void> syncTokenWithBackend() async {
    _fcmToken ??= await _messaging.getToken();
    await _registerTokenWithBackend();
  }

  /// Called by the Profile screen's notification switch.
  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      return _enableNotifications(requestPermission: true);
    }
    notificationsEnabled.value = false;
    await _storage.write(_preferenceKey, false);
    if (kDebugMode) {
      debugPrint('In-app push notifications disabled.');
    }
    return true;
  }

  Future<bool> _enableNotifications({required bool requestPermission}) async {
    try {
      final settings = requestPermission
          ? await _messaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
            )
          : await _messaging.getNotificationSettings();
      final status = settings.authorizationStatus;
      final permitted =
          status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;
      if (kDebugMode) {
        debugPrint('Notification permission: $status');
      }
      if (!permitted) {
        notificationsEnabled.value = false;
        await _storage.write(_preferenceKey, false);
        Get.snackbar(
          'Permission required',
          'Allow notifications in your device settings to enable them.',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM token available: ${_fcmToken != null}');
        debugPrint('FCM TOKEN: $_fcmToken');
      }
      notificationsEnabled.value = true;
      await _storage.write(_preferenceKey, true);
      if (kDebugMode) {
        debugPrint('FCM token available: ${_fcmToken != null}');
        debugPrint('FCM TOKEN: $_fcmToken');
      }
      _registerTokenWithBackend();
      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Could not enable notifications: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      Get.snackbar(
        'Could not enable notifications',
        'Please check your connection and try again.',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!notificationsEnabled.value) return;

    final remoteNotification = message.notification;
    final data = message.data;

    final title =
        remoteNotification?.title ??
        data['title']?.toString() ??
        'Magna Data Store';

    final body = remoteNotification?.body ?? data['body']?.toString() ?? '';

    final id =
        message.messageId ??
        data['notification_id']?.toString() ??
        data['id']?.toString() ??
        'fcm_${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().microsecondsSinceEpoch}';

    final notification = AppNotification(
      id: id,
      title: title,
      message: body,
      type: data['type']?.toString() ?? 'general',
      createdAt: message.sentTime ?? DateTime.now(),
      isRead: false,
    );

    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().addNotification(notification);
    } else {
      _saveNotificationToStorage(notification);
    }
    if (kDebugMode) {
      debugPrint('Foreground notification saved: $id');
    }
    if (remoteNotification != null || body.isNotEmpty) {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        onTap: (_) => _handleNotificationTap(message),
      );
    }
  }

  void _saveNotificationToStorage(AppNotification notification) {
    final storage = GetStorage();
    const storageKey = 'magna_app_notifications';

    final saved = storage.read<List<dynamic>>(storageKey) ?? [];

    if (saved.any(
      (item) => item is Map && item['id']?.toString() == notification.id,
    )) {
      return;
    }
    saved.insert(0, notification.toJson());
    storage.write(storageKey, saved.take(100).toList());
  }

  Future<void> _persistMessage(RemoteMessage message) async {
    const storageKey = 'magna_app_notifications';
    final box = GetStorage();
    final id =
        message.messageId ??
        'fcm_${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
    final raw = box.read<dynamic>(storageKey);
    final history = raw is List
        ? raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];
    // Avoid inserting the same FCM message twice.
    if (history.any((item) => item['id'] == id)) {
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().reloadFromStorage();
      }
      return;
    }
    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Notification';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';
    final notification = <String, dynamic>{
      'id': id,
      'title': title,
      'message': body,
      'type': message.data['type']?.toString() ?? 'general',
      'createdAt': (message.sentTime ?? DateTime.now()).toIso8601String(),
      'isRead': false,
    };
    history.insert(0, notification);
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await box.write(storageKey, history);
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().reloadFromStorage();
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    if (!notificationsEnabled.value) return;
    await _persistMessage(message);
    if (kDebugMode) {
      debugPrint('Notification tapped: ${message.messageId}');
      debugPrint('Notification data: ${message.data}');
    }
    Get.toNamed('/notifications');
  }

  Future<void> _registerTokenWithBackend({bool? enabledOverride}) async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<AuthService>() ||
        !Get.isRegistered<ApiClient>(tag: 'fastApi')) {
      debugPrint(
        'FCM registration deferred: authentication services unavailable.',
      );
      return;
    }
    final accessToken = Get.find<AuthService>().accessToken;
    // The registration endpoint requires an authenticated user.
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('FCM registration deferred until login.');
      return;
    }
    final platform = kIsWeb
        ? 'web'
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => 'android',
            TargetPlatform.iOS => 'ios',
            TargetPlatform.macOS => 'macos',
            TargetPlatform.windows => 'windows',
            TargetPlatform.linux => 'linux',
            TargetPlatform.fuchsia => 'fuchsia',
          };
    try {
      final api = Get.find<ApiClient>(tag: 'fastApi');
      await api.dio.post(
        '/notifications/devices/register',
        data: {
          'token': token,
          'platform': platform,
          'enabled': enabledOverride ?? notificationsEnabled.value,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      debugPrint('FCM device registration synced with backend.');
    } on DioException catch (error) {
      debugPrint(
        'FCM registration failed: '
        '${error.response?.statusCode ?? 'network error'}',
      );
    } catch (error) {
      debugPrint('FCM registration error: $error');
    }
  }
}
