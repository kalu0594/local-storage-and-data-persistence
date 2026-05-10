// lib/services/pin_vault.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinVault {
  static const _kPin = 'app_pin';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> savePin(String pin) => _storage.write(key: _kPin, value: pin);

  Future<String?> readPin() => _storage.read(key: _kPin);

  Future<bool> hasPin() async => (await readPin()) != null;

  Future<bool> verifyPin(String input) async {
    final stored = await readPin();
    return stored == input;
  }

  Future<void> deletePin() => _storage.delete(key: _kPin);
}
