import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

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
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.doc_text_fill,
                        size: 48.sp,
                        color: Colors.blue,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    SizedBox(height: 24.h),
                    Text(
                      'Conditions\nd\'Utilisation',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.1),
                    SizedBox(height: 16.h),
                    Text(
                      'Veuillez lire attentivement les conditions d\'utilisation de l\'application Koala.',
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
                    number: '01',
                    title: 'Usage Personnel',
                    content: 'Koala est un outil conçu pour un usage personnel uniquement. Il vous aide à suivre vos finances mais ne remplace pas un conseiller financier professionnel.',
                    delay: 200,
                  ),
                  _buildSection(
                    context,
                    number: '02',
                    title: 'Responsabilité',
                    content: "Bien que nous fassions tout notre possible pour garantir l'exactitude des calculs, nous ne sommes pas responsables des erreurs de saisie ou des décisions prises sur la base de l'application.",
                    delay: 300,
                  ),
                  _buildSection(
                    context,
                    number: '03',
                    title: 'Données',
                    content: 'En utilisant l\'application, vous acceptez que vos données soient stockées localement sur votre appareil. Vous êtes responsable de la sauvegarde de votre téléphone.',
                    delay: 400,
                  ),
                   _buildSection(
                    context,
                    number: '04',
                    title: 'Mises à jour',
                    content: "Nous nous réservons le droit de mettre à jour l'application pour ajouter des fonctionnalités ou corriger des bugs. Ces conditions peuvent évoluer avec l'application.",
                    delay: 500,
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
    required String number,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w900,
              color: theme.primaryColor.withOpacity(0.1),
              height: 0.8,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}