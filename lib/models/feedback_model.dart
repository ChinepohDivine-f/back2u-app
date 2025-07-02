import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String username;
  final String type;
  final String message;
  final DateTime createdAt;
  final String contactPreference;
  final bool isAnonymous;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> appInfo;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    required this.username,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.contactPreference,
    this.isAnonymous = false,
    this.deviceInfo = const {},
    this.appInfo = const {},
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      feedbackId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      type: data['type'] ?? 'general',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contactPreference: data['contactPreference'] ?? 'none',
      isAnonymous: data['isAnonymous'] ?? false,
      deviceInfo: Map<String, dynamic>.from(data['deviceInfo'] ?? {}),
      appInfo: Map<String, dynamic>.from(data['appInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'type': type,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'contactPreference': contactPreference,
      'isAnonymous': isAnonymous,
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
    };
  }
} 