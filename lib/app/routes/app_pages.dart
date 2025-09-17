import 'package:get/get.dart';
import 'package:koala/app/modules/main/bindings/main_binding.dart';
import 'package:koala/app/modules/main/views/main_view.dart';
import 'package:koala/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:koala/app/modules/onboarding/views/onboarding_view.dart';
import 'package:koala/app/modules/settings/bindings/settings_binding.dart';
import 'package:koala/app/modules/settings/views/settings_view.dart';
import 'package:koala/app/modules/transactions/bindings/transaction_binding.dart';
import 'package:koala/app/modules/transactions/views/transaction_view.dart';
import 'package:koala/app/routes/app_routes.dart';

class AppPages {
  static const initial = Routes.main;

  static final List<GetPage> routes = [
    GetPage(name: Routes.main, page: () => MainView(), binding: MainBinding()),
    GetPage(
      name: Routes.onboarding,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.transactions,
      page: () => TransactionView(),
      binding: TransactionBinding(),
    ),

    // Add other non-main routes as needed
  ];
}
