import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:show_hide_password/show_hide_password_text_field.dart';

import '../main.dart';
import 'landingFunctions/loginUser.dart';
import 'landingFunctions/signInWithGoogle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  //un
  AppUser? get user => context.watch<UserProvider>().user;

  Future<void> verifyAndNavigate(BuildContext context) async {
    final callable = FirebaseFunctions.instance.httpsCallable('verifyUser');

    try {
      final result = await callable();

      final data = result.data;

      if (data['success'] == true) {
        final route = data['redirect'];

        if (!context.mounted) return;

        if (route == "/dashboard") {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      debugPrint("Verification failed: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Back")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 90,
              child: TextFormField(
                controller: _email,
                style: const TextStyle(
                  fontSize: 20.0,
                  height: 2.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Email",
                  //labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black38, width: 1),
                    //borderRadius: BorderRadius.circular(5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSaved: (String? value) {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 90,
              child: ShowHidePasswordTextField(
                controller: _password,
                fontStyle: const TextStyle(
                  fontSize: 20,
                  height: 2.0,
                  fontWeight: FontWeight.normal,
                ),
                textColor: const Color(0xff010101),
                hintColor: const Color(0xff060606),
                iconSize: 20,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Enter Password',
                  //labelText: 'Enter Password',
                  hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.black38,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black38,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black38,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  bool mounted = false;
                  final email = _email.text.trim().toLowerCase();
                  final password = _password.text.trim();
                  loginUser(context, mounted, email, password);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  //fixedSize: const Size.fromWidth(20),
                  textStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: const Color(0xffd00c96),
                  foregroundColor: Colors.white,
                  elevation: 15,
                  shadowColor: Colors.grey,
                ),
                child: const Text("LOG IN", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: const Color(0xffffffff),
                  foregroundColor: const Color(0xff0a0a0a),
                  elevation: 15,
                  shadowColor: Colors.grey,
                ),
                icon: const FaIcon(FontAwesomeIcons.google),
                label: const Text(
                  "Log in with Google",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
