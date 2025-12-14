import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

// --- Colors ---
class KoalaColors {
  // Brand Colors
  static const _brandBlack = Color(0xFF000000);

  static const secondary = Color(0xFFF5F5F7); // Light gray background
  static const accent =
      Color(0xFF2997FF); // Lighter Blue for better contrast on dark bg
  static const destructive = Color(0xFFFF453A); // iOS Dark Mode Red
  static const success = Color(0xFF32D74B); // iOS Dark Mode Green
  static const warning = Color(0xFFFF9F0A); // iOS Dark Mode Orange

  // Deprecated direct use of primary, prefer primaryUi(context)
  static const primary = _brandBlack;

  // Income/Expense Colors
  static final incomeGreen = Colors.green.shade700;
  static final expenseOrange = Colors.orange.shade800;

  // Premium Text Colors (Light Mode)
  static const premiumTextPrimary = Color(0xFF2D3250);
  static const premiumTextSecondary = Color(0xFF7D8397);

  // Dark Mode Specific Colors
  static const darkCardBackground = Color(0xFF1C1C1E); // iOS System Grey 6 Dark
  static const darkBackground =
      Color(0xFF000000); // Pitch Black OLED (Wait user said NOT pitch black)
  // Re-read: "pitch black isn't it the background shouldnt be pitch black"
  // So I'll use a very dark grey/blue.
  static const darkBackgroundCustom = Color(0xFF121217);

  static const darkInputBackground = Color(0xFF2C2C2E);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(
      0xFFEBEBF5); // High contrast secondary (60% white equivalent but solid)
  // Actually 0xEBEBF5 is usually with opacity. I'll use Color(0xFF8E8E93) or lighter?
  // Let's use Color(0xFFC7C7CC) (System Grey 4) for good visibility.
  static const darkBorder = Color(0xFF38383A);

  // Contextual Colors
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCardBackground
          : Colors.white;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackgroundCustom
          : const Color(0xFFF2F2F7);

  static Color primaryUi(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? accent // Blue in Dark Mode
          : _brandBlack; // Black in Light Mode

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextPrimary
          : premiumTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF8E8E93) // Standard iOS readable secondary
          : premiumTextSecondary;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : Colors.grey.shade200;

  static Color inputBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkInputBackground
          : Colors.white;

  // Shadows
  static List<BoxShadow> get shadowSubtle => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];
}

// --- Typography ---
class KoalaTypography {
  static TextStyle heading1(BuildContext context) => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: KoalaColors.text(context),
        letterSpacing: -0.5,
      );

  static TextStyle heading2(BuildContext context) => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: KoalaColors.text(context),
      );

  static TextStyle heading3(BuildContext context) => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: KoalaColors.text(context),
      );

  static TextStyle heading4(BuildContext context) => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: KoalaColors.text(context),
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w400,
        color: KoalaColors.text(context),
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: KoalaColors.text(context),
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: KoalaColors.textSecondary(context),
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: KoalaColors.textSecondary(context),
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: KoalaColors.textSecondary(context),
      );
}

// --- Spacing ---
class KoalaSpacing {
  static final xs = 4.h;
  static final sm = 8.h;
  static final md = 12.h;
  static final lg = 16.h;
  static final xl = 20.h;
  static final xxl = 24.h;
  static final xxxl = 32.h;
  static final huge = 48.h;
}

// --- Border Radius ---
class KoalaRadius {
  static final xs = 8.r;
  static final sm = 12.r;
  static final md = 16.r;
  static final lg = 20.r;
  static final xl = 24.r;
  static final xxl = 28.r;
  static final full = 9999.r;
}

// --- Shadows ---
class KoalaShadows {
  static List<BoxShadow> xs = [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KoalaTypography.label(context)),
        SizedBox(height: KoalaSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: KoalaColors.inputBackground(context),
            borderRadius: BorderRadius.circular(KoalaRadius.md),
            border: Border.all(color: KoalaColors.border(context)),
            boxShadow: KoalaShadows.xs,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onTap: onTap,
            readOnly: readOnly,
            style: KoalaTypography.bodyLarge(context)
                .copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: isAmount ? '0.00' : label,
              hintStyle: KoalaTypography.bodyMedium(context).copyWith(
                color: KoalaColors.textSecondary(context).withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: KoalaSpacing.lg, vertical: KoalaSpacing.lg),
              prefixIcon: icon != null
                  ? Icon(icon,
                      color: KoalaColors.textSecondary(context), size: 20.sp)
                  : null,
              suffixText: isAmount ? 'FCFA' : null,
              suffixStyle: KoalaTypography.label(context),
            ),
            onChanged: isAmount
                ? (value) {
                    // Simple formatter logic here if needed
                  }
                : null,
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
        : (backgroundColor ?? KoalaColors.primaryUi(context));

    final adaptiveTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    final txtColor = isDestructive
        ? KoalaColors.destructive
        : (textColor ?? adaptiveTextColor);

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: CupertinoButton(
        color: bgColor,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16.r),
        onPressed: isLoading
            ? null
            : () {
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

// --- Alerts ---
class KoalaAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback? onConfirm;
  final bool isDestructive; // Use for coloring confirm button

  const KoalaAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'OK',
    this.onConfirm,
    this.isDestructive = false,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    bool isDestructive = false,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => KoalaAlertDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
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
          onPressed: () {
            NavigationHelper.safeBack();
            onConfirm?.call(); // Call the provided onConfirm callback
          },
          isDestructiveAction: isDestructive,
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
                  color: KoalaColors.surface(context),
                  shape: BoxShape.circle,
                  boxShadow: KoalaColors.shadowSubtle,
                ),
                child: Icon(
                  icon,
                  size: 48.sp,
                  color: KoalaColors.textSecondary(context),
                ),
              ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: KoalaTypography.heading3(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: KoalaTypography.bodyMedium(context).copyWith(
                color: KoalaColors.textSecondary(context),
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
    return Container(
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
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
                color: KoalaColors.textSecondary(context).withOpacity(0.3),
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
                      color: KoalaColors.primaryUi(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon,
                        color: KoalaColors.primaryUi(context), size: 24.sp),
                  ),
                  SizedBox(width: 16.w),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: KoalaTypography.heading3(context),
                  ),
                ),
                IconButton(
                  onPressed: () => NavigationHelper.safeBack(),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: KoalaColors.background(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.xmark,
                        size: 18, color: KoalaColors.text(context)),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: KoalaColors.border(context)),

          Flexible(child: child),
        ],
      ),
    );
  }
}


