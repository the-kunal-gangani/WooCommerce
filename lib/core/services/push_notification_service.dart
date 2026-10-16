import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/firebase_options.dart';

/// Handles FCM messages when the app is in the background or terminated.
/// Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    debugPrint('Background FCM message: ${message.messageId}');
  }

  // Do not use GetX navigation or update UI from this handler.
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _initialized = false;

  Future<PushNotificationService> initialize() async {
    if (_initialized) return this;
    _initialized = true;

    // Register the background message handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Ask permission where supported.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('Notification permission: ${settings.authorizationStatus}');
    }

    // Obtain the device's FCM registration token.
    await _refreshToken();

    // Listen for token changes.
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;

      if (kDebugMode) {
        debugPrint('FCM token refreshed.');
      }

      // TODO: Send the refreshed token to your FastAPI backend.
    });

    // Handle messages while the app is in the foreground.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle a notification tap when the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle a notification that launched the terminated app.
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }

    return this;
  }

  Future<void> _refreshToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (kDebugMode) {
        debugPrint('FCM token available: ${_fcmToken != null}');
      }

      // TODO: Register this token with FastAPI.
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Could not retrieve FCM token: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;

    if (kDebugMode) {
      debugPrint('Foreground FCM message: ${message.messageId}');
    }

    if (notification == null) return;

    Get.snackbar(
      notification.title ?? 'Magna Data Store',
      notification.body ?? 'You have a new notification.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      onTap: (_) => _handleNotificationTap(message),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${message.messageId}');
      debugPrint('Notification data: ${message.data}');
    }
    // TODO: Navigate to the notifications screen once it exists.
    // Later, use message.data to open a specific order or product.
  }
}
