import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:koala/app/bindings/initial_binding.dart';
import 'package:koala/app/data/services/hive_service.dart';
import 'package:koala/app/routes/app_pages.dart';
import 'package:koala/hive_registrar.g.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Already in FLUTTER_INTEGRATION_GUIDE.md

  // Initialize Hive CE with proper registration
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Register all Hive adapters
  Hive.registerAdapters();
  
  // Initialize Hive service (opens boxes)
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Koala',
          // theme: AppTheme.light,
          // darkTheme: AppTheme.dark,
          // themeMode: themeController.themeMode,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}
