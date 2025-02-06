import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TheathresFavoritesStorage {
  static const String favoritesKey = 'favorite_theathres';

  // Save favorites using a Map<String, bool>
  static Future<void> saveFavorites(Map<String, bool> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save only the keys (titles) where the value is true.
    List<String> favoriteKeys = favorites.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Encode the list as JSON.
    String encodedData = jsonEncode(favoriteKeys);
    await prefs.setString(favoritesKey, encodedData);
  }

  // Load favorites and return them as a Map<String, bool>
  static Future<Map<String, bool>> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString(favoritesKey);
    Map<String, bool> favorites = {};

    if (encodedData != null) {
      List<dynamic> favoriteKeys = jsonDecode(encodedData);
      for (var key in favoriteKeys) {
        favorites[key.toString()] = true;
      }
    }

    return favorites;
  }
}
