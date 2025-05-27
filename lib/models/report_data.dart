// lib/models/report_data.dart
import 'package:flutter/material.dart'; // Just for context, not strictly needed for model

class ReportData {
  final String ownerName;
  final String subCategory;
  final String type; // 'Lost' or 'Found'
  final String location;
  final String? subLocation;
  final String? description;
  final DateTime incidentDate;
  final int imageCount;
  final bool isResolved;
  final double? rewardAmount;

  // Contact Details fields
  final String? contactName;
  final String? phoneNumber;
  final String? whatsappNumber;
  final bool requiresKycForContact; // Set to true if KYC is needed to view contact info

  ReportData({
    required this.ownerName,
    required this.subCategory,
    required this.type,
    required this.location,
    this.subLocation,
    this.description,
    required this.incidentDate,
    this.imageCount = 0,
    this.isResolved = false,
    this.rewardAmount,
    this.contactName,
    this.phoneNumber,
    this.whatsappNumber,
    this.requiresKycForContact = false, // Default to false if not specified
  });
}