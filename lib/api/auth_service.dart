// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safehome/home_page.dart';
import 'package:safehome/models/Emergency_contact_model.dart';
import 'package:safehome/profile/profile.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthService() {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign Up with Email/Password
  Future<bool> signUp({
    required String firstname,
    required String lastname,
    required String email,
    required String contact,
    required String dob,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user in Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName("$firstname $lastname");

      // Register with Laravel backend
      final response = await _apiService.firebaseSignup(
        firstname: firstname,
        lastname: lastname,
        email: email,
        contact: contact,
        dob: dob,
        password: password,
      );

      _userData = response['data']['user'];
      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Firebase authentication error';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign In with Email/Password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      debugPrint("Attempting to sign in with email: $email");
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
        "Firebase sign in successful for user: ${userCredential.user?.email}",
      );
      // Login to Laravel backend
      final response = await _apiService.firebaseLogin(
        email: email,
        password: password,
      );
      debugPrint("Laravel login response: $response");
      _userData = response['data']['user'];
      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Firebase authentication error';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //Update the profile
  Future<bool> _handleUpdateProfile(
    String updated,
    String textLabel,
    String updateData,
  ) async {
    try {
      debugPrint("trying to Update the user profile");

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({textLabel: updated})
          .then(
            (value) => {
              ScaffoldMessenger.of(context!).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.white,

                  content: Text(
                    "Profile Updated",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Navigator.push(
                context!,
                MaterialPageRoute(builder: (context) => Profile()),
              ),
              debugPrint("Profile Updated"),
            },
          );

      final response = _apiService.updateProfile(
        textLabel: textLabel,
        updateData: updateData,
        updated: updated,
        id: _user?.uid,
      );

      debugPrint("Profile Update response $response");
      return true;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }

  // Sign In with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final serverClientId =
          "1023303544342-jntf37igfkq46u585boac4a4umqqo4g5.apps.googleusercontent.com";
      final clientID =
          "1023303544342-7q4rfin60qd1tds4qb3u4gvqq6kh46dg.apps.googleusercontent.com";

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      unawaited(
        googleSignIn.initialize(
          clientId: clientID,
          serverClientId: serverClientId,
        ),
      );
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      debugPrint("Error before authentication");

      debugPrint("Google user obtained: ${googleUser.email}");

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint("Access Token: ${googleAuth.accessToken}");
      debugPrint("ID Token: ${googleAuth.idToken}");

      // Create Firebase credential
      final credential2 = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential2 = await _firebaseAuth.signInWithCredential(
        credential2,
      );
      // Get Firebase ID token
      final firebaseToken1 = await userCredential2.user?.getIdToken();

      if (firebaseToken1 == null) {
        throw Exception('Failed to get Firebase token');
      }

      // Send to Laravel backend
      final response = await _apiService.socialLogin(
        firebaseToken: firebaseToken1,
        provider: 'google',
      );

      _userData = response['data']['user'];
      _user = userCredential2.user;
      _isLoading = false;
      notifyListeners();

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("Credential created successfully");

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user is new or existing
        debugPrint("User Available: ${user.uid}");
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .limit(1)
            .get();
        final List<DocumentSnapshot> documents = result.docs;

        if (documents.isEmpty) {
          debugPrint("New user - creating document");
          // New user, create a new document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'firstname': user.displayName,
                'email': user.email,
                'uid': user.uid,
                'provider': 'google',
                'photoURL': user.photoURL,
                'createdAt': FieldValue.serverTimestamp(),
              });
          return true;
        } else {
          debugPrint("Existing user - updating last sign in");
          // Update existing user
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastSignIn': FieldValue.serverTimestamp()});
          return true;
        }
      } else {
        debugPrint("No user after authentication");
        return false;
      }
    } catch (e) {
      debugPrint("Error during sign-in: $e");
      bool mounted = true;
      if (mounted) {
        //BuildContext context = context;
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Failed to send reset email';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Logout from Laravel
      await _apiService.logout();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google
      //await _googleSignIn.signOut();

      _user = null;
      _userData = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user data from Laravel
  Future<void> fetchUserData() async {
    try {
      final response = await _apiService.getUser();
      _userData = response['data'];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signInWithTwitter(BuildContext context, bool mounted) async {
    try {
      final twitterProvider = TwitterAuthProvider();

      //Twitter sign in
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithProvider(twitterProvider);

      final User? user = userCredential.user;
      // Get Firebase ID token
      final firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        debugPrint("Failed to obtain  the Firebase token");
        throw Exception("Failed to obtain  the Firebase token");
      }

      // Send to Laravel backend
      final response = await _apiService.socialLogin(
        firebaseToken: firebaseToken,
        provider: 'twitter',
      );

      _userData = response['data']['user'];
      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      if (user != null) {
        debugPrint("Twitter user available: ${user.uid}");

        // Check if user is new or existing
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .limit(1)
            .get();
        final List<DocumentSnapshot> documents = result.docs;

        if (documents.isEmpty) {
          debugPrint("New Twitter user - creating document");
          // New user, create a new document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'firstname': user.displayName,
                'email': user.email,
                'uid': user.uid,
                'provider': 'twitter',
                'photoURL': user.photoURL,
                'createdAt': FieldValue.serverTimestamp(),
              });
          return true;
        } else {
          debugPrint("Existing Twitter user - updating last sign in");
          // Update existing user
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastSignIn': FieldValue.serverTimestamp()});
          return true;
        }
      } else {
        debugPrint("No user after Twitter authentication");
        return false;
      }
    } catch (e) {
      debugPrint("Error during Twitter sign-in: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Twitter sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> signInWithOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    final User? user = userCredential.user;

    // Get Firebase ID token
    final firebaseToken = await userCredential.user?.getIdToken();
    if (firebaseToken == null) {
      debugPrint("Failed to obtain  the Firebase token");
      throw Exception("Failed to obtain  the Firebase token");
    }
    // Send to Laravel backend
    final response = await _apiService.socialLogin(
      firebaseToken: firebaseToken,
      provider: 'phone',
    );
    _userData = response['data']['user'];
    _user = userCredential.user;
    _isLoading = false;
    notifyListeners();
    if (user != null) {
      debugPrint("Phone user available: ${user.uid}");
      // Check if user is new or existing
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();
      final List<DocumentSnapshot> documents = result.docs;

      if (documents.isEmpty) {
        debugPrint("New phone user - creating document");
        // New user, create a new document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phoneNumber': user.phoneNumber,
          'uid': user.uid,
          'provider': 'phone',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        debugPrint("Existing phone user - updating last sign in");
        // Update existing user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastSignIn': FieldValue.serverTimestamp()});
        return true;
      }

      // await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      debugPrint("No phone user found");
      return false;
    }
  }

  Future<void> _handlePhoneUser(
    User user,
    BuildContext context,
    bool mounted,
  ) async {
    debugPrint("Phone user available: ${user.uid}");
    // Check if user is new or existing
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      debugPrint("New phone user - creating document");
      // New user, create a new document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phoneNumber': user.phoneNumber,
        'uid': user.uid,
        'provider': 'phone',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      debugPrint("Existing phone user - updating last sign in");
      // Update existing user
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'lastSignIn': FieldValue.serverTimestamp()},
      );
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SafeSpace()),
    );
  }

  Future<bool> saveReportWithUser({
    required String reportTime,
    required String date,
    required String location,
    required String incident,
    required String contact,
  }) async {
    try {
      debugPrint("Attempting to Save the report");
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      // Login to Laravel backend
      final response = await _apiService.saveReportWithUser(
        reportTime: reportTime,
        date: date,
        location: location,
        incident: incident,
        contact: contact,
      );
      debugPrint("Laravel report response: $response");
      _userData = response['data']['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> saveEmergencyContact({
    required String userid,
    required String contactName,
    required String contactNumber,
  }) async {
    try {
      debugPrint("Attempting to save emergency contact");
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      // Login to Laravel backend
      final response = await _apiService.add_emergencyContacts(
        userid: userid,
        contactName: contactName,
        contactNumber: contactNumber,
      );
      debugPrint("Laravel emergency contact response: $response");
      _userData = response['data']['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  List<EmergencyContact> _emergencyContacts = [];
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;

  Future<bool> obtain_emergency_contacts(String uid) async {
    try {
      debugPrint('Attempting to obtain emergency contacts: $_userData');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final response = await _apiService.obtain_emergencyContacts(uid);
      debugPrint("Laravel emergency contacts response: $response");
      _emergencyContacts = (response['data'] as List)
          .map((e) => EmergencyContact.fromJson(e))
          .toList();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //Deleting the emergency contact
  Future<bool> delete_emergency_contact(int contactId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.delete_emergencyContact(contactId);

      // Remove from local list without re-fetching from API
      _emergencyContacts.removeWhere((contact) => contact.id == contactId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

extension on AuthService {
  BuildContext? get context => null;
}

extension on GoogleSignInAuthentication {
  get accessToken => null;
}
