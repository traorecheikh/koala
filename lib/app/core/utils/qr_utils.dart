import 'package:encrypt/encrypt.dart' as encrypt;

/// Must be exactly 32 characters
const String _aesKey = 'iJVqFUOddDKStWmVwP+SaOEa0uj7ndIK';

/// Must be exactly 16 characters
const String _aesIV = 'Ex-AvCPxXXZWb-q!';

/// Encrypts a contact payload to a base64 string for QR
String encryptContactQr(String payload) {
  assert(
    _aesKey.length == 32,
    'AES key must be exactly 32 characters (256 bits)',
  );
  assert(
    _aesIV.length == 16,
    'AES IV must be exactly 16 characters (128 bits)',
  );

  final key = encrypt.Key.fromUtf8(_aesKey);
  final iv = encrypt.IV.fromUtf8(_aesIV);
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  );
  final encrypted = encrypter.encrypt(payload, iv: iv);
  return encrypted.base64;
}

/// Decrypts a base64 QR string to a Contact, or null if invalid

String? decryptContactQr(String encryptedBase64) {
  assert(
    _aesKey.length == 32,
    'AES key must be exactly 32 characters (256 bits)',
  );
  assert(
    _aesIV.length == 16,
    'AES IV must be exactly 16 characters (128 bits)',
  );
  try {
    final key = encrypt.Key.fromUtf8(_aesKey);
    final iv = encrypt.IV.fromUtf8(_aesIV);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    return encrypter.decrypt64(encryptedBase64, iv: iv);
  } catch (_) {
    // Handle errors (invalid base64, decryption failure, JSON parse error)
    return null;
  }
}

