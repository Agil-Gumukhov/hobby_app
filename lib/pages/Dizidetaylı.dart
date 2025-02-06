import 'package:flutter/material.dart';

import 'DiziTürleri.dart';

class Dizidetayli extends StatefulWidget {
  final Results series;
  const Dizidetayli({super.key, required this.series});

  @override
  State<Dizidetayli> createState() => _DizidetayliState();
}

class _DizidetayliState extends State<Dizidetayli> {
  @override
  Widget build(BuildContext context) {
    // Base URL for images (TMDB)
    const String baseUrl = "https://image.tmdb.org/t/p/w500";

    // Build full URLs for backdrop and poster images.
    final String backdropUrl = widget.series.backdropPath != null
        ? "$baseUrl${widget.series.backdropPath}"
        : "https://via.placeholder.com/500x281?text=No+Backdrop";
    final String posterUrl = widget.series.posterPath != null
        ? "$baseUrl${widget.series.posterPath}"
        : "https://via.placeholder.com/120x180?text=No+Image";

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.series.name ?? "Dizi Detayı"),
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
                    widget.series.name ?? "No Title",
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
                          widget.series.originalName ?? '',
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
                              widget.series.firstAirDate ?? "N/A",
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
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.series.voteAverage != null
                                  ? widget.series.voteAverage!
                                      .toStringAsFixed(1)
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
                (widget.series.overview?.trim().isNotEmpty ?? false)
                    ? widget.series.overview!
                    : "No description Available",
                style: const TextStyle(fontSize: 16, color: Colors.black),
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
