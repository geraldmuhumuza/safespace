import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/home_page.dart';
import 'package:safehome/imageservice.dart';
import 'package:safehome/landing/landingPage.dart';
import 'package:safehome/main.dart';
import 'package:safehome/profile/profile.dart';
import 'package:safehome/profile/emergency_contacts.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'preferencePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  final _service = ImageService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> _images = [];
  bool _loading = true;
  bool _uploading = false;
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _loading = true);
    final images = await _service.getUserImages(_user!.uid);
    setState(() {
      _images = images;
      _loading = false;
    });
  }

  Future<void> _pick({bool camera = false}) async {
    setState(() => _uploading = true);
    try {
      final docId = await _service.pickUploadAndSave(
        fromCamera: camera,
        userId: _userId,
      );
      if (docId != null) {
        await _loadImages(); // refresh grid
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This will remove it from storage and Firestore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteImage(
        userId: _userId,
        docId: image['id'],
        storagePath: image['storagePath'],
      );
      await _loadImages();
    }
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    context.read<UserProvider>().clearUser();
    debugPrint("User logged out because app closed/backgrounded");
  }

  Stream<DocumentSnapshot> userProfileStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // final appuser = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 58, 77),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 58, 77),
        automaticallyImplyLeading: false,
        title: const Text(
          'PROFILE MANAGEMENT',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: _user == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Manage your account and preferences",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xff424141),
                      child: ListTile(
                        title: Text(
                          "Please Login",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "You are using the application anonymously",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'ACCOUNT PRIVACY',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Card(
                    color: const Color(0x613d3c3c),
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      children: [
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Edit Your profile details",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Profile(),
                                ),
                              );
                            },
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.lock,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: ToggleSwitch(
                              initialLabelIndex: 0,
                              minHeight: 20.0,
                              minWidth: 25.0,
                              cornerRadius: 20.0,
                              activeBgColors: [
                                [Colors.black],
                                [Colors.blue],
                              ],
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colors.grey,
                              inactiveFgColor: Colors.white,
                              customTextStyles: [TextStyle(fontSize: 15.0)],
                              multiLineText: true,
                              centerText: true,
                              totalSwitches: 2,
                              onToggle: (index) {
                                debugPrint('switched to: $index');
                              },
                            ),
                            title: const Text(
                              "Anonymous mode",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Have your identity in your interactions",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.private_connectivity,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Privacy Settings",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Control who can see your information",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.remove_red_eye,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Data & Security",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Manage your data and security preferences",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PreferencesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'EMERGENCY & CONTACTS',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Card(
                    color: const Color(0x613d3c3c),
                    child: Column(
                      children: [
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.call,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Emergency Contacts",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Add trusted people to contacts",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmergencyPage(),
                                ),
                              );
                            },
                          ),
                        ),

                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Trusted Support Persons",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Someone who can help during crisis",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'APP PREFERENCES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Card(
                    color: const Color(0x613d3c3c),
                    child: Column(
                      children: [
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.call,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Notifications",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Daily reminders and support messages",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Dark Mode",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Toggle dark appearance",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Sound Effects",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "App sounds and haptic feedback",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'SUPPORT & HELP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Card(
                    color: const Color(0x613d3c3c),
                    child: Column(
                      children: [
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.call,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Help Center",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Find answers and get support",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Share App",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Help others find help",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color(0x61272626),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              size: 24,
                              color: Colors.white,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Rate SafeSpace",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Share your feedback",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : StreamBuilder(
                stream: userProfileStream(_user!.uid),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasError) {
                    //debugPrint(_user!.uid);
                    return const Text("Something went wrong");
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Padding(
                      //   padding: EdgeInsets.all(10.0),
                      //   child: Text(
                      //     "Manage your account and preferences",
                      //     style: TextStyle(fontSize: 18, color: Colors.white),
                      //     textAlign: TextAlign.left,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: userProfileStream(_user!.uid),
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasError) {
                              //debugPrint(_user!.uid);
                              return const Text("Something went wrong");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData) {
                              //debugPrint(_user!.uid);
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
                              color: const Color.fromARGB(255, 54, 58, 77),
                              child: Column(
                                children: [
                                  IconButton(
                                    onPressed: _uploading
                                        ? null
                                        : () => _pick(camera: false),
                                    icon: Icon(
                                      Icons.account_circle,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    iconSize: 50,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      // maximumSize: Size(10, 15),
                                      // minimumSize: Size(10, 15),
                                    ),
                                  ),

                                  ListTile(
                                    // leading: IconButton(
                                    //   icon: const Icon(
                                    //     Icons.account_circle,
                                    //     color: Colors.blue,
                                    //     size: 24,
                                    //   ),
                                    //   style: IconButton.styleFrom(
                                    //     backgroundColor: Colors.blue,
                                    //   ),
                                    //   onPressed: () {},
                                    // ),
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
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      8.0,
                                                      0,
                                                    ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    logoutUser();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LandingPage(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('Yes'),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
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
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'ACCOUNT PRIVACY',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Card(
                        color: const Color(0x613d3c3c),
                        margin: const EdgeInsets.all(12),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        //padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Column(
                          children: [
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Edit Your profile details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Profile(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.lock,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: ToggleSwitch(
                                  initialLabelIndex: 0,
                                  minHeight: 20.0,
                                  minWidth: 25.0,
                                  cornerRadius: 20.0,
                                  activeBgColors: [
                                    [Colors.black],
                                    [Colors.blue],
                                  ],
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: Colors.grey,
                                  inactiveFgColor: Colors.white,
                                  customTextStyles: [TextStyle(fontSize: 15.0)],
                                  multiLineText: true,
                                  centerText: true,
                                  totalSwitches: 2,
                                  onToggle: (index) {
                                    debugPrint('switched to: $index');

                                    if (index == 1) {
                                      logoutUser();
                                      //signInAnonymously(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SafeSpace(),
                                        ),
                                      );
                                    } else {
                                      debugPrint("Login Anonymously");
                                      //loginAnonymous(context);
                                    }
                                  },
                                ),
                                title: const Text(
                                  "Anonymous mode",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Have your identity in your interactions",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.private_connectivity,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Privacy Settings",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Control who can see your information",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.remove_red_eye,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Data & Security",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Manage your data and security preferences",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PreferencesPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'EMERGENCY & CONTACTS',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Card(
                        color: const Color.fromARGB(255, 54, 58, 77),
                        child: Column(
                          children: [
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.call,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Emergency Contacts",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Add trusted people to contacts",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmergencyPage(),
                                    ),
                                  );
                                },
                              ),
                            ),

                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person_add,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Trusted Support Persons",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Someone who can help during crisis",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'APP PREFERENCES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Card(
                        color: const Color.fromARGB(255, 54, 58, 77),
                        child: Column(
                          children: [
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.call,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Notifications",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Daily reminders and support messages",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person_add,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Dark Mode",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Toggle dark appearance",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person_add,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Sound Effects",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "App sounds and haptic feedback",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'SUPPORT & HELP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Card(
                        color: const Color(0x613d3c3c),
                        child: Column(
                          children: [
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.call,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Help Center",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Find answers and get suppoert",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person_add,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Share App",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Help others find help",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Card(
                              color: const Color(0x61272626),
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person_add,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Rate SafeSpace",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Share your feedback",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                          ],
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
