import 'dart:developer';

import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/Sonu%C3%A7Detay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeagueSonucdetay extends StatefulWidget {
  final String leagueKey;
  const LeagueSonucdetay({super.key, required this.leagueKey});

  @override
  State<LeagueSonucdetay> createState() => _LeagueSonucdetayState();
}

class _LeagueSonucdetayState extends State<LeagueSonucdetay> {
  LeagueDetay? futureLeagueDetay;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    print("LeagueSonucdetay: leagueKey = ${widget.leagueKey}");
    _fetchLeagueDetay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchLeagueDetay(currentLang);
  }

  void _fetchLeagueDetay([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchLeagueDetay(lang, widget.leagueKey).then((data) {
      
      if (!mounted) return;
      setState(() {
        futureLeagueDetay = data as LeagueDetay?;
        isLoading = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      log('Error fetching league result: $error');
    });
  }

  Future<void> _refreshLeagueResult() async {
    String currentLang = Provider.of<LocaleProvider>(context, listen: false)
        .current
        .languageCode;
    _fetchLeagueDetay(currentLang);
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

  @override
  Widget build(BuildContext context) {
    // DataTable ayarları: sütun arası mesafe, kenar boşlukları, satır yükseklikleri vs.
    const double columnSpacing = 12.0;
    const double horizontalMargin = 15.0;
    const double dataRowHeight = 60.0;
    const double headingRowHeight = 64.0;

    // Başlık ve hücre metin stilleri
    const TextStyle headerTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    const TextStyle cellTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.black87,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshLeagueResult,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : futureLeagueDetay == null
                ? const Center(child: Text('Veri yüklenemedi'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        // Yalnızca dikey kaydırma olacak
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              width: constraints
                                  .maxWidth, // Ekran genişliğine sabitleniyor
                              child: DataTable(
                                columnSpacing: columnSpacing,
                                horizontalMargin: horizontalMargin,
                                dataRowHeight: dataRowHeight,
                                headingRowHeight: headingRowHeight,
                                headingRowColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (states) =>
                                      Colors.blueAccent.withOpacity(0.1),
                                ),
                                dataRowColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (states) => Colors.grey.withOpacity(0.1),
                                ),
                                columns: const [
                                  DataColumn(
                                      label:
                                          Text('Sıra', style: headerTextStyle)),
                                  DataColumn(
                                      label: Text('Takım',
                                          style: headerTextStyle)),
                                  DataColumn(
                                      label: Text('O', style: headerTextStyle)),
                                  DataColumn(
                                      label: Text('G', style: headerTextStyle)),
                                  DataColumn(
                                      label: Text('B', style: headerTextStyle)),
                                  DataColumn(
                                      label: Text('M', style: headerTextStyle)),
                                  DataColumn(
                                      label: Text('P', style: headerTextStyle)),
                                ],
                                rows: futureLeagueDetay!.result!.map((result) {
                                  return DataRow(
                                    cells: [
                                      // Sıra
                                      DataCell(
                                        Text(result.rank ?? '',
                                            style: cellTextStyle),
                                      ),
                                      // Takım (logo + takım adı)
                                      DataCell(
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Sabit genişlikte Container ile metni sarmalayarak, uzun isimlerin 2–3 satırda görünmesini sağlıyoruz.
                                            Container(
                                              width: 150,
                                              height: 50,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                result.team ?? '',
                                                style: cellTextStyle,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Oynadı
                                      DataCell(
                                        Text(result.play ?? '',
                                            style: cellTextStyle),
                                      ),
                                      // Galibiyet
                                      DataCell(
                                        Text(result.win ?? '',
                                            style: cellTextStyle),
                                      ),
                                      // Beraberlik
                                      DataCell(
                                        Text(result.lose ?? '',
                                            style: cellTextStyle),
                                      ),
                                      // Mağlubiyet
                                      DataCell(
                                        Text(result.lose ?? '',
                                            style: cellTextStyle),
                                      ),
                                      // Puan
                                      DataCell(
                                        Text(result.point ?? '',
                                            style: cellTextStyle),
                                      ),
                                    ],
                                  );
                                }).toList(),
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
