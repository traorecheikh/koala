import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/modules/goals/views/widgets/goal_card.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/goals/views/add_goal_view.dart';

class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
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
                  hasScrollBody: false,
                  child: const KoalaEmptyState(
                    icon: CupertinoIcons.flag_fill,
                    title: 'Pas encore d\'objectifs',
                    message:
                        'Définissez vos objectifs financiers et suivez vos progrès pour réaliser vos rêves.',
                    buttonText: 'Créer un objectif',
                  ).animate().fadeIn(duration: 400.ms),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSection(context, 'ACTIFS', controller.activeGoals),
                    _buildSection(
                        context, 'TERMINÉS', controller.completedGoals),
                    _buildSection(context, 'EN PAUSE', controller.pausedGoals),
                    _buildSection(
                        context, 'ABANDONNÉS', controller.abandonedGoals),
                    SizedBox(height: 32.h),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<FinancialGoal> goals) {
    if (goals.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        ...goals.map((g) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: GestureDetector(
                onTap: () => _showGoalDetailsBottomSheet(context, g),
                child: GoalCard(goal: g),
              ),
            )),
        SizedBox(height: 16.h),
      ]
          .animate(interval: 50.ms)
          .fadeIn(duration: KoalaAnim.medium)
          .slideX(begin: 0.1, curve: KoalaAnim.entryCurve),
    );
  }

  void _openAddGoalSheet({FinancialGoal? goal}) {
    Get.bottomSheet(
      AddGoalView(goalToEdit: goal),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showGoalDetailsBottomSheet(BuildContext context, FinancialGoal goal) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: goal.title,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: KoalaColors.textSecondary(context)),
                    onPressed: () {
                      NavigationHelper.safeBack();
                      _openAddGoalSheet(goal: goal);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: KoalaColors.destructive),
                    onPressed: () {
                      NavigationHelper.safeBack();
                      KoalaConfirmationDialog.show(
                        context: context,
                        title: 'Supprimer l\'objectif',
                        message:
                            'Êtes-vous sûr de vouloir supprimer "${goal.title}" ?',
                        isDestructive: true,
                        onConfirm: () async {
                          await controller.deleteGoal(goal.id);
                        },
                      );
                    },
                  ),
                ],
              ),
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                Text(goal.description!,
                    style: KoalaTypography.bodyMedium(context)),
                SizedBox(height: 16.h),
              ],
              _buildDetailRow(
                  context, 'Statut', _goalStatusToString(goal.status)),
              _buildDetailRow(context, 'Type', _goalTypeToString(goal.type)),
              _buildDetailRow(
                  context, 'Montant cible', 'FCFA ${goal.targetAmount}'),
              _buildDetailRow(
                  context, 'Montant actuel', 'FCFA ${goal.currentAmount}'),
              _buildDetailRow(context, 'Progression',
                  '${goal.progressPercentage.toStringAsFixed(1)}%'),
              if (goal.targetDate != null)
                _buildDetailRow(context, 'Date cible',
                    '${goal.targetDate!.day}/${goal.targetDate!.month}/${goal.targetDate!.year}'),
              if (goal.completedAt != null)
                _buildDetailRow(context, 'Terminé le',
                    '${goal.completedAt!.day}/${goal.completedAt!.month}/${goal.completedAt!.year}'),
              SizedBox(height: 24.h),
              if (goal.status == GoalStatus.active)
                _buildGoalActionButton(
                  context,
                  'Marquer comme terminé',
                  Icons.check_circle_outline,
                  KoalaColors.success,
                  () {
                    controller.setGoalStatus(goal.id, GoalStatus.completed);
                    NavigationHelper.safeBack();
                  },
                ),
              if (goal.status == GoalStatus.completed)
                _buildGoalActionButton(
                  context,
                  'Réactiver l\'objectif',
                  Icons.replay,
                  KoalaColors.primaryUi(context),
                  () {
                    controller.setGoalStatus(goal.id, GoalStatus.active);
                    NavigationHelper.safeBack();
                  },
                ),
              if (goal.status == GoalStatus.active ||
                  goal.status == GoalStatus.paused)
                _buildGoalActionButton(
                  context,
                  goal.status == GoalStatus.active
                      ? 'Mettre en pause'
                      : 'Reprendre',
                  goal.status == GoalStatus.active
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  KoalaColors.warning,
                  () {
                    controller.setGoalStatus(
                      goal.id,
                      goal.status == GoalStatus.active
                          ? GoalStatus.paused
                          : GoalStatus.active,
                    );
                    NavigationHelper.safeBack();
                  },
                ),
              _buildGoalActionButton(
                context,
                'Abandonner l\'objectif',
                Icons.cancel_outlined,
                KoalaColors.destructive,
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
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: KoalaTypography.bodyLarge(context)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: KoalaTypography.bodyLarge(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalActionButton(BuildContext context, String text,
      IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: KoalaButton(
        text: text,
        onPressed: onPressed,
        backgroundColor: color,
        icon: icon,
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
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back,
                size: 28, color: KoalaColors.text(context)),
            onPressed: () => NavigationHelper.safeBack(),
            padding: EdgeInsets.zero,
          ).animate().fadeIn().slideX(begin: -0.1),
          Text(
            'Mes Objectifs',
            style: KoalaTypography.heading3(context),
          ).animate().fadeIn(),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(KoalaRadius.md),
                boxShadow: KoalaShadows.sm,
              ),
              child: Icon(CupertinoIcons.add,
                  size: 20.sp, color: KoalaColors.text(context)),
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
        style: KoalaTypography.caption(context).copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
