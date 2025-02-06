import 'package:firstapp/LanguageProvider.dart';
import 'package:firstapp/main.dart';
import 'package:firstapp/pages/Sport_LeagueList.dart';
import 'package:firstapp/pages/TapBarView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum LeagueFilter { all, football, basketball, others, highlights }

class SportSayfa extends StatefulWidget {
  const SportSayfa({super.key});

  @override
  State<SportSayfa> createState() => _SportSayfaState();
}

class _SportSayfaState extends State<SportSayfa> {
  LeagueList? futureLeagueList;
  late bool isLoading;
  LeagueFilter _selectedFilter = LeagueFilter.all;

  // Manual key sets for filtering
  final Set<String> footballKeys = {
    "super-lig",
    "tff-1-lig",
    "ingiltere-premier-ligi",
    "uefa-konferans-ligi",
    "almanya-bundesliga",
    "fransa-ligue-1",
    "ispanya-la-liga",
    "italya-serie-a-ligi",
    "ingiltere-sampiyonluk-ligi",
    "almanya-bundesliga-2-ligi",
    "fransa-ligue-2",
    "/2024-uefa-euro-cup",
    "/beinsquad",
  };

  final Set<String> basketballKeys = {
    "basketbol-super-ligi",
    "euroleague",
    "nba",
  };

  final Set<String> othersKeys = {
    "/gundem/voleybol",
    "/gundem/gures",
    "/gundem/atletizm",
    "/gundem/e-spor",
    "/gundem/diger",
  };

  final Set<String> highlightsKeys = {
    "/mac-ozetleri-goller/super-lig",
    "/mac-ozetleri-goller/tff-1-lig",
    "/mac-ozetleri-goller/ingiltere-premier-ligi",
    "/mac-ozetleri-goller/almanya-bundesliga",
    "/mac-ozetleri-goller/fransa-ligue-1",
    "/mac-ozetleri-goller/almanya-bundesliga-2-ligi",
    "/mac-ozetleri-goller/fransa-ligue-2",
    "/mac-ozetleri-goller/basketbol-super-ligi",
  };
// External URL mapping for specific keys
  final Map<String, String> _externalUrlMapping = {
    "/gundem/voleybol": "https://beinsports.com.tr/gundem/voleybol",
    "/gundem/gures": "https://beinsports.com.tr/gundem/gures",
    "/gundem/atletizm": "https://beinsports.com.tr/gundem/atletizm",
    "/gundem/e-spor": "https://beinsports.com.tr/gundem/e-spor",
    "/gundem/diger": "https://beinsports.com.tr/gundem/diger",
    "nba": "https://beinsports.com.tr/lig/nba",
    // Highlight (match summary) URLs
    "/mac-ozetleri-goller/super-lig":
        "https://beinsports.com.tr/mac-ozetleri-goller/super-lig",
    "/mac-ozetleri-goller/tff-1-lig":
        "https://beinsports.com.tr/mac-ozetleri-goller/tff-1-lig",
    "/mac-ozetleri-goller/ingiltere-premier-ligi":
        "https://beinsports.com.tr/mac-ozetleri-goller/ingiltere-premier-ligi",
    "/mac-ozetleri-goller/almanya-bundesliga":
        "https://beinsports.com.tr/mac-ozetleri-goller/almanya-bundesliga",
    "/mac-ozetleri-goller/fransa-ligue-1":
        "https://beinsports.com.tr/mac-ozetleri-goller/fransa-ligue-1",
    "/mac-ozetleri-goller/almanya-bundesliga-2-ligi":
        "https://beinsports.com.tr/mac-ozetleri-goller/almanya-bundesliga-2-ligi",
    "/mac-ozetleri-goller/fransa-ligue-2":
        "https://beinsports.com.tr/mac-ozetleri-goller/fransa-ligue-2",
    "/mac-ozetleri-goller/basketbol-super-ligi":
        "https://beinsports.com.tr/mac-ozetleri-goller/basketbol-super-ligi",
  };
  @override
  void initState() {
    super.initState();
    isLoading = true;
    _fetchLeagueList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLang =
        Provider.of<LocaleProvider>(context, listen: true).current.languageCode;
    _fetchLeagueList(currentLang);
  }

  void _fetchLeagueList([String lang = 'en']) {
    setState(() {
      isLoading = true;
    });
    fetchLeagueList(lang).then((data) {
      setState(() {
        futureLeagueList = data as LeagueList?;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching league list: $error');
    });
  }

  Future<void> _refreshLeagueList() async {
    String currentLang = Provider.of<LocaleProvider>(context, listen: false)
        .current
        .languageCode;
    _fetchLeagueList(currentLang);
  }

  String getCountryFlagByLeagueName(String leagueName) {
    final lowerCaseName = leagueName.toLowerCase();

    if (lowerCaseName.contains('almanya')) {
      return 'assets/images/germany.png';
    } else if (lowerCaseName.contains('ingiltere')) {
      return 'assets/images/united-kingdom.png';
    } else if (lowerCaseName.contains('türkiye') ||
        lowerCaseName.contains('trendyol')) {
      return 'assets/images/turkey.png';
    } else if (lowerCaseName.contains('fransa')) {
      return 'assets/images/france.png';
    } else if (lowerCaseName.contains('çin')) {
      return 'assets/images/china.png';
    } else if (lowerCaseName.contains('şili')) {
      return 'assets/images/chile.png';
    } else if (lowerCaseName.contains('america')) {
      return 'assets/images/united-states.png';
    } else if (lowerCaseName.contains('kanada')) {
      return 'assets/images/canada.png';
    } else if (lowerCaseName.contains('ispanya')) {
      return 'assets/images/spain.png';
    } else if (lowerCaseName.contains('italya')) {
      return 'assets/images/italy.png';
    } else if (lowerCaseName.contains('japon') ||
        lowerCaseName.contains('japonya')) {
      return 'assets/images/japan.png';
    } else {
      return 'assets/images/world.png';
    }
  }

  // Filtrelenmiş lig listesini _selectedFilter'e göre oluşturuyoruz.
  List<Result>? get filteredLeagueList {
    if (futureLeagueList == null || futureLeagueList!.result == null) {
      return null;
    }
    if (_selectedFilter == LeagueFilter.all) return futureLeagueList!.result;
    return futureLeagueList!.result!.where((leagueItem) {
      final key = (leagueItem.key ?? "").toLowerCase();
      switch (_selectedFilter) {
        case LeagueFilter.football:
          return footballKeys.contains(key);
        case LeagueFilter.basketball:
          return basketballKeys.contains(key);
        case LeagueFilter.others:
          return othersKeys.contains(key);
        case LeagueFilter.highlights:
          return highlightsKeys.contains(key);
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bağlantı açılamadı: $urlString")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaguesToDisplay = filteredLeagueList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spor Ligleri"),
        actions: [
          PopupMenuButton<LeagueFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (LeagueFilter category) {
              setState(() {
                _selectedFilter = category;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<LeagueFilter>>[
              const PopupMenuItem(
                value: LeagueFilter.all,
                child: Text('Tümü'),
              ),
              const PopupMenuItem(
                value: LeagueFilter.football,
                child: Text('Futbol'),
              ),
              const PopupMenuItem(
                value: LeagueFilter.basketball,
                child: Text('Basketbol'),
              ),
              const PopupMenuItem(
                value: LeagueFilter.others,
                child: Text('Diğer Sporlar'),
              ),
              const PopupMenuItem(
                value: LeagueFilter.highlights,
                child: Text('Özetler'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLeagueList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (futureLeagueList == null ||
                    (leaguesToDisplay != null && leaguesToDisplay.isEmpty))
                ? const Center(
                    child: Text(
                        'Veri yüklenemedi veya seçili spor türüne ait lig bulunamadı'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: leaguesToDisplay?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final leagueItem = leaguesToDisplay![index];

                      final leagueName = leagueItem.league ?? '';
                      final leagueKey = leagueItem.key ?? '';

                      String imgUrl = getCountryFlagByLeagueName(leagueName);

                      return SizedBox(
                        height: 85,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Eğer leagueKey, external URL mapping içinde varsa dış URL'i aç; yoksa uygulama içinde navigasyon yap.
                              if (_externalUrlMapping.containsKey(leagueKey)) {
                                final String? externalUrl =
                                    _externalUrlMapping[leagueKey];
                                if (externalUrl != null &&
                                    externalUrl.isNotEmpty) {
                                  _launchExternalUrl(externalUrl);
                                } else {
                                  // External URL mapping var ama boş ise, varsayılan navigasyonu kullan.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Tapbarview(leagueKey: leagueKey),
                                    ),
                                  );
                                }
                              } else {
                                // Eğer leagueKey, external URL mapping içinde yoksa da varsayılan navigasyonu kullan.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Tapbarview(leagueKey: leagueKey),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Görsel kısmı
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      imgUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Lig bilgileri
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          leagueName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Sağdaki ikon
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 24,
                                    color: Colors.grey,
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
