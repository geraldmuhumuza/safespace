// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SuspisionPage extends StatefulWidget {
  const SuspisionPage({super.key});

  @override
  State<SuspisionPage> createState() => _SuspisionPageState();
}

class _SuspisionPageState extends State<SuspisionPage> {
  //final LatLng _center = const LatLng(37.7749, -122.4194);
  // ignore: unused_field
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation!, 15.0);
    } catch (e) {
      debugPrint("Error getting location: $e");
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
            Text(
              "Suspicious of the people around You!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              "Kindly Share your Location for the rescue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: BorderSide(color: Color(0xff4c76af), width: 3),
                    right: BorderSide(color: Color(0xff4c76af), width: 3),
                    top: BorderSide(color: Color(0xff4c76af), width: 3),
                    bottom: BorderSide(color: Color(0xff4c76af), width: 3),
                  ),
                ),
                height: 450,
                child: _currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _currentLocation!, // Example: San Francisco
                          initialZoom: 13.0,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation =
                                  _currentLocation!; // save tapped point
                            });

                            // show alert dialog with coordinates
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Location Selected'),
                                content: Text(
                                  'Latitude: ${point.latitude.toStringAsFixed(6)}\n'
                                  'Longitude: ${point.longitude.toStringAsFixed(6)}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        children: [
                          TileLayer(
                            // This uses free OpenStreetMap tiles
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.yourapp',
                          ),
                          //if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLocation!,
                                width: 60,
                                height: 60,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocation =
                            _currentLocation!; // save tapped point
                      });
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Location Selected'),
                          content: Text(
                            'Latitude: ${_currentLocation!.latitude.toStringAsFixed(6)}\n'
                            'Longitude: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text("Send An Alert Message"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
