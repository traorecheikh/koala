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

/// Modern onboarding experience following UX best practices
/// - Clear visual hierarchy
/// - Minimal cognitive load per step
/// - Progressive disclosure
/// - Proper form validation
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
                _buildPersonalInfoStep(context),
                _buildIncomeStep(context),
                _buildBalanceStep(context),
                _buildSecurityStep(context),
                _buildCompletionStep(context),
              ],
            ),
            Positioned(
              top: 16.h,
              left: 20.w,
              right: 20.w,
              child: _buildHeader(context),
            ),
            Positioned(
              bottom: 32.h,
              left: 20.w,
              right: 20.w,
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
          count: 7, // Updated to 7 steps for better UX
          effect: ExpandingDotsEffect(
            activeDotColor: theme.colorScheme.primary,
            dotColor: theme.colorScheme.outline,
            dotHeight: 4.h,
            dotWidth: 4.w,
            expansionFactor: 4,
          ),
        ),
        Obx(() {
          if (controller.currentPage.value < 6) { // Updated condition
            return FadeIn(
              child: TextButton(
                onPressed: controller.skipToEnd,
                child: Text(
                  'Passer',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
    final isLastStep = controller.currentPage.value == 6; // Updated to 7 steps (0-6)
    final isFirstStep = controller.currentPage.value == 0;

    return FadeInUp(
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousPage,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
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
                padding: EdgeInsets.symmetric(vertical: 12.h),
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

  /// Personal information collection step
  Widget _buildPersonalInfoStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.person_outline_rounded,
              size: 120.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 32.h),
          FadeInUp(
            child: Text(
              'Parlez-nous de vous',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Ces informations nous aident à personnaliser votre expérience.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Column(
              children: [
                _buildTextField(
                  context,
                  controller: controller.nameInputController,
                  hintText: 'Votre nom complet',
                  prefixIcon: Icons.person_outline,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  context,
                  controller: controller.phoneInputController,
                  hintText: 'Numéro de téléphone',
                  prefixIcon: Icons.phone_outlined,
                ),
              ],
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

  /// Security setup step for PIN and biometric authentication
  Widget _buildSecurityStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.security_rounded,
              size: 120.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 32.h),
          FadeInUp(
            child: Text(
              'Sécurisez votre compte',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Créez un code PIN à 4 chiffres pour protéger vos données.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildPinInput(context),
          ),
          SizedBox(height: 24.h),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildBiometricOption(context),
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
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    String? suffixText,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    final isNumeric = suffixText != null; // Numeric fields have suffix (XOF)
    
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
      textAlign: prefixIcon != null ? TextAlign.start : TextAlign.center,
      style: prefixIcon != null 
          ? theme.textTheme.titleLarge 
          : theme.textTheme.displaySmall,
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  /// PIN input widget for security setup
  Widget _buildPinInput(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Code PIN',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: index < controller.pinInputController.text.length
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  index < controller.pinInputController.text.length ? '●' : '',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          }),
        )),
        SizedBox(height: 16.h),
        _buildNumericKeypad(context),
      ],
    );
  }

  /// Biometric authentication option
  Widget _buildBiometricOption(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Obx(() => SwitchListTile(
        title: Text(
          'Empreinte digitale',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          'Utiliser l\'empreinte pour une connexion rapide',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        secondary: Icon(
          Icons.fingerprint,
          color: theme.colorScheme.primary,
        ),
        value: controller.biometricEnabled.value,
        onChanged: (value) => controller.biometricEnabled.value = value,
      )),
    );
  }

  /// Numeric keypad for PIN input
  Widget _buildNumericKeypad(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((digit) => 
            _buildKeypadButton(context, digit)).toList(),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((digit) => 
            _buildKeypadButton(context, digit)).toList(),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((digit) => 
            _buildKeypadButton(context, digit)).toList(),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 56.w), // Empty space
            _buildKeypadButton(context, '0'),
            _buildKeypadButton(context, '⌫', isBackspace: true),
          ],
        ),
      ],
    );
  }

  /// Individual keypad button
  Widget _buildKeypadButton(BuildContext context, String value, {bool isBackspace = false}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (isBackspace) {
          if (controller.pinInputController.text.isNotEmpty) {
            controller.pinInputController.text = 
                controller.pinInputController.text.substring(0, 
                controller.pinInputController.text.length - 1);
          }
        } else {
          if (controller.pinInputController.text.length < 4) {
            controller.pinInputController.text += value;
          }
        }
      },
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Center(
          child: Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}