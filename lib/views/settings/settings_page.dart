import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back2u/main.dart';
import 'package:back2u/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    
    // Update the app locale
    if (mounted) {
      setState(() {
        _selectedLanguage = language;
      });
      
      // Force rebuild the app with new locale
      if (context.mounted) {
        final locale = language == 'fr' ? const Locale('fr') : const Locale('en');
        context.findAncestorStateOfType<MyAppState>()?.changeLocale(locale);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Language'),
              subtitle: Text(_selectedLanguage == 'fr' ? 'Français' : 'English'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _saveLanguage(newValue);
                  }
                },
                items: <String>['en', 'fr'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'fr' ? 'Français' : 'English'),
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
