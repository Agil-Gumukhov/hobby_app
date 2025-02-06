// lib/navbar.dart
import 'package:firstapp/pages/Haberler.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/LanguageProvider.dart';
import 'package:provider/provider.dart';



class Dildegistirme extends StatelessWidget {
  final Future<Haberler> haberler;

  const Dildegistirme({
    super.key,
    required this.haberler, // Ensure haberler is passed here
  });

  @override
  Widget build(BuildContext context) {
    // Handle haberler as a Future by using FutureBuilder
    return Scaffold(
      body: FutureBuilder<Haberler>(
        future: haberler, // Provide haberler Future to FutureBuilder
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            // Handle the data when the Future is completed
            Haberler haberlerData = snapshot.data!;
            return Column(
              children: [
                // Haberlerin sayısını gösteren bir metin
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Latest News: ${haberlerData.result?.length ?? 0} articles found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Dil değiştirme seçenekleri
                ListTile(
                  onTap: () {
                    print("Türkçe butonuna basıldı");
                    context.read<LocaleProvider>().setTurkish();
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.language),
                  title: Text('Türkçe'),
                ),
                ListTile(
                  onTap: () {
                    print("İngilizce butonuna basıldı");
                    context.read<LocaleProvider>().setEnglish();
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.language),
                  title: Text('English'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
