import 'package:get/get.dart';
import 'package:koala/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:koala/app/modules/dashboard/views/dashboard_view.dart';
import 'package:koala/app/modules/insights/bindings/insights_binding.dart';
import 'package:koala/app/modules/insights/views/insights_view.dart';
import 'package:koala/app/modules/loans/bindings/loans_binding.dart';
import 'package:koala/app/modules/loans/views/loans_view.dart';
import 'package:koala/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:koala/app/modules/onboarding/views/onboarding_view.dart';
import 'package:koala/app/modules/settings/bindings/settings_binding.dart';
import 'package:koala/app/modules/settings/views/settings_view.dart';
import 'package:koala/app/modules/transactions/bindings/transaction_binding.dart';
import 'package:koala/app/modules/transactions/views/transaction_view.dart';
import 'package:koala/app/routes/app_routes.dart';

class AppPages {
  static const initial = Routes.dashboard;

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.dashboard,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.loans,
      page: () => LoansView(),
      binding: LoansBinding(),
    ),
    GetPage(
      name: Routes.transactions,
      page: () => TransactionView(),
      binding: TransactionBinding(),
    ),
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
      name: Routes.insights,
      page: () => InsightsView(),
      binding: InsightsBinding(),
    ),
    // Add other routes as needed
  ];
}
