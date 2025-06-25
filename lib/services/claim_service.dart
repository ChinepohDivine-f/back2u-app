import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/claim_model.dart';

class ClaimService {
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'back2u/countries/cameroon/data/claims';

  Future<void> createClaim(Claim claim) async {
    await _firestore.collection(_collection).add(claim.toMap());
  }

  Future<List<Claim>> getClaimsForUser(String userId) async {
    final query = await _firestore
        .collection(_collection)
        .where('claimerId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => Claim.fromFirestore(doc)).toList();
  }

  Future<List<Claim>> getClaimsForOwner(String ownerId) async {
    final query = await _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return query.docs.map((doc) => Claim.fromFirestore(doc)).toList();
  }

  Future<void> updateClaimStatus(String claimId, String status, {String? reviewerId, String? decisionMessage}) async {
    await _firestore.collection(_collection).doc(claimId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewerId': reviewerId,
      'decisionMessage': decisionMessage,
    });
  }

  Future<void> deleteClaim(String claimId) async {
    await _firestore.collection(_collection).doc(claimId).delete();
  }
} 