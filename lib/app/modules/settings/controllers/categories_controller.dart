import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:uuid/uuid.dart';

class CategoriesController extends GetxController {
  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    final box = Hive.box<Category>('categoryBox');
    
    if (box.isEmpty) {
      await _seedDefaultCategories(box);
    } else {
      await _migrateLegacyIcons(box);
    }

    categories.assignAll(box.values.toList());
    
    // Listen to changes
    box.watch().listen((_) {
      categories.assignAll(box.values.toList());
    });
  }

  Future<void> _migrateLegacyIcons(Box<Category> box) async {
    for (var category in box.values) {
      if (IconHelper.isEmoji(category.icon)) {
        for (var enumCat in TransactionCategory.values) {
          if (enumCat.displayName == category.name) {
             category.icon = enumCat.iconKey;
             await category.save();
             break;
          }
        }
      }
    }
  }

  Future<void> _seedDefaultCategories(Box<Category> box) async {
    final List<Category> defaults = [];
    
    // Seed Income Categories
    for (var cat in TransactionCategoryExtension.getByType(TransactionType.income)) {
      defaults.add(Category(
        id: const Uuid().v4(),
        name: cat.displayName,
        icon: cat.icon,
        colorValue: Colors.green.value, // Default green for income
        type: TransactionType.income,
        isDefault: true,
      ));
    }

    // Seed Expense Categories
    int colorIndex = 0;
    for (var cat in TransactionCategoryExtension.getByType(TransactionType.expense)) {
      defaults.add(Category(
        id: const Uuid().v4(),
        name: cat.displayName,
        icon: cat.icon,
        colorValue: Colors.primaries[colorIndex % Colors.primaries.length].value,
        type: TransactionType.expense,
        isDefault: true,
      ));
      colorIndex++;
    }

    await box.addAll(defaults);
  }

  List<Category> get incomeCategories => 
      categories.where((c) => c.type == TransactionType.income).toList();

  List<Category> get expenseCategories => 
      categories.where((c) => c.type == TransactionType.expense).toList();

  Future<void> addCategory({
    required String name,
    required String icon,
    required int colorValue,
    required TransactionType type,
  }) async {
    final box = Hive.box<Category>('categoryBox');
    final category = Category(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      colorValue: colorValue,
      type: type,
      isDefault: false,
    );
    await box.add(category);
  }

  Future<void> updateCategory(Category category) async {
    await category.save();
  }

  Future<void> deleteCategory(Category category) async {
    if (category.isDefault) {
      Get.snackbar(
        'Action impossible',
        'Vous ne pouvez pas supprimer une catégorie par défaut',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    await category.delete();
  }

  void showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    String selectedIcon = 'other';
    Color selectedColor = Colors.blue;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Material(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Text(
                'Nouvelle Catégorie',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Nom de la catégorie',
              ),
              const SizedBox(height: 20),
              // Simplified Type Selector
              CupertinoSegmentedControl<TransactionType>(
                groupValue: selectedType,
                children: const {
                  TransactionType.expense: Text('Dépense'),
                  TransactionType.income: Text('Revenu'),
                },
                onValueChanged: (value) {
                  // State management inside dialog would need StatefulBuilder or Getx
                  // For simplicity, just logic here
                  selectedType = value!;
                },
              ),
              const Spacer(),
              CupertinoButton.filled(
                child: const Text('Ajouter'),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    addCategory(
                      name: nameController.text,
                      icon: selectedIcon,
                      colorValue: selectedColor.value,
                      type: selectedType,
                    );
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}