import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koala/app/shared/theme/colors.dart';

class PinInputWidget extends StatelessWidget {
  final int length;
  final List<String> enteredDigits;
  final bool isLoading;

  const PinInputWidget({
    super.key,
    required this.length,
    required this.enteredDigits,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          child: _buildPinDot(index),
        ),
      ),
    );
  }

  Widget _buildPinDot(int index) {
    final bool isFilled = index < enteredDigits.length;
    final bool isActive = index == enteredDigits.length && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isActive
              ? AppColors.primary
              : isFilled
              ? AppColors.primary
              : AppColors.border,
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: isLoading && index == 0
          ? SizedBox(
              width: 12.w,
              height: 12.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : null,
    );
  }
}
