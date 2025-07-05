import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewInventory extends StatefulWidget {
  const ViewInventory({super.key});

  @override
  ViewInventoryState createState() => ViewInventoryState();
}

class ViewInventoryState extends State<ViewInventory> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedstationName; // Stores the selected station name
  String _selectedproductId = ''; // Stores the corresponding station ID
  List<StationInventoryItem> _inventory = [];
  List<Map<String, String>> _stations =
      []; // List to store station names and IDs
  bool _isLoadingStations =
      true; // Tracks whether the stations are being fetched
  bool _isLoadingInventory =
      false; // Tracks whether the inventory is being fetched

  @override
  void initState() {
    super.initState();
    _fetchStations(); // Fetch police stations when the screen is initialized
  }

  // Fetch the list of police stations from Firestore
  Future<void> _fetchStations() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('policestations').get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _stations = snapshot.docs.map((doc) {
            return {
              'stationName': doc.data().containsKey('stationName')
                  ? doc['stationName'] as String
                  : 'Unknown Station',
              'productId': doc.data().containsKey('productId')
                  ? doc['productId'] as String
                  : '',
            };
          }).toList();
          _isLoadingStations =
              false; // Set loading to false after data is fetched
        });
      } else {
        setState(() {
          _isLoadingStations = false;
        });
      }
    } catch (e) {
      print('Error fetching stations: $e');
      setState(() {
        _isLoadingStations = false; // Handle error state
      });
    }
  }

  // Fetch inventory data for the selected station
  Future<void> _fetchInventory() async {
    try {
      // Get the document of the current station
      final snapshot = await FirebaseFirestore.instance
          .collection('policestations')
          .where('productId', isEqualTo: _selectedproductId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          var data = snapshot.docs.first.data();
          // Cast each item from dynamic to StationInventoryItem
          _inventory = (data['stationInventory'] as List<dynamic>).map((item) {
            return StationInventoryItem(
              productId: item['productID'] ?? '',
              productName: item['productName'] ?? 'Unknown Product',
              quantity: int.tryParse(item['quantity'].toString()) ??
                  0, // Convert to int safely
              serialNumbers: List<String>.from(item['serialNumbers'] ?? []),
            );
          }).toList();
        });
      } else {
        print('No inventory found for station ID: $_selectedproductId');
      }
    } catch (e) {
      print('Error fetching inventory: $e');
    }
  }

  // Submit form and fetch the inventory
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _fetchInventory(); // Fetch the inventory after form submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Inventory'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Show loading indicator while stations are being fetched
                  _isLoadingStations
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Walmart Shop Place'),
                          value: _selectedstationName,
                          items: _stations.map((station) {
                            return DropdownMenuItem<String>(
                              value:
                                  station['stationName'], // Station name as value
                              child: Text(station[
                                  'stationName']!), // Display station name
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedstationName = value!;
                              _selectedproductId = _stations.firstWhere(
                                  (station) =>
                                      station['stationName'] ==
                                      value)['productId']!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a police station';
                            }
                            return null;
                          },
                        ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Walmart Shop ID'),
                    readOnly: true,
                    controller: TextEditingController(text: _selectedproductId),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoadingInventory
                ? const CircularProgressIndicator() // Show loading while fetching inventory
                : Expanded(
                    child: _inventory.isEmpty
                        ? const Center(child: Text('No inventory data'))
                        : ListView.builder(
                            itemCount: _inventory.length,
                            itemBuilder: (context, index) {
                              return _buildInventoryCard(_inventory[index]);
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  // Widget to build each inventory item card
  Widget _buildInventoryCard(StationInventoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: const Icon(Icons.image, size: 40), // Placeholder icon
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Product ID: ${item.productId}'),
                  Text('Quantity: ${item.quantity}'),
                  Text('Serial No: ${item.serialNumbers.join(", ")}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for inventory item
class StationInventoryItem {
  final String productId;
  final String productName;
  final int quantity;
  final List<String> serialNumbers;

  StationInventoryItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.serialNumbers,
  });
}
