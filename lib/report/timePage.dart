import 'package:flutter/material.dart';

import 'happenedPage.dart';

class TimePage extends StatefulWidget {
  const TimePage({super.key, required this.reportTime});
  final String reportTime;

  @override
  State<TimePage> createState() => _TimePageState();
}

final _formKey = GlobalKey<FormState>();
final _dateController = TextEditingController();
final _districtController = TextEditingController();

class _TimePageState extends State<TimePage> {
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

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Report Recent Incident')),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "When and where did it happen?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 3,
                              style: BorderStyle.solid,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          hintText: 'Date(Optional)',
                          labelText: 'Select Date Of the incident',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "General area or description(No specific address)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black, // background color of the field
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white, // shadow color
                            blurRadius: 5, // softness
                            spreadRadius: 1, // size
                            offset: Offset(0, 4), // position (x, y)
                          ),
                        ],
                      ),
                      child: TextField(
                        maxLines: 4,
                        maxLength: 100,
                        textAlign: TextAlign.start,
                        controller: _districtController,
                        decoration: const InputDecoration(
                          label: Text("Location(Optional)"),
                          fillColor: Colors.black,
                          counterStyle: TextStyle(color: Colors.white),
                          //labelText: 'Location(Optional)',
                          labelStyle: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,

                          // shadow:Color.fromARGB(255, 253, 253, 195),
                          // border: OutlineInputBorder(
                          //   borderSide: BorderSide(
                          //     color: Colors.yellowAccent,
                          //     width: 5,
                          //     style: BorderStyle.solid,
                          //   ),
                          //   borderRadius: BorderRadius.all(Radius.circular(10)),
                          // ),
                          // suffixIcon: Icon(
                          //   Icons.location_on,
                          //   color: Colors.white,
                          // ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final String date = _dateController.text.trim();
                      final String location = _districtController.text.trim();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HappenedPage(
                            reportTime: widget.reportTime,
                            date: date,
                            location: location,
                          ),
                          //builder: (context) => const HappenedPage(date: '',, location: '',),
                        ),
                      );
                    }
                  },
                  child: const Text("Continue"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
