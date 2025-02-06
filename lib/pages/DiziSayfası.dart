import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/DiziT%C3%BCrleri.dart' as dizi;
import 'package:firstapp/pages/Dizidetayl%C4%B1.dart';
import 'package:firstapp/pages/FavoriteStorageSeries.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DiziTürleri.dart';

enum SeriesFilter { all, topRated, favorites }

class Dizisayfasi extends StatefulWidget {
  final SeriesFilter filter;
  final Map<int, bool> favorites; // Parent'tan paylaşılan favorites map
  final String searchQuery;
  const Dizisayfasi(
      {super.key,
      required this.filter,
      required this.favorites,
      this.searchQuery = ''});

  @override
  State<Dizisayfasi> createState() => _DizisayfasiState();
}

class _DizisayfasiState extends State<Dizisayfasi> {
  dizi.SeriesTypes? futureSeriesTypes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchSeriesTypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchSeriesTypes(currentLang);
  }

  void _loadFavorites() async {
    Map<int, bool> loadedFavorites =
        await SeriesFavoritesStorage.loadFavorites();
    setState(() {
      widget.favorites.clear();
      widget.favorites.addAll(loadedFavorites);
    });
  }

  void _fetchSeriesTypes([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchSeriesTypesData(lang).then((data) {
      setState(() {
        // Cast data to the series model using the alias "dizi"
        futureSeriesTypes = data as dizi.SeriesTypes?;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching series type: $error');
    });
  }

  Future<void> _refreshFilmList() async {
    final String currentLang =
        Provider.of<LocaleProvider>(context, listen: false)
            .current
            .languageCode;
    _fetchSeriesTypes(currentLang);
  }

  @override
  Widget build(BuildContext context) {
    // Base URL for images (from TMDB)
    const String baseUrl = "https://image.tmdb.org/t/p/w500";
    final List<dizi.Results> allSeries =
        futureSeriesTypes?.results ?? <dizi.Results>[];

    // Assuming you already have a list of movies called allMovies:
    final List<Results> searchFilteredSeries = allSeries.where((series) {
      final title = series.name?.toLowerCase() ?? '';
      final query = widget.searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    // Filtreye göre filmleri ayıklıyoruz.
    List<Results> filteredSeries;
    switch (widget.filter) {
      case SeriesFilter.topRated:
        filteredSeries = searchFilteredSeries
            .where((series) =>
                series.voteAverage != null && series.voteAverage! >= 7.5)
            .toList();
        break;
      case SeriesFilter.favorites:
        filteredSeries = searchFilteredSeries
            .where((series) => widget.favorites[series.id] == true)
            .toList();
        break;
      case SeriesFilter.all:
      default:
        filteredSeries = searchFilteredSeries;
        break;
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshFilmList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : futureSeriesTypes == null
                ? const Center(child: Text('Veri yüklenemedi'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredSeries.length,
                    itemBuilder: (BuildContext context, int index) {
                      // Use the series model from the alias "dizi"
                      // final dizi.Results series =
                      //     futureSeriesTypes!.results![index];
                      final dizi.Results series = filteredSeries[index];
                      // Build full URLs for poster and backdrop images.
                      final String posterUrl = series.posterPath != null
                          ? "$baseUrl${series.posterPath}"
                          : 'https://via.placeholder.com/120x180?text=No+Image';
                      final String backdropUrl = series.backdropPath != null
                          ? "$baseUrl${series.backdropPath}"
                          : 'https://via.placeholder.com/500x281?text=No+Backdrop';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Dizidetayli(
                                  series: series,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Backdrop image with a gradient overlay for improved text readability
                                Stack(
                                  children: [
                                    Image.network(
                                      backdropUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                            Colors.black.withOpacity(0.6),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    // Series title positioned at the bottom of the backdrop.
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Text(
                                        series.name ?? '',
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
                                          widget.favorites[series.id] == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: const Color.fromARGB(
                                              255, 255, 17, 0),
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          if (series.id != null) {
                                            setState(() {
                                              // Favori durumunu tersine çevir.
                                              widget.favorites[series.id!] =
                                                  !(widget.favorites[
                                                          series.id!] ??
                                                      false);
                                              // Değişiklikleri kaydet.
                                              SeriesFavoritesStorage
                                                  .saveFavorites(
                                                      widget.favorites);
                                              print(
                                                  "Toggled favorite for series id ${series.id}: ${widget.favorites[series.id!]}");
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Poster Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          posterUrl,
                                          width: 100,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 100,
                                              height: 150,
                                              color: Colors.grey,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Series Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              series.originalName ?? '',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Release Date: ${series.firstAirDate ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  series.voteAverage != null
                                                      ? series.voteAverage!
                                                          .toStringAsFixed(1)
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              series.overview ?? '',
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
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
    );
  }
}
