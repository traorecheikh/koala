import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/modules/dashboard/views/dashboard_view.dart';
import 'package:koala/app/modules/insights/views/insights_view.dart';
import 'package:koala/app/modules/loans/views/loans_view.dart';
import 'package:koala/app/modules/transactions/views/transaction_view.dart';
import 'package:koala/app/shared/widgets/koa_ai_bottom_sheet.dart';

class MainController extends GetxController {
  final selectedIndex = 0.obs;

  void onTabTapped(int index) {
    selectedIndex.value = index;
  }
}

class MainView extends StatelessWidget {
  final MainController controller = Get.find<MainController>();

  final List<Widget> _pages = [
    DashboardView(),
    TransactionView(),
    LoansView(),
    InsightsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: _pages,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => KoaAiBottomSheet.show(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.smart_toy),
          label: const Text(
            'Koa',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          tooltip: 'Parler avec Koa - Assistant IA',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 65,
          color: AppColors.background,
          elevation: 8,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_outlined),
                activeIcon: Icon(Icons.account_balance),
                label: 'Prêts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outlined),
                activeIcon: Icon(Icons.lightbulb),
                label: 'Insights',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
