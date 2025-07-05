import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Add the url_launcher package

class BluetoothTrackingScreen extends StatefulWidget {
  @override
  _BluetoothTrackingScreenState createState() =>
      _BluetoothTrackingScreenState();
}

class _BluetoothTrackingScreenState extends State<BluetoothTrackingScreen> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  String? _selectedDocumentID; // For dropdown menu selection
  String? _googleMapsUrl; // Variable to store the generated URL
  List<String> _documentIDs = []; // List to store document IDs

  String? _pname; // Store fetched pname
  String? _pcategory; // Store fetched pcategory

  @override
  void initState() {
    super.initState();
    _fetchDocumentIDs(); // Fetch document IDs on initialization
  }

  // Fetch document IDs from Firestore location collection
  Future<void> _fetchDocumentIDs() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('location').get();

      print("Fetched ${snapshot.docs.length} documents from 'location'");

      setState(() {
        _documentIDs = snapshot.docs.map((doc) => doc.id).toList();
      });

      for (var doc in _documentIDs) {
        print("Document ID: $doc");
      }
    } catch (e) {
      print("Error fetching document IDs: $e");
    }
  }


  // Fetch lat and lon from Firestore when a document ID is selected
  Future<void> _fetchLocationData(String documentID) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('location')
        .doc(documentID)
        .get();

    if (doc.exists) {
      setState(() {
        _latitudeController.text = doc['lat'].toString();
        _longitudeController.text = doc['lon'].toString();
      });
    }
  }

  // Fetch pname and pcategory from Central collection in Firestore
 // Fetch pname and pcategory from Central collection based on pserialNo
Future<void> _fetchProductData(String pserialNo) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Central')
      .where('pserialNo', isEqualTo: pserialNo)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    setState(() {
      _pname = doc['pname'];
      _pcategory = doc['pcategory'];
    });
  } else {
    // Handle case where no matching document is found
    setState(() {
      _pname = null;
      _pcategory = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No product found for the entered serial number.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // Generate the Google Maps URL from latitude and longitude
  void _generateGoogleMapsUrl(String latitude, String longitude) {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    setState(() {
      _googleMapsUrl = googleMapsUrl.toString(); // Store the generated URL
      _disposeFields(); // Dispose fields after submission
    });
  }

  // Dispose fields after submission
  void _disposeFields() {
    _latitudeController.clear();
    _longitudeController.clear();
    _selectedDocumentID = null;
    _pname = null;
    _pcategory = null;
  }

  // Function to launch the URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Location Tracker'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Serial No:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Dropdown menu to select document ID
            DropdownButton<String>(
              hint: const Text('Select Document ID'),
              value: _selectedDocumentID,
              isExpanded: true,
              items: _documentIDs.map((String docID) {
                return DropdownMenuItem<String>(
                  value: docID,
                  child: Text(docID),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDocumentID = newValue;
                  if (_selectedDocumentID != null) {
                    _fetchLocationData(_selectedDocumentID!);
                    _fetchProductData(_selectedDocumentID!); // Fetch pname and pcategory
                  }
                });
              },
            ),

            

            const SizedBox(height: 20),
            if (_pname != null && _pcategory != null) ...[
              Text(
                'Product Name: $_pname',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Product Category: $_pcategory',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _latitudeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Latitude',
                hintText: 'Auto-filled latitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              readOnly: true, // Make the field read-only
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _longitudeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Longitude',
                hintText: 'Auto-filled longitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              readOnly: true, // Make the field read-only
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String latitude = _latitudeController.text;
                final String longitude = _longitudeController.text;
                if (latitude.isNotEmpty && longitude.isNotEmpty) {
                  _generateGoogleMapsUrl(latitude, longitude);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both latitude and longitude'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Generate URL'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            if (_googleMapsUrl != null) // Check if the URL is generated
              InkWell(
                onTap: () => _launchURL(_googleMapsUrl!),
                child: const Text(
                  'Live Location',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
