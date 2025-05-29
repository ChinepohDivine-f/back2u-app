import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  final String id; // Use 'cameroon' as the document ID
  final String nameEn;
  final String nameFr;
  final String countryCode; // e.g., "CM"
  final String phoneCode; // e.g., "+237"
  final String flagEmoji; // e.g., "🇨🇲"
  final String currencyName; // e.g., "Central African CFA franc"
  final String currencyCode; // e.g., "XAF"
  final String capitalCityEn;
  final String capitalCityFr;
  final List<String> officialLanguages; // e.g., ["English", "French"]
  final String region; // e.g., "Central Africa"
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Country({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.countryCode,
    required this.phoneCode,
    required this.flagEmoji,
    required this.currencyName,
    required this.currencyCode,
    required this.capitalCityEn,
    required this.capitalCityFr,
    required this.officialLanguages,
    required this.region,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Country.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Country(
      id: doc.id, // The document ID itself
      nameEn: data['name_en'] ?? '',
      nameFr: data['name_fr'] ?? '',
      countryCode: data['country_code'] ?? '',
      phoneCode: data['phone_code'] ?? '',
      flagEmoji: data['flag_emoji'] ?? '',
      currencyName: data['currency_name'] ?? '',
      currencyCode: data['currency_code'] ?? '',
      capitalCityEn: data['capital_city_en'] ?? '',
      capitalCityFr: data['capital_city_fr'] ?? '',
      officialLanguages: List<String>.from(data['official_languages'] ?? []),
      region: data['region'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name_en': nameEn,
      'name_fr': nameFr,
      'country_code': countryCode,
      'phone_code': phoneCode,
      'flag_emoji': flagEmoji,
      'currency_name': currencyName,
      'currency_code': currencyCode,
      'capital_city_en': capitalCityEn,
      'capital_city_fr': capitalCityFr,
      'official_languages': officialLanguages,
      'region': region,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}