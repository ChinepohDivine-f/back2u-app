import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/feedback_model.dart';

class FeedbackService {
  final CollectionReference _baseCollection =
      FirebaseFirestore.instance.collection('back2u/countries/cameroon/data/feedback');

  // Submit feedback to Firebase under 'feedback/{userId}/{autoId}'
  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      final userId = feedback.userId.isNotEmpty ? feedback.userId : 'anonymous';
      final userFeedbackCollection = _baseCollection.doc(userId).collection('feedback');
      await userFeedbackCollection.add(feedback.toFirestore());
    } catch (e) {
      // In a real app, you'd want more robust error handling
      print('Error submitting feedback: $e');
      throw Exception('Failed to submit feedback. $e');
    }
  }

  // Fetch feedback for a user, sorted by createdAt descending
  Future<List<FeedbackModel>> getFeedbackForUser(String userId) async {
    final userFeedbackCollection = _baseCollection.doc(userId).collection('feedback');
    final query = await userFeedbackCollection.orderBy('createdAt', descending: true).get();
    return query.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();
  }
} 