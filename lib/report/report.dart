import 'package:flutter/material.dart';
import 'package:safehome/report/timePage.dart';
import 'package:safehome/tabs/tab/functions.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

final _formKey = GlobalKey<FormState>();

class _ReportPageState extends State<ReportPage> {
  final _dateController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dOBController = TextEditingController();
  final _villageNameController = TextEditingController();
  final _subcountyNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _countryNameController = TextEditingController();
  final _rapistNameController = TextEditingController();
  final _rapistLocationController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(
          ' ',
        )[0]; // Format as YYYY-MM-DD
      });
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dOBController.text = "${picked.toLocal()}".split(
          ' ',
        )[0]; // Format as YYYY-MM-DD
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffddf4f1),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Report Rape"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "It is sad to hear what has happened to You",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Text(
              "You are kindly asked to REPORT to us and we shall respond in realtime",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            //Text("Enter the name", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                //decoration: BoxDecoration(color: Colors.white),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: TextFormField(
                            controller: _firstnameController,
                            decoration: const InputDecoration(
                              labelText: "Enter First Name",
                              border: OutlineInputBorder(),
                              hintText: 'Enter First Name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Enter Last Name',
                              border: OutlineInputBorder(),
                              hintText: 'Enter Last Name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: TextFormField(
                            controller: _dOBController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'D.O.B',
                              fillColor: Colors.black,
                              labelText: 'Date Of Birth',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () => _selectDOB(context),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text(
                              "YOUR RESIDENCE",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    controller: _villageNameController,
                                    decoration: const InputDecoration(
                                      labelText: "Village",
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Your Village',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    controller: _subcountyNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Subcounty',
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Your Subcounty',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    controller: _districtNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'District',
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Your District',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    controller: _countryNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Country',
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Your Country',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: TextField(
                            controller: _rapistNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Name Of the Person if Known',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: TextField(
                            controller: _rapistLocationController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:
                                  'Enter Location of the Rapist if you know',
                            ),
                          ),
                        ),
                      ),
                      /*TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),*/
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select Date of Rape',
                              fillColor: Colors.black,
                              labelText: 'Select Date Of Rape',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 20),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            fixedSize: Size(150, 50),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // all fields valid
                              debugPrint("Form is valid!");
                              debugPrint(_dateController.text.toUpperCase());
                              debugPrint(_dOBController.text);
                              debugPrint(
                                _firstnameController.text.toLowerCase(),
                              );
                              debugPrint(_lastNameController.text.toString());
                              debugPrint(
                                _countryNameController.text.toUpperCase(),
                              );
                              debugPrint(_villageNameController.text);
                              debugPrint(_subcountyNameController.text.trim());
                              debugPrint(_districtNameController.text.trim());
                              debugPrint(_rapistNameController.text.trim());
                              debugPrint(_rapistLocationController.text.trim());

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Success"),
                                  content: Text(
                                    "Report successfully Submitted!",
                                  ),
                                  actions: [
                                    TextButton(
                                      style: ButtonStyle(),
                                      onPressed: () {
                                        //Navigator.pop(context, 'Cancel');
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                                barrierDismissible: false,
                              );
                            }
                          },
                          child: Text("SUBMIT"),
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
    );
  }
}

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 56, 21),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 0, 56, 21),
        title: Text(
          "REPORT INCIDENT",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     "Your safety is our priority. Your reports are confidential and secure.",
            //     textAlign: TextAlign.left,
            //     style: TextStyle(
            //       fontSize: 18,
            //       color: Colors.white,
            //       //fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff1e3d20),
                  border: const Border(
                    left: BorderSide(color: Colors.green, width: 5),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: Colors.white,
                          size: 30,
                          weight: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Safe and Confidential",
                                style: TextStyle(
                                  color: Color(0xff7ee183),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Your information is encrypted and only shared with authorities if you choose. You can report anonymously",
                                style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "What would you like to report?",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff391310),
                  border: const Border(
                    left: BorderSide(color: Colors.red, width: 2),
                    top: BorderSide(color: Colors.red, width: 2),
                    right: BorderSide(color: Colors.red, width: 2),
                    bottom: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.privacy_tip,
                          color: Colors.red,
                          size: 30,
                          weight: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ongoing Sitution",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Text(
                                "Report an incident that is currently happening or ongoing",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              //const Divider(color: Colors.red),
                              ListTile(
                                style: ListTileStyle.drawer,
                                shape: Border(
                                  top: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Immediate Danger',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        "If you are in immediate danger, please call emergency services right away. Would like to call for help now or continue with the report?",
                                      ),
                                      actions: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            8.0,
                                            0,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              String phoneNumber = '911';
                                              openDialer(phoneNumber);
                                            },
                                            child: const Text('Call 911'),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            10.0,
                                            0,
                                            0,
                                            0,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              String reportTime =
                                                  "Ongoing Situation";
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TimePage(
                                                        reportTime: reportTime,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Continue Report',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.red,
                                  weight: 20,
                                ),
                                title: const Text(
                                  "Start Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff48452a),
                  border: const Border(
                    left: BorderSide(color: Colors.yellow, width: 2),
                    right: BorderSide(color: Colors.yellow, width: 2),
                    bottom: BorderSide(color: Colors.yellow, width: 2),
                    top: BorderSide(color: Colors.yellow, width: 2),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.privacy_tip,
                          color: Colors.yellow,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recent Incident",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Report incident that happened recently(Within 72 hours)",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  String reportTime = "Recent Incident";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TimePage(reportTime: reportTime),
                                    ),
                                  );
                                },
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.yellow,
                                ),
                                title: const Text(
                                  "Start Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff273b4c),
                  border: const Border(
                    left: BorderSide(color: Colors.blue, width: 2),
                    top: BorderSide(color: Colors.blue, width: 2),
                    bottom: BorderSide(color: Colors.blue, width: 2),
                    right: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.report, color: Colors.blue, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Past Incident",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Report incident that happened in the past(Later than 3 days)",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  String reportTime = "Past Incident";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TimePage(reportTime: reportTime),
                                    ),
                                  );
                                },
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                title: const Text(
                                  "Start Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff365637),
                  border: const Border(
                    left: BorderSide(color: Colors.green, width: 2),
                    right: BorderSide(color: Colors.green, width: 2),
                    bottom: BorderSide(color: Colors.green, width: 2),
                    top: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.remove_red_eye,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Suspected/Witnessed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Report incident that you suspect or witnessed happening to someone",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              ListTile(
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                title: const Text(
                                  "Start Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                onTap: () {
                                  String reportTime = "Suspected Incident";
                                  Navigator.pop(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TimePage(reportTime: reportTime),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff383535),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person_add,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Anonymous Reporting",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "You can choose to report anonymously. Your identity will not be recorded or shared with anyone",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  8.0,
                                  0,
                                  0,
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.lock,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    "Anonymous Report",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {},
                                  tileColor: Colors.blue,
                                  selectedColor: Colors.blue,
                                  selectedTileColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff391310),
                  border: const Border(
                    left: BorderSide(color: Colors.red, width: 2),
                    top: BorderSide(color: Colors.red, width: 2),
                    bottom: BorderSide(color: Colors.red, width: 2),
                    right: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                //color: Colors.teal[100],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.call, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Need Immediate Help?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "If you're in immediate danger, don't wait. Call emergency services right now.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  8.0,
                                  0,
                                  0,
                                ),
                                child: ListTile(
                                  tileColor: Colors.red,
                                  leading: Icon(
                                    Icons.call,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Call Emergency Services",
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
