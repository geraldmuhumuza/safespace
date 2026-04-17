import 'package:flutter/material.dart';

//Personal Information from the Profile page in
class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final _firstnameController = TextEditingController();
  final _dOBController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
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
    _dOBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Back")),
      body: SingleChildScrollView(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: "Contact Number",
                    border: OutlineInputBorder(),
                    hintText: 'Enter your Contact Number',
                  ),
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
          ],
        ),
      ),
    );
  }
}
