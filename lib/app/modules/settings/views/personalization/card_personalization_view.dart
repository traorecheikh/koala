import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/theme.dart';
import 'package:koaa/app/modules/home/widgets/enhanced_balance_card.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart';

class CardPersonalizationView extends GetView<SettingsController> {
  const CardPersonalizationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary local state for preview before applying
    final Rx<BalanceCardStyle> previewStyle =
        controller.currentCardStyle.value.obs;
    final RxString previewHero = controller.currentHeroAsset.value.obs;

    // PageController for carousel
    final PageController pageController = PageController(
      viewportFraction: 0.85,
      initialPage:
          BalanceCardStyle.values.indexOf(controller.currentCardStyle.value),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Personnalisation',
          style: KoalaTypography.heading3(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),

          // 1. CAROUSEL PREVIEW
          SizedBox(
            height: 240.h,
            child: PageView.builder(
              controller: pageController,
              itemCount: BalanceCardStyle.values.length,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                previewStyle.value = BalanceCardStyle.values[index];
              },
              itemBuilder: (context, index) {
                final style = BalanceCardStyle.values[index];

                return Obx(() {
                  // Calculate scale for carousel effect
                  // We can't easily animate scale driven by controller here without logic,
                  // so we kept it simple PageView for now.

                  final isSelected = previewStyle.value == style;

                  return AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: isSelected ? 1.0 : 0.9,
                    child: Center(
                      child: EnhancedBalanceCard(
                        style: style,
                        isPreview: true,
                        // If Hero style is active in preview, pass the preview Hero asset
                        // Otherwise for non-hero styles, use app theme (or potentially a picker later)
                        heroAsset: style == BalanceCardStyle.hero
                            ? previewHero.value
                            : null,
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          SizedBox(height: 30.h),

          // 2. CONTROLS SECTION
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Obx(() {
                final style = previewStyle.value;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStyleName(style),
                        style: KoalaTypography.heading2(context),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _getStyleDescription(style),
                        style: KoalaTypography.bodyMedium(context).copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Specific Controls
                      if (style == BalanceCardStyle.hero) ...[
                        Text(
                          'Choisir un Héros',
                          style: KoalaTypography.heading3(context)
                              .copyWith(fontSize: 16.sp),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 80.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: SettingsController.heroThemes.length,
                            separatorBuilder: (_, __) => SizedBox(width: 16.w),
                            itemBuilder: (context, index) {
                              final assetPath = SettingsController
                                  .heroThemes.keys
                                  .elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  previewHero.value = assetPath;
                                },
                                child: Obx(() {
                                  final isSelected =
                                      previewHero.value == assetPath;
                                  return Container(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: isSelected
                                              ? controller.activeThemeColor
                                              : Colors.transparent,
                                          width: 3),
                                      image: DecorationImage(
                                        image: AssetImage(assetPath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        // Standard Style Controls
                        if (style != BalanceCardStyle.classic) ...[
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: controller.activeThemeColor
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(KoalaRadius.md),
                              border: Border.all(
                                  color: controller.activeThemeColor
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.palette_outlined,
                                    color: controller.activeThemeColor),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Ce style s\'adapte à la couleur de votre thème.',
                                    style: KoalaTypography.caption(context)
                                        .copyWith(
                                      color: controller.activeThemeColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Couleur du Thème',
                            style: KoalaTypography.heading3(context)
                                .copyWith(fontSize: 16.sp),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: AppSkin.values.map((skin) {
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.changeSkin(skin);
                                },
                                child: Obx(() {
                                  final isSelected =
                                      controller.currentSkin.value == skin;
                                  return Container(
                                    width: 45.w,
                                    height: 45.w,
                                    decoration: BoxDecoration(
                                      color: skin.color,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              width: 3)
                                          : null,
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: skin.color.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                      ],
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check,
                                            color: Colors.white, size: 20.sp)
                                        : null,
                                  );
                                }),
                              );
                            }).toList(),
                          ),
                        ],
                      ],

                      SizedBox(height: 24.h),

                      // APPLY BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            controller.changeCardStyle(previewStyle.value);
                            if (previewStyle.value == BalanceCardStyle.hero) {
                              controller.changeHeroAsset(previewHero.value);
                            }
                            Get.back();
                            Get.snackbar(
                              'Style appliqué',
                              'Votre carte a été mise à jour avec succès.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: controller.activeThemeColor,
                              colorText: Colors.white,
                              margin: EdgeInsets.all(16.w),
                              borderRadius: 16.r,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.activeThemeColor,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(KoalaRadius.xl),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Appliquer ce style',
                            style: KoalaTypography.bodyLarge(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _getStyleName(BalanceCardStyle style) {
    switch (style) {
      case BalanceCardStyle.classic:
        return 'Classique';
      case BalanceCardStyle.minimal:
        return 'Minimaliste';
      case BalanceCardStyle.mesh:
        return 'Mesh Gradient';
      case BalanceCardStyle.comic:
        return 'Pop Art / Comic';
      case BalanceCardStyle.hero:
        return 'Mode Héros';
    }
  }

  String _getStyleDescription(BalanceCardStyle style) {
    switch (style) {
      case BalanceCardStyle.classic:
        return 'Le style original avec gradients dynamiques selon l\'heure de la journée.';
      case BalanceCardStyle.minimal:
        return 'Simple, épuré et sans distraction.';
      case BalanceCardStyle.mesh:
        return 'Des dégradés fluides et organiques.';
      case BalanceCardStyle.comic:
        return 'Un style inspiré des bandes dessinées avec des effets de trame.';
      case BalanceCardStyle.hero:
        return 'Affichez votre héros préféré en arrière-plan avec un thème assorti.';
    }
  }
}
