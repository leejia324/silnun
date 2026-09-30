import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() {
  runApp(const SilnunApp());
}

class SilnunApp extends StatelessWidget {
  const SilnunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '실눈',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.onboarding,
      getPages: AppPages.pages,
    );
  }
}
