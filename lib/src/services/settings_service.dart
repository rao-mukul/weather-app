import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';
import '../models/settings.dart';

class SettingsService {
  static const String _settingsKey = 'settings_v1';
  static const String _lastCityKey = 'last_city_v1';

  Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) {
      return Settings.initial();
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return Settings(
        temperatureUnit: TemperatureUnit.values.firstWhere(
          (unit) => unit.name == map['temperatureUnit'],
          orElse: () => TemperatureUnit.celsius,
        ),
        windSpeedUnit: WindSpeedUnit.values.firstWhere(
          (unit) => unit.name == map['windSpeedUnit'],
          orElse: () => WindSpeedUnit.kilometresPerHour,
        ),
      );
    } catch (_) {
      return Settings.initial();
    }
  }

  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode(<String, dynamic>{
      'temperatureUnit': settings.temperatureUnit.name,
      'windSpeedUnit': settings.windSpeedUnit.name,
    });
    await prefs.setString(_settingsKey, payload);
  }

  Future<CityLocation?> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastCityKey);
    if (raw == null) {
      return null;
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return CityLocation.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastCity(CityLocation city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, json.encode(city.toJson()));
  }

  Future<void> clearLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCityKey);
  }
}
