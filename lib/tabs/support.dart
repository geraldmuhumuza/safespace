import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safehome/tabs/tab/functions.dart';

import 'tab/counsellors.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Stream<QuerySnapshot> motivationsStream() {
    return FirebaseFirestore.instance.collection("Motivations").snapshots();
  }

  Stream<QuerySnapshot> hotlineStream() {
    return FirebaseFirestore.instance.collection("Hotline").snapshots();
  }

  Stream<QuerySnapshot> searchHotline() {
    if (_searchQuery.isEmpty) {
      return FirebaseFirestore.instance.collection('users').snapshots();
    }

    return FirebaseFirestore.instance
        .collection('Hotline')
        .where('title', arrayContains: _searchQuery)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 58, 77),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 54, 58, 77),
        foregroundColor: Colors.white,
        title: const Text(
          "Reach out For Support",
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 55, 88, 94),
                  border: const Border(
                    left: BorderSide(color: Colors.red, width: 2),
                    top: BorderSide(color: Colors.red, width: 2),
                    bottom: BorderSide(color: Colors.red, width: 2),
                    right: BorderSide(color: Colors.red, width: 2),
                  ),
                ), //color: Colors.teal[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 180, 179, 179),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              style: BorderStyle.solid,
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          hintText: "Search for Support Hotline",
                          hintStyle: TextStyle(color: Colors.white),
                        ),

                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.call, color: Colors.red),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            "Crisis Support - Available 24/7",
                            style: TextStyle(
                              color: Color.fromARGB(255, 135, 230, 225),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    //HOTLINE
                    StreamBuilder(
                      stream: hotlineStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            //final m = motivations[index];

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8.0),
                              child: Card(
                                color: const Color(0xff3b3b3b),
                                elevation: 10,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(
                                        Icons.circle,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        data['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      subtitle: Text(
                                        data["subtitle"],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          final phone = data['phoneNumber']
                                              .replaceAll(' ', '');
                                          openDialer(phone);
                                        },
                                        icon: Icon(
                                          Icons.call,
                                          color: Colors.white,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    //const SizedBox(width: 8),
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
            ),
            const ListTile(
              leading: Icon(Icons.calendar_month_outlined, color: Colors.blue),
              title: Text(
                "Book a consellor",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const Counsellor(),
            const ListTile(
              leading: Icon(Icons.calendar_view_month, color: Colors.blue),
              title: Text(
                "Daily Motivation",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            StreamBuilder(
              stream: motivationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    //final m = motivations[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: const Color.fromARGB(255, 250, 250, 250),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              //leading:
                              //Icon(Icons.person, color: Colors.white, size: 30),
                              title: Text(
                                data['title'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                data["subtitle"],
                                style: const TextStyle(color: Colors.black),
                              ),
                              //trailing: Icon(Icons.call, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
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
