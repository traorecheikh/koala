/// Predefined subscription services with logos and default pricing
class SubscriptionService {
  final String id;
  final String name;
  final String? logoAsset; // null = use fallback icon
  final String category; // entertainment, ai, cloud, music, fitness, etc.
  final double defaultMonthlyPrice; // in FCFA
  final String fallbackIcon; // CupertinoIcons key

  const SubscriptionService({
    required this.id,
    required this.name,
    this.logoAsset,
    required this.category,
    required this.defaultMonthlyPrice,
    required this.fallbackIcon,
  });
}

class SubscriptionAssets {
  static const String _basePath = 'assets/subscriptions/';

  /// Get logo asset path for a subscription service ID
  static String? getLogoPath(String serviceId) {
    final service = predefinedServices.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => predefinedServices.first,
    );
    return service.logoAsset != null ? '$_basePath${service.logoAsset}' : null;
  }

  /// All predefined subscription services
  static const List<SubscriptionService> predefinedServices = [
    // Entertainment
    SubscriptionService(
      id: 'netflix',
      name: 'Netflix',
      logoAsset: 'netflix.png',
      category: 'entertainment',
      defaultMonthlyPrice: 5000,
      fallbackIcon: 'play_rectangle_fill',
    ),
    SubscriptionService(
      id: 'disney',
      name: 'Disney+',
      logoAsset: 'disney.png',
      category: 'entertainment',
      defaultMonthlyPrice: 4000,
      fallbackIcon: 'star_fill',
    ),
    SubscriptionService(
      id: 'youtube',
      name: 'YouTube Premium',
      logoAsset: 'youtube.png',
      category: 'entertainment',
      defaultMonthlyPrice: 4500,
      fallbackIcon: 'play_fill',
    ),

    // Music
    SubscriptionService(
      id: 'spotify',
      name: 'Spotify',
      logoAsset: 'spotify.png',
      category: 'music',
      defaultMonthlyPrice: 3000,
      fallbackIcon: 'music_note',
    ),
    SubscriptionService(
      id: 'apple_music',
      name: 'Apple Music',
      logoAsset: null,
      category: 'music',
      defaultMonthlyPrice: 3000,
      fallbackIcon: 'music_note_2',
    ),

    // AI Tools
    SubscriptionService(
      id: 'chatgpt',
      name: 'ChatGPT Plus',
      logoAsset: 'chatgpt.png',
      category: 'ai',
      defaultMonthlyPrice: 12000,
      fallbackIcon: 'bubble_left_fill',
    ),
    SubscriptionService(
      id: 'claude',
      name: 'Claude Pro',
      logoAsset: 'claude.png',
      category: 'ai',
      defaultMonthlyPrice: 12000,
      fallbackIcon: 'text_bubble_fill',
    ),
    SubscriptionService(
      id: 'gemini',
      name: 'Gemini Advanced',
      logoAsset: 'gemini.png',
      category: 'ai',
      defaultMonthlyPrice: 12000,
      fallbackIcon: 'sparkles',
    ),

    // Cloud Storage
    SubscriptionService(
      id: 'icloud',
      name: 'iCloud+',
      logoAsset: 'icloud.png',
      category: 'cloud',
      defaultMonthlyPrice: 1500,
      fallbackIcon: 'cloud_fill',
    ),
    SubscriptionService(
      id: 'google_one',
      name: 'Google One',
      logoAsset: null,
      category: 'cloud',
      defaultMonthlyPrice: 2000,
      fallbackIcon: 'cloud',
    ),

    // Other
    SubscriptionService(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      logoAsset: null,
      category: 'shopping',
      defaultMonthlyPrice: 3500,
      fallbackIcon: 'bag_fill',
    ),
    SubscriptionService(
      id: 'canva',
      name: 'Canva Pro',
      logoAsset: null,
      category: 'design',
      defaultMonthlyPrice: 6000,
      fallbackIcon: 'paintbrush_fill',
    ),
    SubscriptionService(
      id: 'vpn',
      name: 'VPN',
      logoAsset: null,
      category: 'security',
      defaultMonthlyPrice: 5000,
      fallbackIcon: 'shield_fill',
    ),
    SubscriptionService(
      id: 'gym',
      name: 'Salle de sport',
      logoAsset: null,
      category: 'fitness',
      defaultMonthlyPrice: 20000,
      fallbackIcon: 'sportscourt_fill',
    ),
    SubscriptionService(
      id: 'custom',
      name: 'Autre',
      logoAsset: null,
      category: 'other',
      defaultMonthlyPrice: 0,
      fallbackIcon: 'ellipsis_circle_fill',
    ),
  ];

  /// Get services by category
  static List<SubscriptionService> getByCategory(String category) {
    return predefinedServices.where((s) => s.category == category).toList();
  }

  /// Get service by ID
  static SubscriptionService? getById(String id) {
    try {
      return predefinedServices.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// All category names
  static const List<String> categories = [
    'entertainment',
    'music',
    'ai',
    'cloud',
    'shopping',
    'design',
    'security',
    'fitness',
    'other',
  ];

  /// Localized category names
  static String getCategoryName(String category) {
    switch (category) {
      case 'entertainment':
        return 'Divertissement';
      case 'music':
        return 'Musique';
      case 'ai':
        return 'Intelligence Artificielle';
      case 'cloud':
        return 'Cloud';
      case 'shopping':
        return 'Shopping';
      case 'design':
        return 'Design';
      case 'security':
        return 'Securite';
      case 'fitness':
        return 'Sport';
      case 'other':
        return 'Autre';
      default:
        return category;
    }
  }
}
