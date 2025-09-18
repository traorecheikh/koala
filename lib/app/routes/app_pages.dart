import 'package:get/get.dart';
import 'package:koala/app/modules/main/bindings/main_binding.dart';
import 'package:koala/app/modules/main/views/main_view.dart';
import 'package:koala/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:koala/app/modules/onboarding/views/onboarding_view.dart';
import 'package:koala/app/modules/settings/bindings/settings_binding.dart';
import 'package:koala/app/modules/settings/views/settings_view.dart';
import 'package:koala/app/modules/settings/views/personal_info_view.dart';
import 'package:koala/app/modules/settings/views/financial_info_view.dart';
import 'package:koala/app/modules/settings/views/change_pin_view.dart';
import 'package:koala/app/modules/settings/views/help_view.dart';
import 'package:koala/app/modules/settings/views/feedback_view.dart';
import 'package:koala/app/modules/settings/views/about_view.dart';
import 'package:koala/app/modules/settings/views/backups_view.dart';
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

    // Settings sub-routes
    GetPage(
      name: Routes.profileEdit,
      page: () => const PersonalInfoView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.profileFinancial,
      page: () => const FinancialInfoView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.changePin,
      page: () => const ChangePinView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.help,
      page: () => const HelpView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.feedback,
      page: () => const FeedbackView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.settingsBackups,
      page: () => const BackupsView(),
      binding: SettingsBinding(),
    ),

    // Add other non-main routes as needed
  ];
}
