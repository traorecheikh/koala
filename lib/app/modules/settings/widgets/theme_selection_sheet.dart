import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/theme.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart';

class ThemeSelectionSheet extends StatelessWidget {
  const ThemeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return KoalaBottomSheet(
      title: 'Apparence',
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Couleur d\'accentuation',
              style: KoalaTypography.label(context),
            ),
            SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: AppSkin.values.map((skin) {
                    final isSelected = controller.currentSkin.value == skin;
                    return _buildColorOption(context, skin, isSelected, () {
                      controller.changeSkin(skin);
                    });
                  }).toList(),
                )),
            SizedBox(height: 32),
            Text(
              'Mode sombre',
              style: KoalaTypography.label(context),
            ),
            SizedBox(height: 12),
            _buildDarkModeSwitch(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
      BuildContext context, AppSkin skin, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: skin.color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: KoalaColors.text(context), width: 3)
                  : null,
              boxShadow: KoalaShadows.sm,
            ),
            child: isSelected
                ? Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
          SizedBox(height: 8),
          Text(
            skin.label.split(' ').first, // Show only first word for compactness
            style: KoalaTypography.caption(context).copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? KoalaColors.text(context)
                  : KoalaColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSwitch(
      BuildContext context, SettingsController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: KoalaColors.inputBackground(context),
        borderRadius: BorderRadius.circular(KoalaRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.dark_mode_rounded, color: KoalaColors.text(context)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mode sombre',
              style: KoalaTypography.bodyMedium(context),
            ),
          ),
          Obx(() => Switch.adaptive(
                value: controller.isDarkMode.value,
                onChanged: controller.toggleTheme,
                activeColor: KoalaColors.primaryUi(context),
              )),
        ],
      ),
    );
  }
}
