import 'package:firstapp/main.dart';
import 'package:firstapp/pages/FilmDetayli.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/pages/FilmlerTürler.dart'; // Contains FilmlerTypes & Results classes
import 'package:firstapp/pages/FavoritesStorageMovie.dart';

enum MovieFilter { all, topRated, favorites }

class Filmsayfasi extends StatefulWidget {
  final MovieFilter filter;
  final Map<int, bool> favorites; // Parent'tan paylaşılan favorites map
  final String searchQuery;
  const Filmsayfasi(
      {super.key,
      required this.filter,
      required this.favorites,
     this.searchQuery = ''});

  @override
  State<Filmsayfasi> createState() => _FilmsayfasiState();
}

class _FilmsayfasiState extends State<Filmsayfasi> {
  FilmlerTypes? futurefilmTypes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Uygulama başladığında kaydedilmiş favorileri yükle.
    _loadFavorites();
    _fetchFilmTypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchFilmTypes(currentLang);
  }

  void _loadFavorites() async {
    Map<int, bool> loadedFavorites = await FavoritesStorage.loadFavorites();
    setState(() {
      widget.favorites.clear();
      widget.favorites.addAll(loadedFavorites);
    });
  }

  void _fetchFilmTypes([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchFilmTypesData(lang).then((data) {
      setState(() {
        futurefilmTypes = data as FilmlerTypes?;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching film type: $error');
    });
  }

  Future<void> _refreshFilmList() async {
    final String currentLang =
        Provider.of<LocaleProvider>(context, listen: false)
            .current
            .languageCode;
    _fetchFilmTypes(currentLang);
  }

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "https://image.tmdb.org/t/p/w500";
    final List<Results> allMovies = futurefilmTypes?.results ?? <Results>[];


    // Assuming you already have a list of movies called allMovies:
    final List<Results> searchFilteredMovies = allMovies.where((movie) {
      final title = movie.title?.toLowerCase() ?? '';
      final query = widget.searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    // Filtreye göre filmleri ayıklıyoruz.
    List<Results> filteredMovies;
    switch (widget.filter) {
      case MovieFilter.topRated:
        filteredMovies = searchFilteredMovies
            .where((movie) =>
                movie.voteAverage != null && movie.voteAverage! >= 7.5)
            .toList();
        break;
      case MovieFilter.favorites:
        filteredMovies = searchFilteredMovies
            .where((movie) => widget.favorites[movie.id] == true)
            .toList();
        break;
      case MovieFilter.all:
      default:
        filteredMovies = searchFilteredMovies;
        break;
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshFilmList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredMovies.isEmpty
                ? const Center(child: Text('No movies found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredMovies.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Results movie = filteredMovies[index];
                      final String posterUrl = movie.posterPath != null
                          ? "$baseUrl${movie.posterPath}"
                          : 'https://via.placeholder.com/120x180?text=No+Image';
                      final String backdropUrl = movie.backdropPath != null
                          ? "$baseUrl${movie.backdropPath}"
                          : 'https://via.placeholder.com/500x281?text=No+Backdrop';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Filmdetayli(movie: movie),
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
                                // Backdrop resmi, gradient ve favori ikonu.
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
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Text(
                                        movie.title ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Favori ikonu
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: Icon(
                                          widget.favorites[movie.id] == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: const Color.fromARGB(
                                              255, 255, 17, 0),
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          if (movie.id != null) {
                                            setState(() {
                                              // Favori durumunu tersine çevir.
                                              widget.favorites[movie.id!] =
                                                  !(widget.favorites[
                                                          movie.id!] ??
                                                      false);
                                              // Değişiklikleri kaydet.
                                              FavoritesStorage.saveFavorites(
                                                  widget.favorites);
                                              print(
                                                  "Toggled favorite for movie id ${movie.id}: ${widget.favorites[movie.id!]}");
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                // Film detayları
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.originalTitle ?? '',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Release Date: ${movie.releaseDate ?? 'N/A'}',
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
                                                  movie.voteAverage != null
                                                      ? movie.voteAverage!
                                                          .toStringAsFixed(1)
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              movie.overview ?? '',
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
