import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:safehome/landing/landingPage.dart';
import 'package:safehome/landing/locationPermission.dart';
import 'package:safehome/profile/emergency_contacts.dart';
import 'package:safehome/profile/preferencePage.dart';
import 'package:safehome/profile/profile.dart';
import 'package:safehome/tabs/appointments_page.dart';
import 'package:safehome/tabs/tab/constants.dart';
import '../app_user.dart';
import 'tab/anonymouschat.dart';
import 'tab/counsellors.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  User? _user;
  int index = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      setState(() {
        index = (index + 1) % messages.length;
      });
    });
    _getLocation();
    //requestLocationPermission();
    //requestNotificationPermission();
  }

  @override
  void dispose() {
    //timer.cancel();
    super.dispose();
  }

  LatLng? _currentLocation;
  //final MapController _mapController = MapController();
  //
  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    context.read<UserProvider>().clearUser();
    debugPrint("User logged out because app closed/backgrounded");
  }

  Future<void> _getLocation() async {
    try {
      await LocationPermissionRequest.initialize();
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      debugPrint("Location: $position");
      debugPrint("Location: $_currentLocation");
      debugPrint(_currentLocation!.longitude.toString());
      debugPrint(_currentLocation!.latitude.toString());

      //save Location for today
      if (_user?.uid != null) {
        FirebaseFirestore.instance
            .collection('location')
            .doc(_user!.uid)
            .collection('Registered user')
            .add({
              'latitude': _currentLocation!.latitude,
              'longitude': _currentLocation!.longitude,
            });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Selected'),
            content: const Text("Emergency alert sent"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        SnackBar(
          backgroundColor: Colors.white,
          elevation: 15,
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(10),
          content: Text(
            "Error getting your location",
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  bool _counsellor = false;

  Future<void> _pickCounsellor() async {
    const Counsellor();
    if (_counsellor) {
      _counsellor = false;
    } else {
      _counsellor = true;
    }
  }

  Future<void> requestNotificationPermission() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final notificationPermission = settings.authorizationStatus;
    if (notificationPermission == AuthorizationStatus.authorized) {
      debugPrint("Notification permission granted!");
    } else if (notificationPermission == AuthorizationStatus.denied) {
      settings = await messaging.requestPermission();
    }
  }

  Stream<DocumentSnapshot> userProfileStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Define the gradient
        gradient: LinearGradient(
          // Specify the colors for the gradient
          colors: [
            const Color.fromARGB(255, 34, 156, 95),
            const Color.fromARGB(255, 238, 247, 242),
          ],
          // Define the start and end points
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: [
              ListTile(
                title: StreamBuilder(
                  stream: userProfileStream(_user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          Text("Something went Wrong"),
                          Text("Please try Again"),
                        ],
                      );
                    }
                    if (snapshot.hasData == false) {
                      return Column(
                        children: [
                          Text("Something went Wrong"),
                          Text("Please try Again"),
                        ],
                      );
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${data['lastname']} ${data['firstname']}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    );
                  },
                ),
                subtitle: StreamBuilder(
                  stream: userProfileStream(_user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          Text("Something went Wrong"),
                          Text("Please try Again"),
                        ],
                      );
                    }
                    if (snapshot.hasData == false) {
                      return Column(
                        children: [
                          Text("Something went Wrong"),
                          Text("Please try Again"),
                        ],
                      );
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${data['email']}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    );
                  },
                ),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.account_circle),
                child: const Text('Edit Profile'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.calendar_today),
                child: Text("Appointments"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppointmentsPage()),
                  );
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.private_connectivity),
                child: const Text('Privacy Settings'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreferencesPage()),
                  );
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.settings),
                child: const Text('Preferences'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreferencesPage()),
                  );
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.data_usage),
                child: const Text('Data and Security'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreferencesPage()),
                  );
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.logout),
                child: const Text('Logout'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Log Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                          child: TextButton(
                            onPressed: () {
                              logoutUser();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LandingPage(),
                                ),
                              );
                            },
                            child: const Text('Yes'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
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
            ],
            style: MenuStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
              ),
              elevation: WidgetStatePropertyAll(40),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
            child: ListTile(
              title: StreamBuilder(
                stream: userProfileStream(_user!.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        Text("Something went Wrong"),
                        Text("Please try Again"),
                      ],
                    );
                  }
                  if (snapshot.hasData == false) {
                    return Column(
                      children: [
                        Text("Something went Wrong"),
                        Text("Please try Again"),
                      ],
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${data['lastname']}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  );
                },
              ),
              trailing: MenuAnchor(
                builder: (context, controller, child) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.contact_emergency),
                    child: const Text('Emergency Contacts'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmergencyPage(),
                        ),
                      );
                    },
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.share),
                    child: const Text('Share'),
                    onPressed: () {},
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.star),
                    child: const Text('Favourite'),
                    onPressed: () {},
                  ),
                ],
                style: MenuStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                  ),
                  elevation: WidgetStatePropertyAll(40),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 247, 230, 230),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(color: Colors.white, width: 2),
                          ),
                          shadowColor: Colors.black.withOpacity(0.5),
                          elevation: 100,
                        ),
                        iconSize: 80,
                        color: Colors.white,
                        icon: const Icon(
                          Symbols.e911_emergency_rounded,
                          weight: 100,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: _currentLocation == null
                            ? () {
                                SnackBar(
                                  backgroundColor: Colors.white,
                                  elevation: 15,
                                  padding: EdgeInsets.all(8.0),
                                  margin: EdgeInsets.all(10),
                                  content: Text(
                                    "Error getting your location",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                            : () {
                                _getLocation();
                                debugPrint("error");
                              },
                        onHover: (value) {
                          const Color(0xff35b016);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: const Text(
                          "Need help ASAP",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xff3e5f3f),
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  //padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.light_mode, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Today's Message",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000000),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              messages[index],
                              key: ValueKey<String>(messages[index]),
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  shrinkWrap: true, // VERY IMPORTANT
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      //color: Colors.teal[100],
                      child: InkWell(
                        onTap: _pickCounsellor,
                        onHover: (value) {
                          const Color(0xff4f8bf9);
                        },
                        child: const Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.lightBlue,
                                size: 30,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                                child: Text(
                                  "Book counselor",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    //fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              Text(
                                'Available 24/7',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: InkWell(
                        child: Align(
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              Icon(Icons.chat, color: Colors.blue, size: 30),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                                child: Text(
                                  "Anonymous Chat",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    //fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              Text(
                                'Safe & Private',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          /**...... */
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnonymousChatPage(),
                            ),
                          );
                        },
                        onHover: (value) {
                          Colors.teal[100];
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_counsellor) const Counsellor(),
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color.fromARGB(255, 253, 252, 252),
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  top: 8.0,
                                ),
                                child: Icon(
                                  Icons.privacy_tip,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "Your Privacy and Safety",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    //fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(255, 250, 249, 249),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.blue,
                            ),
                            title: const Text(
                              "All data is encrypted and secure",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(255, 250, 249, 249),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.blue,
                            ),
                            title: const Text(
                              "Anonymous reporting options",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(255, 250, 249, 249),
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.blue,
                            ),
                            title: const Text(
                              "Quick exit for your safety",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
