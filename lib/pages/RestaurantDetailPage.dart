import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'RestaurantsData.dart'; // Model sınıflarınızın bulunduğu dosya

class RestaurantDetailPage extends StatelessWidget {
  final Businesses restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  /// Adres bilgisini oluşturur.
  String buildAddress() {
    final location = restaurant.location;
    if (location == null) return 'Adres bilgisi bulunamadı';
    return [
      location.address1,
      location.address2,
      location.address3,
      location.city,
      location.state,
      location.zipCode
    ]
        .where((element) =>
            element != null && element.toString().trim().isNotEmpty)
        .join(', ');
  }

  /// Kategori etiketlerini oluşturur.
  Widget buildCategories(BuildContext context) {
    if (restaurant.categories == null || restaurant.categories!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      children: restaurant.categories!.map((category) {
        return Chip(
          label: Text(category.title ?? ''),
          backgroundColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        );
      }).toList(),
    );
  }

  /// Açılış saatlerini listeler.
  Widget buildBusinessHours(BuildContext context) {
    if (restaurant.businessHours == null || restaurant.businessHours!.isEmpty) {
      return const SizedBox.shrink();
    }
    // İlk businessHours kaydını alıyoruz.
    final businessHours = restaurant.businessHours!.first;
    if (businessHours.open == null || businessHours.open!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Açılış Saatleri:',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...businessHours.open!.map((open) {
          // Gün bilgisini dönüştürelim.
          String day;
          switch (open.day) {
            case 0:
              day = "Pazartesi";
              break;
            case 1:
              day = "Salı";
              break;
            case 2:
              day = "Çarşamba";
              break;
            case 3:
              day = "Perşembe";
              break;
            case 4:
              day = "Cuma";
              break;
            case 5:
              day = "Cumartesi";
              break;
            case 6:
              day = "Pazar";
              break;
            default:
              day = "Bilinmiyor";
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '$day: ${formatTime(open.start)} - ${formatTime(open.end)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }),
      ],
    );
  }

  /// Zaman bilgisini (örn: "0900") "09:00" formatına dönüştürür.
  String formatTime(String? time) {
    if (time == null || time.length != 4) return time ?? '';
    return '${time.substring(0, 2)}:${time.substring(2)}';
  }

  /// Telefon numarası için arama yapmayı sağlayan fonksiyon.
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  Future<void> _launchMap(String address) async {
    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    debugPrint('Map URI: $mapUri');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $mapUri');
      throw 'Could not launch $mapUri';
    }
  }

  void _openYelpPage(String? yelpUrl) async {
    if (yelpUrl != null && yelpUrl.isNotEmpty) {
      try {
        await launchUrl(
          Uri.parse(yelpUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Could not open Yelp page: $yelpUrl, Error: $e');
      }
    } else {
      debugPrint("No Yelp URL provided.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = buildAddress();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          /// Genişleyen görsel alan ve başlık.
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Hero(
                tag: restaurant.id!,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    restaurant.imageUrl ??
                        'https://e7.pngegg.com/pngimages/592/414/png-clipart-computer-icons-news-news-icon-angle-text-thumbnail.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          /// Detay içeriği.
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Restoranın puanı, ismi, fiyatı ve açık/kapalı durumu.
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        restaurant.rating != null
                            ? restaurant.rating!.toStringAsFixed(1)
                            : 'N/A',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          restaurant.name ?? 'Restoran Detayları',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (restaurant.price != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Fiyat: ${restaurant.price}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (restaurant.isClosed ?? false)
                              ? Colors.redAccent
                              : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (restaurant.isClosed ?? false) ? 'Kapalı' : 'Açık',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// Adres bölümü (Tıklanabilir).
                  Text(
                    'Adres:',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchMap(address),
                    child: Text(
                      address,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Telefon bölümü (Tıklanabilir).
                  if (restaurant.phone != null &&
                      restaurant.phone!.trim().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telefon:',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _launchPhone(restaurant.phone!),
                          child: Text(
                            restaurant.phone!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  /// Kategori bölümü.
                  if (restaurant.categories != null &&
                      restaurant.categories!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategoriler:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        buildCategories(context),
                        const SizedBox(height: 24),
                      ],
                    ),

                  /// Açılış saatleri bölümü.
                  buildBusinessHours(context),
                  const SizedBox(height: 24),

                  /// Menü veya diğer attribute bilgileri.
                  if (restaurant.attributes != null &&
                      restaurant.attributes!.menuUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menü:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _openYelpPage(restaurant.url!);
                          },
                          icon: const Icon(Icons.link),
                          label: const Text('Menüyü Görüntüle'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.blue, // Buton yazı rengi
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
