import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/financial_goal.dart'; // Added
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:uuid/uuid.dart';

class GoalCreationDialog extends StatefulWidget {
  const GoalCreationDialog({super.key});

  @override
  State<GoalCreationDialog> createState() => _GoalCreationDialogState();
}

class _GoalCreationDialogState extends State<GoalCreationDialog> {
  final GoalsController _goalsController = Get.find<GoalsController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  GoalType _selectedGoalType = GoalType.savings;
  DateTime? _selectedTargetDate;

  // For icon and color selection
  int? _selectedIconKey;
  final Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedTargetDate) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Créer un nouvel objectif', style: theme.textTheme.titleLarge),
            SizedBox(height: 24.h),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre de l\'objectif',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Montant cible',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                suffixText: 'FCFA',
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<GoalType>(
              initialValue: _selectedGoalType,
              decoration: InputDecoration(
                labelText: 'Type d\'objectif',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              items: GoalType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                            type.toString().split('.').last), // e.g., 'savings'
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGoalType = value;
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            ListTile(
              title: Text(_selectedTargetDate == null
                  ? 'Sélectionner une date cible (optionnel)'
                  : 'Date cible: ${DateFormat('dd/MM/yyyy').format(_selectedTargetDate!)}'),
              trailing: const Icon(CupertinoIcons.calendar),
              onTap: () => _selectDate(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              tileColor: theme.inputDecorationTheme.fillColor,
            ),
            SizedBox(height: 16.h),
            // Icon and color picker row
            Row(
              children: [
                Expanded(
                  child: Text('Icône:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                Wrap(
                  spacing: 8.w,
                  children: [0, 1, 2, 3, 4, 5].map((index) {
                    final isSelected = _selectedIconKey == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconKey = index),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                          border: isSelected
                              ? Border.all(color: _selectedColor, width: 2)
                              : null,
                        ),
                        child: CategoryIcon(
                            iconKey: index.toString(),
                            size: 24.sp,
                            color: isSelected ? _selectedColor : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => NavigationHelper.safeBack(),
                        child: const Text('Annuler'))),
                SizedBox(width: 12.w),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty &&
                        _targetAmountController.text.isNotEmpty) {
                      final amount = double.parse(_amountController.text);

                      final newGoal = FinancialGoal(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        targetAmount: amount,
                        type: _selectedType,
                        targetDate: _selectedDate,
                        iconKey: _selectedIconKey ?? 0,
                        colorValue: _selectedColor.value,
                      );

                      await controller.addGoal(newGoal);
                      NavigationHelper.safeBack();
                    }
                  },
                  child: const Text('Créer'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


