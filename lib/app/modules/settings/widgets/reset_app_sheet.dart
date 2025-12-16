import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/core/design_system.dart';

void showResetAppSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ResetAppSheet(),
  );
}

class _ResetAppSheet extends StatefulWidget {
  const _ResetAppSheet();

  @override
  State<_ResetAppSheet> createState() => _ResetAppSheetState();
}

class _ResetAppSheetState extends State<_ResetAppSheet> {
  bool _loading = false;
  bool _buttonPressed = false;

  Future<void> _handleReset() async {
    HapticFeedback.heavyImpact();
    setState(() => _loading = true);

    final controller = Get.find<SettingsController>();
    await controller.performReset();

    // The app should restart, but if it doesn't immediately:
    if (mounted) {
      // Keep loading state until restart happens
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          // Handle
          const KoalaDragHandle(),

          // Icon
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.red,
              size: 40.sp,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

          SizedBox(height: 24.h),

          // Title
          Text(
            'Réinitialiser l\'application ?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

          SizedBox(height: 16.h),

          // Description
          Text(
            'Attention : Toutes vos données (transactions, budgets, paramètres) seront effacées définitivement.\n\nCette action est irréversible.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          SizedBox(height: 40.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56.h,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.r),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      NavigationHelper.safeBack();
                    },
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: AnimatedScale(
                  scale: _buttonPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: SizedBox(
                    height: 56.h,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16.r),
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() => _buttonPressed = true);
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                              setState(() => _buttonPressed = false);
                              _handleReset();
                            },
                      child: _loading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white)
                          : Text(
                              'Tout effacer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
