import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:koaa/app/modules/settings/views/categories/add_category_dialog.dart'
    as styled;
import 'package:uuid/uuid.dart';
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
    // Check if any categories exist in Isar
    final existingCategories = await IsarService.getAllCategories();

    if (existingCategories.isEmpty) {
      await _seedDefaultCategories();
    } else {
      await _migrateLegacyIcons(existingCategories);
    }

    categories.assignAll(await IsarService.getAllCategories());

    // Listen to changes from Isar
    _categoryBoxSubscription = IsarService.watchCategories().listen((cats) {
      categories.assignAll(cats);
    });
  }

  Future<void> _migrateLegacyIcons(List<Category> categoryList) async {
    for (var category in categoryList) {
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

  Future<void> _seedDefaultCategories() async {
    final List<Category> defaults = [];

    // Seed Income Categories
    for (var cat
        in TransactionCategoryExtension.getByType(TransactionType.income)) {
      defaults.add(Category(
        id: const Uuid().v4(),
        name: cat.displayName,
        icon: cat.icon,
        colorValue: Colors.green.toARGB32(), // Default green for income
        type: TransactionType.income,
        isDefault: true,
      ));
    }

    // Seed Expense Categories
    int colorIndex = 0;
    for (var cat
        in TransactionCategoryExtension.getByType(TransactionType.expense)) {
      defaults.add(Category(
        id: const Uuid().v4(),
        name: cat.displayName,
        icon: cat.icon,
        colorValue:
            Colors.primaries[colorIndex % Colors.primaries.length].toARGB32(),
        type: TransactionType.expense,
        isDefault: true,
      ));
      colorIndex++;
    }

    IsarService.addCategories(defaults);
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
      final category = Category(
        id: const Uuid().v4(),
        name: name,
        icon: icon,
        colorValue: colorValue,
        type: type,
        isDefault: false,
      );
      await category.save();
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
      IsarService.updateCategory(category);
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
    // Delegate to the styled dialog from add_category_dialog.dart
    styled.showAddCategoryDialog(context);
  }
}
