import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final Timestamp createdAt;
  final String email;
  final Timestamp joinedDate;
  final String lastLogin;
  final String phone;
  final List<String> profileImage;
  final List<String> savedReports; // Assuming savedReports store report IDs
  final Timestamp updatedAt;
  final String userId;
  final String userStatus; // This seems to be a profile image URL in your sample
  final String username;
  final String whatsappNumber;

  AppUser({
    required this.createdAt,
    required this.email,
    required this.joinedDate,
    required this.lastLogin,
    required this.phone,
    required this.profileImage,
    required this.savedReports,
    required this.updatedAt,
    required this.userId,
    required this.userStatus,
    required this.username,
    required this.whatsappNumber,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppUser(
      createdAt: data['createdAt'] ?? Timestamp.now(),
      email: data['email'] ?? '',
      joinedDate: data['joinedDate'] ?? Timestamp.now(),
      lastLogin: data['lastLogin'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: List<String>.from(data['profileImage'] ?? []),
      savedReports: List<String>.from(data['savedReports'] ?? []),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
      userStatus: data['userStatus'] ?? '',
      username: data['username'] ?? '',
      whatsappNumber: data['whatsappNumber'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt,
      'email': email,
      'joinedDate': joinedDate,
      'lastLogin': lastLogin,
      'phone': phone,
      'profileImage': profileImage,
      'savedReports': savedReports,
      'updatedAt': updatedAt,
      'userId': userId,
      'userStatus': userStatus,
      'username': username,
      'whatsappNumber': whatsappNumber,
    };
  }
}