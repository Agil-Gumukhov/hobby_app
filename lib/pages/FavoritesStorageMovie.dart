import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String favoritesKey = 'favorite_movies';

  // Favori ID'leri içeren Map'i SharedPreferences'e kaydeder.
  static Future<void> saveFavorites(Map<int, bool> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Sadece true olanları kaydediyoruz.
    List<int> favoriteIds = favorites.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // List<int>'i JSON formatında string olarak kaydediyoruz.
    String encodedData = jsonEncode(favoriteIds);
    await prefs.setString(favoritesKey, encodedData);
  }

  // Kaydedilmiş favori ID'lerini yükler ve Map<int, bool> formatına çevirir.
  static Future<Map<int, bool>> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString(favoritesKey);
    Map<int, bool> favorites = {};

    if (encodedData != null) {
      List<dynamic> favoriteIds = jsonDecode(encodedData);
      // Tüm id'ler için true değerini atıyoruz.
      for (var id in favoriteIds) {
        favorites[id as int] = true;
      }
    }

    return favorites;
  }
}
