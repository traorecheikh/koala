import 'package:get/get.dart';
import 'package:koaa/app/modules/analytics/bindings/analytics_binding.dart';
import 'package:koaa/app/modules/analytics/views/analytics_view.dart';
import 'package:koaa/app/modules/settings/bindings/categories_binding.dart';
import 'package:koaa/app/modules/settings/views/categories/categories_view.dart';
import 'package:koaa/app/modules/settings/views/recurring_transactions_view.dart';
import 'package:koaa/app/modules/settings/views/persona/discover_persona_view.dart';
import 'package:koaa/app/modules/transactions/bindings/transactions_binding.dart';
import 'package:koaa/app/modules/transactions/views/transactions_view.dart';
import 'package:koaa/app/modules/budget/bindings/budget_binding.dart';
import 'package:koaa/app/modules/budget/views/budget_view.dart';
import 'package:koaa/app/modules/debt/bindings/debt_binding.dart';
import 'package:koaa/app/modules/debt/views/debt_view.dart';
import 'package:koaa/app/modules/simulator/bindings/simulator_binding.dart';
import 'package:koaa/app/modules/simulator/views/simulator_view.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.analytics,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.recurring,
      page: () => const RecurringTransactionsView(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.persona,
      page: () => const DiscoverPersonaView(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: _Paths.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.budget,
      page: () => const BudgetView(),
      binding: BudgetBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.debt,
      page: () => const DebtView(),
      binding: DebtBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.simulator,
      page: () => const SimulatorView(),
      binding: SimulatorBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
