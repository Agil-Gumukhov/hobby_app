import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SeriesFavoritesStorage {
  static const String favoritesKey = 'favorite_series';

  static Future<void> saveFavorites(Map<int, bool> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> favoriteIds = favorites.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    String encodedData = jsonEncode(favoriteIds);
    await prefs.setString(favoritesKey, encodedData);
  }

  static Future<Map<int, bool>> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString(favoritesKey);
    Map<int, bool> favorites = {};
    if (encodedData != null) {
      List<dynamic> favoriteIds = jsonDecode(encodedData);
      for (var id in favoriteIds) {
        favorites[id as int] = true;
      }
    }
    return favorites;
  }
}
