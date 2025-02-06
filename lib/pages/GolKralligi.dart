import 'package:flutter/material.dart';
import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/GolKralligiData.dart';
import 'package:provider/provider.dart';

class Golkralligi extends StatefulWidget {
  final String leagueKey;
  const Golkralligi({super.key, required this.leagueKey});

  @override
  State<Golkralligi> createState() => _GolkralligiState();
}

class _GolkralligiState extends State<Golkralligi> {
  GolKralligiData? futureGolKralligiData;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _fetchGolKralligi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchGolKralligi(currentLang);
  }

  void _fetchGolKralligi([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchGolKralligiData(lang, widget.leagueKey).then((data) {
      if (!mounted) return;
      setState(() {
        futureGolKralligiData = data;
        isLoading = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      // Hata mesajını burada gösterebilirsiniz.
    });
  }

  Future<void> _refreshGolKralligi() async {
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: false).current.languageCode;
    _fetchGolKralligi(currentLang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshGolKralligi,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : futureGolKralligiData == null
                ? const Center(child: Text('Veri yüklenemedi'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: futureGolKralligiData?.result?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final oyuncu = futureGolKralligiData!.result![index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade300,
                              Colors.indigo.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // İsteğe bağlı: Detay sayfasına geçiş vb.
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Sıralama için yuvarlak daire
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Oyuncu bilgileri
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Oyuncu ismi
                                        Text(
                                          oyuncu.name ?? "Bilinmeyen Oyuncu",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Gol ve oynadığı maç sayısı
                                        Row(
                                          children: [
                                            // Gol sayısı
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.sports_soccer,
                                                  size: 20,
                                                  color: Colors.white70,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  oyuncu.goals ?? "0",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 24),
                                            // Oynadığı maç sayısı
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.play_arrow,
                                                  size: 20,
                                                  color: Colors.white70,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  oyuncu.play ?? "0",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
    );
  }
}
