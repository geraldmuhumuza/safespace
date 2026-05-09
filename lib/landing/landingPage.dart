import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safehome/home_page.dart';
import 'package:safehome/registerPage.dart';
import 'package:safehome/tabs/phoneNumberLogin/phoneNumberLogin.dart';
import 'package:safehome/tabs/tab/constants.dart';
import 'package:show_hide_password/show_hide_password.dart';

import '../api/auth_service.dart';
import 'landingFunctions/show_forgort_password_dialog.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _email = TextEditingController();
  final _passwordController = TextEditingController();
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Auto slide every 4 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;

      _currentIndex = (_currentIndex + 1) % images.length;
      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  Future<void> _handleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _email.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      debugPrint("Email or password is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }
    try {
      final success = await authService.signIn(
        email: email,
        password: password,
      );

      if (!success && mounted) {
        debugPrint("Login failed: ${authService.errorMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SafeSpace()),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.signInWithGoogle();

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Google sign in failed'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SafeSpace()),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleTwitterSignin() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.signInWithTwitter(context, mounted);

      if (!success && mounted) {
        debugPrint("Login failed: ${authService.errorMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Twitter Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SafeSpace()),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return authService.isAuthenticated
        ? SafeSpace()
        : Scaffold(
            extendBodyBehindAppBar: false,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // IMAGE SLIDER WITH OVERLAY
                PageView.builder(
                  // controller: _controller,
                  // itemCount: images.length,
                  // onPageChanged: (index) {
                  //   setState(() => _currentIndex = 1);
                  // },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/indoor.jpeg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.linearToSrgbGamma(),
                          opacity: 0.50,
                        ),
                        //color: Color.fromRGBO(255, 255, 255, 0.89),
                      ),
                    );
                    // return Stack(
                    //   fit: StackFit.expand,
                    //   children: [
                    //     Image.asset(images[1], fit: BoxFit.cover),
                    //     // ignore: deprecated_member_use
                    //     Container(color: Colors.black.withOpacity(0.4)),
                    //   ],
                    // );
                  },
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35),
                              bottomLeft: Radius.circular(35),
                              bottomRight: Radius.circular(35),
                            ),
                            image: DecorationImage(
                              image: AssetImage("assets/splash.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          foregroundDecoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),

                          height: 70,
                          width: 70,
                        ),
                        Center(
                          child: Text(
                            "Welcome back!",
                            style: TextStyle(
                              //fontStyle: GoogleFonts.aboreto,
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            "Please log into your safespace account",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),

                        Card(
                          color: Colors.white,
                          elevation: 10,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: _email,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      height: 1.5,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      hint: const Text(
                                        "Email Address",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            164,
                                            164,
                                            163,
                                          ),
                                        ),
                                      ),
                                      labelText: 'Email Address',
                                      prefixIcon: const Icon(Icons.email),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          style: BorderStyle.solid,
                                          color: Color.fromARGB(
                                            169,
                                            158,
                                            156,
                                            156,
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black38,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onSaved: (String? value) {
                                      if (value!.isEmpty) {
                                        return;
                                      } else {
                                        if (value.contains('@')) {
                                          if (value.endsWith(".com")) {
                                          } else {
                                            return;
                                          }
                                        } else {
                                          return;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ShowHidePasswordTextField(
                                    controller: _passwordController,
                                    fontStyle: const TextStyle(
                                      fontSize: 20,
                                      height: 1.5,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    textColor: const Color(0xff010101),
                                    hintColor: const Color(0xff060606),
                                    iconSize: 20,
                                    //visibleOffIcon: Iconsax.eye_slash,
                                    //visibleOnIcon: Iconsax.eye,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Password',
                                      labelText: 'Password',
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Colors.black38,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          style: BorderStyle.solid,
                                          color: Color.fromARGB(96, 59, 57, 57),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black38,
                                          width: 2,
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
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      String email = _email.text.trim();
                                      if (email.isEmpty) {
                                        return;
                                      } else {
                                        if (email.contains('@')) {
                                          if (email.endsWith(".com")) {
                                          } else {
                                            return;
                                          }
                                        } else {
                                          return;
                                        }
                                      }
                                      _handleLogin();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size.fromWidth(20),
                                      textStyle: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                        164,
                                        90,
                                        238,
                                        77,
                                      ),
                                      foregroundColor: Colors.white,
                                      elevation: 15,
                                      shadowColor: Colors.grey,
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showForgotPasswordDialog(context);
                                },
                                style: TextButton.styleFrom(
                                  // fixedSize: const Size.fromWidth(20),
                                  textStyle: const TextStyle(fontSize: 20),
                                ),
                                child: Text("Forgot Password?"),
                              ),
                              const SizedBox(
                                height: 20,
                                child: Text(
                                  "Or",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                                height: 20,
                                thickness: 2,
                                indent: 10,
                                endIndent: 10,
                              ),
                              Text("Log in with"),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _handleGoogleSignIn();
                                          // signInWithGoogle(context, mounted);
                                        },
                                        style: ButtonStyle(
                                          side: WidgetStateProperty.all(
                                            const BorderSide(
                                              color: Color.fromARGB(
                                                255,
                                                138,
                                                137,
                                                137,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          maximumSize: WidgetStatePropertyAll(
                                            const Size(55, 60),
                                          ),
                                          minimumSize: WidgetStatePropertyAll(
                                            const Size(55, 60),
                                          ),
                                          backgroundColor:
                                              WidgetStateColor.resolveWith(
                                                (states) => Colors.white,
                                              ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          padding: WidgetStateProperty.all(
                                            const EdgeInsets.all(12),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                "assets/google.jpeg",
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                            color: Colors.white,
                                          ),
                                          height: 35,
                                          width: 35,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          //signInWithTwitter(context, mounted);
                                          _handleTwitterSignin();
                                          debugPrint("Twitter login");
                                        },
                                        icon: FaIcon(
                                          color: const Color.fromARGB(
                                            255,
                                            18,
                                            18,
                                            18,
                                          ),
                                          FontAwesomeIcons.xTwitter,
                                          size: 30,
                                          applyTextScaling: true,
                                        ),
                                        style: ButtonStyle(
                                          side: WidgetStateProperty.all(
                                            const BorderSide(
                                              color: Color.fromARGB(
                                                255,
                                                138,
                                                137,
                                                137,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          padding: WidgetStateProperty.all(
                                            const EdgeInsets.all(12),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Phonenumberlogin(),
                                            ),
                                          );
                                          debugPrint("Phone Number login");
                                        },
                                        icon: FaIcon(
                                          color: Colors.blue,
                                          FontAwesomeIcons.phone,
                                          size: 30,
                                          applyTextScaling: true,
                                        ),
                                        hoverColor: Colors.blue,
                                        style: ButtonStyle(
                                          side: WidgetStateProperty.all(
                                            const BorderSide(
                                              color: Color.fromARGB(
                                                255,
                                                138,
                                                137,
                                                137,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          padding: WidgetStateProperty.all(
                                            const EdgeInsets.all(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                                height: 20,
                                thickness: 2,
                                indent: 10,
                                endIndent: 10,
                              ),
                              const SizedBox(
                                child: Text(
                                  "Don't have an account?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  textStyle: TextStyle(fontSize: 20),
                                ),
                                child: Text('Register'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
