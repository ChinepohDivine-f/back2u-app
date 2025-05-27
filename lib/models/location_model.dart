import 'package:cloud_firestore/cloud_firestore.dart';

class SubLocation {
  final Timestamp createdAt;
  final String locationId;
  final String nameEn;
  final String nameFr;
  final String subLocationId;
  final Timestamp updatedAt;

  SubLocation({
    required this.createdAt,
    required this.locationId,
    required this.nameEn,
    required this.nameFr,
    required this.subLocationId,
    required this.updatedAt,
  });

  factory SubLocation.fromFirestore(Map<String, dynamic> data) {
    return SubLocation(
      createdAt: data['createdAt'] ?? Timestamp.now(),
      locationId: data['locationId'] ?? '',
      nameEn: data['name_en'] ?? '',
      nameFr: data['name_fr'] ?? '',
      subLocationId: data['subLocationId'] ?? '',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt,
      'locationId': locationId,
      'name_en': nameEn,
      'name_fr': nameFr,
      'subLocationId': subLocationId,
      'updatedAt': updatedAt,
    };
  }
}

class Location {
  final Timestamp createdAt;
  final String locationId;
  final String nameEn;
  final String nameFr;
  final List<SubLocation> sublocations;
  final Timestamp updatedAt;


  Location({
    required this.createdAt,
    required this.locationId,
    required this.nameEn,
    required this.nameFr,
    required this.sublocations,
    required this.updatedAt,
  });

  factory Location.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Location(
      createdAt: data['createdAt'] ?? Timestamp.now(),
      locationId: data['locationId'] ?? '',
      nameEn: data['name_en'] ?? '',
      nameFr: data['name_fr'] ?? '',
      sublocations: (data['sublocations'] as List? ?? [])
          .map((subLocData) => SubLocation.fromFirestore(subLocData as Map<String, dynamic>))
          .toList(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt,
      'locationId': locationId,
      'name_en': nameEn,
      'name_fr': nameFr,
      'sublocations': sublocations.map((subLoc) => subLoc.toFirestore()).toList(),
      'updatedAt': updatedAt,
    };
  }
}