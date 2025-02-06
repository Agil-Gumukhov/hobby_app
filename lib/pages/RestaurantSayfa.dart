import 'package:flutter/material.dart';
import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/RestaurantsData.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RestaurantDetailPage.dart';

class Restaurantsayfa extends StatefulWidget {
  const Restaurantsayfa({super.key});

  @override
  State<Restaurantsayfa> createState() => _RestaurantsayfaState();
}

class _RestaurantsayfaState extends State<Restaurantsayfa> {
  RestaurantsData? futureRestaurant;
  bool isLoading = true;
  Set<String> _favoriteRestaurants = {};
  // TextEditingController for the search bar (lokasyon girişi)
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Varsayılan lokasyon olarak "Ankara"
    _searchController.text = "Ankara";
    _fetchRestaurants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değişikliğinde de veriyi yeniden yükleyelim.
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchRestaurants(currentLang);
  }

  // _fetchRestaurants fonksiyonu artık targetLang ve lokasyon alıyor.
  void _fetchRestaurants([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    String location = _searchController.text.trim();
    // Eğer lokasyon boşsa varsayılan olarak "Ankara" kullanın
    if (location.isEmpty) {
      location = "Ankara";
    }
    // fetchRestaurants fonksiyonunun imzası: fetchRestaurants(String targetLang, String location)
    fetchRestaurants(lang, location).then((data) {
      if (!mounted) return;
      setState(() {
        futureRestaurant = data;
        isLoading = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      // Hata yönetimi: Hata mesajı gösterilebilir.
    });
  }

  Future<void> _refreshRestaurant() async {
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: false).current.languageCode;
    _fetchRestaurants(currentLang);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteRestaurants = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteRestaurants.toList());
  }

  void _toggleFavorite(String restaurantId) {
    setState(() {
      if (_favoriteRestaurants.contains(restaurantId)) {
        _favoriteRestaurants.remove(restaurantId);
      } else {
        _favoriteRestaurants.add(restaurantId);
      }
    });
    _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Arama çubuğu (Search Bar) kısmı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Lokasyon girişi için TextField
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Lokasyon giriniz (ör. Ankara)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Arama butonu
                ElevatedButton(
                  onPressed: () {
                    String currentLang =
                        Provider.of<LocaleProvider>(context, listen: false)
                            .current
                            .languageCode;
                    _fetchRestaurants(currentLang);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          // ListView kısmı, RefreshIndicator ile sarmalanmış
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshRestaurant,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : futureRestaurant == null
                      ? const Center(child: Text('Veri yüklenemedi'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: futureRestaurant?.businesses?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            final Businesses restaurant =
                                futureRestaurant!.businesses![index];
                            final isFav =
                                _favoriteRestaurants.contains(restaurant.id);
                            // Resim URL kontrolü
                            String imgUrl = restaurant.imageUrl ??
                                'https://e7.pngegg.com/pngimages/592/414/png-clipart-computer-icons-news-news-icon-angle-text-thumbnail.png';

                            return GestureDetector(
                              onTap: () {
                                // Restoran detay sayfasına navigasyon
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailPage(
                                        restaurant: restaurant),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Restoran resmi
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imgUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey[700],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Metin kısmını Stack ile sarıp favori ikonunu sağ alt köşeye yerleştiriyoruz
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            // Restoran bilgilerini içeren Column
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  restaurant.name ??
                                                      'Restaurant',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      restaurant.rating != null
                                                          ? restaurant.rating!
                                                              .toStringAsFixed(
                                                                  1)
                                                          : 'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                               
                                               
                                              ],
                                            ),
                                            // Favori ikonunu sağ alt köşeye yerleştiriyoruz
                                            Positioned(
                                              top:25,
                                              right: 8,
                                              child: IconButton(
                                                icon: Icon(
                                                  isFav
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: const Color.fromARGB(
                                                      255, 255, 17, 0),
                                                  size: 28,
                                                ),
                                                onPressed: () =>
                                                    _toggleFavorite(
                                                        restaurant.id!),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
