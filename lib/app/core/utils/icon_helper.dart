import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconHelper {
  static const Map<String, IconData> _iconMap = {
    // General
    'other': CupertinoIcons.square_grid_2x2,
    'salary': CupertinoIcons.money_dollar_circle_fill,
    'freelance': CupertinoIcons.briefcase_fill,
    'investment': CupertinoIcons.graph_circle_fill,
    'business': CupertinoIcons.building_2_fill,
    'gift': CupertinoIcons.gift_fill,
    'bonus': CupertinoIcons.star_circle_fill,
    'refund': CupertinoIcons.arrow_2_circlepath_circle_fill,
    'rental': CupertinoIcons.house_fill,
    
    // Expenses
    'food': CupertinoIcons.cart_fill, // Using cart for general food/groceries or similar
    'restaurant': CupertinoIcons.tickets_fill, // Abstract for dining/tickets
    'transport': CupertinoIcons.car_detailed,
    'shopping': CupertinoIcons.bag_fill,
    'entertainment': CupertinoIcons.game_controller_solid,
    'bills': CupertinoIcons.doc_text_fill,
    'health': CupertinoIcons.heart_fill,
    'education': CupertinoIcons.book_fill,
    'rent': CupertinoIcons.house_alt_fill,
    'groceries': CupertinoIcons.cart, 
    'utilities': CupertinoIcons.lightbulb_fill,
    'insurance': CupertinoIcons.shield_fill,
    'travel': CupertinoIcons.airplane,
    'clothing': CupertinoIcons.tag_fill,
    'fitness': CupertinoIcons.sportscourt_fill,
    'beauty': CupertinoIcons.scissors,
    'charity': CupertinoIcons.heart_circle_fill,
    'subscriptions': CupertinoIcons.arrow_2_squarepath,
    'maintenance': CupertinoIcons.wrench_fill,
    'tech': CupertinoIcons.device_laptop,
    'family': CupertinoIcons.person_2_fill,
    'pets': CupertinoIcons.paw_solid,
  };

  static IconData getIcon(String key) {
    return _iconMap[key] ?? CupertinoIcons.question_circle;
  }

  static String getKey(IconData icon) {
    return _iconMap.entries
        .firstWhere((element) => element.value == icon, orElse: () => const MapEntry('other', CupertinoIcons.square_grid_2x2))
        .key;
  }

  static List<String> get allKeys => _iconMap.keys.toList();
}
