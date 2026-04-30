//import 'dart:html';
// ignore_for_file: unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/api/auth_service.dart';
import 'package:safehome/app_user.dart';
import 'package:safehome/home_page.dart';
import 'package:safehome/landing/loading_page.dart';
import 'package:safehome/notifications/notifications_service.dart';
//import 'package:safehome/providers/auth_provider.dart';
import 'package:safehome/tabs/home.dart';
import 'firebase_options.dart';
import 'landing/landingPage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

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
          create: (_) => AuthService(),
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
    return MaterialApp(
      title: 'SafeHome',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        // This stream emits the cached user INSTANTLY on first event
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen(); // only shown briefly
          }
          if (snapshot.hasData) {
            return const SafeSpace(); // logged-in user goes straight here
          }
          return const LandingPage();
        },
      ),
    );
  }
}
