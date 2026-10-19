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

const String _notificationHistoryKey = 'magna_app_notifications';

/// Handles FCM messages when the application is in the background.
/// This handler runs in a separate isolate, so it persists notification
/// data directly instead of depending on GetX controllers.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  final storage = GetStorage();
  final id = _messageId(message);
  final saved =
      storage.read<List<dynamic>>(_notificationHistoryKey) ?? <dynamic>[];
  final alreadyExists = saved.any((item) {
    if (item is! Map) return false;
    return item['id']?.toString() == id;
  });
  if (alreadyExists) return;
  final notification = _notificationToJson(message, id);
  saved.insert(0, notification);
  await storage.write(_notificationHistoryKey, saved.take(100).toList());
  if (kDebugMode) {
    debugPrint('Background notification saved: $id');
  }
}

/// Firebase Cloud Messaging integration for Magna Data Store.
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
      // Also sync a disabled preference when a token refreshes.
      _registerTokenWithBackend(enabledOverride: notificationsEnabled.value);
    });
    if (notificationsEnabled.value) {
      await _enableNotifications(requestPermission: false);
    }
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && notificationsEnabled.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }
    return this;
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
    // Update the backend preference, if the user is authenticated.
    try {
      _fcmToken ??= await _messaging.getToken();
      await _registerTokenWithBackend(enabledOverride: false);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Could not sync disabled notification preference: $error');
      }
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
      notificationsEnabled.value = true;
      await _storage.write(_preferenceKey, true);
      if (kDebugMode) {
        debugPrint('FCM token available: ${_fcmToken != null}');
      }
      await _registerTokenWithBackend(enabledOverride: true);
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

  /// Saves incoming messages and displays a snackbar in the foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!notificationsEnabled.value) return;
    await _persistMessage(message);
    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Magna Data Store';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';
    if (message.notification != null || body.isNotEmpty) {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        onTap: (_) => _handleNotificationTap(message),
      );
    }
  }

  /// Saves a message to GetStorage and updates the controller if present.
  Future<void> _persistMessage(RemoteMessage message) async {
    final id = _messageId(message);
    final storage = GetStorage();
    final saved =
        storage.read<List<dynamic>>(_notificationHistoryKey) ?? <dynamic>[];
    final alreadyExists = saved.any((item) {
      if (item is! Map) return false;
      return item['id']?.toString() == id;
    });
    if (alreadyExists) {
      // A background handler may have saved it while the app was paused.
      _updateRegisteredController(message, id);
      return;
    }
    final json = _notificationToJson(message, id);
    saved.insert(0, json);
    await storage.write(_notificationHistoryKey, saved.take(100).toList());
    _updateRegisteredController(message, id);
    if (kDebugMode) {
      debugPrint('Notification saved: $id');
    }
  }

  /// Updates an existing notification controller without creating duplicates.
  void _updateRegisteredController(RemoteMessage message, String id) {
    if (!Get.isRegistered<NotificationsController>()) return;
    final controller = Get.find<NotificationsController>();
    final alreadyInController = controller.notifications.any(
      (item) => item.id == id,
    );
    if (alreadyInController) return;
    final json = _notificationToJson(message, id);
    controller.addNotification(AppNotification.fromJson(json));
  }

  /// Called after a notification is tapped or opened from a terminated app.
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    if (!notificationsEnabled.value) return;
    await _persistMessage(message);
    if (kDebugMode) {
      debugPrint('Notification tapped: ${_messageId(message)}');
      debugPrint('Notification data: ${message.data}');
    }
    Get.toNamed('/notifications');
  }

  /// Allows AuthService to register the device after successful login.
  /// Call this after the access token has been saved.
  Future<void> syncTokenWithBackend() async {
    try {
      _fcmToken ??= await _messaging.getToken();
      await _registerTokenWithBackend(
        enabledOverride: notificationsEnabled.value,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM token sync failed: $error');
      }
    }
  }

  /// Registers or updates the device token through the authenticated API.
  /// Endpoint: POST /notifications/devices/register
  Future<void> _registerTokenWithBackend({bool? enabledOverride}) async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<AuthService>() ||
        !Get.isRegistered<ApiClient>(tag: 'fastApi')) {
      if (kDebugMode) {
        debugPrint('FCM registration deferred: API services are unavailable.');
      }
      return;
    }
    final authService = Get.find<AuthService>();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('FCM registration deferred until login.');
      }
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
      await api.dio.post<dynamic>(
        '/notifications/devices/register',
        data: {
          'token': token,
          'platform': platform,
          'enabled': enabledOverride ?? notificationsEnabled.value,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (kDebugMode) {
        debugPrint('FCM device registration synced with FastAPI.');
      }
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'FCM registration failed: '
          '${error.response?.statusCode ?? 'network error'}',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM registration error: $error');
      }
    }
  }
}

/// Returns a stable ID for deduplication whenever Firebase provides one.
String _messageId(RemoteMessage message) {
  return message.messageId ??
      message.data['notification_id']?.toString() ??
      message.data['id']?.toString() ??
      'fcm_${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().microsecondsSinceEpoch}';
}

/// Converts an FCM message into the existing AppNotification JSON format.
Map<String, dynamic> _notificationToJson(RemoteMessage message, String id) {
  return {
    'id': id,
    'title':
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Magna Data Store',
    'message':
        message.notification?.body ?? message.data['body']?.toString() ?? '',
    'type': message.data['type']?.toString() ?? 'general',
    'createdAt': (message.sentTime ?? DateTime.now()).toIso8601String(),
    'isRead': false,
  };
}
