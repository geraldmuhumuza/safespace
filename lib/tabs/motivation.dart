import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safehome/registerPage.dart';
import '../home_page.dart';
import '../landing/loginPage.dart';
import 'tab/constants.dart';
import 'tab/functions.dart';

class MotivationPage extends StatefulWidget {
  final String title;
  const MotivationPage({super.key, required this.title});

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffc2d6f2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 150,
              color: Color(0xfffbf7f7),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Image(
                        image: NetworkImage(
                          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                        ),
                      ),
                      title: Text('The Enchanted Nightingale'),
                      subtitle: Text(
                        'Music by Julie Gable. Lyrics by Sidney Stein.',
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          child: const Text('BUY TICKETS'),
                          onPressed: () {
                            /* ... */
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // You can navigate to a details page here
                            },
                            child: Text('Read More'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Create Account
class NewLandingPage extends StatefulWidget {
  const NewLandingPage({super.key});

  @override
  State<NewLandingPage> createState() => _NewLandingPageState();
}

class _NewLandingPageState extends State<NewLandingPage> {
  // final _email = TextEditingController();

  User? _user;
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
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

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        // Check if user is new or existing
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .limit(1)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          // New user, create a new document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'firstname': user.displayName,
                'email': user.email,
                'uid': user.uid,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
        if (!mounted) return;
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("WELCOME SAFESPACE"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // IMAGE SLIDER WITH OVERLAY
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(images[index], fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.4)),
                ],
              );
            },
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Welcome to safespace",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                  child: Text(
                    "Don't have an Account?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        fixedSize: const Size.fromWidth(20),
                        textStyle: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.lightGreenAccent,
                        foregroundColor: Colors.white,
                        elevation: 15,
                        shadowColor: Colors.grey,
                      ),
                      child: const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                  child: Text(
                    "Or",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 60,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_user?.uid == null &&
                                  _user?.isAnonymous == false) {
                                signInAnonymously(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SafeSpace(),
                                  ),
                                );
                                SnackBar(
                                  content: Text(
                                    "You have signed in anonymously",
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              fixedSize: const Size.fromWidth(20),
                              textStyle: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: const Color(0xffffffff),
                              foregroundColor: const Color(0xff0a0a0a),
                              elevation: 15,
                              shadowColor: Colors.grey,
                            ),
                            child: const Text(
                              "GUEST",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 60,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              fixedSize: const Size.fromWidth(20),
                              textStyle: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: const Color(0xffffffff),
                              foregroundColor: const Color(0xff0a0a0a),
                              elevation: 15,
                              shadowColor: Colors.grey,
                            ),
                            child: const Text(
                              "REGISTER",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BUTTONS (remain below)
        ],
      ),
    );
  }
}

extension on GoogleSignInAuthentication {
  String? get accessToken => null;
}
