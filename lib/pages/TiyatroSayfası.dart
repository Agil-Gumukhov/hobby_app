import 'package:firstapp/main.dart';
import 'package:firstapp/pages/FavoriteStorageTiyatro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/pages/Tiyatro.dart';
import 'package:url_launcher/url_launcher.dart'; // Contains your Theathres and TheathresItem models

// import 'package:url_launcher/url_launcher.dart'; // Uncomment if using url_launcher
enum TheathresFilter { all, topRated, favorites }

class Tiyatrosayfasi extends StatefulWidget {
  final TheathresFilter filter;
  final Map<String, bool> favorites; // Parent'tan paylaşılan favorites map
  final String searchQuery;
  const Tiyatrosayfasi(
      {super.key,
      required this.filter,
      required this.favorites,
      this.searchQuery = ''});

  @override
  State<Tiyatrosayfasi> createState() => _TiyatrosayfasiState();
}

class _TiyatrosayfasiState extends State<Tiyatrosayfasi> {
  Theathres? futureTheathres;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchTheathresData();
  }

  void _loadFavorites() async {
    Map<String, bool> loadedFavorites =
        await TheathresFavoritesStorage.loadFavorites();
    setState(() {
      widget.favorites.clear();
      widget.favorites.addAll(loadedFavorites);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchTheathresData(currentLang);
  }

  void _fetchTheathresData([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchTheathresData(lang).then((data) {
      setState(() {
        futureTheathres = data;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching tiyatro: $error');
    });
  }

  Future<void> _refreshData() async {
    final String currentLang =
        Provider.of<LocaleProvider>(context, listen: false)
            .current
            .languageCode;
    _fetchTheathresData(currentLang);
  }

  // Optional: Function to open URL (requires url_launcher package)
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // If your API does not provide images with the TMDB base URL,
    // use the URL provided in your model directly.
    // Otherwise, update the baseUrl variable accordingly.
    // For this example, we'll assume image URLs are provided directly.
    // const String baseUrl = "https://image.tmdb.org/t/p/w500";
    final List<TheathresItem> allTheathres =
        futureTheathres?.result ?? <TheathresItem>[];

    // Assuming you already have a list of movies called allMovies:
    final List<TheathresItem> searchFilteredTheathres = allTheathres.where((series) {
      final title = series.title?.toLowerCase() ?? '';
      final query = widget.searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    // Filtreye göre filmleri ayıklıyoruz.
    List<TheathresItem> filteredTheathres;
    switch (widget.filter) {
      case TheathresFilter.favorites:
        filteredTheathres = searchFilteredTheathres
            .where((theathres) => widget.favorites[theathres.title] == true)
            .toList();
        break;
      case TheathresFilter.all:
      default:
        filteredTheathres = searchFilteredTheathres;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : futureTheathres == null || futureTheathres!.result == null
                ? const Center(child: Text('Veri yüklenemedi'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTheathres.length,
                    itemBuilder: (context, index) {
                      final TheathresItem item = filteredTheathres[index];

                      // Use the provided image URL or a placeholder if missing.
                      final String imageUrl = item.image ??
                          "https://via.placeholder.com/500x281?text=No+Image";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Backdrop image with gradient overlay and title.
                              Stack(
                                children: [
                                  Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Text(
                                      item.title ?? "No Title",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(
                                        widget.favorites[item.title] == true
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: const Color.fromARGB(
                                            255, 255, 17, 0),
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        if (item.title != null) {
                                          setState(() {
                                            // Favori durumunu tersine çevir.
                                            widget.favorites[item.title!] =
                                                !(widget.favorites[
                                                        item.title!] ??
                                                    false);
                                            // Değişiklikleri kaydet.
                                            TheathresFavoritesStorage
                                                .saveFavorites(
                                                    widget.favorites);
                                            print(
                                                "Toggled favorite for series id ${item.title}: ${widget.favorites[item.title!]}");
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // Details section.
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Yöneten: ${item.sahne ?? 'N/A'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (item.url != null)
                                      ElevatedButton(
                                        onPressed: () {
                                          // Uncomment and implement the below function if using url_launcher
                                          _launchURL(item.url!);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text("Detayları Gör"),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
