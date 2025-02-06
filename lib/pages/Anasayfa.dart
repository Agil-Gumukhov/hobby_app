import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/Haber_detay.dart';
import 'package:firstapp/pages/Haberler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Anasayfa extends StatefulWidget {
  final Future<Haberler> haberler;

  const Anasayfa({super.key, required this.haberler});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  Haberler? futureHaberler;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _fetchNews();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchNews(currentLang);
  }

  void _fetchNews([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchHaberler(lang).then((data) {
      if (!mounted) return; // Widget hala ağaçta mı kontrolü
      setState(() {
        futureHaberler = data;
        isLoading = false;
      });
    }).catchError((error) {
      if (!mounted) return; // Widget dispose edilmişse çık
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Haberler yüklenirken hata oluştu: $error')),
      );
    });
  }

  Future<void> _refreshNews() async {
    String currentLang = Provider.of<LocaleProvider>(context, listen: false)
        .current
        .languageCode;
    _fetchNews(currentLang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RefreshIndicator(
          onRefresh: _refreshNews,
          child: isLoading
              ? const CircularProgressIndicator()
              : futureHaberler == null
                  ? const Text('Veri yüklenemedi')
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: futureHaberler?.result?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        String? imgUrl = futureHaberler?.result?[index].image;
                        imgUrl ??=
                            'https://e7.pngegg.com/pngimages/592/414/png-clipart-computer-icons-news-news-icon-angle-text-thumbnail.png';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: GestureDetector(
                            onTap: () {
                              // 👇 Haberi detay sayfasına aktarıyoruz.
                              var selectedHaber =
                                  futureHaberler!.result![index];

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HaberDetay(
                                    haberler: selectedHaber,
                                    haber: selectedHaber, // Veriyi aktarıyoruz
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kaynak (Source)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '${futureHaberler!.result?[index].source}',
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // Resim & Başlık
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          imgUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                Icons.image_not_supported,
                                                size: 120,
                                                color: Colors.grey);
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        // Başlık
                                        Expanded(
                                          child: Text(
                                            '${futureHaberler?.result?[index].name}',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
