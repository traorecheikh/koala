import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/core/design_system.dart';

void showAddCategoryDialog(BuildContext context, {Category? category}) {
  Get.bottomSheet(
    KoalaBottomSheet(
      title: category != null ? 'Modifier la catégorie' : 'Nouvelle catégorie',
      icon: category != null ? Icons.edit_rounded : Icons.category_rounded,
      child: _AddCategorySheet(category: category),
    ),
    isScrollControlled: true,
  );
}

class _AddCategorySheet extends StatefulWidget {
  final Category? category;
  const _AddCategorySheet({this.category});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _controller = Get.find<CategoriesController>();

  late TransactionType _selectedType;
  late String _selectedIconKey;
  late Color _selectedColor;

  final List<String> _iconKeys = IconHelper.allKeys;

  final List<Color> _colors = [
    const Color(0xFFFF3B30), // iOS Red
    const Color(0xFFFF9500), // iOS Orange
    const Color(0xFFFFCC00), // iOS Yellow
    const Color(0xFF34C759), // iOS Green
    const Color(0xFF00C7BE), // iOS Teal
    const Color(0xFF30B0C7), // iOS Cyan
    const Color(0xFF007AFF), // iOS Blue
    const Color(0xFF5856D6), // iOS Indigo
    const Color(0xFFAF52DE), // iOS Purple
    const Color(0xFFFF2D55), // iOS Pink
    const Color(0xFFA2845E), // iOS Brown
    const Color(0xFF8E8E93), // iOS Grey
    const Color(0xFF1C1C1E), // Darker Grey / Carbon
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIconKey = widget.category!.icon;
      _selectedColor = Color(widget.category!.colorValue);
    } else {
      _selectedType = TransactionType.expense;
      _selectedIconKey = _iconKeys.first; // Default
      _selectedColor = _colors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getColorName(Color color) {
    // Basic color naming for Tooltip/Semantics
    if (color == const Color(0xFFFF3B30)) return 'Rouge';
    if (color == const Color(0xFFFF9500)) return 'Orange';
    if (color == const Color(0xFFFFCC00)) return 'Jaune';
    if (color == const Color(0xFF34C759)) return 'Vert';
    if (color == const Color(0xFF00C7BE)) return 'Teal';
    if (color == const Color(0xFF30B0C7)) return 'Cyan';
    if (color == const Color(0xFF007AFF)) return 'Bleu';
    if (color == const Color(0xFF5856D6)) return 'Indigo';
    if (color == const Color(0xFFAF52DE)) return 'Violet';
    if (color == const Color(0xFFFF2D55)) return 'Rose';
    if (color == const Color(0xFFA2845E)) return 'Marron';
    if (color == const Color(0xFF8E8E93)) return 'Gris';
    if (color == const Color(0xFF1C1C1E)) return 'Noir';
    return 'Couleur';
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      if (widget.category != null) {
        widget.category!.name = _nameController.text.trim();
        widget.category!.icon = _selectedIconKey;
        widget.category!.colorValue = _selectedColor.toARGB32();
        widget.category!.type = _selectedType;
        await _controller.updateCategory(widget.category!);
      } else {
        await _controller.addCategory(
          name: _nameController.text.trim(),
          icon: _selectedIconKey,
          colorValue: _selectedColor.toARGB32(),
          type: _selectedType,
        );
      }

      NavigationHelper.safeBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 48.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selector
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: KoalaColors.background(context),
                borderRadius: BorderRadius.circular(KoalaRadius.md),
              ),
              child: Row(
                children: [
                  _TypeButton(
                    label: 'Dépense',
                    type: TransactionType.expense,
                    isSelected: _selectedType == TransactionType.expense,
                    onTap: () =>
                        setState(() => _selectedType = TransactionType.expense),
                  ),
                  _TypeButton(
                    label: 'Revenu',
                    type: TransactionType.income,
                    isSelected: _selectedType == TransactionType.income,
                    onTap: () =>
                        setState(() => _selectedType = TransactionType.income),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Preview & Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Hero(
                  tag: widget.category?.id ?? 'new_category_icon',
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: CategoryIcon(
                      iconKey: _selectedIconKey,
                      size: 32.sp,
                      color: _selectedColor,
                    ),
                  ).animate(key: ValueKey(_selectedIconKey)).shimmer(
                        duration: 800.ms,
                        color: _selectedColor.withValues(alpha: 0.2),
                      ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: KoalaTextField(
                    controller: _nameController,
                    label: 'Nom de la catégorie',
                    validator: (v) => v!.isEmpty ? 'Le nom est requis' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Icon Picker
            Text('Icône', style: KoalaTypography.heading4(context)),
            SizedBox(height: 16.h),
            Container(
              height: 220.h,
              decoration: BoxDecoration(
                color: KoalaColors.background(context),
                borderRadius: BorderRadius.circular(KoalaRadius.lg),
                border: Border.all(color: KoalaColors.border(context)),
              ),
              child: GridView.builder(
                padding: EdgeInsets.all(12.w),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.w,
                ),
                itemCount: _iconKeys.length,
                itemBuilder: (context, index) {
                  final key = _iconKeys[index];
                  final isSelected = _selectedIconKey == key;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedIconKey = key);
                    },
                    child: AnimatedContainer(
                      duration: KoalaAnim.fast,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor
                            : KoalaColors.surface(context),
                        borderRadius: BorderRadius.circular(KoalaRadius.md),
                        boxShadow: isSelected ? KoalaShadows.sm : null,
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : KoalaColors.border(context),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: CategoryIcon(
                          iconKey: key,
                          size: 24.sp,
                          color: isSelected
                              ? Colors.white
                              : KoalaColors.textSecondary(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32.h),

            // Color Picker
            Text('Couleur', style: KoalaTypography.heading4(context)),
            SizedBox(height: 16.h),
            Center(
              child: Wrap(
                spacing: 16.w,
                runSpacing: 16.w,
                alignment: WrapAlignment.center,
                children: _colors.map((color) {
                  final isSelected =
                      _selectedColor.toARGB32() == color.toARGB32();
                  return Tooltip(
                    message: _getColorName(color),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedColor = color);
                      },
                      child: AnimatedContainer(
                        duration: KoalaAnim.fast,
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? KoalaColors.text(context)
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected ? KoalaShadows.md : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 48.h),

            // Save Button
            KoalaButton(
              text: widget.category != null
                  ? 'Mettre à jour'
                  : 'Créer la catégorie',
              onPressed: _save,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final TransactionType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color:
                isSelected ? KoalaColors.surface(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(KoalaRadius.sm),
            boxShadow: isSelected ? KoalaShadows.xs : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? KoalaColors.text(context)
                  : KoalaColors.textSecondary(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
