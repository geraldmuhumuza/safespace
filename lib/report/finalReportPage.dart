import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safehome/api/auth_service.dart';
import 'package:safehome/home_page.dart';

class FinalReportPage extends StatefulWidget {
  const FinalReportPage({
    super.key,
    required this.reportTime,
    required this.date,
    required this.location,
    required this.incident,
  });
  final String reportTime;
  final String date;
  final String location;
  final String incident;

  @override
  State<FinalReportPage> createState() => _FinalReportPageState();
}

String selectedValue = "Yes";

class _FinalReportPageState extends State<FinalReportPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _handleSaveReportWithUSer(
    String reportTime,
    String date,
    String location,
    String incident,
    String contact,
  ) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final success = await authService.saveReportWithUser(
        reportTime: reportTime,
        date: date,
        location: location,
        incident: incident,
        contact: contact,
      );
      if (success) {
        debugPrint("Report Saved Successfully");
      } else {
        debugPrint("Report not Saved");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveReportWithUser(
    String reportTime,
    String date,
    String location,
    String incident,
    String contact,
  ) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(_user!.uid)
        .collection('report')
        .add({
          'name': _user!.email ?? _user!.phoneNumber,
          'reportTime': reportTime,
          'date': date,
          'location': location,
          'incident': incident,
          'tobeCalled': contact,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> saveReportWithoutUser(
    String reportTime,
    String date,
    String location,
    String incident,
  ) async {
    await FirebaseFirestore.instance.collection('reports').add({
      'name': 'Anonymous',
      'reportTime': reportTime,
      'date': date,
      'location': location,
      'incident': incident,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("REPORT CONFIRMATION")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_user != null)
              Column(
                children: [
                  Text("Do you wish to be contacted at any moment?"),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Yes",
                        groupValue: selectedValue,
                        onChanged: (value) {
                          setState(() => selectedValue = value!);
                          _handleSaveReportWithUSer(
                            widget.reportTime,
                            widget.date,
                            widget.location,
                            widget.incident,
                            selectedValue,
                          );
                          // saveReportWithUser(
                          //   widget.reportTime,
                          //   widget.date,
                          //   widget.location,
                          //   widget.incident,
                          //   selectedValue,
                          // );
                        },
                      ),
                      const Text("Yes"),

                      Radio<String>(
                        value: "No",
                        groupValue: selectedValue,
                        onChanged: (value) {
                          setState(() => selectedValue = value!);
                          _handleSaveReportWithUSer(
                            widget.reportTime,
                            widget.date,
                            widget.location,
                            widget.incident,
                            selectedValue,
                          );
                          // saveReportWithUser(
                          //   widget.reportTime,
                          //   widget.date,
                          //   widget.location,
                          //   widget.incident,
                          //   selectedValue,
                          // );
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                ],
              ),
            Text("It takes some courage to open up"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  saveReportWithoutUser(
                    widget.reportTime,
                    widget.date,
                    widget.location,
                    widget.incident,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SafeSpace()),
                  );
                },
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
                  "SAVE REPORT",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
