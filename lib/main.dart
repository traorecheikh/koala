import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:koaa/app/core/service_initializer.dart';
import 'package:koaa/app/core/theme.dart';
import 'app/routes/app_pages.dart';

/// Global theme mode read from settings at startup
late ThemeMode _initialThemeMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  // Initialize all services (opens Hive boxes)
  await ServiceInitializer.initialize();

  // Read saved theme AFTER Hive is initialized
  _initialThemeMode = _getSavedThemeMode();

  // Register lifecycle listener
  WidgetsBinding.instance.addObserver(KoalaLifecycleObserver());
  runApp(AppInfo(data: await AppInfoData.get(), child: const KoalaApp()));
}

/// Read theme mode from Hive settingsBox
ThemeMode _getSavedThemeMode() {
  try {
    final settingsBox = Hive.box('settingsBox');
    final isDarkMode = settingsBox.get('isDarkMode');
    if (isDarkMode == true) return ThemeMode.dark;
    if (isDarkMode == false) return ThemeMode.light;
  } catch (_) {
    // If box not available, use system default
  }
  return ThemeMode.system;
}

class KoalaApp extends StatelessWidget {
  const KoalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "Koala",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _initialThemeMode, // Use saved theme
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
