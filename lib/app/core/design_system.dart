import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

// --- Colors ---
class KoalaColors {
  static const primary = Color(0xFF000000); // Black for primary actions
  static const secondary = Color(0xFFF5F5F7); // Light gray background
  static const accent = Color(0xFF007AFF); // iOS Blue
  static const destructive = Color(0xFFFF3B30); // iOS Red
  static const success = Color(0xFF34C759); // iOS Green
  static const warning = Color(0xFFFF9500); // iOS Orange
  
  static Color surface(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white;
  
  static Color background(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
      
  static Color text(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
}

// --- Inputs ---
class KoalaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType keyboardType;
  final bool isAmount;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const KoalaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.isAmount = false,
    this.validator,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onTap: onTap,
            readOnly: readOnly,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: isAmount ? '0.00' : label,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              prefixIcon: icon != null 
                  ? Icon(icon, color: Colors.grey.shade500, size: 20.sp)
                  : null,
              suffixText: isAmount ? 'FCFA' : null,
              suffixStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            onChanged: isAmount ? (value) {
              // Simple formatter logic here if needed
            } : null,
          ),
        ),
      ],
    );
  }
}

// --- Buttons ---
class KoalaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isDestructive;

  const KoalaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDestructive 
        ? KoalaColors.destructive.withOpacity(0.1)
        : (backgroundColor ?? KoalaColors.primary);
        
    final txtColor = isDestructive 
        ? KoalaColors.destructive
        : (textColor ?? Colors.white);

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: CupertinoButton(
        color: bgColor,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16.r),
        onPressed: isLoading ? null : () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: isLoading
            ? CupertinoActivityIndicator(color: txtColor)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: txtColor, size: 20.sp),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: txtColor,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// --- Dialogs ---
class KoalaConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const KoalaConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.isDestructive = false,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirmer',
    bool isDestructive = false,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => KoalaConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => NavigationHelper.safeBack(),
          child: Text(cancelText),
        ),
        CupertinoDialogAction(
          isDestructiveAction: isDestructive,
          onPressed: () {
            onConfirm();
            NavigationHelper.safeBack();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// --- Empty States ---
class KoalaEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customIllustration;

  const KoalaEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null)
              customIllustration!
            else if (icon != null)
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
              ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 32.h),
              SizedBox(
                width: 200.w,
                child: KoalaButton(
                  text: buttonText!,
                  onPressed: onButtonPressed!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Bottom Sheet Container ---
class KoalaBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;

  const KoalaBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: theme.primaryColor, size: 24.sp),
                  ),
                  SizedBox(width: 16.w),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => NavigationHelper.safeBack(),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.xmark, size: 18),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          
          Flexible(child: child),
        ],
      ),
    );
  }
}