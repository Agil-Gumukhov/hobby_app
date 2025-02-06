import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale current = Locale('tr'); // Default language is Turkish

  // Locale get currentLocale => current;

  // void setLocale(Locale locale) {
  //   if (!S.delegate.supportedLocales.contains(locale))
  //     return; // Geçersiz bir locale atamamak için
  //   current = locale;
  //   notifyListeners();
  // }
  void setTurkish() {
    print("Türkçe seçildi");
    current = const Locale('tr');
    notifyListeners(); // Notify listeners to rebuild widgets
  }

  void setEnglish() {
    print("İngilizce seçildi");
    current = const Locale('en');
    notifyListeners(); // Notify listeners to rebuild widgets
  }
}
