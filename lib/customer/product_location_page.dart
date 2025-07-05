import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductLocationPage extends StatefulWidget {
  const ProductLocationPage({super.key});

  @override
  State<ProductLocationPage> createState() => _ProductLocationPageState();
}

class _ProductLocationPageState extends State<ProductLocationPage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  String? _selectedDocumentID;
  String? _googleMapsUrl;
  List<String> _documentIDs = [];

  String? _pname;
  String? _pcategory;

  @override
  void initState() {
    super.initState();
    _fetchDocumentIDs();
  }

  Future<void> _fetchDocumentIDs() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('location').get();

      setState(() {
        _documentIDs = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print("Error fetching document IDs: $e");
    }
  }

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

  void _generateGoogleMapsUrl(String latitude, String longitude) {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    setState(() {
      _googleMapsUrl = googleMapsUrl.toString();
      _disposeFields();
    });
  }

  void _disposeFields() {
    _latitudeController.clear();
    _longitudeController.clear();
    _selectedDocumentID = null;
    _pname = null;
    _pcategory = null;
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Location'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Select Serial No:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
                    _fetchProductData(_selectedDocumentID!);
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
              readOnly: true,
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
              readOnly: true,
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Generate URL'),
            ),
            const SizedBox(height: 20),
            if (_googleMapsUrl != null)
              InkWell(
                onTap: () => _launchURL(_googleMapsUrl!),
                child: const Text(
                  'Live Location',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
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
