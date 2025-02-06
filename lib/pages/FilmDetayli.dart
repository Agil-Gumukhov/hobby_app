import 'package:flutter/material.dart';
import 'package:firstapp/pages/FilmlerT%C3%BCrler.dart'; // Contains your Results model

class Filmdetayli extends StatefulWidget {
  final Results movie;
  const Filmdetayli({super.key, required this.movie});

  @override
  State<Filmdetayli> createState() => _FilmdetayliState();
}

class _FilmdetayliState extends State<Filmdetayli> {
  @override
  Widget build(BuildContext context) {
    // Base URL for images (TMDB)
    const String baseUrl = "https://image.tmdb.org/t/p/w500";

    // Build full URLs for backdrop and poster images.
    final String backdropUrl = widget.movie.backdropPath != null
        ? "$baseUrl${widget.movie.backdropPath}"
        : "https://via.placeholder.com/500x281?text=No+Backdrop";
    final String posterUrl = widget.movie.posterPath != null
        ? "$baseUrl${widget.movie.posterPath}"
        : "https://via.placeholder.com/120x180?text=No+Image";

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.movie.title ?? "Film Detayı"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop image with gradient overlay and title.
            Stack(
              children: [
                Image.network(
                  backdropUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white, size: 50),
                      ),
                    );
                  },
                ),
                Container(
                  width: double.infinity,
                  height: 250,
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
                // Positioned title over the backdrop.
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    widget.movie.title ?? "No Title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row with poster and basic movie info.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster Image.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      posterUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 180,
                          color: Colors.grey,
                          child: const Icon(Icons.image_not_supported,
                              size: 50, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Movie details.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie.originalTitle ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.releaseDate ?? "N/A",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.voteAverage != null
                                  ? widget.movie.voteAverage!.toStringAsFixed(1)
                                  : "N/A",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Overview text.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.movie.overview ?? "No Overview Available",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 24),
            // Additional details can be added here.
          ],
        ),
      ),
    );
  }
}
