import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../home_page.dart';

// clientID -> 1023303544342-6cumend5keu1vcju9tfh9qt8tsd81np9.apps.googleusercontent.com
// server -> 1023303544342-jntf37igfkq46u585boac4a4umqqo4g5.apps.googleusercontent.com

Future<void> signInWithGoogle(BuildContext context, bool mounted) async {
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
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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

      if (!mounted) return;
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
}

extension on GoogleSignInAuthentication {
  String? get accessToken => null;
}
