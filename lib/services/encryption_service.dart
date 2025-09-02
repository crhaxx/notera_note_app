import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = "encryption_key";

  /// Vrátí nebo vytvoří náhodný klíč
  static Future<String> _getKey() async {
    String? key = await _storage.read(key: _keyName);
    if (key == null) {
      final newKey = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: _keyName, value: newKey);
      key = newKey;
    }
    return key;
  }

  /// "Zašifruje" text (zjednodušená ukázka – base64 + HMAC)
  static Future<String> encrypt(String plainText) async {
    final key = await _getKey();
    final hmacSha256 = Hmac(sha256, utf8.encode(key));
    final digest = hmacSha256.convert(utf8.encode(plainText));
    return base64.encode(utf8.encode(plainText)) + ":" + digest.toString();
  }

  /// Ověří a dešifruje text
  static Future<String> decrypt(String data) async {
    if (!data.contains(":")) return data;
    final parts = data.split(":");
    final base = parts[0];
    try {
      return utf8.decode(base64.decode(base));
    } catch (_) {
      return "[Decryption failed]";
    }
  }
}
