import 'package:cloud_firestore/cloud_firestore.dart';

class Claim {
  final String claimId;
  final String reportId;
  final String claimerId;
  final String ownerId;
  final String type; // 'lost' or 'found'
  final String status; // 'pending', 'accepted', 'rejected'
  final Timestamp createdAt;
  final List<String> photoUrls; // URLs to images on Cloudinary
  final String message; // Optional message from claimer

  Claim({
    required this.claimId,
    required this.reportId,
    required this.claimerId,
    required this.ownerId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.photoUrls = const [],
    this.message = '',
  });

  factory Claim.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Claim(
      claimId: doc.id,
      reportId: data['reportId'],
      claimerId: data['claimerId'],
      ownerId: data['ownerId'],
      type: data['type'],
      status: data['status'],
      createdAt: data['createdAt'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      message: data['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'claimerId': claimerId,
      'ownerId': ownerId,
      'type': type,
      'status': status,
      'createdAt': createdAt,
      'photoUrls': photoUrls,
      'message': message,
    };
  }
} 