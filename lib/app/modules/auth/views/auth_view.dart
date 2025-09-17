import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/auth/controllers/auth_controller.dart';
import 'package:koala/generated/assets.dart';

/// Modern authentication view with improved UX
/// - Clear visual hierarchy
/// - Better error handling
/// - Smooth animations
/// - Proper accessibility
class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildHeader(context),
              const Spacer(flex: 1),
              _buildPinDots(context),
              SizedBox(height: 32.h),
              _buildKeypad(context),
              const Spacer(flex: 2),
              _buildFooter(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FadeInDown(
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.asset(
                Assets.imagesKoala,
                width: 80.w,
                height: 80.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'Bon retour !',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Text(
            'Saisissez votre code PIN pour continuer',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Obx(() {
          if (controller.errorMessage.value.isNotEmpty) {
            return FadeIn(
              child: Container(
                margin: EdgeInsets.only(top: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildPinDots(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final pinLength = controller.enteredPin.length;
      return ShakeX(
        key: ValueKey(controller.errorMessage.value),
        manualTrigger: controller.errorMessage.value.isNotEmpty,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < pinLength 
                    ? theme.colorScheme.primary 
                    : Colors.transparent,
                border: Border.all(
                  color: controller.errorMessage.value.isNotEmpty
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildKeypad(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((d) => _buildKeypadButton(context, d)).toList(),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((d) => _buildKeypadButton(context, d)).toList(),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((d) => _buildKeypadButton(context, d)).toList(),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton(context, 'fingerprint', isIcon: true),
            _buildKeypadButton(context, '0'),
            _buildKeypadButton(context, 'backspace', isIcon: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(BuildContext context, String value, {bool isIcon = false}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (isIcon) {
          if (value == 'backspace') {
            controller.removePinDigit();
          } else if (value == 'fingerprint') {
            // TODO: Implement biometric login
            Get.snackbar(
              'Bientôt disponible', 
              'La connexion par empreinte digitale sera bientôt disponible.',
              backgroundColor: theme.colorScheme.primaryContainer,
              colorText: theme.colorScheme.onPrimaryContainer,
            );
          }
        } else {
          controller.addPinDigit(value);
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
        alignment: Alignment.center,
        child: isIcon
            ? Icon(
                value == 'backspace' ? Icons.backspace_outlined : Icons.fingerprint,
                size: 24.sp,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextButton(
          onPressed: controller.showForgotPinDialog,
          child: Text(
            'Code PIN oublié ?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Utilisez votre empreinte digitale ou saisissez votre code PIN',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}