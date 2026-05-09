import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:safehome/app_user.dart';
import 'package:safehome/home_page.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Convert Firebase User to UserModel
  UserModel? getCurrentUserModel() {
    final user = currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // ============== EMAIL & PASSWORD ==============

  // Sign up with email and password

  Future<UserModel> saveUser(
    dynamic _email,
    dynamic _contact,
    dynamic _lastName,
    dynamic _password,
    dynamic _firstname,
    dynamic _dOBController,
    dynamic _passwordconfirm,
    bool mounted, {
    required email,
    required lastName,
    required password,
    //Personal Information from the Profile page in
    required firstName,
    required passwordconfirm,
    required dobController,
    required contact,
    required context,
  }) async {
    final email = _email.text.trim();
    final contact = _contact.text.trim();
    final lastName = _lastName.text.trim();
    final firstName = _firstname.text.trim();
    final password = _password.text.trim();
    final passwordConfirm = _passwordconfirm.text.trim();
    final dob = _dOBController.text.trim();

    if (email.isEmpty ||
        contact.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty ||
        dob.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
    }

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
    }

    // ✅ Check duplicates
    final exists = await userExists(email: email, contact: contact);
    if (!mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration cancelled")));
    }
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email or phone already exists"),
          backgroundColor: Colors.red,
        ),
      );
    }

    try {
      // 🔐 Create Auth account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;
      debugPrint(uid);

      // 📦 Save profile (NO PASSWORD)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'Contact': contact,
        'firstname': firstName,
        'lastname': lastName,
        'DOB': dob,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registered successfully")));

      Provider.of<UserProvider>(context, listen: false).setUser(
        AppUser(
              uid: uid,
              email: email,
              firstName: firstName,
              lastName: lastName,
              contact: contact,
              createdAt: FieldValue.serverTimestamp().toString(),
            )
            as User,
      );

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => SafeSpace()),
      // );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    }
    return UserModel(
      uid: FirebaseAuth.instance.currentUser!.uid,
      email: email,
      provider: 'email',
    );
  }

  Future<bool> userExists({
    required String email,
    required String contact,
  }) async {
    final emailQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (emailQuery.docs.isNotEmpty) {
      return true;
    }

    final phoneQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Contact', isEqualTo: contact)
        .limit(1)
        .get();

    return phoneQuery.docs.isNotEmpty;
  }
  // Sign in with email and password

  Future<UserModel> loginUser({
    required String email,
    required String password,
    required bool mounted,
    required context,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password required")),
      );
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) {}

      loadUser(context, mounted);
      // await verifyAndNavigate(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SafeSpace()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      String message = "Login failed";
      if (e.code == 'network-request-failed') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your internet connection')),
        );
      }
      if (e.code == 'user-not-found') {
        message = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      }

      if (!mounted) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    return UserModel(uid: '', email: '', provider: '');
  }

  // Load user information
  Future<void> loadUser(BuildContext context, bool mounted) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data()!;
    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).setUser(
      AppUser(
            uid: uid,
            email: data['email'],
            firstName: data['firstname'],
            lastName: data['lastname'],
            contact: data['Contact'],
            createdAt: data['createdAt'].toString(),
          )
          as User,
    );
  }

  // ============== GOOGLE SIGN IN ==============
  Future<UserModel> signInWithGoogle(BuildContext context, bool mounted) async {
    try {
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

      // if (googleUser == null) {
      //   debugPrint("Google sign in cancelled by user");
      //   return;
      // }

      debugPrint("Google user obtained: ${googleUser.email}");

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint("Access Token: ${googleAuth.accessToken}");
      debugPrint("ID Token: ${googleAuth.idToken}");

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
        } else {
          debugPrint("Existing user - updating last sign in");
          // Update existing user
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastSignIn': FieldValue.serverTimestamp()});
        }

        if (!mounted) {}
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SafeSpace()),
        );
      } else {
        debugPrint("No user after authentication");
      }
    } catch (e) {
      debugPrint("Error during sign-in: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return UserModel(uid: '', email: '', provider: '');
  }

  // ============== TWITTER (X) SIGN IN ==============
  Future<UserModel> signInWithTwitter(
    BuildContext context,
    bool mounted,
  ) async {
    try {
      final twitterProvider = TwitterAuthProvider();

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithProvider(twitterProvider);

      final User? user = userCredential.user;

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
        } else {
          debugPrint("Existing Twitter user - updating last sign in");
          // Update existing user
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastSignIn': FieldValue.serverTimestamp()});
        }

        if (!mounted) {}
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SafeSpace()),
        );
      } else {
        debugPrint("No user after Twitter authentication");
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
    }
    return UserModel(uid: '', email: '', provider: '');
  }

  // ============== PHONE AUTHENTICATION ==============

  Future<UserModel> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(UserModel user) verificationCompleted,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return UserModel(uid: '', email: '', provider: 'phone');
  }

  Future<UserModel> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      bool mounted = true;

      var context;
      await _handlePhoneUser(user, context!, mounted);
    }

    await _firebaseAuth.signInWithCredential(credential);
    return UserModel.fromFirebaseUser(user!);
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

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  //Signout
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Handle Firebase errors
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

extension on GoogleSignInAuthentication {
  get accessToken => null;
}
