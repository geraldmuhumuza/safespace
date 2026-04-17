// ignore_for_file: unused_import

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:safehome/main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../home_page.dart';

Future<void> openDialer(String phoneNumber) async {
  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not open dialer';
  }
}

Future<void> signInAnonymously(BuildContext context) async {
  try {
    // UserCredential userCredential = await FirebaseAuth.instance
    //     .signInAnonymously();

    // User? user = userCredential.user;
    FirebaseAuth.instance.signInAnonymously();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SafeSpace()),
    );
    SnackBar(content: Text("You have signed in anonymously"));
  } on FirebaseAuthException catch (e) {
    debugPrint("Error: ${e.message}");
  }
}

Future<void> loginAnonymous(BuildContext context) async {
  FirebaseAuth.instance.signInAnonymously();

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SafeSpace()),
  );
}

Future<void> signInWithTwitter(BuildContext context, bool mounted) async {
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
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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

      if (!mounted) return;
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
}
