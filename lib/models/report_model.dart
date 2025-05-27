import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? ownerName;
  final String category;
  final String categoryFr;
  final String contactPhone;
  final Timestamp dateOfLoss;
  final String documentName;
  final List<String> images;
  final Timestamp? lastKnownStatusUpdate;
  final String locationLost;
  final String locationLostFr;
  final String notes;
  final Timestamp reportDate;
  final String reportId;
  final String reporterId;
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
    required this.dateOfLoss,
    required this.documentName,
    required this.images,
    this.lastKnownStatusUpdate,
    required this.locationLost,
    required this.locationLostFr,
    required this.notes,
    required this.reportDate,
    required this.reportId,
    required this.reporterId,
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
      dateOfLoss: data['date_of_loss'] ?? Timestamp.now(),
      documentName: data['document_name'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      lastKnownStatusUpdate: data['last_known_status_update'],
      locationLost: data['location_lost'] ?? '',
      locationLostFr: data['location_lost_fr'] ?? '',
      notes: data['notes'] ?? '',
      reportDate: data['report_date'] ?? Timestamp.now(),
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
      'date_of_loss': dateOfLoss,
      'document_name': documentName,
      'images': images,
      if (lastKnownStatusUpdate != null)
        'last_known_status_update': lastKnownStatusUpdate,
      'location_lost': locationLost,
      'location_lost_fr': locationLostFr,
      'notes': notes,
      'report_date': reportDate,
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
}