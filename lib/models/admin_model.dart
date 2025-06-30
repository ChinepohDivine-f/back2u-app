import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String email;
  final String name;
  final String role;
  final String phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> permissions;
  final String? department;
  final String? location;

  Admin({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.permissions,
    this.department,
    this.location,
  });

  // Create Admin from Firestore document
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Admin(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      permissions: List<String>.from(data['permissions'] ?? []),
      department: data['department'],
      location: data['location'],
    );
  }

  // Convert Admin to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'permissions': permissions,
      'department': department,
      'location': location,
    };
  }

  // Create Admin from Map
  factory Admin.fromMap(Map<String, dynamic> map, String id) {
    return Admin(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      permissions: List<String>.from(map['permissions'] ?? []),
      department: map['department'],
      location: map['location'],
    );
  }

  // Convert Admin to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'permissions': permissions,
      'department': department,
      'location': location,
    };
  }

  // Copy Admin with new values
  Admin copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? permissions,
    String? department,
    String? location,
  }) {
    return Admin(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
      department: department ?? this.department,
      location: location ?? this.location,
    );
  }

  // Check if admin has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'super_admin';
  }

  // Check if admin can verify reports
  bool canVerifyReports() {
    return hasPermission('verify_reports') || role == 'super_admin';
  }

  // Check if admin can manage users
  bool canManageUsers() {
    return hasPermission('manage_users') || role == 'super_admin';
  }

  // Check if admin can view analytics
  bool canViewAnalytics() {
    return hasPermission('view_analytics') || role == 'super_admin';
  }

  // Check if admin is super admin
  bool get isSuperAdmin => role == 'super_admin';

  @override
  String toString() {
    return 'Admin(id: $id, email: $email, name: $name, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 