import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
