import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/widgets/category_tile.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Catégories',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.add, color: theme.colorScheme.primary),
            onPressed: () => controller.showAddCategoryDialog(context),
          ),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return CategoryTile(category: category);
          },
        ),
      ),
    );
  }
}