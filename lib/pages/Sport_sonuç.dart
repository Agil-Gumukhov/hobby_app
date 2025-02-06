import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/Sport_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SportSonuc extends StatefulWidget {
  final String leagueKey;
  const SportSonuc({super.key, required this.leagueKey});

  @override
  State<SportSonuc> createState() => _SportSonucState();
}

class _SportSonucState extends State<SportSonuc> {
  LeagueResults? futureLeagueResult;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    print("SportSonuc: leagueKey = ${widget.leagueKey}");
    _fetchLeagueResult();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchLeagueResult(currentLang);
  }

  void _fetchLeagueResult([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchSportResult(lang, widget.leagueKey).then((data) {
      setState(() {
        futureLeagueResult = data as LeagueResults?;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _refreshLeagueResult() async {
    String currentLang = Provider.of<LocaleProvider>(context, listen: false)
        .current
        .languageCode;
    _fetchLeagueResult(currentLang);
  }

  String getTeamLogo(String teamName) {
    final lowerCaseName = teamName.toLowerCase();

    if (lowerCaseName.contains('fenerbahçe')) {
      return 'https://link.to/fenerbahce_logo.png';
    } else if (lowerCaseName.contains('galatasaray')) {
      return 'https://link.to/galatasaray_logo.png';
    } else {
      return 'https://e7.pngegg.com/pngimages/592/414/png-clipart-computer-icons-news-news-icon-angle-text-thumbnail.png';
    }
  }

  /// Eğer orijinal tarih bilgisini (tarih, gün, saat) detaylı göstermek isterseniz
  /// bu fonksiyonu kullanabilirsiniz.
  String formatFullDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      final DateFormat formatter =
          DateFormat('dd MMMM yyyy - EEEE - HH:mm', 'tr');
      return formatter.format(dateTime);
    } catch (e) {
      return date;
    }
  }

  /// Bu fonksiyon, verilen tarih string'inden yalnızca saat bilgisini (HH:mm) alır.
  String getMatchTime(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
      return DateFormat('HH:mm', 'tr').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  /// Maçları gün bazında gruplayıp, her grubun başına gün başlığını ekliyoruz.
  Widget buildMatchList() {
    // Maç listesinin boş olmadığını varsayalım.
    var matches = futureLeagueResult!.result!;
    // Tarihe göre sıralıyoruz.
    matches.sort((a, b) {
      DateTime dtA, dtB;
      try {
        dtA = DateTime.parse(a.date ?? "");
      } catch (e) {
        dtA = DateTime.now();
      }
      try {
        dtB = DateTime.parse(b.date ?? "");
      } catch (e) {
        dtB = DateTime.now();
      }
      return dtA.compareTo(dtB);
    });

    // Gruplama işlemi: key olarak gün adı (ör. "Cuma") ve value olarak o güne ait maçlar.
    Map<String, List> groupedMatches = {};
    List<String> groupKeys = [];
    for (var match in matches) {
      try {
        DateTime dt = DateTime.parse(match.date ?? "");
        String dayName = DateFormat('EEEE', 'tr').format(dt);
        if (groupedMatches.containsKey(dayName)) {
          groupedMatches[dayName]!.add(match);
        } else {
          groupedMatches[dayName] = [match];
          groupKeys.add(dayName);
        }
      } catch (e) {
        // Eğer tarih parse edilemiyorsa "Bilinmeyen" grubuna ekleyelim.
        if (groupedMatches.containsKey("Bilinmeyen")) {
          groupedMatches["Bilinmeyen"]!.add(match);
        } else {
          groupedMatches["Bilinmeyen"] = [match];
          groupKeys.add("Bilinmeyen");
        }
      }
    }

    List<Widget> listItems = [];

    // Her grup için: önce grup başlığını, ardından o güne ait maç kartlarını ekliyoruz.
    for (var dayName in groupKeys) {
      listItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            dayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
      for (var match in groupedMatches[dayName]!) {
        final homeTeam = match.home ?? 'Ev Sahibi';
        final awayTeam = match.away ?? 'Deplasman';
        final rawScore = match.score ?? '';
        // Skor değeri içinde "undefined" kelimesi geçiyorsa varsayılan olarak "0 - 0" atayalım.
        final score = rawScore.trim().toLowerCase().contains('undefined')
            ? 'Maç henüz oynanmadı'
            : rawScore;
        final date = match.date ?? '';
        final matchTime = getMatchTime(date);
        final homeLogo = getTeamLogo(homeTeam);
        final awayLogo = getTeamLogo(awayTeam);

        listItems.add(
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           LeagueSonucdetay(leagueKey: widget.leagueKey),
              //     ),
              //   );
              // },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Maç saatini bold olarak gösteriyoruz.
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          matchTime,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Takımlar ve skor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ev Sahibi Takım
                        Expanded(
                          child: Column(
                            children: [
                              Image.network(
                                homeLogo,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                homeTeam,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Skor
                        Column(
                          children: [
                            Text(
                              score,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                        // Deplasman Takımı
                        Expanded(
                          child: Column(
                            children: [
                              Image.network(
                                awayLogo,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                awayTeam,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
      }
    }

    return ListView(
      children: listItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshLeagueResult,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : futureLeagueResult == null
                ? const Center(child: Text('Veri yüklenemedi'))
                : buildMatchList(),
      ),
    );
  }
}
