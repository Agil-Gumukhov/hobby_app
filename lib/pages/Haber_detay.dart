import 'package:firstapp/pages/Haberler.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HaberDetay extends StatelessWidget {
  final Result haber; //  Gelen haber nesnesi

  const HaberDetay({super.key, required this.haber, required Result haberler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(haber.name ?? 'Haber Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Haber Kaynağı (Source)
            Text(
              haber.source ?? 'Bilinmeyen Kaynak',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Haber Resmi
            if (haber.image != null && haber.image!.isNotEmpty)
              Image.network(
                haber.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported,
                      size: 120, color: Colors.grey);
                },
              ),

            const SizedBox(height: 16),

            // Haber Başlığı
            Text(
              haber.name ?? 'Başlık bulunamadı',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Haber Açıklaması
            Text(
              haber.description ?? 'Açıklama bulunamadı',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Haberin URL'si varsa
            if (haber.url != null && haber.url!.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final Uri uri = Uri.parse(haber.url!);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bağlantı açılamadı!')),
                    );
                  }
                },
                child: Text(
                  haber.url!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
