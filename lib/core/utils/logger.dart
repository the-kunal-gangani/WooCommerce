import 'package:flutter/foundation.dart';

void printLog(Object? message) {
  if (kDebugMode) {
    debugPrint(message.toString());
  }
}

void logError(Object error, StackTrace? stack) {
  if (kDebugMode) {
    debugPrint('$error\n$stack');
  }
}
