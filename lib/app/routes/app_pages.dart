import 'package:get/get.dart';
import 'package:koaa/app/modules/analytics/bindings/analytics_binding.dart';
import 'package:koaa/app/modules/analytics/views/analytics_view.dart';
import 'package:koaa/app/modules/settings/bindings/categories_binding.dart';
import 'package:koaa/app/modules/settings/views/categories/categories_view.dart';
import 'package:koaa/app/modules/settings/bindings/security_settings_binding.dart'; // New Import
import 'package:koaa/app/modules/settings/views/security_settings_view.dart'; // New Import
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
import 'package:koaa/app/modules/goals/views/goals_view.dart';
import 'package:koaa/app/modules/goals/bindings/goals_binding.dart';
import 'package:koaa/app/modules/intelligence/views/intelligence_view.dart';
import 'package:koaa/app/modules/challenges/views/challenges_view.dart';
import 'package:koaa/app/modules/challenges/bindings/challenges_binding.dart';
import 'package:koaa/app/modules/home/views/insights_view.dart'; // New Import

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;
  static const categories = '/categories';
  static const challenges = '/challenges';
  static const intelligence = '/intelligence';
  static const insights = '/insights'; // New route for detailed list

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
      // binding: SettingsBinding(), // SettingsController is now global
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
      name: _Paths.securitySettings, // New GetPage
      page: () => const SecuritySettingsView(),
      binding: SecuritySettingsBinding(),
      transition: Transition.cupertino,
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
    GetPage(
      name: _Paths.goals,
      page: () => const GoalsView(),
      binding: GoalsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.intelligence,
      page: () => const IntelligenceView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.challenges,
      page: () => const ChallengesView(),
      binding: ChallengesBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.insights,
      page: () => const InsightsView(),
    ),
  ];
}
