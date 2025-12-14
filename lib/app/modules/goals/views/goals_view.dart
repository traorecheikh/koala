import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/modules/goals/views/widgets/goal_card.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/goals/views/add_goal_view.dart';

class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: _Header(onAddTap: () {
                  HapticFeedback.lightImpact();
                  _openAddGoalSheet();
                }),
              ),
            ),
            Obx(() {
              if (controller.financialGoals.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(theme),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (controller.activeGoals.isNotEmpty) ...[
                      const _SectionHeader(title: 'ACTIFS'),
                      ...controller.activeGoals.map((g) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: GestureDetector(
                          onTap: () => _showGoalDetailsBottomSheet(context, theme, g),
                          child: GoalCard(goal: g),
                        ),
                      )),
                      SizedBox(height: 16.h),
                    ],
                    if (controller.completedGoals.isNotEmpty) ...[
                      const _SectionHeader(title: 'TERMINÉS'),
                      ...controller.completedGoals.map((g) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: GestureDetector(
                          onTap: () => _showGoalDetailsBottomSheet(context, theme, g),
                          child: GoalCard(goal: g),
                        ),
                      )),
                      SizedBox(height: 16.h),
                    ],
                    if (controller.pausedGoals.isNotEmpty) ...[
                      const _SectionHeader(title: 'EN PAUSE'),
                      ...controller.pausedGoals.map((g) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: GestureDetector(
                          onTap: () => _showGoalDetailsBottomSheet(context, theme, g),
                          child: GoalCard(goal: g),
                        ),
                      )),
                      SizedBox(height: 16.h),
                    ],
                    if (controller.abandonedGoals.isNotEmpty) ...[
                      const _SectionHeader(title: 'ABANDONNÉS'),
                      ...controller.abandonedGoals.map((g) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: GestureDetector(
                          onTap: () => _showGoalDetailsBottomSheet(context, theme, g),
                          child: GoalCard(goal: g),
                        ),
                      )),
                      SizedBox(height: 32.h),
                    ],
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openAddGoalSheet({FinancialGoal? goal}) {
    Get.bottomSheet(
      AddGoalView(goalToEdit: goal),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return KoalaEmptyState(
      icon: CupertinoIcons.flag_fill,
      title: 'Pas encore d\'objectifs',
      message: 'Définissez vos objectifs financiers et suivez vos progrès pour réaliser vos rêves.',
      buttonText: 'Créer un objectif',
      onButtonPressed: () => _openAddGoalSheet(),
    );
  }

  void _showGoalDetailsBottomSheet(BuildContext context, ThemeData theme, FinancialGoal goal) {
    final isDark = theme.brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goal.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          NavigationHelper.safeBack();
                          _openAddGoalSheet(goal: goal);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          NavigationHelper.safeBack();
                          KoalaConfirmationDialog.show(
                            context: context,
                            title: 'Supprimer l\'objectif',
                            message: 'Êtes-vous sûr de vouloir supprimer "${goal.title}" ?',
                            isDestructive: true,
                            onConfirm: () async {
                              await controller.deleteGoal(goal.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(goal.description!, style: theme.textTheme.bodyMedium),
              ],
              SizedBox(height: 16.h),
              _buildDetailRow('Statut', _goalStatusToString(goal.status), theme),
              _buildDetailRow('Type', _goalTypeToString(goal.type), theme),
              _buildDetailRow('Montant cible', 'FCFA ${goal.targetAmount}', theme),
              _buildDetailRow('Montant actuel', 'FCFA ${goal.currentAmount}', theme),
              _buildDetailRow('Progression', '${goal.progressPercentage.toStringAsFixed(1)}%', theme),
              if (goal.targetDate != null)
                _buildDetailRow('Date cible',
                    '${goal.targetDate!.day}/${goal.targetDate!.month}/${goal.targetDate!.year}', theme),
              if (goal.completedAt != null)
                _buildDetailRow('Terminé le',
                    '${goal.completedAt!.day}/${goal.completedAt!.month}/${goal.completedAt!.year}', theme),
              SizedBox(height: 24.h),
              if (goal.status == GoalStatus.active)
                _buildGoalActionButton(
                  theme,
                  'Marquer comme terminé',
                  Icons.check_circle_outline,
                  Colors.green,
                  () {
                    controller.setGoalStatus(goal.id, GoalStatus.completed);
                    NavigationHelper.safeBack();
                  },
                ),
              if (goal.status == GoalStatus.completed)
                _buildGoalActionButton(
                  theme,
                  'Réactiver l\'objectif',
                  Icons.replay,
                  Colors.blue,
                  () {
                    controller.setGoalStatus(goal.id, GoalStatus.active);
                    NavigationHelper.safeBack();
                  },
                ),
              if (goal.status == GoalStatus.active || goal.status == GoalStatus.paused)
                _buildGoalActionButton(
                  theme,
                  goal.status == GoalStatus.active ? 'Mettre en pause' : 'Reprendre',
                  goal.status == GoalStatus.active ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  Colors.orange,
                  () {
                    controller.setGoalStatus(
                      goal.id,
                      goal.status == GoalStatus.active ? GoalStatus.paused : GoalStatus.active,
                    );
                    NavigationHelper.safeBack();
                  },
                ),
              _buildGoalActionButton(
                theme,
                'Abandonner l\'objectif',
                Icons.cancel_outlined,
                Colors.red,
                () {
                  controller.setGoalStatus(goal.id, GoalStatus.abandoned);
                  NavigationHelper.safeBack();
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalActionButton(
      ThemeData theme, String text, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  String _goalStatusToString(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return 'Actif';
      case GoalStatus.completed:
        return 'Terminé';
      case GoalStatus.paused:
        return 'En pause';
      case GoalStatus.abandoned:
        return 'Abandonné';
    }
  }

  String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.savings:
        return 'Épargne';
      case GoalType.debtPayoff:
        return 'Remboursement de dette';
      case GoalType.purchase:
        return 'Achat';
      case GoalType.custom:
        return 'Personnalisé';
    }
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAddTap;

  const _Header({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back, size: 28, color: theme.iconTheme.color),
            onPressed: () => NavigationHelper.safeBack(),
            padding: EdgeInsets.zero,
          ).animate().fadeIn().slideX(begin: -0.1),
          Text(
            'Mes Objectifs',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ).animate().fadeIn(),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(CupertinoIcons.add, size: 20.sp, color: theme.textTheme.bodyLarge?.color),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w, top: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.5,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
