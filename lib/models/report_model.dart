import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? ownerName;
  final String category;
  final String categoryFr;
  final String contactPhone;
  final Timestamp reportedDate;
  final String documentName;
  final List<String> images;
  final Timestamp? updatedAt;
  final String locationLost;
  final String locationLostFr;
  final String notes;
  final Timestamp createdAt;
  final String reportId;
  final String reporterId; // This is the ID from the sample, keeping it for now
  final String reporterUid; // New: Firebase Auth User ID
  final bool resolved;
  final String reward;
  final List<String> searchKeyWords;
  final String status;
  final String subLocationLost;
  final String subLocationLostFr;
  final String subcategory;
  final String subcategoryFr;
  final String type;
  final String whatsappNumber;

  Report({
    this.ownerName,
    required this.category,
    required this.categoryFr,
    required this.contactPhone,
    required this.reportedDate,
    required this.documentName,
    required this.images,
    this.updatedAt,
    required this.locationLost,
    required this.locationLostFr,
    required this.notes,
    required this.createdAt,
    required this.reportId,
    required this.reporterId,
    required this.reporterUid,
    required this.resolved,
    required this.reward,
    required this.searchKeyWords,
    required this.status,
    required this.subLocationLost,
    required this.subLocationLostFr,
    required this.subcategory,
    required this.subcategoryFr,
    required this.type,
    required this.whatsappNumber,
  });

  // Factory constructor to create a Report from a Firestore DocumentSnapshot
  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Report(
      ownerName: data['owner_name'],
      category: data['category'] ?? '',
      categoryFr: data['category_fr'] ?? '',
      contactPhone: data['contact_phone'] ?? '',
      reportedDate: data['date_of_loss'] ?? Timestamp.now(),
      documentName: data['document_name'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      updatedAt: data['updatedAt'],
      locationLost: data['location_lost'] ?? '',
      locationLostFr: data['location_lost_fr'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      reportId: data['report_id'] ?? '',
      reporterId: data['reporter_id'] ?? '',
      reporterUid: data['reporter_uid'] ?? '',
      resolved: data['resolved'] ?? false,
      reward: data['reward'] ?? '',
      searchKeyWords: List<String>.from(data['search_key_words'] ?? []),
      status: data['status'] ?? '',
      subLocationLost: data['sub_location_lost'] ?? '',
      subLocationLostFr: data['sub_location_lost_fr'] ?? '',
      subcategory: data['subcategory'] ?? '',
      subcategoryFr: data['subcategory_fr'] ?? '',
      type: data['type'] ?? '',
      whatsappNumber: data['whatsapp_number'] ?? '',
    );
  }

  // Method to convert a Report object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (ownerName != null) 'owner_name': ownerName,
      'category': category,
      'category_fr': categoryFr,
      'contact_phone': contactPhone,
      'date_of_loss': reportedDate,
      'document_name': documentName,
      'images': images,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'location_lost': locationLost,
      'location_lost_fr': locationLostFr,
      'notes': notes,
      'createdAt': createdAt,
      'report_id': reportId,
      'reporter_id': reporterId,
      'reporter_uid': reporterUid,
      'resolved': resolved,
      'reward': reward,
      'search_key_words': searchKeyWords,
      'status': status,
      'sub_location_lost': subLocationLost,
      'sub_location_lost_fr': subLocationLostFr,
      'subcategory': subcategory,
      'subcategory_fr': subcategoryFr,
      'type': type,
      'whatsapp_number': whatsappNumber,
    };
  }

  // --- ADD THIS copyWith METHOD ---
  Report copyWith({
    String? ownerName,
    String? category,
    String? categoryFr,
    String? contactPhone,
    Timestamp? reportedDate,
    String? documentName,
    List<String>? images,
    Timestamp? updatedAt,
    String? locationLost,
    String? locationLostFr,
    String? notes,
    Timestamp? createdAt,
    String? reportId,
    String? reporterId,
    String? reporterUid,
    bool? resolved,
    String? reward,
    List<String>? searchKeyWords,
    String? status,
    String? subLocationLost,
    String? subLocationLostFr,
    String? subcategory,
    String? subcategoryFr,
    String? type,
    String? whatsappNumber,
  }) {
    return Report(
      ownerName: ownerName ?? this.ownerName,
      category: category ?? this.category,
      categoryFr: categoryFr ?? this.categoryFr,
      contactPhone: contactPhone ?? this.contactPhone,
      reportedDate: reportedDate ?? this.reportedDate,
      documentName: documentName ?? this.documentName,
      images: images ?? this.images,
      updatedAt: updatedAt ?? this.updatedAt,
      locationLost: locationLost ?? this.locationLost,
      locationLostFr: locationLostFr ?? this.locationLostFr,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      reportId: reportId ?? this.reportId,
      reporterId: reporterId ?? this.reporterId,
      reporterUid: reporterUid ?? this.reporterUid,
      resolved: resolved ?? this.resolved,
      reward: reward ?? this.reward,
      searchKeyWords: searchKeyWords ?? this.searchKeyWords,
      status: status ?? this.status,
      subLocationLost: subLocationLost ?? this.subLocationLost,
      subLocationLostFr: subLocationLostFr ?? this.subLocationLostFr,
      subcategory: subcategory ?? this.subcategory,
      subcategoryFr: subcategoryFr ?? this.subcategoryFr,
      type: type ?? this.type,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }
}
