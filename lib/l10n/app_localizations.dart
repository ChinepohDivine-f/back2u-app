import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  static const Locale frLocale = Locale('fr');
  static const Locale enLocale = Locale('en');
  
  static const List<Locale> supportedLocales = [
    frLocale,
    enLocale,
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static String getLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  static String translate(BuildContext context, String key) {
    // You can implement a translation system here if needed
    return key;
  }
}
