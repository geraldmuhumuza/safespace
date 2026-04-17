// // lib/providers/auth_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../repositories/auth_repository.dart';

// enum AuthStatus { uninitialized, authenticated, unauthenticated }

// class AuthProvider extends ChangeNotifier {
//   final AuthRepository _repository;

//   AuthStatus _status = AuthStatus.uninitialized;
//   UserModel? _user;
//   bool _isLoading = false;
//   String? _error;
//   String? _verificationId;

//   AuthProvider(this._repository) {
//     // Listen to auth state changes
//     _repository.authStateChanges.listen(_onAuthStateChanged);
//   }

//   // Getters
//   AuthStatus get status => _status;
//   UserModel? get user => _user;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isAuthenticated => _status == AuthStatus.authenticated;

//   // Handle auth state changes
//   void _onAuthStateChanged(User? firebaseUser) {
//     if (firebaseUser == null) {
//       _user = null;
//       _status = AuthStatus.unauthenticated;
//     } else {
//       _user = UserModel.fromFirebaseUser(firebaseUser);
//       _status = AuthStatus.authenticated;
//     }
//     notifyListeners();
//   }

//   // ============== EMAIL & PASSWORD ==============

//   Future<bool> signUpWithEmail({
//     required String email,
//     required String password,
//     String? displayName,
//     String lastName = '',
//     String firstName = '',
//     String passwordconfirm = '',
//     String dobController = '',
//     String contact = '',
//     String context = '',
//   }) async {
//     return _performAuth(
//       () => _repository.saveUser({
//         email: email,
//         password: password,
//         lastName: lastName,
//         firstName: firstName,
//         passwordconfirm: null,
//         dobController: null,
//         contact: null,
//         context: null,
//       }),
//     );
//   }

//   Future<bool> signInWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     return _performAuth(
//       () => _repository.loginUser(
//         context: null,
//         mounted: true,
//         email: email,
//         password: password,
//       ),
//     );
//   }

//   // ============== GOOGLE SIGN IN ==============

//   Future<bool> signInWithGoogle(BuildContext context) async {
//     return _performAuth(() => _repository.signInWithGoogle(context, true));
//   }

//   // ============== TWITTER SIGN IN ==============

//   Future<bool> signInWithTwitter(BuildContext context) async {
//     return _performAuth(() => _repository.signInWithTwitter(context, true));
//   }

//   // ============== PHONE AUTHENTICATION ==============

//   Future<void> verifyPhoneNumber(String phoneNumber) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _repository.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         onCodeSent: (verificationId) {
//           _verificationId = verificationId;
//           _isLoading = false;
//           notifyListeners();
//         },
//         onError: (error) {
//           _error = error;
//           _isLoading = false;
//           notifyListeners();
//         },
//         verificationCompleted: (user) {
//           _user = user;
//           _status = AuthStatus.authenticated;
//           _isLoading = false;
//           notifyListeners();
//         },
//       );
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> signInWithOTP(String smsCode) async {
//     if (_verificationId == null) {
//       _error = 'Verification ID not found. Please request a new code.';
//       notifyListeners();
//       return false;
//     }

//     return _performAuth(
//       () => _repository.signInWithOTP(
//         verificationId: _verificationId!,
//         smsCode: smsCode,
//       ),
//     );
//   }

//   // ============== COMMON METHODS ==============

//   Future<void> signOut() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _repository.signOut();
//       _user = null;
//       _status = AuthStatus.unauthenticated;
//       _error = null;
//       _verificationId = null;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> sendPasswordResetEmail(String email) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _repository.sendPasswordResetEmail(email);
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // Helper method for authentication
//   Future<bool> _performAuth(Future<UserModel?> Function() authMethod) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final user = await authMethod();

//       if (user != null) {
//         _user = user;
//         _status = AuthStatus.authenticated;
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _error = 'Authentication failed';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyToken = 'authToken';
  static const String _keyUserId = 'userId';

  // Save login state
  Future<void> saveLoginState(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
