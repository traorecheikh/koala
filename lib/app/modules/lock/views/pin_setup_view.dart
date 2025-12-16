import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/services/pin_service.dart';

/// Custom 4-digit PIN setup screen using numpad (no keyboard)
class PinSetupView extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isChangingPin;

  const PinSetupView({
    super.key,
    required this.onComplete,
    this.isChangingPin = false,
  });

  @override
  State<PinSetupView> createState() => _PinSetupViewState();

  /// Show as dialog
  static Future<void> show(BuildContext context, {bool isChanging = false}) {
    return Get.dialog(
      PopScope(
        canPop: true,
        child: PinSetupView(
          onComplete: () => Get.back(),
          isChangingPin: isChanging,
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class _PinSetupViewState extends State<PinSetupView> {
  final List<String> _pin1 = [];
  final List<String> _pin2 = [];
  bool _isConfirmStep = false;
  bool _isError = false;
  String _errorMessage = '';

  List<String> get _currentPin => _isConfirmStep ? _pin2 : _pin1;

  void _onDigitPressed(String digit) {
    if (_currentPin.length >= 4) return;

    HapticFeedback.lightImpact();
    setState(() {
      _currentPin.add(digit);
      _isError = false;
    });

    if (_currentPin.length == 4) {
      if (!_isConfirmStep) {
        // Move to confirm step
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => _isConfirmStep = true);
        });
      } else {
        // Verify match
        _verifyAndSave();
      }
    }
  }

  void _onBackspace() {
    if (_currentPin.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _currentPin.removeLast();
      _isError = false;
    });
  }

  void _verifyAndSave() async {
    final pin1Str = _pin1.join();
    final pin2Str = _pin2.join();

    if (pin1Str != pin2Str) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
        _errorMessage = 'Les codes ne correspondent pas';
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _pin2.clear();
        _isError = false;
      });
      return;
    }

    // Save PIN and enable lock
    final pinService = Get.find<PinService>();
    await pinService.setPin(pin1Str);

    HapticFeedback.mediumImpact();
    widget.onComplete();

    Get.snackbar(
      'Succès',
      'Code PIN défini et verrouillage activé',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: KoalaColors.success,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: KoalaColors.text(context)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isChangingPin ? 'Changer le PIN' : 'Définir un PIN',
          style: KoalaTypography.heading3(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),

              // App Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: KoalaColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text('🐨', style: TextStyle(fontSize: 40.sp)),
                ),
              ),

              SizedBox(height: 32.h),

              // Instruction
              Text(
                _isConfirmStep
                    ? 'Confirmez votre code'
                    : 'Entrez un code à 4 chiffres',
                style: KoalaTypography.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                _isConfirmStep
                    ? 'Saisissez le même code'
                    : 'Ce code protègera votre app',
                style: KoalaTypography.bodySmall(context).copyWith(
                  color: KoalaColors.textSecondary(context),
                ),
              ),

              SizedBox(height: 32.h),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _currentPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isError
                          ? KoalaColors.destructive
                          : isFilled
                              ? KoalaColors.primary
                              : Colors.transparent,
                      border: Border.all(
                        color: _isError
                            ? KoalaColors.destructive
                            : KoalaColors.primary,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_isError)
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Text(
                    _errorMessage,
                    style: KoalaTypography.bodySmall(context).copyWith(
                      color: KoalaColors.destructive,
                    ),
                  ),
                ),

              const Spacer(),

              // Number pad
              _buildNumPad(context),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3']
              .map((d) => _buildDigitButton(context, d))
              .toList(),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6']
              .map((d) => _buildDigitButton(context, d))
              .toList(),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9']
              .map((d) => _buildDigitButton(context, d))
              .toList(),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 80.w, height: 80.w),
            _buildDigitButton(context, '0'),
            _buildActionButton(context,
                icon: Icons.backspace_outlined, onTap: _onBackspace),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitButton(BuildContext context, String digit) {
    return GestureDetector(
      onTap: () => _onDigitPressed(digit),
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KoalaColors.surface(context),
          border: Border.all(color: KoalaColors.border(context), width: 1),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w500,
              color: KoalaColors.text(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(icon, size: 28.sp, color: KoalaColors.text(context)),
        ),
      ),
    );
  }
}
