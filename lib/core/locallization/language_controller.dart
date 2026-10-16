import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const String _storageKey = 'app_locale';
  final GetStorage _storage = GetStorage();
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
    Locale('gu', 'IN'),
    Locale('mr', 'IN'),
  ];

  static Locale get savedLocale {
    final stored = GetStorage().read<String>(_storageKey);
    for (final locale in supportedLocales) {
      if ('${locale.languageCode}_${locale.countryCode}' == stored) {
        return locale;
      }
    }
    return const Locale('en', 'US');
  }

  final RxString selectedLanguageCode = 'en_US'.obs;

  @override
  void onInit() {
    super.onInit();
    final locale = savedLocale;
    selectedLanguageCode.value = '${locale.languageCode}_${locale.countryCode}';
  }

  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode,
    )) {
      return;
    }

    final code = '${locale.languageCode}_${locale.countryCode}';
    await _storage.write(_storageKey, code);
    selectedLanguageCode.value = code;
    Get.updateLocale(locale);
  }

  String get currentLanguageName {
    switch (selectedLanguageCode.value) {
      case 'hi_IN':
        return 'हिन्दी';
      case 'gu_IN':
        return 'ગુજરાતી';
      case 'mr_IN':
        return 'मराठी';
      default:
        return 'English';
    }
  }
}
