// ignore_for_file: unused_import

import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:flutter_contacts/flutter_contacts.dart";
import 'package:provider/provider.dart';
import 'package:safehome/api/api_service.dart';
import 'package:safehome/api/auth_service.dart';
import 'package:safehome/main.dart';
import 'package:safehome/tabs/tab/constants.dart';
import 'package:safehome/tabs/tab/functions.dart';
import 'package:safehome/report/report.dart';

import '../../home_page.dart';

final authService = AuthService();

class Counsellor extends StatefulWidget {
  const Counsellor({super.key});

  @override
  State<Counsellor> createState() => _CounsellorState();
}

class _CounsellorState extends State<Counsellor> {
  DateTime? selectedDate;

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked.toLocal();
        // Format as YYYY-MM-DD
      });
    }
  }

  Stream<QuerySnapshot> counsellorStream() {
    return FirebaseFirestore.instance.collection('Counsellors').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 253, 252, 252),
        ),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: counsellorStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Counsellor available"));
                }

                // final docs = snapshot.data!.docs;

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: authService.counsellor.length,
                  itemBuilder: (context, index) {
                    final data = authService.counsellor[index];
                    //final c = counsellors[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: const Color.fromARGB(255, 250, 249, 249),
                        elevation: 100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                _selectDOB(context);
                                FirebaseFirestore.instance
                                    .collection("counsellors")
                                    .where(
                                      data.counsellorName,
                                      isEqualTo: data.counsellorName,
                                    )
                                    .limit(1)
                                    .snapshots();
                              },
                              leading: Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 30,
                              ),
                              title: Text(
                                data.counsellorName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                data.role,
                                style: const TextStyle(color: Colors.black),
                              ),
                              trailing: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  final phone = data.phone.replaceAll(' ', '');
                                  openDialer(phone);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (selectedDate != null)
                              Text(
                                "Appointment Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}





//Greeting message

