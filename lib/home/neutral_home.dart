import 'package:flutter/material.dart';
import 'package:safehome/tabs/tab/counselling.dart';
import 'package:safehome/report/report.dart';
import 'package:safehome/tabs/tab/suspicion.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

final bool value = true;

class _HomePageState extends State<HomePage> {
  bool value = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xfff8d8d8),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      IconButton(
                        iconSize: 150,
                        color: Colors.red,
                        icon: const Icon(Icons.add_alert),
                        onPressed: () {},
                        onHover: (value) {
                          const Color(0xff35b016);
                        },
                      ),
                      Text(
                        "Need an emergency help ASAP, press the icon above.",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.count(
              //scrollDirection: Axis.horizontal,
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[100],
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: TextButton(
                    child: const Text(
                      "REPORT RAPE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportPage(),
                        ),
                      );
                      /**...... */
                    },
                    onHover: (value) {
                      Color(0xff4f8bf9);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[100],
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: TextButton(
                    child: const Text(
                      "COUNSELLING AND GUIDANCE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      /**...... */
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CounsellingPage(),
                        ),
                      );
                    },
                    onHover: (value) {
                      Colors.teal[100];
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[100],
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: TextButton(
                    child: Text(
                      "REPORT ONGOING RAPE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      /**...... */
                    },
                    onHover: (value) {
                      Colors.teal[100];
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[100],
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: TextButton(
                    child: const Text(
                      "SHARE LOCATION FOR HELP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SuspisionPage(),
                        ),
                      );
                      /**...... */
                    },
                    onHover: (value) {
                      Colors.teal[100];
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[100],
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: TextButton(
                    child: const Text(
                      "REPORT RAPE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      /**...... */
                    },
                    onHover: (value) {
                      Colors.teal[100];
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[100],
                    border: const Border(
                      left: BorderSide(color: Color(0xff4c76af), width: 3),
                      right: BorderSide(color: Color(0xff4c76af), width: 3),
                      top: BorderSide(color: Color(0xff4c76af), width: 3),
                      bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  //color: Colors.teal[100],
                  child: TextButton(
                    child: const Text(
                      "REPORT RAPE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      /**...... */
                    },
                    onHover: (value) {
                      Colors.teal[100];
                    },
                  ),
                ),
                /*
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[500],
                  child: const Text('Revolution is coming...'),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[600],
                  child: const Text('Revolution, they...'),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
