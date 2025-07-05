import 'package:flutter/material.dart';

class InventoryItem {
  final String name;
  final String category;
  final String serialNumber;
  final String status;

  InventoryItem({
    required this.name,
    required this.category,
    required this.serialNumber,
    required this.status,
  });
}

class InventoryPage extends StatelessWidget {
  InventoryPage({super.key});

  final List<InventoryItem> items = [
    InventoryItem(name: 'Football', category: 'Sports', serialNumber: 'WT12345', status: 'Available'),
    InventoryItem(name: 'First Aid Kit', category: 'Medical', serialNumber: 'FAK98765', status: 'Used'),
    InventoryItem(name: 'Running Shoes', category: 'Shoes', serialNumber: 'BPV54321', status: 'Available'),
    InventoryItem(name: 'Shirt', category: 'Cloth', serialNumber: 'TC00123', status: 'In Use'),
    InventoryItem(name: 'Laptop', category: 'Electronics', serialNumber: 'LTP77654', status: 'Under Repair'),
    InventoryItem(name: 'Body wash', category: 'Beauty Product', serialNumber: 'BPP77654', status: 'Available'),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.red[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${item.category}'),
                  Text('Serial: ${item.serialNumber}'),
                  Text('Status: ${item.status}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
