import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/routes/app_routes.dart';
import 'package:koala/app/shared/services/auth_service.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final accounts = <Map<String, dynamic>>[].obs;
  final totalBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAccounts();
  }

  void _loadAccounts() {
    accounts.assignAll([
      {
        'id': '1',
        'name': 'Compte Principal',
        'type': 'Banque',
        'provider': 'Ecobank',
        'balance': 180000.0,
        'accountNumber': '****1234',
        'icon': Icons.account_balance,
        'isDefault': true,
      },
      {
        'id': '2',
        'name': 'Orange Money',
        'type': 'Mobile Money',
        'provider': 'Orange',
        'balance': 45000.0,
        'accountNumber': '77 123 45 67',
        'icon': Icons.phone_android,
        'isDefault': false,
      },
      {
        'id': '3',
        'name': 'Wave',
        'type': 'Mobile Money',
        'provider': 'Wave',
        'balance': 20000.0,
        'accountNumber': '70 987 65 43',
        'icon': Icons.waves,
        'isDefault': false,
      },
    ]);
    _calculateTotalBalance();
  }

  void _calculateTotalBalance() {
    totalBalance.value = accounts.fold(0, (sum, account) => sum + (account['balance'] as double));
  }

  void addAccount() {
    Get.snackbar('Add Account', 'This feature is coming soon.');
  }

  void logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.auth);
  }
}
