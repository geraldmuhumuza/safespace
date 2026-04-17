//import 'dart:html';
// ignore_for_file: unused_element

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/api/auth_service.dart';
import 'package:safehome/notifications/notifications_service.dart';
import 'firebase_options.dart';
import 'landing/landingPage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
  AppUser? _user;

  AppUser? get user => _user;

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://aff39c5d52cab97e8c2c37d2a269e74e@o4510678973939712.ingest.us.sentry.io/4510678986522624';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const SafeHome(),
        ),
      ),
    ),
  );
  await NotificationService.initialize();
}

int _currentIndex = 0;

class SafeHome extends StatelessWidget {
  const SafeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MaterialApp(
        title: "Home",
        debugShowCheckedModeBanner: false,
        home: LandingPage(),
      ),
    );
  }
}
