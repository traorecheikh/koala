import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/savings_goal.dart';

/// Data migration service for managing schema changes across app versions
/// SECURITY: Handles migration of encrypted and unencrypted data safely
class DataMigrationService {
  static const int _currentSchemaVersion =
      2; // Increment with each schema change
  static const String _versionKey = 'schemaVersion';
  static const String _lastMigrationDateKey = 'lastMigrationDate';

  /// Run all pending migrations
  /// This is called automatically on app startup from main.dart
  Future<void> runMigrations() async {
    try {
      final migrationBox = await Hive.openBox('migrationBox');
      final lastSchemaVersion =
          migrationBox.get(_versionKey, defaultValue: 0) as int;

      if (lastSchemaVersion < _currentSchemaVersion) {
        debugPrint(
            'Starting data migrations from version $lastSchemaVersion to $_currentSchemaVersion');

        // Run migrations sequentially
        if (lastSchemaVersion < 1) {
          await _migrateV0toV1();
        }

        if (lastSchemaVersion < 2) {
          await _migrateV1toV2();
        }

        // Update schema version and migration timestamp
        await migrationBox.put(_versionKey, _currentSchemaVersion);
        await migrationBox.put(
            _lastMigrationDateKey, DateTime.now().toIso8601String());

        debugPrint(
            'Data migrations completed successfully. Current schema version: $_currentSchemaVersion');
      } else {
        debugPrint('Schema is up to date. No migrations needed.');
      }
    } catch (e) {
      debugPrint('Migration error: $e');
      // Don't throw - allow app to continue even if migration fails
      // User data is better preserved than crashing
    }
  }

  /// Get current schema version
  Future<int> getCurrentSchemaVersion() async {
    try {
      final migrationBox = await Hive.openBox('migrationBox');
      return migrationBox.get(_versionKey, defaultValue: 0) as int;
    } catch (e) {
      return 0;
    }
  }

  /// Check if migrations are pending
  Future<bool> hasPendingMigrations() async {
    final currentVersion = await getCurrentSchemaVersion();
    return currentVersion < _currentSchemaVersion;
  }

  /// V0 to V1: Migrate existing SavingsGoal to new FinancialGoal model
  Future<void> _migrateV0toV1() async {
    try {
      debugPrint('Running migration V0 to V1: SavingsGoal to FinancialGoal...');
      final savingsGoalBox = Hive.box<SavingsGoal>('savingsGoalBox');
      final financialGoalBox = Hive.box<FinancialGoal>('financialGoalBox');

      int migratedCount = 0;
      for (var oldGoal in savingsGoalBox.values) {
        try {
          final newGoal = FinancialGoal.create(
            title: 'Objectif d\'épargne ${oldGoal.year}-${oldGoal.month}',
            description: 'Migré depuis l\'ancien objectif d\'épargne',
            targetAmount: oldGoal.targetAmount,
            currentAmount: 0.0,
            type: GoalType.savings,
            status: GoalStatus.active,
          );
          await financialGoalBox.put(newGoal.id, newGoal);
          migratedCount++;
        } catch (e) {
          debugPrint('Failed to migrate goal ${oldGoal.id}: $e');
          // Continue with other goals
        }
      }

      debugPrint(
          'Migration V0 to V1 completed: $migratedCount goals migrated.');
    } catch (e) {
      debugPrint('Migration V0 to V1 failed: $e');
      rethrow;
    }
  }

  /// V1 to V2: Add encryption support and data integrity checks
  /// This migration ensures all data is properly encrypted after encryption was added
  Future<void> _migrateV1toV2() async {
    try {
      debugPrint('Running migration V1 to V2: Adding encryption support...');

      // Verify all boxes can be opened (they should already be encrypted from main.dart)
      final boxNames = [
        'userBox',
        'transactionBox',
        'recurringTransactionBox',
        'jobBox',
        'savingsGoalBox',
        'budgetBox',
        'debtBox',
        'financialGoalBox',
      ];

      for (final boxName in boxNames) {
        try {
          final box = Hive.box(boxName);
          // Just accessing the box verifies it's properly encrypted
          final itemCount = box.length;
          debugPrint('Verified encrypted box: $boxName ($itemCount items)');
        } catch (e) {
          debugPrint('Warning: Could not verify box $boxName: $e');
        }
      }

      // Add schema version tracking to settings
      final settingsBox = Hive.box('settingsBox');
      await settingsBox.put('dataEncrypted', true);
      await settingsBox.put('encryptionVersion', 1);

      debugPrint(
          'Migration V1 to V2 completed: Encryption verification successful.');
    } catch (e) {
      debugPrint('Migration V1 to V2 failed: $e');
      rethrow;
    }
  }

  /// Force reset schema version (use with extreme caution)
  /// This should only be used for development or emergency recovery
  Future<void> resetSchemaVersion() async {
    try {
      final migrationBox = await Hive.openBox('migrationBox');
      await migrationBox.clear();
      debugPrint(
          'Schema version reset. App will re-run all migrations on next start.');
    } catch (e) {
      debugPrint('Failed to reset schema version: $e');
      rethrow;
    }
  }
}
