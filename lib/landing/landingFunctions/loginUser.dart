import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/app_user.dart';
import '../../home_page.dart';

Future<void> loginUser(
  BuildContext context,
  bool mounted,
  String email,
  String password,
) async {
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email and password required")),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!mounted) return;

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

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
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
