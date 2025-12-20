import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart'; // Added
import 'package:koaa/app/core/utils/navigation_helper.dart';

class AddGoalView extends StatefulWidget {
  final FinancialGoal? goalToEdit;

  const AddGoalView({super.key, this.goalToEdit});

  @override
  State<AddGoalView> createState() => _AddGoalViewState();
}

class _AddGoalViewState extends State<AddGoalView> {
  final GoalsController controller = Get.find<GoalsController>();
  final CategoriesController categoriesController =
      Get.find<CategoriesController>(); // Added

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;

  late GoalType selectedType;
  late int selectedIcon;
  late Color selectedColor;
  DateTime? selectedDate;
  Category? selectedCategory; // Added

  @override
  void initState() {
    super.initState();
    final goal = widget.goalToEdit;
    titleController = TextEditingController(text: goal?.title);
    descriptionController = TextEditingController(text: goal?.description);
    amountController =
        TextEditingController(text: goal?.targetAmount.toString());

    selectedType = goal?.type ?? GoalType.savings;
    selectedIcon = goal?.iconKey ?? Icons.star.codePoint;
    selectedColor =
        goal?.colorValue != null ? Color(goal!.colorValue!) : Colors.blue;
    selectedDate = goal?.targetDate;

    // Load linked category
    if (goal?.linkedCategoryId != null) {
      selectedCategory = categoriesController.categories
          .firstWhereOrNull((c) => c.id == goal!.linkedCategoryId);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 0.9.sh, // Take up 90% of screen
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.goalToEdit != null ? 'Modifier' : 'Nouveau Projet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => NavigationHelper.safeBack(),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.xmark, size: 18),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  KoalaTextField(
                    controller: titleController,
                    label: 'Nom du projet',
                    icon: CupertinoIcons.tag,
                  ),
                  SizedBox(height: 24.h),

                  // Amount Input
                  KoalaTextField(
                    controller: amountController,
                    label: 'Montant cible',
                    icon: CupertinoIcons.money_dollar,
                    keyboardType: TextInputType.number,
                    isAmount: true,
                  ),
                  SizedBox(height: 24.h),

                  // Type Selector
                  _buildSectionLabel('Type d\'objectif', theme),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: GoalType.values
                        .map((type) => _buildTypeChip(type, theme))
                        .toList(),
                  ),

                  if (selectedType == GoalType.savings ||
                      selectedType == GoalType.purchase) ...[
                    SizedBox(height: 24.h),
                    _buildSectionLabel(
                        'Lier à une catégorie (Auto-épargne)', theme),
                    GestureDetector(
                      onTap: () {
                        Get.bottomSheet(
                          Container(
                            height: 0.5.sh,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24.r)),
                            ),
                            child: Column(
                              children: [
                                Text('Choisir une catégorie',
                                    style: theme.textTheme.titleLarge),
                                SizedBox(height: 16.h),
                                Expanded(
                                  child: Obx(() => ListView(
                                        children: categoriesController
                                            .categories
                                            .map((cat) {
                                          return ListTile(
                                            leading: CategoryIcon(
                                                iconKey: cat.icon,
                                                useOriginalColor: true),
                                            title: Text(cat.name),
                                            onTap: () {
                                              setState(
                                                  () => selectedCategory = cat);
                                              Get.back();
                                            },
                                          );
                                        }).toList(),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            if (selectedCategory != null)
                              CategoryIcon(
                                  iconKey: selectedCategory!.icon,
                                  size: 24.sp,
                                  useOriginalColor: true)
                            else
                              Icon(CupertinoIcons.layers_alt,
                                  color: theme.primaryColor),
                            SizedBox(width: 12.w),
                            Text(
                              selectedCategory?.name ??
                                  'Sélectionner une catégorie',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Icon(CupertinoIcons.chevron_down,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Date
                  _buildSectionLabel('Date cible (Optionnel)', theme),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ??
                            DateTime.now().add(const Duration(days: 90)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              color: theme.primaryColor),
                          SizedBox(width: 12.w),
                          Text(
                            selectedDate == null
                                ? 'Sélectionner une date'
                                : DateFormat('dd MMM yyyy', 'fr_FR')
                                    .format(selectedDate!),
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Spacer(),
                          Icon(CupertinoIcons.chevron_right,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Customization
                  _buildSectionLabel('Personnalisation', theme),
                  SizedBox(height: 12.h),
                  _buildColorPicker(theme),
                  SizedBox(height: 16.h),
                  _buildIconPicker(theme),
                  SizedBox(height: 40.h),
                ]
                    .animate(interval: 50.ms)
                    .fadeIn(duration: KoalaAnim.medium)
                    .slideY(begin: 0.1, curve: KoalaAnim.entryCurve),
              ),
            ),
          ),

          // Footer Button
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  widget.goalToEdit != null
                      ? 'Sauvegarder les modifications'
                      : 'Créer l\'objectif',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeChip(GoalType type, ThemeData theme) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          _goalTypeToString(type),
          style: TextStyle(
            color:
                isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.indigo
    ];

    return SizedBox(
      height: 50.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColor.toARGB32() == color.toARGB32();
          return GestureDetector(
            onTap: () => setState(() => selectedColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3.w)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconPicker(ThemeData theme) {
    return SizedBox(
      height: 60.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: IconHelper.goalIcons.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final icon = IconHelper.goalIcons[index];
          final isSelected = selectedIcon == icon.codePoint;
          return GestureDetector(
            onTap: () => setState(() => selectedIcon = icon.codePoint),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withValues(alpha: 0.1)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? selectedColor
                      : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 2.w : 1.w,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? selectedColor : Colors.grey,
                size: 28.sp,
              ),
            ),
          );
        },
      ),
    );
  }

  String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.savings:
        return 'Épargne';
      case GoalType.debtPayoff:
        return 'Dette';
      case GoalType.purchase:
        return 'Achat';
      case GoalType.custom:
        return 'Autre';
    }
  }

  void _saveGoal() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar(
        'Manquant',
        'Veuillez entrer un titre et un montant.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
      return;
    }

    final FinancialGoal newGoal;

    if (widget.goalToEdit != null) {
      // Editing existing goal
      newGoal = widget.goalToEdit!.copyWith(
        title: titleController.text,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        targetAmount: double.parse(amountController.text),
        type: selectedType,
        targetDate: selectedDate,
        iconKey: selectedIcon,
        colorValue: selectedColor.toARGB32(),
        linkedCategoryId: selectedCategory?.id,
      );
    } else {
      // Creating new goal
      newGoal = FinancialGoal.create(
        title: titleController.text,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        targetAmount: double.parse(amountController.text),
        type: selectedType,
        targetDate: selectedDate,
        iconKey: selectedIcon,
        colorValue: selectedColor.toARGB32(),
        linkedCategoryId: selectedCategory?.id,
      );
    }

    if (widget.goalToEdit != null) {
      await controller.updateGoal(newGoal);
    } else {
      await controller.addGoal(newGoal);
    }
    NavigationHelper.safeBack();
  }
}
