import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/auth/controllers/auth_controller.dart';
import 'package:koala/generated/assets.dart';

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
              const Spacer(flex: 1),
              _buildKeypad(context),
              const Spacer(flex: 2),
              _buildFooter(context),
              SizedBox(height: 20.h),
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
        FadeInDown(child: Image.asset(Assets.imagesKoala, height: 80.h)),
        SizedBox(height: 16.h),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Text('Bon retour parmi nous', style: theme.textTheme.headlineSmall),
        ),
        SizedBox(height: 8.h),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Text(
            'Saisissez votre code PIN pour continuer',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildPinDots(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final pinLength = controller.enteredPin.length;
      return ShakeX(
        key: ValueKey(controller.errorMessage.value), // Shake on error
        manualTrigger: controller.errorMessage.value.isNotEmpty,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < pinLength ? theme.colorScheme.primary : Colors.transparent,
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
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((d) => _buildKeypadButton(context, d)).toList(),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((d) => _buildKeypadButton(context, d)).toList(),
        ),
        SizedBox(height: 20.h),
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
            Get.snackbar('Bientôt disponible', 'La connexion par empreinte digitale sera bientôt disponible.');
          }
        } else {
          controller.addPinDigit(value);
        }
      },
      borderRadius: BorderRadius.circular(50.r),
      child: Container(
        width: 70.w,
        height: 70.w,
        alignment: Alignment.center,
        child: isIcon
            ? Icon(
                value == 'backspace' ? Icons.backspace_outlined : Icons.fingerprint,
                size: 32.sp,
                color: theme.colorScheme.onSurface,
              )
            : Text(
                value,
                style: theme.textTheme.displayMedium,
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: controller.showForgotPinDialog,
      child: Text(
        'Code PIN oublié ?',
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}