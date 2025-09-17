import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';

/// Base bottom sheet widget with consistent styling and animations
class BaseBottomSheet extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showHandle;
  final double heightFactor;
  final bool isScrollable;

  const BaseBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showHandle = true,
    this.heightFactor = 0.9,
    this.isScrollable = true,
  });

  static Future<T?> show<T>({
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool showHandle = true,
    double heightFactor = 0.9,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      BaseBottomSheet(
        title: title,
        child: child,
        actions: actions,
        showHandle: showHandle,
        heightFactor: heightFactor,
        isScrollable: isScrollable,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
    );
  }

  @override
  State<BaseBottomSheet> createState() => _BaseBottomSheetState();
}

class _BaseBottomSheetState extends State<BaseBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            _slideAnimation.value * MediaQuery.of(context).size.height,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * widget.heightFactor,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (widget.showHandle) _buildHandle(),
                _buildHeader(),
                Expanded(
                  child: widget.isScrollable
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: widget.child,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: widget.child,
                        ),
                ),
                if (widget.actions != null) _buildActions(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: widget.actions!.map((action) {
          final isLast = widget.actions!.indexOf(action) == widget.actions!.length - 1;
          return Expanded(
            child: Padding(
              padding: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: AppSpacing.sm),
              child: action,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Loading bottom sheet for async operations
class LoadingBottomSheet extends StatelessWidget {
  final String message;

  const LoadingBottomSheet({
    super.key,
    this.message = 'Chargement...',
  });

  static Future<void> show({String message = 'Chargement...'}) {
    return BaseBottomSheet.show(
      title: '',
      heightFactor: 0.3,
      showHandle: false,
      isScrollable: false,
      child: LoadingBottomSheet(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Confirmation bottom sheet for destructive actions
class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return BaseBottomSheet.show<bool>(
      title: title,
      heightFactor: 0.4,
      child: ConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isDestructive ? Icons.warning_amber_rounded : Icons.help_outline,
          size: 48,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  onCancel?.call();
                  Get.back(result: false);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.textSecondary),
                ),
                child: Text(cancelText),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  onConfirm();
                  Get.back(result: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ],
    );
  }
}