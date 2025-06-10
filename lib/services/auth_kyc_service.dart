import 'dart:io';
import 'package:flutter/material.dart'; // Add for ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back2u/models/user_model.dart'; // Ensure this path is correct

// Make AuthKycService a ChangeNotifier
class AuthKycService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Firestore path for user profiles
  static const String _userCollectionPath = 'back2u/countries/cameroon/data/users';

  // Internal state for current user and profile
  User? _currentUser;
  AppUser? _appUser;
  bool _isLoadingAuth = true; // Overall loading state for auth/user profile

  // Public getters for the state
  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  bool get isLoadingAuth => _isLoadingAuth; // Use this for UI loading indicators
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isAnonymous;
  bool get kycCompleted => _appUser?.kycCompleted ?? false; // Convenience getter

  // Constructor: Set up auth state listener
  AuthKycService() {
    _auth.authStateChanges().listen((user) async {
      _currentUser = user;
      _isLoadingAuth = true; // Set loading true while profile is being fetched
      notifyListeners(); // Notify immediately that user state (logged in/out) has changed

      if (user != null) {
        await _fetchUserProfile(user.uid);
      } else {
        _appUser = null; // Clear app user if logged out
      }
      _isLoadingAuth = false; // Reset loading
      notifyListeners(); // Notify again after profile fetch or clearing
    });
  }

  // Stream to listen to authentication state changes (still useful for some cases)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user UID
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign in anonymously (if still needed)
  Future<UserCredential> signInAnonymously() async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final result = await _auth.signInAnonymously();
      // State updated by authStateChanges listener
      return result;
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    } finally {
      _isLoadingAuth = false; // Re-evaluate if listener has handled it
      notifyListeners();
    }
  }

  // Sign in with Google - Handles both new user creation and existing user sign-in
  Future<User?> signInWithGoogle() async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoadingAuth = false;
        notifyListeners();
        return null; // User cancelled the sign-in process
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential;
      try {
        if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
          userCredential = await _auth.currentUser!.linkWithCredential(credential);
          print('Anonymous account linked with Google successfully!');
        } else {
          userCredential = await _auth.signInWithCredential(credential);
          print('Signed in with Google successfully!');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          print('Error: credential-already-in-use. Attempting to sign in with existing user.');
          userCredential = await _auth.signInWithCredential(credential); // Try direct sign-in
        } else {
          print('Error during Google sign-in: ${e.code} - ${e.message}');
          rethrow;
        }
      } catch (e) {
        print('Unexpected error during Google sign-in: $e');
        rethrow;
      }

      final User? user = userCredential.user;
      if (user != null) {
        await _checkAndCreateUserProfile(user); // Ensure profile exists
      }
      // State will be updated by authStateChanges listener
      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    } finally {
      // If error occurred before listener could update, ensure loading is off.
      // Otherwise, listener will set it.
      if (_currentUser == null) {
        _isLoadingAuth = false;
        notifyListeners();
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('User signed out.');
      // State updated by authStateChanges listener
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  // Internal method to fetch user profile
  Future<void> _fetchUserProfile(String uid) async {
    try {
      final docSnapshot = await _db.collection(_userCollectionPath).doc(uid).get();
      if (docSnapshot.exists) {
        _appUser = AppUser.fromFirestore(docSnapshot);
      } else {
        _appUser = null; // User profile might not exist yet (new user)
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      _appUser = null;
    }
  }

  // Public method to explicitly refresh the AppUser profile (e.g., after KYC)
  Future<void> refreshUserProfile() async {
    if (_currentUser != null) {
      _isLoadingAuth = true;
      notifyListeners();
      await _fetchUserProfile(_currentUser!.uid);
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  // Checks if a user's profile exists in Firestore and creates it if not.
  Future<void> _checkAndCreateUserProfile(User user) async {
    final userRef = _db.collection(_userCollectionPath).doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      final newAppUser = AppUser.fromFirebaseUser(user);
      await userRef.set(newAppUser.toFirestore());
      print('New user profile created in Firestore for ${user.uid} with kycCompleted: false');
      // Update local state and notify after creating profile
      _appUser = newAppUser;
      notifyListeners();
    } else {
      print('User profile already exists for ${user.uid}');
      // Also ensure local _appUser is up-to-date if it was already fetched.
      // This is primarily handled by _fetchUserProfile called from authStateChanges.
    }
  }

  // Get user profile from Firestore (public method, primarily for internal use by provider)
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
  Future<void> updateKycData({
    required String uid,
    required String phone,
    required String whatsappNumber,
    required String accountNameOnId,
    String? profileImageUrl,
    String? idCardFrontUrl,
    String? idCardBackUrl,
  }) async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final userRef = _db.collection(_userCollectionPath).doc(uid);
      await userRef.update({
        'phone': phone,
        'whatsappNumber': whatsappNumber,
        'accountNameOnId': accountNameOnId,
        'profileImageUrl': profileImageUrl,
        'idCardFrontUrl': idCardFrontUrl,
        'idCardBackUrl': idCardBackUrl,
        'kycCompleted': true,
        'updatedAt': Timestamp.now(),
      });
      print('KYC data updated successfully for user $uid. KYC now complete.');
      // Refresh local appUser state and notify
      await _fetchUserProfile(uid); // Re-fetch to update _appUser in provider
    } catch (e) {
      print('Error updating KYC data: $e');
      rethrow;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
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