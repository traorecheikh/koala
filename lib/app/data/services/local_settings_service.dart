import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

/// Settings model for storing app configuration
@HiveType(typeId: 10)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool biometricEnabled;
  
  @HiveField(1)
  final bool cloudSyncEnabled;
  
  @HiveField(2)
  final bool notificationsEnabled;
  
  @HiveField(3)
  final bool paymentRemindersEnabled;
  
  @HiveField(4)
  final String theme;
  
  @HiveField(5)
  final String language;
  
  @HiveField(6)
  final bool firstRun;
  
  @HiveField(7)
  final DateTime lastSyncAt;
  
  @HiveField(8)
  final Map<String, dynamic> customSettings;

  AppSettings({
    this.biometricEnabled = false,
    this.cloudSyncEnabled = true, // Enabled by default per PRD
    this.notificationsEnabled = true,
    this.paymentRemindersEnabled = true,
    this.theme = 'system',
    this.language = 'fr',
    this.firstRun = true,
    DateTime? lastSyncAt,
    this.customSettings = const {},
  }) : lastSyncAt = lastSyncAt ?? DateTime.now();

  AppSettings copyWith({
    bool? biometricEnabled,
    bool? cloudSyncEnabled,
    bool? notificationsEnabled,
    bool? paymentRemindersEnabled,
    String? theme,
    String? language,
    bool? firstRun,
    DateTime? lastSyncAt,
    Map<String, dynamic>? customSettings,
  }) {
    return AppSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      paymentRemindersEnabled: paymentRemindersEnabled ?? this.paymentRemindersEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      firstRun: firstRun ?? this.firstRun,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// Local settings service for offline-first app configuration
class LocalSettingsService extends GetxService {
  static LocalSettingsService get to => Get.find();
  
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';
  static const String _pinKey = 'user_pin';
  
  late Box<AppSettings> _settingsBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Observable settings
  final Rx<AppSettings> settings = AppSettings().obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initSettings();
  }

  /// Initialize settings storage
  Future<void> _initSettings() async {
    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      
      // Open settings box
      _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
      
      // Load current settings or create default
      final savedSettings = _settingsBox.get(_settingsKey);
      if (savedSettings != null) {
        settings.value = savedSettings;
      } else {
        await _saveDefaultSettings();
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les paramètres: $e');
      settings.value = AppSettings(); // Use default settings
    }
  }

  /// Save default settings on first run
  Future<void> _saveDefaultSettings() async {
    final defaultSettings = AppSettings();
    await _settingsBox.put(_settingsKey, defaultSettings);
    settings.value = defaultSettings;
  }

  /// Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      await _settingsBox.put(_settingsKey, newSettings);
      settings.value = newSettings;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  // ==== INDIVIDUAL SETTING METHODS ====

  /// Toggle biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final newSettings = settings.value.copyWith(biometricEnabled: enabled);
    await updateSettings(newSettings);
  }

  /// Toggle cloud synchronization
  Future<void> setCloudSyncEnabled(bool enabled) async {
    final newSettings = settings.value.copyWith(cloudSyncEnabled: enabled);
    await updateSettings(newSettings);
  }

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final newSettings = settings.value.copyWith(notificationsEnabled: enabled);
    await updateSettings(newSettings);
  }

  /// Toggle payment reminders
  Future<void> setPaymentRemindersEnabled(bool enabled) async {
    final newSettings = settings.value.copyWith(paymentRemindersEnabled: enabled);
    await updateSettings(newSettings);
  }

  /// Set app theme
  Future<void> setTheme(String theme) async {
    final newSettings = settings.value.copyWith(theme: theme);
    await updateSettings(newSettings);
  }

  /// Set app language
  Future<void> setLanguage(String language) async {
    final newSettings = settings.value.copyWith(language: language);
    await updateSettings(newSettings);
  }

  /// Mark app as no longer first run
  Future<void> completeFirstRun() async {
    final newSettings = settings.value.copyWith(firstRun: false);
    await updateSettings(newSettings);
  }

  /// Update last sync time
  Future<void> updateLastSyncTime() async {
    final newSettings = settings.value.copyWith(lastSyncAt: DateTime.now());
    await updateSettings(newSettings);
  }

  /// Set custom setting
  Future<void> setCustomSetting(String key, dynamic value) async {
    final customSettings = Map<String, dynamic>.from(settings.value.customSettings);
    customSettings[key] = value;
    final newSettings = settings.value.copyWith(customSettings: customSettings);
    await updateSettings(newSettings);
  }

  /// Get custom setting
  T? getCustomSetting<T>(String key) {
    return settings.value.customSettings[key] as T?;
  }

  // ==== PIN MANAGEMENT ====

  /// Save PIN securely
  Future<void> savePIN(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du PIN: $e');
    }
  }

  /// Verify PIN
  Future<bool> verifyPIN(String pin) async {
    try {
      final storedPIN = await _secureStorage.read(key: _pinKey);
      return storedPIN == pin;
    } catch (e) {
      return false;
    }
  }

  /// Check if PIN exists
  Future<bool> hasPIN() async {
    try {
      final storedPIN = await _secureStorage.read(key: _pinKey);
      return storedPIN != null && storedPIN.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Delete PIN (for logout)
  Future<void> deletePIN() async {
    try {
      await _secureStorage.delete(key: _pinKey);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du PIN: $e');
    }
  }

  // ==== GETTERS ====

  bool get isBiometricEnabled => settings.value.biometricEnabled;
  bool get isCloudSyncEnabled => settings.value.cloudSyncEnabled;
  bool get isNotificationsEnabled => settings.value.notificationsEnabled;
  bool get isPaymentRemindersEnabled => settings.value.paymentRemindersEnabled;
  String get currentTheme => settings.value.theme;
  String get currentLanguage => settings.value.language;
  bool get isFirstRun => settings.value.firstRun;
  DateTime get lastSyncAt => settings.value.lastSyncAt;

  // ==== CLEANUP ====

  /// Clear all settings (for app reset)
  Future<void> clearAllSettings() async {
    try {
      await _settingsBox.clear();
      await _secureStorage.deleteAll();
      settings.value = AppSettings();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des paramètres: $e');
    }
  }

  /// Export settings for backup
  Map<String, dynamic> exportSettings() {
    return {
      'biometric_enabled': settings.value.biometricEnabled,
      'cloud_sync_enabled': settings.value.cloudSyncEnabled,
      'notifications_enabled': settings.value.notificationsEnabled,
      'payment_reminders_enabled': settings.value.paymentRemindersEnabled,
      'theme': settings.value.theme,
      'language': settings.value.language,
      'last_sync_at': settings.value.lastSyncAt.toIso8601String(),
      'custom_settings': settings.value.customSettings,
    };
  }
}

/// Hive adapter for AppSettings (will be generated)
class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 10;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      biometricEnabled: fields[0] as bool,
      cloudSyncEnabled: fields[1] as bool,
      notificationsEnabled: fields[2] as bool,
      paymentRemindersEnabled: fields[3] as bool,
      theme: fields[4] as String,
      language: fields[5] as String,
      firstRun: fields[6] as bool,
      lastSyncAt: fields[7] as DateTime,
      customSettings: Map<String, dynamic>.from(fields[8] as Map),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.biometricEnabled)
      ..writeByte(1)
      ..write(obj.cloudSyncEnabled)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.paymentRemindersEnabled)
      ..writeByte(4)
      ..write(obj.theme)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.firstRun)
      ..writeByte(7)
      ..write(obj.lastSyncAt)
      ..writeByte(8)
      ..write(obj.customSettings);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}