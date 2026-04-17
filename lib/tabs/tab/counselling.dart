import 'package:flutter/material.dart';

class CounsellingPage extends StatefulWidget {
  const CounsellingPage({super.key});

  @override
  State<CounsellingPage> createState() => _CounsellingPageState();
}

DateTime? selectedDate;
String? bookpress;

class _CounsellingPageState extends State<CounsellingPage> {
  void _bookAppoint() async {
    setState(() {
      bookpress = 'BookAppointment';
    });
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      debugPrint("Selected date: $pickedDate");

      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffddf4f1),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Report Rape"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("It is sad to hear what has happened to You",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic)),
            Text(
              "You are kindly tasked to check what counselling you need!!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
            //One-on-one counselling
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8, 0),
              child: Card(
                child: SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.emoji_emotions),
                        title: Text('One-on-One Counselling'),
                        subtitle: Text('Meet the Counsellor alone at Any time'),
                      ),
                      Row(
                        children: [
                          Spacer(
                            flex: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: _pickDate,
                                child: Text('Book Appoimtment'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //const SizedBox(width: 8),
                      if (selectedDate != null)
                        Text(
                          "Appointment Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      //const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            //Group counselling
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8, 0),
              child: Card(
                child: SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.emoji_emotions_rounded),
                        title: Text('Group Counselling'),
                        subtitle: Text('Need a group Counselling'),
                      ),
                      Row(
                        children: [
                          Spacer(
                            flex: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _bookAppoint,
                                child: Text('Book now'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (bookpress == 'BookAppointment')
                        Text("Group Counselling Booked",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ),
            //Online-counselling
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8, 0),
              child: Card(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.emoji_emotions),
                        title: Text('Online Counselling'),
                        subtitle: Text('Schedule the Counselling while home'),
                      ),
                      Row(
                        children: [
                          Spacer(
                            flex: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // You can navigate to a details page here
                                },
                                child: Text('Book Now'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //const SizedBox(width: 8),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            //open talk counselling
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8, 0),
              child: Card(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.emoji_emotions),
                        title: Text('Interactive Counselling'),
                        subtitle: Text(
                            'Ready to be Open and provide the Information'),
                      ),
                      Row(
                        children: [
                          Spacer(
                            flex: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // You can navigate to a details page here
                                },
                                child: Text('Book Now'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            //Mental rehabilitation
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8, 0),
              child: Card(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.emoji_emotions),
                        title: Text('Mental Rehabilitation'),
                        subtitle:
                            Text('Need to Join the Rehabilitation programme'),
                      ),
                      Row(
                        children: [
                          Spacer(flex: 20),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // You can navigate to a details page here
                                },
                                child: Text('Join Now'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
