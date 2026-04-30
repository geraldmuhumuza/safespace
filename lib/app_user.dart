import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String contact;
  final String createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.contact,
    required this.createdAt,
  });
}

class UserProvider with ChangeNotifier {
  User? _user;
  AppUser? _appUser;
  User? get user => _user;
  AppUser? get appUser => _appUser;

  void setUser(User user) {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
