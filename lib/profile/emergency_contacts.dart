import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/api/auth_service.dart';
import 'package:safehome/app_user.dart';
import 'package:safehome/main.dart';
import "package:flutter_contacts/flutter_contacts.dart";

final authService = AuthService();

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  // ignore: unused_field
  User? _user;
  User? get user => context.watch<UserProvider>().user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Stream<QuerySnapshot> emergencyContactsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('emergency_contacts')
        .doc(uid)
        .collection('contacts')
        .snapshots();
  }

  Future<void> openContactsApp() async {
    //final Uri uri = Uri.parse("content://contacts/people/");
    if (Platform.isAndroid) {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();

        if (contact == null || contact.phones.isEmpty) {
          debugPrint("No contact selected");
          return;
        }

        final name = contact.displayName;
        final phone = contact.phones.first.number;

        // Save to Firestore
        // await FirebaseFirestore.instance
        //     .collection('emergency_contacts')
        //     .doc(_user!.uid)
        //     .collection('contacts')
        //     .add({
        //       'name': name,
        //       'phone': phone,
        //       'createdAt': FieldValue.serverTimestamp(),
        //     });

        //save to the database
        await authService.saveEmergencyContact(
          user_id: _user!.uid,
          contactName: name,
          contactNumber: phone,
        );

        debugPrint("Saved: $name - $phone");
      } else {
        debugPrint("Permission denied");
        debugPrint("Running on Android: ${Platform.environment}");

        return;
      }

      // Open system contacts picker
    } else {
      // if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      //   throw "Could not open contacts app";
    }
  }

  Future<void> obtainEmergencyContacts() async {
    final success = await authService.obtain_emergency_contacts(_user!.uid);
    if (!success) {
      debugPrint("Failed to obtain emergency contacts");
    } else {
      debugPrint("Successfully obtained emergency contacts");
      //debugPrint("Emergency contacts: $_userData");
    }
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context, MaterialPageRoute(builder: (context) => SafeHome()));
    print("User logged out because app closed/backgrounded");
  }

  Future<void> deleteContact(String docId) async {
    await FirebaseFirestore.instance
        .collection('emergency_contacts')
        .doc(_user!.uid)
        .collection('contacts')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Back")),
      body: Column(
        children: [
          const Text(
            "Emergency Contacts",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Contact the numbers below in case of an emergency",
            style: TextStyle(fontSize: 20),
          ),

          _user!.isAnonymous
              ? Column(
                  children: [
                    Text("Please Login to add Emergency Contacts"),
                    Text("No emergency contacts added"),
                  ],
                )
              : Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: emergencyContactsStream(_user!.uid),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("No emergency contacts added"),
                        );
                      }

                      return ListView.builder(
                        itemCount: authService.emergencyContacts.length,
                        itemBuilder: (context, index) {
                          final contacts = authService.emergencyContacts[index];
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(contacts.contactName),
                            subtitle: Text(contacts.phone),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Delete Contact'),
                                    content: Text(
                                      'Are you sure you want to delete ${contacts.contactName}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await authService.delete_emergency_contact(
                                    contacts.id,
                                    _user!.uid,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: openContactsApp,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                fixedSize: const Size(double.infinity, 50),
                maximumSize: const Size(double.infinity, 50),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Select Emergency Contacts",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
