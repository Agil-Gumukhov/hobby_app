// lib/main.dart
import 'dart:convert';
import 'dart:io';

import 'package:firstapp/pages/DiziT%C3%BCrleri.dart';
import 'package:firstapp/pages/FilmlerT%C3%BCrler.dart';
import 'package:firstapp/pages/GolKralligiData.dart';
import 'package:firstapp/pages/Haberler.dart';
import 'package:firstapp/pages/RestaurantsData.dart';
import 'package:firstapp/pages/Sonu%C3%A7Detay.dart';
import 'package:firstapp/pages/Sport_LeagueList.dart';
import 'package:firstapp/pages/Sport_result.dart';
import 'package:firstapp/pages/Tiyatro.dart';
import 'package:firstapp/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Localization import
import 'package:firstapp/generated/l10n.dart';

// Language Provider import
import 'package:firstapp/LanguageProvider.dart';

// Navbar import
import 'package:firstapp/navbar.dart';

// TranslationService sınıfı
class TranslationService {
  static final String apiUrl = dotenv.env['TRANSLATE_API_URL'] ??
      'https://translation.googleapis.com/language/translate/v2';
  static final String apiKey =
      dotenv.env['TRANSLATE_API_KEY'] ?? 'YENI_GOOGLE_TRANSLATE_API_KEY';
  static final Map<String, String> _cache = {};

  /// Metni hedef dile çevirir ve önbelleğe alır.
  static Future<String> translateText(String text, String targetLang) async {
    String cacheKey = 'tr-$targetLang-$text';
    if (_cache.containsKey(cacheKey)) {
      print("Çeviri önbellekten alındı: $cacheKey");
      return _cache[cacheKey]!;
    }

    print("Çeviri API çağrısı yapılıyor: $text");

    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'q': text,
        'target': targetLang,
        'format': 'text',
        'source': 'tr', // Kaynak dili Türkçe olarak belirtiyoruz
      }),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final translatedText =
          jsonBody['data']['translations'][0]['translatedText'];
      _cache[cacheKey] = translatedText;
      print("Çeviri başarılı: $translatedText");
      return translatedText;
    } else {
      print("Çeviri API hatası: ${response.statusCode}");
      print("Hata Detayı: ${response.body}");
      throw Exception('Çeviri işlemi başarısız oldu: ${response.statusCode}');
    }
  }
}

// Haberleri çeken ve çeviren fonksiyon
Future<Haberler> fetchHaberler(String targetLang) async {
  final response = await http.get(
    Uri.parse('https://api.collectapi.com/news/getNews?country=tr&tag=general'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          dotenv.env['COLLECTAPI_KEY'] ?? 'apikey YENI_COLLECTAPI_KEY',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    Haberler haberler =
        Haberler.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in haberler.result ?? []) {
        if (result.name != null && result.description != null) {
          result.name =
              await TranslationService.translateText(result.name!, targetLang);
          result.description = await TranslationService.translateText(
              result.description!, targetLang);
        }
      }
    }

    return haberler;
  } else {
    throw Exception('Failed to load Haberler: ${response.statusCode}');
  }
}

Future<LeagueList> fetchLeagueList(String targetLang) async {
  final response = await http.get(
    Uri.parse('https://api.collectapi.com/sport/leaguesList'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          dotenv.env['COLLECTAPI_KEY'] ?? 'apikey YENI_COLLECTAPI_KEY',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    LeagueList leagueList =
        LeagueList.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in leagueList.result ?? []) {
        if (result.league != null && result.description != null) {
          result.league = await TranslationService.translateText(
              result.league!, targetLang);
          result.description = await TranslationService.translateText(
              result.description!, targetLang);
        }
      }
    }

    return leagueList;
  } else {
    throw Exception('Failed to load fetchLeagueList: ${response.statusCode}');
  }
}

Future<LeagueResults> fetchSportResult(
    String targetLang, String leagueKey) async {
  final response = await http.get(
    Uri.parse(
        'https://api.collectapi.com/sport/results?data.league=$leagueKey'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          dotenv.env['COLLECTAPI_KEY'] ?? 'apikey YENI_COLLECTAPI_KEY',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    LeagueResults sportResult = LeagueResults.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in sportResult.result ?? []) {
        if (result.home != null && result.away != null) {
          result.home =
              await TranslationService.translateText(result.home!, targetLang);
          result.away =
              await TranslationService.translateText(result.away!, targetLang);
        }
      }
    }

    return sportResult;
  } else {
    throw Exception('Failed to load fetchSportResult: ${response.statusCode}');
  }
}

Future<LeagueDetay> fetchLeagueDetay(
    String targetLang, String leagueKey) async {
  final response = await http.get(
    Uri.parse('https://api.collectapi.com/sport/league?data.league=$leagueKey'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          dotenv.env['COLLECTAPI_KEY'] ?? 'apikey YENI_COLLECTAPI_KEY',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    LeagueDetay sportDetay =
        LeagueDetay.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in sportDetay.result ?? []) {
        if (result.team != null) {
          result.team =
              await TranslationService.translateText(result.team!, targetLang);
        }
      }
    }

    return sportDetay;
  } else {
    throw Exception('Failed to load fetchLeagueDetay: ${response.statusCode}');
  }
}

Future<GolKralligiData> fetchGolKralligiData(
    String targetLang, String leagueKey) async {
  final response = await http.get(
    Uri.parse(
        'https://api.collectapi.com/sport/goalKings?data.league=$leagueKey'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          dotenv.env['COLLECTAPI_KEY'] ?? 'apikey YENI_COLLECTAPI_KEY',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    GolKralligiData golKralligiData = GolKralligiData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in golKralligiData.result ?? []) {
        if (result.team != null) {
          result.team =
              await TranslationService.translateText(result.team!, targetLang);
        }
      }
    }

    return golKralligiData;
  } else {
    throw Exception(
        'Failed to load fetchGolKralligiData: ${response.statusCode}');
  }
}

Future<FilmlerTypes> fetchFilmTypesData(String targetLang) async {
  // Vizyondaki filmleri getirir
  final url = Uri.parse(
    'https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1',
  );

  final response = await http.get(
    url,
    headers: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ZTAwNDZmNjQzOTJjNDBmMTRiZWI5OWE4NWUxZmFlZCIsIm5iZiI6MTczODY2NTM1OS44ODksInN1YiI6IjY3YTFlZDhmMzgwYjg2YWNkOTAyZmJmZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Xo_Wp1Soy7TGZx9YAb5XGHg7krqyrPZ8ohhCukAMcP8',
      'accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    FilmlerTypes filmlerTypesData = FilmlerTypes.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in filmlerTypesData.results ?? []) {
        if (result.team != null) {
          result.team =
              await TranslationService.translateText(result.team!, targetLang);
        }
      }
    }

    return filmlerTypesData;
  } else {
    throw Exception(
        'Failed to load fetchFilmTypesData: ${response.statusCode}');
  }
}

Future<SeriesTypes> fetchSeriesTypesData(String targetLang) async {
  // Vizyondaki filmleri getirir
  final url = Uri.parse(
    'https://api.themoviedb.org/3/discover/tv?include_adult=false&language=en-US&page=1', //&sort_by=popularity.desc
  );

  final response = await http.get(
    url,
    headers: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ZTAwNDZmNjQzOTJjNDBmMTRiZWI5OWE4NWUxZmFlZCIsIm5iZiI6MTczODY2NTM1OS44ODksInN1YiI6IjY3YTFlZDhmMzgwYjg2YWNkOTAyZmJmZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Xo_Wp1Soy7TGZx9YAb5XGHg7krqyrPZ8ohhCukAMcP8',
      'accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    SeriesTypes seriesTypesData =
        SeriesTypes.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in seriesTypesData.results ?? []) {
        if (result.team != null) {
          result.team =
              await TranslationService.translateText(result.team!, targetLang);
        }
      }
    }

    return seriesTypesData;
  } else {
    throw Exception(
        'Failed to load fetchFilmTypesData: ${response.statusCode}');
  }
}

Future<Theathres> fetchTheathresData(String targetLang) async {
  final response = await http.get(
    Uri.parse('https://api.collectapi.com/watching/tiyatro?data.city=ankara'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          'apikey 4vLetu7XsKob5wPb9fqnGi:6iiAv1r1exuGBVZjw9znnr' ?? 'apikey YENI_COLLECTAPI_KEY',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    Theathres tiyatroData =
        Theathres.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in tiyatroData.result ?? []) {
        if (result.team != null) {
          result.team =
              await TranslationService.translateText(result.team!, targetLang);
        }
      }
    }

    return tiyatroData;
  } else {
    throw Exception('Failed to load tiyatro: ${response.statusCode}');
  }
}
Future<RestaurantsData> fetchRestaurants(String targetLang,String location) async {
  final response = await http.get(
    Uri.parse('https://api.yelp.com/v3/businesses/search?term=restaurants&location=$location&limit=20'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:'Bearer ZQ_Rx1misHRgHM8zil0b6_zdNil0B5OoN8UMBGP_L6EMEXBHysm08arOEgfo9pa4ae5TbH3cKTkZLgUQXQXL5027gJtBHje0khTtiQRmhpRmpNMuMu0wXfbcVEajZ3Yx',
    },
  );

  if (response.statusCode == 200) {
    // JSON yanıtını parse et
    RestaurantsData tiyatroData =
        RestaurantsData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    // Eğer hedef dil Türkçe değilse, çeviri yap
    if (targetLang != 'tr') {
      for (var result in tiyatroData.businesses ?? []) {
        if (result.team != null) {
          result.team =
              await TranslationService.translateText(result.team!, targetLang);
        }
      }
    }

    return tiyatroData;
  } else {
    throw Exception('Failed to load tiyatro: ${response.statusCode}');
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // .env dosyasını yükle
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Haberler> futureHaberler;
  late Future<LeagueList> futureLeagueList;
  late Future<LeagueResults> futureSportResult;
  late Future<GolKralligiData> futureGolKralligiData;

  @override
  void initState() {
    super.initState();
    // İlk başta mevcut locale'ı al
    String targetLang = Provider.of<LocaleProvider>(context, listen: false)
        .current
        .languageCode;
    futureHaberler = fetchHaberler(targetLang);
    futureLeagueList = fetchLeagueList(targetLang);
    // futureSportResult = fetchSportResult(targetLang, );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        // Locale değiştiğinde yeni haberleri çek
        futureHaberler = fetchHaberler(localeProvider.current.languageCode);
        futureLeagueList = fetchLeagueList(localeProvider.current.languageCode);

        return MaterialApp(
          theme: ThemeData.light(), // Light theme
          darkTheme: ThemeData.dark(), // Dark theme
          themeMode: themeProvider.themeMode == ThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: localeProvider.current, // Seçili dil
          debugShowCheckedModeBanner: false,
          title: 'Fetch Data Example',

          home: Scaffold(
            body: Navbar(
              haberler: futureHaberler,
              selectedImage: null,
              name: '',
              department: '',
              phone: '',
              email: '',
            ),
          ),
        );
      },
    );
  }
}
