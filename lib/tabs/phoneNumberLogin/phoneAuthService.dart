import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safehome/home_page.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BuildContext? get context => null;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
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

  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      bool mounted = true;

      await _handlePhoneUser(user, context!, mounted);
    }

    await _auth.signInWithCredential(credential);
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
}
