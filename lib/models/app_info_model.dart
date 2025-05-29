import 'package:cloud_firestore/cloud_firestore.dart';

class AppInfo {
  final String appVersion;
  final String appNameEn;
  final String appNameFr;
  final String contactEmail;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final Timestamp lastUpdated;

  AppInfo({
    required this.appVersion,
    required this.appNameEn,
    required this.appNameFr,
    required this.contactEmail,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.lastUpdated,
  });

  factory AppInfo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppInfo(
      appVersion: data['app_version'] ?? '1.0.0',
      appNameEn: data['app_name_en'] ?? 'Back2u',
      appNameFr: data['app_name_fr'] ?? 'Back2u',
      contactEmail: data['contact_email'] ?? '',
      privacyPolicyUrl: data['privacy_policy_url'] ?? '',
      termsOfServiceUrl: data['terms_of_service_url'] ?? '',
      lastUpdated: data['last_updated'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'app_version': appVersion,
      'app_name_en': appNameEn,
      'app_name_fr': appNameFr,
      'contact_email': contactEmail,
      'privacy_policy_url': privacyPolicyUrl,
      'terms_of_service_url': termsOfServiceUrl,
      'last_updated': lastUpdated,
    };
  }
}