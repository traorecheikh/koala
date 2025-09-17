import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/dashboard/views/dashboard_view.dart';
import 'package:koala/app/modules/home/controllers/home_controller.dart';
import 'package:koala/app/modules/insights/views/insights_view.dart';
import 'package:koala/app/modules/settings/views/settings_view.dart';
import 'package:koala/app/modules/transactions/views/transactions_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DashboardView(),
            TransactionsView(),
            InsightsView(),
            SettingsView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurfaceVariant,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11.sp,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Tableau de bord',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz_outlined),
                activeIcon: Icon(Icons.swap_horiz_rounded),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                activeIcon: Icon(Icons.insights_rounded),
                label: 'Analyses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
