import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';

class CategoryTile extends StatelessWidget {
  final Category category;

  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(category.colorValue).withOpacity(0.1), // Subtler bg
          shape: BoxShape.circle,
        ),
        // Use CategoryIcon to render PNG
        child: CategoryIcon(
          iconKey: category.icon,
          size: 28,
          useOriginalColor: true, // Keep the PNG's nice colors
        ),
      ),
      title: Text(category.name),
      trailing: category.isDefault
          ? null
          : IconButton(
              icon: const Icon(CupertinoIcons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Supprimer la catégorie ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuler'),
            onPressed: () => Get.back(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Supprimer'),
            onPressed: () {
              controller.deleteCategory(category);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}