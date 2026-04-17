// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:safehome/profile/profilePage.dart';

import 'tabs/home.dart';
import 'tabs/support.dart';
import 'report/report.dart';

int _currentIndex = 0;

class SafeSpace extends StatefulWidget {
  const SafeSpace({super.key});

  @override
  State<SafeSpace> createState() => _SafeSpaceState();
}

ThemeMode _themeMode = ThemeMode.light;

class _SafeSpaceState extends State<SafeSpace> {
  final List<Widget> _pages = [
    const HomePageContent(),
    const NewHomePage(),
    const SupportPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    // ignore: unused_local_variable
    const apiKey = String.fromEnvironment(
      "AIzaSyCgO8D8LS8bRhdwetrauolCcOkqKLnJYwo",
      defaultValue: 'key not found',
    );
    // if (apiKey == 'key not found') {
    //   throw InvalidApiKey(
    //     'Key not found in environment. Please add an API key.',
    //   );

    // }

    final genAI = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: const String.fromEnvironment(
        'AIzaSyCgO8D8LS8bRhdwetrauolCcOkqKLnJYwo',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
    genAI.startChat();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // switch tabs
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: "Report",
            tooltip: "Report",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: "Support",
            tooltip: "Support",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_3),
            label: "Profile",
            tooltip: "Profile",
          ),
        ],
      ),
    );
  }
}
