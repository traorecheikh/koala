import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'dart:async'; // Added import for StreamSubscription

class CategoriesController extends GetxController {
  final categories = <Category>[].obs;
  StreamSubscription? _categoryBoxSubscription; // Store the subscription

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
  }

  @override
  void onClose() {
    _categoryBoxSubscription?.cancel(); // Cancel the subscription
    super.onClose();
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
    _categoryBoxSubscription = box.watch().listen((_) {
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
    try {
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
      Get.snackbar(
        'Succès',
        'Catégorie ajoutée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter la catégorie: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await category.save();
      Get.snackbar(
        'Succès',
        'Catégorie mise à jour avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la catégorie: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
    try {
      await category.delete();
      Get.snackbar(
        'Succès',
        'Catégorie supprimée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la catégorie: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
                    NavigationHelper.safeBack();
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