import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/locallization/language_controller.dart';

class LanguagesPage extends GetView<LanguageController> {
  const LanguagesPage({super.key});

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _navy = Color(0xFF111827);
  static const Color _muted = Color(0xFF687386);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _violet = Color(0xFF6D4AFF);
  static const Color _border = Color(0xFFE6EAF0);

  static const List<_LanguageOption> _languages = [
    _LanguageOption(
      locale: Locale('en', 'US'),
      name: 'English',
      nativeName: 'English',
      code: 'EN',
    ),
    _LanguageOption(
      locale: Locale('hi', 'IN'),
      name: 'Hindi',
      nativeName: 'हिन्दी',
      code: 'HI',
    ),
    _LanguageOption(
      locale: Locale('gu', 'IN'),
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      code: 'GU',
    ),
    _LanguageOption(
      locale: Locale('mr', 'IN'),
      name: 'Marathi',
      nativeName: 'मराठी',
      code: 'MR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: _navy),
        ),
        title: Text(
          'languages'.tr,
          style: const TextStyle(
            color: _navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final selectedCode = controller.selectedLanguageCode.value;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primary, _violet],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.translate_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'select_language'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'language_description'.tr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'languages'.tr,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._languages.map((language) {
                      final code =
                          '${language.locale.languageCode}_'
                          '${language.locale.countryCode}';
                      final isSelected = selectedCode == code;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              controller.changeLanguage(language.locale);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? _primary : _border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _primary.withValues(alpha: 0.09)
                                          : const Color(0xFFF1F4F9),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      language.code,
                                      style: TextStyle(
                                        color: isSelected ? _primary : _muted,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language.nativeName,
                                          style: const TextStyle(
                                            color: _navy,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          language.name,
                                          style: const TextStyle(
                                            color: _muted,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: _primary,
                                      size: 24,
                                    )
                                  else
                                    const Icon(
                                      Icons.circle_outlined,
                                      color: _border,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primary, _violet],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final selected = _languages.firstWhere(
                          (language) =>
                              '${language.locale.languageCode}_'
                                  '${language.locale.countryCode}' ==
                              controller.selectedLanguageCode.value,
                        );

                        await controller.changeLanguage(selected.locale);

                        Get.snackbar(
                          'language_updated'.tr,
                          'language_updated_message'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: _navy,
                          margin: const EdgeInsets.all(16),
                        );

                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'save'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.code,
  });

  final Locale locale;
  final String name;
  final String nativeName;
  final String code;
}
