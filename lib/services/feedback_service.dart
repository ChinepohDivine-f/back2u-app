import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:back2u/models/feedback_model.dart';
import 'package:back2u/models/user_model.dart';
import 'package:back2u/services/auth_kyc_service.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthKycService _authService = AuthKycService();

  // Submit feedback to Firebase
  Future<bool> submitFeedback({
    required String type,
    required String category,
    required String title,
    required String description,
    int rating = 0,
    String priority = 'medium',
    List<String> attachments = const [],
    String deviceInfo = '',
    String appVersion = '',
    bool isAnonymous = false,
    String? contactPreference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      AppUser? appUser;
      
      if (currentUser != null && !isAnonymous) {
        appUser = await _authService.getUserProfile(currentUser.uid);
      }

      final feedback = Feedback(
        feedbackId: '',
        userId: currentUser?.uid ?? 'anonymous',
        userEmail: appUser?.email ?? currentUser?.email ?? '',
        username: appUser?.username ?? currentUser?.displayName ?? 'Anonymous User',
        type: type,
        category: category,
        title: title,
        description: description,
        rating: rating,
        priority: priority,
        status: 'pending',
        attachments: attachments,
        deviceInfo: deviceInfo,
        appVersion: appVersion,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isAnonymous: isAnonymous,
        contactPreference: contactPreference,
        metadata: metadata,
      );

      await _firestore
          .collection('countries')
          .doc('cameroon')
          .collection('data')
          .doc('feedback')
          .collection('feedback_submissions')
          .add(feedback.toFirestore());

      return true;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Get feedback submissions (for admin use)
  Future<List<Feedback>> getFeedbackSubmissions({
    String? status,
    String? type,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('countries')
          .doc('cameroon')
          .collection('data')
          .doc('feedback')
          .collection('feedback_submissions')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        return Feedback.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting feedback submissions: $e');
      return [];
    }
  }

  // Update feedback status (for admin use)
  Future<bool> updateFeedbackStatus({
    required String feedbackId,
    required String status,
    String? adminResponse,
    String? resolvedBy,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': Timestamp.now(),
      };

      if (adminResponse != null) {
        updates['adminResponse'] = adminResponse;
      }

      if (status == 'resolved' || status == 'closed') {
        updates['resolvedAt'] = Timestamp.now();
        if (resolvedBy != null) {
          updates['resolvedBy'] = resolvedBy;
        }
      }

      await _firestore
          .collection('countries')
          .doc('cameroon')
          .collection('data')
          .doc('feedback')
          .collection('feedback_submissions')
          .doc(feedbackId)
          .update(updates);

      return true;
    } catch (e) {
      print('Error updating feedback status: $e');
      return false;
    }
  }

  // Get feedback statistics (for admin use)
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('countries')
          .doc('cameroon')
          .collection('data')
          .doc('feedback')
          .collection('feedback_submissions')
          .get();

      final List<Feedback> feedbacks = snapshot.docs
          .map((doc) => Feedback.fromFirestore(doc))
          .toList();

      final Map<String, int> statusCounts = {};
      final Map<String, int> typeCounts = {};
      final Map<String, int> priorityCounts = {};
      int totalRating = 0;
      int ratingCount = 0;

      for (final feedback in feedbacks) {
        // Status counts
        statusCounts[feedback.status] = (statusCounts[feedback.status] ?? 0) + 1;
        
        // Type counts
        typeCounts[feedback.type] = (typeCounts[feedback.type] ?? 0) + 1;
        
        // Priority counts
        priorityCounts[feedback.priority] = (priorityCounts[feedback.priority] ?? 0) + 1;
        
        // Rating average
        if (feedback.rating > 0) {
          totalRating += feedback.rating;
          ratingCount++;
        }
      }

      return {
        'total': feedbacks.length,
        'statusCounts': statusCounts,
        'typeCounts': typeCounts,
        'priorityCounts': priorityCounts,
        'averageRating': ratingCount > 0 ? totalRating / ratingCount : 0,
        'ratingCount': ratingCount,
      };
    } catch (e) {
      print('Error getting feedback stats: $e');
      return {};
    }
  }
} 