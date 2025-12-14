import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:crypto/crypto.dart';

/// Secure encryption service for protecting sensitive data in Hive boxes
/// Uses AES-256 encryption with secure key derivation and storage
class EncryptionService {
  static const String _encryptionKeyStorageKey = 'hive_encryption_master_key';
  static const String _secureKeyDerivationSalt = 'koala_secure_salt_v1';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Get or create encryption key for Hive boxes
  /// This key is stored securely in the platform's secure storage
  Future<List<int>> getEncryptionKey() async {
    try {
      // Try to retrieve existing key
      final existingKey = await _secureStorage.read(key: _encryptionKeyStorageKey);

      if (existingKey != null) {
        // Decode existing key from base64
        return base64Decode(existingKey);
      }

      // Generate new secure key
      final newKey = await _generateSecureKey();

      // Store key securely
      await _secureStorage.write(
        key: _encryptionKeyStorageKey,
        value: base64Encode(newKey),
      );

      return newKey;
    } catch (e) {
      throw EncryptionException('Failed to get or create encryption key: $e');
    }
  }

  /// Generate a secure 256-bit encryption key
  Future<List<int>> _generateSecureKey() async {
    // Generate a random 32-byte key (256 bits) for AES-256
    final secureRandom = enc.SecureRandom(32);
    final randomBytes = secureRandom.bytes;

    // Additional entropy from time-based salt
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combinedData = randomBytes + utf8.encode(timestamp + _secureKeyDerivationSalt);

    // Hash to ensure proper key length and distribution
    final digest = sha256.convert(combinedData);

    return digest.bytes;
  }

  /// Derive an encryption key from a user PIN or password
  /// Use this for user-authenticated encryption
  Future<List<int>> deriveKeyFromPIN(String pin) async {
    if (pin.length < 4) {
      throw EncryptionException('PIN must be at least 4 characters');
    }

    // Use PBKDF2-like key derivation
    const iterations = 10000;
    List<int> current = utf8.encode(pin + _secureKeyDerivationSalt);

    for (var i = 0; i < iterations; i++) {
      current = sha256.convert(current).bytes;
    }

    return current;
  }

  /// Get Hive cipher for box encryption
  Future<HiveAesCipher> getHiveCipher() async {
    final key = await getEncryptionKey();
    return HiveAesCipher(key);
  }

  /// Verify if encryption key exists
  Future<bool> hasEncryptionKey() async {
    try {
      final key = await _secureStorage.read(key: _encryptionKeyStorageKey);
      return key != null;
    } catch (e) {
      return false;
    }
  }

  /// Delete encryption key (use with extreme caution - will make encrypted data unrecoverable)
  Future<void> deleteEncryptionKey() async {
    try {
      await _secureStorage.delete(key: _encryptionKeyStorageKey);
    } catch (e) {
      throw EncryptionException('Failed to delete encryption key: $e');
    }
  }

  /// Encrypt a string value
  String encryptString(String plainText, List<int> keyBytes) {
    final key = enc.Key(Uint8List.fromList(keyBytes));
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Combine IV and encrypted data
    return base64Encode(iv.bytes + encrypted.bytes);
  }

  /// Decrypt a string value
  String decryptString(String encryptedText, List<int> keyBytes) {
    final key = enc.Key(Uint8List.fromList(keyBytes));
    final combined = base64Decode(encryptedText);

    // Extract IV and encrypted data
    final iv = enc.IV(Uint8List.fromList(combined.sublist(0, 16).cast<int>()));
    final encryptedData = combined.sublist(16).cast<int>();

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    return encrypter.decrypt(enc.Encrypted(Uint8List.fromList(encryptedData)), iv: iv);
  }

  /// Securely wipe sensitive data from memory
  void secureWipe(List<int> data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}

/// Custom exception for encryption-related errors
class EncryptionException implements Exception {
  final String message;

  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}

