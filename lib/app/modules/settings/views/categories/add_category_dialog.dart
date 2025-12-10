import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';

void showAddCategoryDialog(BuildContext context, {Category? category}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddCategorySheet(category: category),
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
  late String _selectedIcon;
  late Color _selectedColor;
  
  final List<String> _emojis = [
    '🍔', '🛒', '🚗', '🏠', '💡', '🎮', '💊', '🎓', '✈️', '🎁',
    '👗', '🔧', '📱', '💻', '💼', '💰', '📈', '🏦', '👶', '🐾',
    '🏋️', '🎨', '📚', '🎵', '🎥', '🚌', '⛽', '💇', '💐', '💸',
    '🍇', '🍻', '🥂', '🧊', '🎲', '🎰', '🎯', '🎳', '🎷', '🎸',
  ];

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = Color(widget.category!.colorValue);
    } else {
      _selectedType = TransactionType.expense;
      _selectedIcon = _emojis.first;
      _selectedColor = _colors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      if (widget.category != null) {
        widget.category!.name = _nameController.text.trim();
        widget.category!.icon = _selectedIcon;
        widget.category!.colorValue = _selectedColor.value;
        widget.category!.type = _selectedType;
        await _controller.updateCategory(widget.category!);
      } else {
        await _controller.addCategory(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          colorValue: _selectedColor.value,
          type: _selectedType,
        );
      }
      
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                  style: theme.textTheme.titleLarge,
                ),
                CloseButton(onPressed: () => Get.back()),
              ],
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(24.w),
                children: [
                  // Type Selector
                  if (!isEditing) ...[
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(value: TransactionType.expense, label: Text('Dépense')),
                        ButtonSegment(value: TransactionType.income, label: Text('Revenu')),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<TransactionType> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                        });
                      },
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Preview Icon
                  Center(
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: _selectedColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _selectedIcon,
                          style: TextStyle(fontSize: 40.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom de la catégorie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  SizedBox(height: 24.h),

                  // Icon Picker
                  Text('Icône', style: theme.textTheme.titleMedium),
                  SizedBox(height: 12.h),
                  Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(12.w),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _emojis.length,
                      itemBuilder: (context, index) {
                        final emoji = _emojis[index];
                        final isSelected = _selectedIcon == emoji;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = emoji),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: isSelected ? Border.all(color: _selectedColor) : null,
                            ),
                            child: Center(
                              child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Color Picker
                  Text('Couleur', style: theme.textTheme.titleMedium),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 48.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
