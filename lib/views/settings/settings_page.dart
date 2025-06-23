import 'package:flutter/material.dart';
import 'package:back2u/main.dart';
import 'package:back2u/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Get the app's state to access the locale and the method to change it.
    final myAppState = MyApp.of(context);
    final currentLanguageCode = myAppState?.locale?.languageCode ?? 'en';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(l10n.language),
              subtitle: Text(currentLanguageCode == 'fr' ? l10n.french : l10n.english),
              trailing: DropdownButton<String>(
                value: currentLanguageCode,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // Call the method from MyAppState to change the locale
                    myAppState?.changeLocale(Locale(newValue));
                  }
                },
                items: <String>['en', 'fr'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'fr' ? l10n.french : l10n.english),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
