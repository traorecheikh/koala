import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/transactions/controllers/transactions_controller.dart';

class AddTransactionSheet extends GetView<TransactionsController> {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Transaction', style: theme.textTheme.headlineSmall),
            SizedBox(height: 24.h),
            _buildTextField('Title', controller.titleController),
            SizedBox(height: 16.h),
            _buildTextField('Amount', controller.amountController, keyboardType: TextInputType.number),
            SizedBox(height: 16.h),
            _buildDropdown('Category', controller.selectedCategory, controller.categories),
            SizedBox(height: 16.h),
            _buildDropdown('Account', controller.selectedAccount, controller.accounts),
            SizedBox(height: 16.h),
            _buildTextField('Description', controller.descriptionController, maxLines: 3),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.saveTransaction(),
                    child: const Text('Save'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, int? maxLines}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, RxString selectedValue, List<String> options) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: selectedValue.value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            selectedValue.value = value;
          }
        },
      ),
    );
  }
}
