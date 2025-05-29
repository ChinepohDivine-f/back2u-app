import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? ownerName;
  final String category;
  final String categoryFr; // Assuming French translation
  final String contactPhone;
  final Timestamp reportedDate; // Incident Date
  final String documentName; // Can be used for specific item name, e.g., "National ID"
  final List<String> images; // List of image URLs (after upload)
  final Timestamp? updatedAt;
  final String locationLost;
  final String locationLostFr; // Assuming French translation
  final String notes;
  final Timestamp createdAt; // Report Date (set at submission)
  final String reportId; // Unique ID for the report
  final String reporterId; // ID of the user who made the report
  final bool resolved;
  final String reward; // Reward amount as string or number
  final List<String> searchKeyWords;
  final String status;
  final String subLocationLost;
  final String subLocationLostFr; // Assuming French translation
  final String subcategory;
  final String subcategoryFr; // Assuming French translation
  final String type; // "Lost" or "Found"
  final String whatsappNumber;

  Report({
    this.ownerName, // Now nullable
    this.category = '', // Provide default values
    this.categoryFr = '',
    this.contactPhone = '',
    Timestamp? reportedDate, // Make nullable in constructor for initial creation
    this.documentName = '',
    this.images = const [],
    this.updatedAt,
    this.locationLost = '',
    this.locationLostFr = '',
    this.notes = '',
    Timestamp? createdAt, // Make nullable for initial creation
    this.reportId = '',
    this.reporterId = '',
    this.resolved = false,
    this.reward = '',
    this.searchKeyWords = const [],
    this.status = 'active',
    this.subLocationLost = '',
    this.subLocationLostFr = '',
    this.subcategory = '',
    this.subcategoryFr = '',
    this.type = '', // This will be set by ReportPage
    this.whatsappNumber = '',
  }) : reportedDate = reportedDate ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();


  // Factory constructor to create a Report from a Firestore DocumentSnapshot
  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Report(
      ownerName: data['owner_name'],
      category: data['category'] ?? '',
      categoryFr: data['category_fr'] ?? '',
      contactPhone: data['contact_phone'] ?? '',
      reportedDate: data['reported_date'] ?? Timestamp.now(),
      documentName: data['document_name'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      updatedAt: data['updated_at'],
      locationLost: data['location_lost'] ?? '',
      locationLostFr: data['location_lost_fr'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      reportId: data['report_id'] ?? '',
      reporterId: data['reporter_id'] ?? '',
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
      'reported_date': reportedDate,
      'document_name': documentName,
      'images': images,
      if (updatedAt != null) 'updated_at': updatedAt,
      'location_lost': locationLost,
      'location_lost_fr': locationLostFr,
      'notes': notes,
      'created_at': createdAt,
      'report_id': reportId,
      'reporter_id': reporterId,
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

  // Helper method to create a copy with updated values
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