import 'package:get/get.dart';
import 'package:koala/app/modules/auth/bindings/auth_binding.dart';
import 'package:koala/app/modules/auth/views/auth_view.dart';
import 'package:koala/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:koala/app/modules/dashboard/views/dashboard_view.dart';
import 'package:koala/app/modules/home/bindings/home_binding.dart';
import 'package:koala/app/modules/home/views/home_view.dart';
import 'package:koala/app/modules/insights/bindings/insights_binding.dart';
import 'package:koala/app/modules/insights/views/insights_view.dart';
import 'package:koala/app/modules/loans/bindings/loans_binding.dart';
import 'package:koala/app/modules/loans/views/loans_view.dart';
import 'package:koala/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:koala/app/modules/onboarding/views/onboarding_view.dart';
import 'package:koala/app/modules/settings/bindings/settings_binding.dart';
import 'package:koala/app/modules/settings/views/settings_view.dart';
import 'package:koala/app/modules/splash/bindings/splash_binding.dart';
import 'package:koala/app/modules/splash/views/splash_view.dart';
import 'package:koala/app/modules/transactions/bindings/transactions_binding.dart';
import 'package:koala/app/modules/transactions/views/transactions_view.dart';
import 'package:koala/app/routes/app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: Routes.insights,
      page: () => const InsightsView(),
      binding: InsightsBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.loans,
      page: () => const LoansView(),
      binding: LoansBinding(),
    ),
  ];
}
