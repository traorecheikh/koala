import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/core/theme.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/hive_registrar.g.dart';
import 'package:path_provider/path_provider.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await getApplicationDocumentsDirectory();

  Hive.init(appDocDir.path);
  Hive.registerAdapters();
  await Hive.openBox<LocalUser>('userBox');
  await Hive.openBox<LocalTransaction>('transactionBox');
  await Hive.openBox<RecurringTransaction>('recurringTransactionBox');
  // await Hive.deleteFromDisk();

  runApp(AppInfo(data: await AppInfoData.get(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
          themeMode: ThemeMode.system,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
