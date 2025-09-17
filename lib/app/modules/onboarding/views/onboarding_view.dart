import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:koala/generated/assets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeStep(context),
                _buildKoalaBotStep(context),
                _buildIncomeStep(context),
                _buildBalanceStep(context),
                _buildCompletionStep(context),
              ],
            ),
            Positioned(
              top: 20.h,
              left: 24.w,
              right: 24.w,
              child: _buildHeader(context),
            ),
            Positioned(
              bottom: 40.h,
              left: 24.w,
              right: 24.w,
              child: Obx(() => _buildNavigation(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SmoothPageIndicator(
          controller: controller.pageController,
          count: 5,
          effect: ExpandingDotsEffect(
            activeDotColor: theme.colorScheme.primary,
            dotColor: theme.colorScheme.surfaceVariant,
            dotHeight: 6.h,
            dotWidth: 6.w,
            expansionFactor: 4,
          ),
        ),
        Obx(() {
          if (controller.currentPage.value < 2) {
            return FadeIn(
              child: TextButton(
                onPressed: controller.skipToEnd,
                child: Text('Ignorer', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = controller.currentPage.value == 4;
    final isFirstStep = controller.currentPage.value == 0;

    return FadeInUp(
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousPage,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
                child: const Text('Précédent'),
              ),
            ),
          if (!isFirstStep) SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.nextPage,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(isLastStep ? 'Commencer' : 'Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: SvgPicture.asset(Assets.imagesOnboarding, height: 280.h)),
          SizedBox(height: 40.h),
          FadeInUp(
            child: AutoSizeText(
              'Bienvenue chez Koala',
              style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: AutoSizeText(
              'Votre assistant financier intelligent pour une gestion simplifiée.',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKoalaBotStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: Image.asset(Assets.imagesKoala, height: 150.h)),
          SizedBox(height: 32.h),
          FadeInUp(
            child: AutoSizeText(
              'Rencontrez Koala AI',
              style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: AutoSizeText(
              'Votre conseiller personnel pour des décisions financières éclairées.',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: SvgPicture.asset(Assets.imagesCoins, height: 180.h)),
          SizedBox(height: 32.h),
          FadeInUp(
            child: Text('Vos revenus mensuels', style: theme.textTheme.displaySmall),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Saisissez votre salaire net pour personnaliser vos analyses.',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildTextField(
              context,
              controller: controller.salaryInputController,
              hintText: 'Ex: 350000',
              suffixText: 'XOF',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: SvgPicture.asset(Assets.imagesBank, height: 180.h)),
          SizedBox(height: 32.h),
          FadeInUp(
            child: Text('Votre solde actuel', style: theme.textTheme.displaySmall),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Indiquez le montant total de vos comptes (banque, mobile money, etc.).',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildTextField(
              context,
              controller: controller.balanceInputController,
              hintText: 'Ex: 1200000',
              suffixText: 'XOF',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Icon(Icons.check_circle_outline_rounded, size: 100.sp, color: theme.colorScheme.primary),
            ),
            SizedBox(height: 32.h),
            FadeInUp(
              child: Text(
                'Configuration terminée !',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.h),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Koala est prêt à vous aider à atteindre vos objectifs financiers.',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    {
    required TextEditingController controller,
    required String hintText,
    String? suffixText,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: theme.textTheme.displaySmall,
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}