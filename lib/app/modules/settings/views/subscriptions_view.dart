// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/subscription_assets.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class SubscriptionsView extends GetView<RecurringTransactionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child:
                    _Header(onAddTap: () => _showAddSubscriptionSheet(context)),
              ),
            ),

            // Stats Card
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: Obx(() => _StatsCard(
                      monthlyTotal: _calculateMonthlyTotal(),
                      yearlyTotal: _calculateMonthlyTotal() * 12,
                      activeCount: controller.recurringTransactions
                          .where((t) => t.type == TransactionType.expense)
                          .length,
                    )),
              ),
            ),

            // Active Subscriptions
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionHeader(title: 'ABONNEMENTS ACTIFS'),
              ),
            ),

            // Subscription List
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              sliver: Obx(() {
                final subscriptions = controller.recurringTransactions
                    .where((t) => t.type == TransactionType.expense)
                    .toList();

                if (subscriptions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyState(
                      onAddTap: () => _showAddSubscriptionSheet(context),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _SubscriptionCard(
                        subscription: subscriptions[index],
                        delay: index * 80,
                        onTap: () =>
                            _showEditSheet(context, subscriptions[index]),
                      ),
                    ),
                    childCount: subscriptions.length,
                  ),
                );
              }),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  double _calculateMonthlyTotal() {
    return controller.recurringTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _showAddSubscriptionSheet(BuildContext context) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Ajouter un abonnement',
        child: _AddSubscriptionSheet(
          onServiceSelected: (service) {
            NavigationHelper.safeBack();
            _showSubscriptionForm(context, service);
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSubscriptionForm(
      BuildContext context, SubscriptionService service) {
    final amountController = TextEditingController();
    final dayController = TextEditingController(text: '1');

    Get.bottomSheet(
      KoalaBottomSheet(
        title: service.name,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Icon Preview
              Center(
                child: _ServiceIcon(service: service, size: 64),
              ),
              SizedBox(height: 24.h),

              // Amount Input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: KoalaTypography.bodyMedium(context),
                decoration: InputDecoration(
                  labelText: 'Montant mensuel (FCFA)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Day of Month
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                style: KoalaTypography.bodyMedium(context),
                decoration: InputDecoration(
                  labelText: 'Jour de prelevement (1-28)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              KoalaButton(
                text: 'Ajouter',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final amount = double.tryParse(amountController.text) ?? 0;
                  final day = int.tryParse(dayController.text) ?? 1;

                  if (amount > 0) {
                    controller.addRecurringTransaction(
                      RecurringTransaction(
                        amount: amount,
                        description: service.name,
                        frequency: Frequency.monthly,
                        dayOfMonth: day.clamp(1, 28),
                        lastGeneratedDate:
                            DateTime.now().subtract(const Duration(days: 1)),
                        category: TransactionCategory.entertainment,
                        type: TransactionType.expense,
                        categoryId: 'subscription_${service.id}',
                      ),
                    );
                    NavigationHelper.safeBack();
                    Get.snackbar(
                      'Abonnement ajouté',
                      '${service.name} - ${NumberFormat('#,###', 'fr_FR').format(amount)} FCFA/mois',
                      backgroundColor: KoalaColors.success,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: EdgeInsets.all(16.w),
                    );
                  }
                },
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => NavigationHelper.safeBack(),
                child: Text(
                  'Annuler',
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditSheet(BuildContext context, RecurringTransaction subscription) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: subscription.description,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount Display
              Text(
                '${NumberFormat('#,###', 'fr_FR').format(subscription.amount)} FCFA',
                style: KoalaTypography.heading2(context),
              ),
              SizedBox(height: 8.h),
              Text(
                'par mois • ${NumberFormat('#,###', 'fr_FR').format(subscription.amount * 12)} FCFA/an',
                style: KoalaTypography.bodyMedium(context).copyWith(
                  color: KoalaColors.textSecondary(context),
                ),
              ),
              SizedBox(height: 24.h),

              // Next Payment
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: KoalaColors.surface(context),
                  borderRadius: BorderRadius.circular(KoalaRadius.lg),
                  border: Border.all(color: KoalaColors.border(context)),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.calendar, color: KoalaColors.primary),
                    SizedBox(width: 12.w),
                    Text(
                      'Prochain: le ${subscription.dayOfMonth} du mois',
                      style: KoalaTypography.bodyMedium(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    controller.deleteRecurringTransaction(subscription);
                    NavigationHelper.safeBack();
                    Get.snackbar(
                      'Abonnement supprime',
                      subscription.description,
                      backgroundColor: KoalaColors.destructive,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: EdgeInsets.all(16.w),
                    );
                  },
                  icon: const Icon(CupertinoIcons.trash, color: Colors.red),
                  label: Text(
                    'Supprimer l\'abonnement',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onAddTap;
  const _Header({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => NavigationHelper.safeBack(),
            icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
          ).animate().fadeIn().slideX(begin: -0.1),
          const Spacer(),
          Text('Abonnements', style: KoalaTypography.heading3(context))
              .animate()
              .fadeIn(),
          const Spacer(),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: KoalaColors.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(CupertinoIcons.add, size: 20.sp, color: Colors.white),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final double monthlyTotal;
  final double yearlyTotal;
  final int activeCount;

  const _StatsCard({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coût mensuel',
            style: KoalaTypography.caption(context).copyWith(
              color: KoalaColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${NumberFormat('#,###', 'fr_FR').format(monthlyTotal)} FCFA',
            style: KoalaTypography.heading1(context).copyWith(
              color: KoalaColors.destructive,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _StatPill(
                icon: CupertinoIcons.calendar,
                value:
                    '${NumberFormat('#,###', 'fr_FR').format(yearlyTotal)} F/an',
                backgroundColor:
                    KoalaColors.primaryUi(context).withValues(alpha: 0.1),
                textColor: KoalaColors.primaryUi(context),
              ),
              SizedBox(width: 12.w),
              _StatPill(
                icon: CupertinoIcons.checkmark_circle,
                value: '$activeCount actifs',
                backgroundColor: KoalaColors.success.withValues(alpha: 0.1),
                textColor: KoalaColors.success,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? backgroundColor;
  final Color? textColor;

  const _StatPill({
    required this.icon,
    required this.value,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? KoalaColors.surface(context);
    final fgColor = textColor ?? KoalaColors.text(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(KoalaRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: fgColor),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
                color: fgColor, fontSize: 11.sp, fontWeight: FontWeight.w600),
          ),
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
    return Text(
      title,
      style: KoalaTypography.caption(context).copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: KoalaColors.textSecondary(context),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final RecurringTransaction subscription;
  final int delay;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.subscription,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Try to match to a predefined service
    final serviceId =
        subscription.categoryId?.replaceFirst('subscription_', '') ?? 'custom';
    final service = SubscriptionAssets.getById(serviceId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.lg),
          border: Border.all(color: KoalaColors.border(context)),
          boxShadow: KoalaShadows.xs,
        ),
        child: Row(
          children: [
            _ServiceIcon(
              service: service ?? SubscriptionAssets.predefinedServices.last,
              size: 44,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.description,
                    style: KoalaTypography.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Le ${subscription.dayOfMonth} du mois',
                    style: KoalaTypography.caption(context).copyWith(
                      color: KoalaColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${NumberFormat('#,###', 'fr_FR').format(subscription.amount)} F',
              style: KoalaTypography.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: KoalaColors.destructive,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: KoalaAnim.medium)
        .slideX(begin: 0.03, end: 0, curve: KoalaAnim.entryCurve);
  }
}

class _ServiceIcon extends StatelessWidget {
  final SubscriptionService service;
  final double size;

  const _ServiceIcon({required this.service, required this.size});

  @override
  Widget build(BuildContext context) {
    final logoPath = SubscriptionAssets.getLogoPath(service.id);

    if (logoPath != null) {
      Widget imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          logoPath,
          width: size.sp,
          height: size.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(context),
        ),
      );

      // Wrap in white container for transparent logos
      if (service.needsWhiteBackground) {
        return Container(
          width: size.sp,
          height: size.sp,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: imageWidget,
        );
      }
      return imageWidget;
    }

    return _buildFallbackIcon(context);
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      width: size.sp,
      height: size.sp,
      decoration: BoxDecoration(
        color: _getCategoryColor(service.category).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        _getIconData(service.fallbackIcon),
        size: size * 0.5,
        color: _getCategoryColor(service.category),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'entertainment':
        return const Color(0xFFE50914); // Netflix red
      case 'music':
        return const Color(0xFF1DB954); // Spotify green
      case 'ai':
        return const Color(0xFF10A37F); // ChatGPT green
      case 'cloud':
        return const Color(0xFF007AFF); // Apple blue
      case 'shopping':
        return const Color(0xFFFF9900); // Amazon orange
      case 'design':
        return const Color(0xFF00C4CC); // Canva teal
      case 'security':
        return const Color(0xFF5F6368); // Grey
      case 'fitness':
        return const Color(0xFFFF5722); // Orange
      default:
        return Colors.grey;
    }
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'play_rectangle_fill':
        return CupertinoIcons.play_rectangle_fill;
      case 'star_fill':
        return CupertinoIcons.star_fill;
      case 'play_fill':
        return CupertinoIcons.play_fill;
      case 'music_note':
        return CupertinoIcons.music_note;
      case 'music_note_2':
        return CupertinoIcons.music_note_2;
      case 'bubble_left_fill':
        return CupertinoIcons.bubble_left_fill;
      case 'text_bubble_fill':
        return CupertinoIcons.text_bubble_fill;
      case 'sparkles':
        return CupertinoIcons.sparkles;
      case 'cloud_fill':
        return CupertinoIcons.cloud_fill;
      case 'cloud':
        return CupertinoIcons.cloud;
      case 'bag_fill':
        return CupertinoIcons.bag_fill;
      case 'paintbrush_fill':
        return CupertinoIcons.paintbrush_fill;
      case 'shield_fill':
        return CupertinoIcons.shield_fill;
      case 'sportscourt_fill':
        return CupertinoIcons.sportscourt_fill;
      default:
        return CupertinoIcons.ellipsis_circle_fill;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.creditcard,
              size: 48.sp,
              color: KoalaColors.textSecondary(context),
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun abonnement',
              style: KoalaTypography.heading4(context),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ajoutez vos abonnements pour suivre vos depenses recurrentes',
              style: KoalaTypography.bodyMedium(context).copyWith(
                color: KoalaColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            KoalaButton(
              text: 'Ajouter un abonnement',
              onPressed: onAddTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSubscriptionSheet extends StatelessWidget {
  final Function(SubscriptionService) onServiceSelected;

  const _AddSubscriptionSheet({required this.onServiceSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: KoalaColors.border(context),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Choisir un service',
              style: KoalaTypography.heading3(context),
            ),
            SizedBox(height: 4.h),
            Text(
              'Selectionnez le type d\'abonnement',
              style: KoalaTypography.bodyMedium(context).copyWith(
                color: KoalaColors.textSecondary(context),
              ),
            ),
            SizedBox(height: 24.h),

            // Categories
            for (final category in SubscriptionAssets.categories)
              if (SubscriptionAssets.getByCategory(category).isNotEmpty) ...[
                _CategorySection(
                  category: category,
                  services: SubscriptionAssets.getByCategory(category),
                  onServiceSelected: onServiceSelected,
                ),
                SizedBox(height: 20.h),
              ],
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<SubscriptionService> services;
  final Function(SubscriptionService) onServiceSelected;

  const _CategorySection({
    required this.category,
    required this.services,
    required this.onServiceSelected,
  });

  Color get _accentColor {
    switch (category) {
      case 'entertainment':
        return const Color(0xFFE50914);
      case 'music':
        return const Color(0xFF1DB954);
      case 'ai':
        return const Color(0xFF10A37F);
      case 'cloud':
        return const Color(0xFF007AFF);
      case 'shopping':
        return const Color(0xFFFF9900);
      case 'design':
        return const Color(0xFF00C4CC);
      case 'security':
        return const Color(0xFF5F6368);
      case 'fitness':
        return const Color(0xFFFF5722);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with accent line
        Row(
          children: [
            Container(
              width: 3.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              SubscriptionAssets.getCategoryName(category).toUpperCase(),
              style: KoalaTypography.caption(context).copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: KoalaColors.textSecondary(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Services as simple list rows
        ...services.map((service) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onServiceSelected(service);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: KoalaColors.border(context)),
              ),
              child: Row(
                children: [
                  // Icon with white bg for transparent logos
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: service.needsWhiteBackground
                          ? Colors.white
                          : _accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: _buildServiceIcon(context, service),
                  ),
                  SizedBox(width: 14.w),
                  // Name
                  Expanded(
                    child: Text(
                      service.name,
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Arrow
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 16.sp,
                    color: KoalaColors.textSecondary(context),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildServiceIcon(BuildContext context, SubscriptionService service) {
    final logoPath = SubscriptionAssets.getLogoPath(service.id);

    if (logoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.asset(
          logoPath,
          width: 28.w,
          height: 28.w,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            CupertinoIcons.circle,
            size: 20.sp,
            color: _accentColor,
          ),
        ),
      );
    }

    return Icon(
      _getFallbackIcon(service.fallbackIcon),
      size: 20.sp,
      color: _accentColor,
    );
  }

  IconData _getFallbackIcon(String iconKey) {
    switch (iconKey) {
      case 'play_rectangle_fill':
        return CupertinoIcons.play_rectangle_fill;
      case 'star_fill':
        return CupertinoIcons.star_fill;
      case 'play_fill':
        return CupertinoIcons.play_fill;
      case 'music_note':
        return CupertinoIcons.music_note;
      case 'music_note_2':
        return CupertinoIcons.music_note_2;
      case 'bubble_left_fill':
        return CupertinoIcons.bubble_left_fill;
      case 'text_bubble_fill':
        return CupertinoIcons.text_bubble_fill;
      case 'sparkles':
        return CupertinoIcons.sparkles;
      case 'cloud_fill':
        return CupertinoIcons.cloud_fill;
      case 'cloud':
        return CupertinoIcons.cloud;
      case 'ellipsis_circle_fill':
        return CupertinoIcons.ellipsis_circle_fill;
      default:
        return CupertinoIcons.app;
    }
  }
}
