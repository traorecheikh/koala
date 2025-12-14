import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

void showRechargeDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _RechargeSheet(),
  );
}

class _RechargeSheet extends StatefulWidget {
  const _RechargeSheet();

  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  String? _selectedMethod;
  bool _loading = false;

  void _selectMethod(String method) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMethod = method;
    });
  }

  void _proceedWithRecharge() async {
    if (_selectedMethod == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _loading = true);

    // Simulate navigation to payment flow
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      NavigationHelper.safeBack();
      // Payment integration - show info message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Intégration $_selectedMethod bientôt disponible. Rechargez via l\'application $_selectedMethod.'),
          backgroundColor: const Color(0xFF2A2A3E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0.h),
            child: Row(
              children: [
                Text(
                  'Recharger',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    NavigationHelper.safeBack();
                  },
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // Subtitle
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choisissez votre méthode de paiement',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          // Payment methods
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _PaymentMethodTile(
                    method: 'wave',
                    title: 'Wave',
                    subtitle: 'Paiement mobile Wave',
                    isSelected: _selectedMethod == 'wave',
                    onTap: () => _selectMethod('wave'),
                  )
                      .animate()
                      .slideX(
                        begin: -0.2,
                        duration: 400.ms,
                        delay: 200.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  SizedBox(height: 12.h),

                  _PaymentMethodTile(
                    method: 'orange',
                    title: 'Orange Money',
                    subtitle: 'Paiement mobile Orange',
                    isSelected: _selectedMethod == 'orange',
                    onTap: () => _selectMethod('orange'),
                  )
                      .animate()
                      .slideX(
                        begin: -0.2,
                        duration: 400.ms,
                        delay: 300.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  SizedBox(height: 12.h),

                  _PaymentMethodTile(
                    method: 'free',
                    title: 'Free Money',
                    subtitle: 'Paiement mobile Free',
                    isSelected: _selectedMethod == 'free',
                    onTap: () => _selectMethod('free'),
                  )
                      .animate()
                      .slideX(
                        begin: -0.2,
                        duration: 400.ms,
                        delay: 400.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  const Spacer(),

                  // Continue button
                  AnimatedOpacity(
                    opacity: _selectedMethod != null ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: CupertinoButton(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16.r),
                        onPressed: _selectedMethod != null && !_loading
                            ? _proceedWithRecharge
                            : null,
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Redirection...',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withAlpha(
                                        (0.8 * 255).round(),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Continuer',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ).animate().slideY(
                        begin: 0.3,
                        duration: 500.ms,
                        delay: 500.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatefulWidget {
  final String method;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PaymentMethodTile> createState() => _PaymentMethodTileState();
}

class _PaymentMethodTileState extends State<_PaymentMethodTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Use asset images for payment methods
              SizedBox(
                width: 48.w,
                height: 48.h,
                child: ClipOval(child: _getMethodImage(widget.method)),
              ),
              SizedBox(width: 16.w),
              // Method info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? Colors.black : Colors.transparent,
                  border: Border.all(color: Colors.black, width: 2.w),
                ),
                child: widget.isSelected
                    ? Icon(
                        CupertinoIcons.checkmark,
                        color: Colors.white,
                        size: 14.sp,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMethodImage(String method) {
    switch (method) {
      case 'wave':
        return Image.asset(
          'assets/img/wave.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        );
      case 'orange':
        return Image.asset(
          'assets/img/om.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        );
      case 'free':
        return Image.asset(
          'assets/img/free.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        );
      default:
        return Icon(
          _getMethodIcon(method),
          color: _getMethodColor(method),
          size: 24.sp,
        );
    }
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'wave':
        return const Color(0xFF00D4FF); // Wave blue
      case 'orange':
        return const Color(0xFFFF6900); // Orange color
      case 'free':
        return const Color(0xFF8B5CF6); // Purple for Free
      default:
        return Colors.grey;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'wave':
        return CupertinoIcons.waveform_circle_fill;
      case 'orange':
        return CupertinoIcons.phone_circle;
      case 'free':
        return CupertinoIcons.money_dollar_circle;
      default:
        return CupertinoIcons.creditcard;
    }
  }
}


