
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';

void showEditProfileDialog(BuildContext context) {
  final homeController = Get.find<HomeController>();
  final user = homeController.user.value;
  if (user == null) return;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController(text: user.fullName);
  final salaryController = TextEditingController(text: user.salary.toString());
  final paydayController = TextEditingController(text: user.payday.toString());
  final ageController = TextEditingController(text: user.age.toString());
  String budgetingType = user.budgetingType;

  Get.dialog(
    AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your salary';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: paydayController,
                decoration: const InputDecoration(labelText: 'Payday (Day of Month)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your payday';
                  }
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) {
                    return 'Please enter a valid day (1-31)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: budgetingType,
                decoration: const InputDecoration(labelText: 'Budgeting Type'),
                items: ['50/30/20', '70/20/10', 'Zero-Based']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  budgetingType = value!;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final updatedUser = LocalUser(
                fullName: fullNameController.text,
                salary: double.parse(salaryController.text),
                payday: int.parse(paydayController.text),
                age: int.parse(ageController.text),
                budgetingType: budgetingType,
              );
              homeController.user.value = updatedUser;
              Get.back();
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
