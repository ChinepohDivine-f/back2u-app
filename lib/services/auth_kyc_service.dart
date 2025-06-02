import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back2u/models/user_model.dart'; // Ensure this path is correct

class AuthKycService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Firestore path for user profiles
  // This path assumes a collection 'users' directly under 'cameroon/data'
  static const String _userCollectionPath = 'back2u/countries/cameroon/data/users';

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user UID
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign in anonymously (if still needed for onboarding or initial app launch)
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  // Sign in with Google - Handles both new user creation and existing user sign-in
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled the sign-in process
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential;
      try {
        // Check if there's an existing anonymous user to link
        if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
          // Link the anonymous Firebase account to the Google account
          userCredential = await _auth.currentUser!.linkWithCredential(credential);
          print('Anonymous account linked with Google successfully!');
        } else {
          // Sign in directly with Google (Firebase handles creating a new user or signing in existing)
          userCredential = await _auth.signInWithCredential(credential);
          print('Signed in with Google successfully!');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          print('Error: credential-already-in-use. Attempting to sign in with existing user.');
          // If the credential is already in use, it means the Google account is
          // already linked to a Firebase user. We need to sign in with that user.
          // This typically means signing in with the credential will still work,
          // but the error is thrown if a LINKING operation failed because it's already linked.
          // The most robust way to handle this is to try signing in with the credential directly.
          try {
            userCredential = await _auth.signInWithCredential(credential);
            print('Successfully signed in with the existing user associated with this Google credential.');
          } catch (signInError) {
            print('Error signing in with existing user after credential-already-in-use: $signInError');
            rethrow; // Re-throw if even direct sign-in fails
          }
        } else {
          print('Error during Google sign-in: ${e.code} - ${e.message}');
          rethrow; // Re-throw other FirebaseAuthExceptions
        }
      } catch (e) {
        print('Unexpected error during Google sign-in: $e');
        rethrow; // Re-throw any other exceptions
      }

      final User? user = userCredential.user;

      if (user != null) {
        // This crucial step ensures a corresponding AppUser profile exists in Firestore.
        // It *creates* one if it's a completely new user, or *does nothing* if it already exists.
        await _checkAndCreateUserProfile(user);
      }
      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow; // Re-throw to propagate the error to the UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut(); // Sign out from Firebase
    print('User signed out.');
  }

  // Checks if a user's profile exists in Firestore and creates it if not.
  // This ensures every authenticated Firebase user has an AppUser document.
  Future<void> _checkAndCreateUserProfile(User user) async {
    final userRef = _db.collection(_userCollectionPath).doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      // If the document doesn't exist, create a new AppUser profile.
      // kycCompleted will be false by default for new profiles.
      final newAppUser = AppUser.fromFirebaseUser(user);
      await userRef.set(newAppUser.toFirestore());
      print('New user profile created in Firestore for ${user.uid} with kycCompleted: false');
    } else {
      // If the document already exists, do nothing (use the existing profile).
      print('User profile already exists for ${user.uid}');
    }
  }

  // Get user profile from Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _db.collection(_userCollectionPath).doc(uid).get();
      if (docSnapshot.exists) {
        return AppUser.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile in Firestore (for KYC data)
  // This method will set kycCompleted to true upon successful KYC form submission
  Future<void> updateKycData({
    required String uid,
    required String phone,
    required String whatsappNumber,
    required String accountNameOnId,
    String? profileImageUrl,
    String? idCardFrontUrl,
    String? idCardBackUrl,
  }) async {
    try {
      final userRef = _db.collection(_userCollectionPath).doc(uid);
      await userRef.update({
        'phone': phone,
        'whatsappNumber': whatsappNumber,
        'accountNameOnId': accountNameOnId,
        'profileImageUrl': profileImageUrl,
        'idCardFrontUrl': idCardFrontUrl,
        'idCardBackUrl': idCardBackUrl,
        'kycCompleted': true, // Mark KYC as complete after data is provided
        'updatedAt': Timestamp.now(),
      });
      print('KYC data updated successfully for user $uid. KYC now complete.');
    } catch (e) {
      print('Error updating KYC data: $e');
      rethrow;
    }
  }

  // Pick image from gallery or camera
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded to: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}