import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magna_data_ai_ecommerce/firebase_options.dart';
import 'package:magna_data_ai_ecommerce/my_app/my_app.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/push_notification_service.dart';

import 'core/utils/logger.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await ScreenUtil.ensureScreenSize();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();
  Get.put(PushNotificationService(), permanent: true);
  runApp(const MyApp());
  await Get.find<PushNotificationService>().initialize();
}

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logError(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error, stack);
    return true;
  };
  runZonedGuarded(_bootstrap, logError);
}
