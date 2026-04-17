import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safehome/profile/profile.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({
    super.key,
    required this.updateData,
    required this.textLabel,
  });
  final String updateData;
  final String textLabel;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  User? _user;
  final _updatedText = TextEditingController();

  Future<void> updateProfile(
    String updated,
    String textLabel,
    String updateData,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .update({textLabel: updated})
        .then(
          (value) => {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.white,

                content: Text(
                  "Profile Updated",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            ),
            debugPrint("Profile Updated"),
          },
        );
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back')),
      body: Column(
        children: [
          Text('Update Profile'),
          const SizedBox(height: 5),
          Text("Edit your ${widget.textLabel}"),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 90,
              child: TextFormField(
                readOnly: false,
                showCursor: true,
                cursorColor: Colors.black,
                controller: _updatedText,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hint: Text(
                    widget.updateData,
                    style: TextStyle(
                      height: 2.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                  prefixIconColor: Colors.black,
                  prefixIcon: Icon(Icons.email),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    //borderRadius: BorderRadius.circular(5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                updateProfile(
                  _updatedText.text.trim(),
                  widget.textLabel,
                  widget.updateData,
                );
              },
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
      ),
    );
  }
}
