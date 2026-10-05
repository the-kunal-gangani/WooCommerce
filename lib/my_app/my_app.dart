import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/bindings/inital_binding.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_page.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Flexify(
      designWidth: width,
      designHeight: height,
      app: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}
