import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites_v1';

  Future<List<CityLocation>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? <String>[];
    return raw.map((encoded) {
      final map = json.decode(encoded) as Map<String, dynamic>;
      return CityLocation.fromJson(map);
    }).toList();
  }

  Future<void> saveFavorites(List<CityLocation> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final payload =
        favorites.map((city) => json.encode(city.toJson())).toList();
    await prefs.setStringList(_favoritesKey, payload);
  }
}
