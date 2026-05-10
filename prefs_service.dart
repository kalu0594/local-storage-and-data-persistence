// lib/services/prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _kCurrency = 'currency';
  static const _kDarkMode = 'dark_mode';

  Future<void> saveCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrency, symbol);
  }

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrency) ?? 'ETB';
  }

  Future<void> saveDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, enabled);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDarkMode) ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
