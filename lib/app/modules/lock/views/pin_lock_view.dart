import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/services/pin_service.dart';

/// Custom 4-digit PIN lock screen with shake animation and button feedback
class PinLockView extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onBiometricRequest;

  const PinLockView({
    super.key,
    required this.onUnlocked,
    this.onBiometricRequest,
  });

  @override
  State<PinLockView> createState() => _PinLockViewState();
}

class _PinLockViewState extends State<PinLockView>
    with SingleTickerProviderStateMixin {
  final List<String> _enteredDigits = [];
  bool _isError = false;
  bool _isSuccess = false;
  int _attemptCount = 0;
  static const int _maxAttempts = 5;
  bool _isLocked = false;
  int _lockoutSeconds = 0;

  // Shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _loadLockoutState(); // Load persisted lockout
  }

  Future<void> _loadLockoutState() async {
    try {
      final box = Hive.box('settingsBox');
      final lockoutEnd = box.get('pin_lockout_end', defaultValue: 0) as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lockoutEnd > now) {
        final remainingSeconds = ((lockoutEnd - now) / 1000).ceil();
        setState(() {
          _isLocked = true;
          _lockoutSeconds = remainingSeconds;
          _attemptCount = _maxAttempts;
        });
        _startLockoutCountdown();
      }
    } catch (_) {
      // Box may not be ready, ignore
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_enteredDigits.length >= 4 || _isSuccess) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredDigits.add(digit);
      _isError = false;
    });

    if (_enteredDigits.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty || _isSuccess) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredDigits.removeLast();
      _isError = false;
    });
  }

  void _verifyPin() async {
    if (_isLocked) return;

    final enteredPin = _enteredDigits.join();
    final storedPin = Get.find<PinService>().getStoredPin();

    if (enteredPin == storedPin) {
      setState(() => _isSuccess = true);
      _attemptCount = 0; // Reset on success
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onUnlocked();
    } else {
      _attemptCount++;
      setState(() => _isError = true);
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);

      // Check for lockout
      if (_attemptCount >= _maxAttempts) {
        _startLockout();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _enteredDigits.clear();
        _isError = false;
      });
    }
  }

  void _startLockout() async {
    try {
      final box = Hive.box('settingsBox');
      final lockoutEnd = DateTime.now().millisecondsSinceEpoch + (30 * 1000);
      await box.put('pin_lockout_end', lockoutEnd);
    } catch (_) {}

    setState(() {
      _isLocked = true;
      _lockoutSeconds = 30;
    });

    _startLockoutCountdown();
  }

  void _startLockoutCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _lockoutSeconds--);
      if (_lockoutSeconds <= 0) {
        _clearLockout();
        return false;
      }
      return true;
    });
  }

  Future<void> _clearLockout() async {
    try {
      final box = Hive.box('settingsBox');
      await box.delete('pin_lockout_end');
    } catch (_) {}
    setState(() {
      _isLocked = false;
      _attemptCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),

              // App Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: KoalaColors.primaryUi(context),
                  borderRadius: BorderRadius.circular(KoalaRadius.lg),
                ),
                child: Center(
                  child: Text('🐨', style: TextStyle(fontSize: 40.sp)),
                ),
              ),

              SizedBox(height: 20.h),

              // App name
              Text('Koala', style: KoalaTypography.heading2(context)),

              SizedBox(height: 8.h),

              // Instruction
              Text(
                'Entrez votre code PIN',
                style: KoalaTypography.bodyMedium(context).copyWith(
                  color: KoalaColors.textSecondary(context),
                ),
              ),

              SizedBox(height: 32.h),

              // PIN dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake = _shakeAnimation.value * 10;
                  return Transform.translate(
                    offset: Offset(
                      shake *
                          ((_shakeController.value * 10).toInt() % 2 == 0
                              ? 1
                              : -1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _enteredDigits.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isError
                            ? KoalaColors.destructive
                            : _isSuccess
                                ? KoalaColors.success
                                : isFilled
                                    ? KoalaColors.accent
                                    : Colors.transparent,
                        border: Border.all(
                          color: _isError
                              ? KoalaColors.destructive
                              : _isSuccess
                                  ? KoalaColors.success
                                  : KoalaColors.accent,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Fixed height container for error message (prevents layout shift)
              SizedBox(
                height: 28.h,
                child: Center(
                  child: _isLocked
                      ? Text(
                          'Réessayer dans $_lockoutSeconds s',
                          style: KoalaTypography.bodySmall(context).copyWith(
                            color: KoalaColors.warning,
                          ),
                        )
                      : _isError
                          ? Text(
                              'Code incorrect (${_maxAttempts - _attemptCount} essais restants)',
                              style:
                                  KoalaTypography.bodySmall(context).copyWith(
                                color: KoalaColors.destructive,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),

              SizedBox(height: 16.h),

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
            SizedBox(width: 72.w, height: 72.w),
            _buildDigitButton(context, '0'),
            _buildActionButton(context,
                icon: Icons.backspace_outlined, onTap: _onBackspace),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitButton(BuildContext context, String digit) {
    return _PressableButton(
      onTap: () => _onDigitPressed(digit),
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KoalaColors.surface(context),
          border: Border.all(color: KoalaColors.border(context), width: 1),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 28.sp,
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
    return _PressableButton(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(icon, size: 26.sp, color: KoalaColors.text(context)),
        ),
      ),
    );
  }
}

/// Button with scale-down press effect for tactile feedback
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _isPressed ? [] : KoalaShadows.sm,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
