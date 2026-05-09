import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/app_user.dart';
import 'package:safehome/profile/updateProfilePage.dart';

import '../home_page.dart';
import '../landing/landingPage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? _user;

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _contactController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    context.read<UserProvider>().clearUser();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
    print("User logged out because app closed/backgrounded");
  }

  Stream<DocumentSnapshot> userProfileStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfile(String updated, String textLabel) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpdatePage(updateData: updated, textLabel: textLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SafeSpace()),
            );
          },
        ),
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: _user!.isAnonymous
            ? const Text('Please log in to see your profile.')
            : StreamBuilder(
                stream: userProfileStream(_user!.uid),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint(_user!.uid);
                    print("snapshot has error");
                    return const Text("Something went wrong");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    debugPrint(_user!.uid);
                    print('Snapshot is empty');
                    return const Center(
                      child: Text("You are using the application anonymously"),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: userProfileStream(_user!.uid),
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasError) {
                              debugPrint(_user!.uid);
                              return const Text("Something went wrong");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData) {
                              debugPrint(_user!.uid);
                              return const Center(
                                child: Text(
                                  "You are using the application anonymously",
                                ),
                              );
                            }

                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            Timestamp timestamp = data['createdAt'];
                            DateTime dateTime = timestamp.toDate();
                            String formattedDate =
                                "${dateTime.day}-${dateTime.month}-${dateTime.year}";
                            return Card(
                              color: const Color(0xff424141),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.account_circle,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.exit_to_app,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Log Out',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to log out?",
                                        ),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              0,
                                              0,
                                              8.0,
                                              0,
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                logoutUser();
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              10.0,
                                              0,
                                              0,
                                              0,
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                return;
                                              },
                                              child: const Text('No'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                title: Text(
                                  data["email"] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _user != null
                                      ? 'Date_creation $formattedDate'
                                      : 'When the account was created',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 90,
                          child: TextFormField(
                            readOnly: true,
                            showCursor: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hint: Text(
                                data['email'],
                                style: TextStyle(
                                  height: 2.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              //labelText: 'Email',
                              prefixIconColor: Colors.white,
                              prefixIcon: Icon(Icons.email),
                              suffixIconColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mode_edit),
                                onPressed: () {},
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(
                                    248,
                                    248,
                                    248,
                                    248,
                                  ),
                                  width: 1,
                                ),
                                //borderRadius: BorderRadius.circular(5),
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 2, 2, 2),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 90,
                          child: TextFormField(
                            controller: _firstnameController,
                            readOnly: true,
                            showCursor: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hint: Text(
                                data['firstname'],
                                style: TextStyle(
                                  height: 2.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              prefixIconColor: Colors.white,
                              prefixIcon: Icon(Icons.email),
                              suffixIconColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mode_edit),
                                onPressed: () {
                                  String textLabel = "firstname";
                                  updateProfile(data['firstname'], textLabel);
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                //borderRadius: BorderRadius.circular(5),
                              ),
                              filled: true,
                              fillColor: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      data['lastname'] == null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 90,
                                child: TextFormField(
                                  controller: _lastnameController,
                                  readOnly: true,
                                  showCursor: false,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hint: Text(
                                      "Last name not provided",
                                      style: TextStyle(
                                        height: 2.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 24,
                                      ),
                                    ),
                                    prefixIconColor: Colors.white,
                                    prefixIcon: Icon(Icons.email),
                                    suffixIconColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.mode_edit),
                                      onPressed: () {
                                        String textLabel = "lastname";
                                        updateProfile(
                                          data['lastname'],
                                          textLabel,
                                        );
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      //borderRadius: BorderRadius.circular(5),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black,
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 90,
                                child: TextFormField(
                                  controller: _lastnameController,
                                  readOnly: true,
                                  showCursor: false,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hint: Text(
                                      data['lastname'],
                                      style: TextStyle(
                                        height: 2.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 24,
                                      ),
                                    ),
                                    prefixIconColor: Colors.white,
                                    prefixIcon: Icon(Icons.email),
                                    suffixIconColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.mode_edit),
                                      onPressed: () {
                                        String textLabel = "lastname";
                                        updateProfile(
                                          data['lastname'],
                                          textLabel,
                                        );
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      //borderRadius: BorderRadius.circular(5),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 90,
                          child: TextFormField(
                            readOnly: true,
                            showCursor: false,
                            controller: _contactController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hint: Text(
                                data['Contact'],
                                style: TextStyle(
                                  height: 2.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              prefixIconColor: Colors.white,
                              prefixIcon: Icon(Icons.email),
                              suffixIconColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mode_edit),
                                onPressed: () {
                                  String textLabel = "Contact";
                                  updateProfile(data['Contact'], textLabel);
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                //borderRadius: BorderRadius.circular(5),
                              ),
                              filled: true,
                              fillColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 90,
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            showCursor: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hint: Text(
                                data['DOB'],
                                style: TextStyle(
                                  height: 2.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              prefixIconColor: Colors.white,
                              prefixIcon: Icon(Icons.email),
                              suffixIconColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mode_edit),
                                onPressed: () {
                                  String textLabel = "Date Of Birth";
                                  updateProfile(data['DOB'], textLabel);
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                //borderRadius: BorderRadius.circular(5),
                              ),
                              filled: true,
                              fillColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.infinity, 50),
                            maximumSize: const Size(double.infinity, 50),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 15,
                            shadowColor: const Color.fromARGB(255, 95, 95, 95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),

                            foregroundColor: Colors.white,
                            backgroundColor: Colors.lightGreen,
                          ),
                          child: Text("Edit Profile"),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
