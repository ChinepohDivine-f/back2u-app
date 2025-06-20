import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type

class AppUser {
  final String userId; // Firebase Auth UID
  final String email;
  final String username;
  final String? phone;
  final String? whatsappNumber;
  final bool phoneVerified;
  final String? profileImageUrl; // Changed from List<String> to single String URL
  final String? accountNameOnId; // New field for KYC
  final bool kycCompleted; // New field to track KYC status
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? joinedDate; // Can be null if not explicitly set
  final String? lastLogin; // Can be null or 'Active'

  // Assuming savedReports stores report IDs
  final List<String> savedReports;

  AppUser({
    required this.userId,
    required this.email,
    required this.username,
    this.phone,
    this.whatsappNumber,
    this.phoneVerified = false,
    this.profileImageUrl,
    this.accountNameOnId,
    this.kycCompleted = false, // Default to false
    required this.createdAt,
    required this.updatedAt,
    this.joinedDate,
    this.lastLogin,
    this.savedReports = const [],
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      userId: doc.id, // Document ID is the userId
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      phone: data['phone'],
      phoneVerified: data['phoneVerified'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      accountNameOnId: data['accountNameOnId'],
      kycCompleted: data['kycCompleted'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      joinedDate: data['joinedDate'],
      lastLogin: data['lastLogin'],
      savedReports: List<String>.from(data['savedReports'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'phoneVerified': phoneVerified,
      'profileImageUrl': profileImageUrl,
      'accountNameOnId': accountNameOnId,
      'kycCompleted': kycCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'joinedDate': joinedDate,
      'lastLogin': lastLogin,
      'savedReports': savedReports,
    };
  }

  // Helper to create a new user from Firebase User object
  // kycCompleted is explicitly set to false for new users here
  static AppUser fromFirebaseUser(User user) {
    return AppUser(
      userId: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? 'New User',
      profileImageUrl: user.photoURL,
      phoneVerified: user.phoneNumber != null, // Consider phone verified if user has a phone number
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      joinedDate: Timestamp.now(),
      lastLogin: 'Active',
      kycCompleted: false, // New users start with KYC incomplete
    );
  }
}