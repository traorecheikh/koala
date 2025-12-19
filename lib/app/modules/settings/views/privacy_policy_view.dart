import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.back, size: 28.sp),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      color: isDark ? Colors.white : Colors.black,
                      onPressed: () => NavigationHelper.safeBack(),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.lock_shield_fill,
                        size: 48.sp,
                        color: theme.primaryColor,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    SizedBox(height: 24.h),
                    Text(
                      'Politique de\nConfidentialité',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.1),
                    SizedBox(height: 16.h),
                    Text(
                      'Votre vie privée est notre priorité absolue. Voici comment nous protégeons vos données.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 24.h),
                  _buildSection(
                    context,
                    icon: CupertinoIcons.device_phone_portrait,
                    title: 'Stockage Local',
                    content: 'Toutes vos données financières (transactions, budgets, objectifs) sont stockées exclusivement sur votre appareil. Elles ne sont jamais envoyées vers un serveur externe.',
                    delay: 200,
                  ),
                  _buildSection(
                    context,
                    icon: CupertinoIcons.eye_slash_fill,
                    title: 'Aucun Tracking',
                    content: "Nous ne collectons aucune donnée personnelle, aucune information bancaire, et nous ne suivons pas votre comportement dans l'application.",
                    delay: 300,
                  ),
                  _buildSection(
                    context,
                    icon: CupertinoIcons.lock_fill,
                    title: 'Sécurité Maximale',
                    content: "L'accès à vos données est protégé par les mécanismes de sécurité de votre téléphone (FaceID, TouchID ou code PIN).",
                    delay: 400,
                  ),
                  SizedBox(height: 48.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    {
    required IconData icon,
    required String title,
    required String content,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}

