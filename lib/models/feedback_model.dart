import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final String feedbackId;
  final String userId;
  final String userEmail;
  final String username;
  final String type; // 'bug_report', 'feature_request', 'general_feedback', 'app_review'
  final String category; // 'ui_ux', 'performance', 'functionality', 'content', 'other'
  final String title;
  final String description;
  final int rating; // 1-5 stars for app review type
  final String priority; // 'low', 'medium', 'high', 'critical'
  final String status; // 'pending', 'in_review', 'in_progress', 'resolved', 'closed'
  final List<String> attachments; // URLs to screenshots or other files
  final String deviceInfo; // Device model, OS version, app version
  final String appVersion;
  final String? adminResponse; // Response from admin/developer
  final Timestamp? resolvedAt;
  final String? resolvedBy; // Admin ID who resolved it
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool isAnonymous; // Whether user wants to remain anonymous
  final String? contactPreference; // 'email', 'in_app', 'none'
  final Map<String, dynamic>? metadata; // Additional data like user actions, screens visited, etc.

  Feedback({
    required this.feedbackId,
    required this.userId,
    required this.userEmail,
    required this.username,
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    this.rating = 0,
    this.priority = 'medium',
    this.status = 'pending',
    this.attachments = const [],
    this.deviceInfo = '',
    this.appVersion = '',
    this.adminResponse,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.isAnonymous = false,
    this.contactPreference,
    this.metadata,
  });

  factory Feedback.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Feedback(
      feedbackId: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      username: data['username'] ?? '',
      type: data['type'] ?? 'general_feedback',
      category: data['category'] ?? 'other',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      rating: data['rating'] ?? 0,
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'pending',
      attachments: List<String>.from(data['attachments'] ?? []),
      deviceInfo: data['deviceInfo'] ?? '',
      appVersion: data['appVersion'] ?? '',
      adminResponse: data['adminResponse'],
      resolvedAt: data['resolvedAt'],
      resolvedBy: data['resolvedBy'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      isAnonymous: data['isAnonymous'] ?? false,
      contactPreference: data['contactPreference'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'username': username,
      'type': type,
      'category': category,
      'title': title,
      'description': description,
      'rating': rating,
      'priority': priority,
      'status': status,
      'attachments': attachments,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'adminResponse': adminResponse,
      'resolvedAt': resolvedAt,
      'resolvedBy': resolvedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isAnonymous': isAnonymous,
      'contactPreference': contactPreference,
      'metadata': metadata,
    };
  }

  // Helper method to create a copy with updated fields
  Feedback copyWith({
    String? feedbackId,
    String? userId,
    String? userEmail,
    String? username,
    String? type,
    String? category,
    String? title,
    String? description,
    int? rating,
    String? priority,
    String? status,
    List<String>? attachments,
    String? deviceInfo,
    String? appVersion,
    String? adminResponse,
    Timestamp? resolvedAt,
    String? resolvedBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isAnonymous,
    String? contactPreference,
    Map<String, dynamic>? metadata,
  }) {
    return Feedback(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      username: username ?? this.username,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
      adminResponse: adminResponse ?? this.adminResponse,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      contactPreference: contactPreference ?? this.contactPreference,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper method to check if feedback is resolved
  bool get isResolved => status == 'resolved' || status == 'closed';

  // Helper method to get priority color (for UI)
  String get priorityColor {
    switch (priority) {
      case 'critical':
        return '#FF0000'; // Red
      case 'high':
        return '#FF6B35'; // Orange
      case 'medium':
        return '#FFD23F'; // Yellow
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Helper method to get status color (for UI)
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'in_review':
        return '#2196F3'; // Blue
      case 'in_progress':
        return '#9C27B0'; // Purple
      case 'resolved':
        return '#4CAF50'; // Green
      case 'closed':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }
} 