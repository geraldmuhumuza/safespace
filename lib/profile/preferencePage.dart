import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Data Preferences",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: const Color.fromARGB(255, 103, 74, 107),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 103, 74, 107),
              width: double.infinity,
              child: Column(
                children: [
                  Card(
                    color: const Color(0x61272626),
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.private_connectivity,
                        size: 24,
                        color: Colors.white,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "Data collection",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "Information used and obtained from Safespace. Location and contacts To change the apps from which data can be collected, .......",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    color: const Color(0x61272626),
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.private_connectivity,
                        size: 24,
                        color: Colors.white,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "Data sharing",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "Data collected can be shared with the police, hospitals and other emergency services. If you don't wish your data to be shared, you can opt out",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    color: const Color(0x61272626),
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.private_connectivity,
                        size: 24,
                        color: Colors.white,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "Data sharing consent",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "You can opt in and out whenever you don't feel safe",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            Text("Security Preferences"),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 73, 73, 73),
              child: Column(
                children: [
                  //Authentication: PINs, passwords, biometrics, 2FA.

                  // Authorization: Who can view, edit, or delete data.

                  // Encryption: Data encrypted at rest and in transit.

                  // Access logs & monitoring: Track who accessed data and when.

                  // Backup & recovery: Prevent data loss.

                  // Device permissions: Control access to camera, GPS, contacts, Bluetooth, etc.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
