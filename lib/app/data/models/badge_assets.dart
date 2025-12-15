/// Badge icon definitions mapping badgeIds to asset paths
class BadgeAssets {
  static const String basePath = 'assets/achievements/';

  /// Map of badgeId to asset filename
  static const Map<String, String> _badges = {
    // Star tier badges
    'badge_bronze': 'bronze.png',
    'badge_silver': 'silver.png',
    'badge_gold': 'gold.png',
    'badge_platinum': 'platinum.png',

    // Streak badges
    'badge_week_warrior': 'fire_7day.png',
    'badge_habit': 'fire_30day.png',
    'badge_dedicated': 'fire_30day.png',
    'badge_committed': 'fire_100day.png',
    'badge_legend': 'fire_100day.png',

    // Achievement badges
    'badge_100k': 'money_bag_small.png',
    'badge_millionaire': 'money_bag_large.png',
    'badge_emergency': 'money_bag_medium.png',
    'badge_goal_getter': 'bullseye.png',

    // Special badges
    'badge_spartan': 'trophy_gold.png',
    'badge_perfect_month': 'diamond.png',
    'badge_debt_crusher': 'trophy_bronze.png',
    'badge_debt_free': 'crown.png',
    'badge_100_tx': 'trophy_silver.png',
    'badge_500_tx': 'trophy_gold.png',
    'badge_annual': 'crown.png',

    // Category-specific
    'badge_chef': 'chef.png',
    'badge_walker': 'walking.png',
    'badge_freeze': 'snowflake.png',
  };

  /// Get asset path for a badge ID
  static String? getAssetPath(String badgeId) {
    final filename = _badges[badgeId];
    if (filename == null) return null;
    return '$basePath$filename';
  }

  /// Get all available badge IDs
  static List<String> get allBadgeIds => _badges.keys.toList();

  /// Check if a badge has an asset
  static bool hasAsset(String badgeId) => _badges.containsKey(badgeId);
}
