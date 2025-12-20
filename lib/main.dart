import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:koaa/app/core/service_initializer.dart';
import 'package:koaa/app/core/theme.dart';
import 'app/routes/app_pages.dart';

import 'package:koaa/app/core/widgets/global_hero_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Register lifecycle listener
  WidgetsBinding.instance.addObserver(KoalaLifecycleObserver());
  runApp(AppInfo(data: await AppInfoData.get(), child: const KoalaApp()));
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
        return ValueListenableBuilder<AppSkin>(
          valueListenable: AppTheme.skinNotifier,
          builder: (context, skin, _) {
            return GetMaterialApp(
              title: "Koala",
              debugShowCheckedModeBanner: false,
              theme:
                  AppTheme.getTheme(skin: skin, brightness: Brightness.light),
              darkTheme:
                  AppTheme.getTheme(skin: skin, brightness: Brightness.dark),
              themeMode: ThemeMode.system,
              initialRoute: Routes.splash,
              getPages: AppPages.routes,
              builder: (context, child) {
                return GlobalHeroBackground(child: child ?? const SizedBox());
              },
            );
          },
        );
      },
    );
  }
}
