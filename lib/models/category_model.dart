import 'package:cloud_firestore/cloud_firestore.dart';

class SubCategory {
  final String categoryId;
  final Timestamp createdAt;
  final String nameEn;
  final String nameFr;
  final String subCategoryId;
  final Timestamp updatedAt;

  SubCategory({
    required this.categoryId,
    required this.createdAt,
    required this.nameEn,
    required this.nameFr,
    required this.subCategoryId,
    required this.updatedAt,
  });

  factory SubCategory.fromFirestore(Map<String, dynamic> data) {
    return SubCategory(
      categoryId: data['categoryId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      nameEn: data['name_en'] ?? '',
      nameFr: data['name_fr'] ?? '',
      subCategoryId: data['subCategoryId'] ?? '',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'createdAt': createdAt,
      'name_en': nameEn,
      'name_fr': nameFr,
      'subCategoryId': subCategoryId,
      'updatedAt': updatedAt,
    };
  }
}

class Category {
  final String categoryId;
  final Timestamp createdAt;
  final String nameEn;
  final String nameFr;
  final List<SubCategory> subcategories;
  final Timestamp updatedAt;


  Category({
    required this.categoryId,
    required this.createdAt,
    required this.nameEn,
    required this.nameFr,
    required this.subcategories,
    required this.updatedAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Category(
      categoryId: data['categoryId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      nameEn: data['name_en'] ?? '',
      nameFr: data['name_fr'] ?? '',
      subcategories: (data['subcategories'] as List? ?? [])
          .map((subCatData) => SubCategory.fromFirestore(subCatData as Map<String, dynamic>))
          .toList(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'createdAt': createdAt,
      'name_en': nameEn,
      'name_fr': nameFr,
      'subcategories': subcategories.map((subCat) => subCat.toFirestore()).toList(),
      'updatedAt': updatedAt,
    };
  }
}