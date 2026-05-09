import 'package:flutter/material.dart';

import 'finalReportPage.dart';

final _incidentController = TextEditingController();

class HappenedPage extends StatefulWidget {
  const HappenedPage({
    super.key,
    required this.date,
    required this.location,
    required this.reportTime,
  });

  final String date;
  final String location;
  final String reportTime;

  @override
  State<HappenedPage> createState() => _HappenedPageState();
}

class _HappenedPageState extends State<HappenedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Back")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const Text(
                  "What happened?",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  "Describe what happened at the scene",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _incidentController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: "Incident description",
                      fillColor: Colors.white,
                      counterStyle: TextStyle(color: Colors.white),
                      //labelText: 'Location(Optional)',
                      labelStyle: TextStyle(fontSize: 17, color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  final String incident = _incidentController.text.trim();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinalReportPage(
                        reportTime: widget.reportTime,
                        date: widget.date,
                        location: widget.location,
                        incident: incident,
                      ), //const FinalReportPage(),
                    ),
                  );
                  _incidentController.clear();
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
                child: const Text("Continue"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
