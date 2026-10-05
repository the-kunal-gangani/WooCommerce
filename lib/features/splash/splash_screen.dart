import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppConfig.appName,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
