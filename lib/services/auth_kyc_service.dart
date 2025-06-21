import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back2u/models/user_model.dart';

class AuthKycService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  static const String _userCollectionPath = 'back2u/countries/cameroon/data/users';

  User? _currentUser;
  AppUser? _appUser;
  bool _isLoadingAuth = true;

  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  bool get isLoadingAuth => _isLoadingAuth;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isAnonymous;
  bool get kycCompleted => _appUser?.verified ?? false;

  AuthKycService() {
    _auth.authStateChanges().listen((user) async {
      _currentUser = user;
      _isLoadingAuth = true;
      notifyListeners();

      if (user != null) {
        await _fetchUserProfile(user.uid);
      } else {
        _appUser = null;
      }
      _isLoadingAuth = false;
      notifyListeners();
    });
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserCredential> signInAnonymously() async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final result = await _auth.signInAnonymously();
      // Anonymous users don't get Firestore profiles
      // They will be redirected to sign in with Google
      print('Anonymous user signed in: ${result.user?.uid}');
      return result;
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  Future<User?> signInWithGoogle() async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoadingAuth = false;
        notifyListeners();
        return null;
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
        } else {
          userCredential = await _auth.signInWithCredential(credential);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          rethrow;
        }
      }

      final User? user = userCredential.user;
      if (user != null) {
        await _checkAndCreateUserProfile(user);
      }
      return user;
    } catch (e) {
      rethrow;
    } finally {
      if (_currentUser == null) {
        _isLoadingAuth = false;
        notifyListeners();
      }
    }
  }

  Future<void> signOut() async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      // Check if current user is anonymous
      if (_currentUser?.isAnonymous == true) {
        _appUser = null;
        return;
      }
      
      final docSnapshot = await _db.collection(_userCollectionPath).doc(uid).get();
      if (docSnapshot.exists) {
        _appUser = AppUser.fromFirestore(docSnapshot);
      } else {
        _appUser = null;
      }
    } catch (e) {
      _appUser = null;
    }
  }

  Future<void> refreshUserProfile() async {
    if (_currentUser != null) {
      _isLoadingAuth = true;
      notifyListeners();
      await _fetchUserProfile(_currentUser!.uid);
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  Future<void> _checkAndCreateUserProfile(User user) async {
    // Don't create profiles for anonymous users
    if (user.isAnonymous) {
      print('Anonymous user detected, skipping Firestore profile creation');
      _appUser = null;
      notifyListeners();
      return;
    }
    
    final userRef = _db.collection(_userCollectionPath).doc(user.uid);
    final docSnapshot = await userRef.get();
    
    if (!docSnapshot.exists) {
      // Only create if user doesn't exist and is not anonymous
      final newAppUser = AppUser.fromFirebaseUser(user);
      await userRef.set(newAppUser.toFirestore());
      print('New user profile created for ${user.uid}');
      _appUser = newAppUser;
    } else {
      // User already exists, load existing profile
      _appUser = AppUser.fromFirestore(docSnapshot);
      print('Existing user profile loaded for ${user.uid}');
    }
    notifyListeners();
  }

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _db.collection(_userCollectionPath).doc(uid).get();
      if (docSnapshot.exists) {
        return AppUser.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserVerification({
    required String uid,
    required String name,
    required String phone,
    required bool verified,
  }) async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final userRef = _db.collection(_userCollectionPath).doc(uid);
      await userRef.update({
        'username': name,
        'phone': phone,
        'verified': verified,
        'updatedAt': Timestamp.now(),
      });
      await _fetchUserProfile(uid);
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _picker.pickImage(source: source);
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Stream<AppUser> getUserProfileStream(String uid) {
    return _db.collection(_userCollectionPath).doc(uid).snapshots().map((doc) => AppUser.fromFirestore(doc));
  }

  Future<void> toggleSavedReport(String uid, String reportId) async {
    final userRef = _db.collection(_userCollectionPath).doc(uid);
    final doc = await userRef.get();
    if (!doc.exists) return;
    final appUser = AppUser.fromFirestore(doc);
    final List<String> currentSaved = List<String>.from(appUser.savedReports);
    final isSaved = currentSaved.contains(reportId);
    await userRef.update({
      'savedReports': isSaved
          ? FieldValue.arrayRemove([reportId])
          : FieldValue.arrayUnion([reportId]),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    if (_currentUser != null) {
      await refreshUserProfile();
    }
    notifyListeners();
  }

  bool get isPhoneVerified => _currentUser?.phoneNumber?.isNotEmpty ?? false;

  Future<bool> isPhoneVerifiedAsync() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.phoneNumber?.isNotEmpty ?? false;
  }

  Future<void> verifyPhoneAndCompleteKyc({
    required String phoneNumber,
    required String accountNameOnId,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.currentUser!.updatePhoneNumber(credential);
        await updateUserVerification(
          uid: _currentUser!.uid,
          name: _currentUser!.displayName ?? '',
          phone: phoneNumber,
          verified: true,
        );
        onVerificationCompleted(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  Future<void> confirmSmsCode({
    required String smsCode,
    required String verificationId,
    required String phoneNumber,
    required String accountNameOnId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.currentUser!.updatePhoneNumber(credential);
      await updateUserVerification(
        uid: _currentUser!.uid,
        name: _currentUser!.displayName ?? '',
        phone: phoneNumber,
        verified: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
