import 'package:flutter/material.dart';
import 'package:koaa/app/core/theme.dart';

class GlobalHeroBackground extends StatelessWidget {
  final Widget child;

  const GlobalHeroBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HeroThemeData?>(
      valueListenable: AppTheme.heroThemeNotifier,
      builder: (context, heroTheme, _) {
        if (heroTheme == null) {
          return child;
        }

        return Stack(
          children: [
            // Base Application
            child,

            // Texture Overlay (PointerEvents.none to pass touches)
            IgnorePointer(
              child: Opacity(
                opacity: heroTheme.patternOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(heroTheme.patternAsset),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        heroTheme.patternColor,
                        BlendMode.srcIn,
                      ),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
            ),

            // Optional Vignette for Immersive Feel
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      heroTheme.baseColor.withValues(alpha: 0.1),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
