import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconHelper {
  // We keep this list for reference, but we primarily rely on PNGs now.
  static const Set<String> supportedPngs = {
    'beauty', 'bills', 'bonus', 'business', 'charity', 'clothing', 'education', 
    'entertainment', 'family', 'fitness', 'food', 'freelance', 'groceries', 
    'health', 'insurance', 'investment', 'maintenance', 'other', 'pets', 
    'refund', 'rent', 'rental', 'restaurant', 'salary', 'shopping', 
    'subscriptions', 'tech', 'transport', 'travel', 'utilities', 'gift',
  };

  static bool isEmoji(String text) {
    final RegExp regex = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    return regex.hasMatch(text);
  }

  // Deprecated: getIcon (returning IconData) should be avoided if we want PNGs.
  // We keep a minimal fallback just in case.
  static IconData getFallbackIcon(String key) {
    return CupertinoIcons.square_grid_2x2;
  }
}

class CategoryIcon extends StatelessWidget {
  final String iconKey;
  final Color? color;
  final double size;
  final bool useOriginalColor;

  const CategoryIcon({
    super.key,
    required this.iconKey,
    this.color,
    this.size = 24,
    this.useOriginalColor = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Check if it's an emoji (legacy data)
    if (IconHelper.isEmoji(iconKey)) {
      return Text(
        iconKey,
        style: TextStyle(fontSize: size),
      );
    }

    // 2. Default to PNG asset
    // We assume the key matches the filename exactly
    // If color is provided AND useOriginalColor is false, we tint it.
    // Otherwise we show the vibrant original PNG.
    return Image.asset(
      'assets/icons/$iconKey.png',
      width: size,
      height: size,
      color: useOriginalColor ? null : color,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if PNG missing
        return Icon(
          CupertinoIcons.photo, // Placeholder
          size: size,
          color: color,
        );
      },
    );
  }
}
