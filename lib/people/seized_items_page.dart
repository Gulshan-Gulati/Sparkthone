import 'package:flutter/material.dart';

// SeizedItemsPage Widget for showing seized items to the public
class SeizedItemsPage extends StatelessWidget {
  final List<SeizedItem> _seizedItems = [
    SeizedItem(
      name: "Confiscated Car",
      description: "2017 Honda Civic, seized due to traffic violations.",
      penaltyCost: 1500,
      itemType: "Confiscated",
      stationName: "Central Police Station",
      productId: "ST001",
    ),
    SeizedItem(
      name: "Recovered Bike",
      description: "Stolen Yamaha R15 found by the police.",
      penaltyCost: 0,
      itemType: "Recovered",
      stationName: "West Side Police Station",
      productId: "ST002",
    ),
    SeizedItem(
      name: "Seized Cloths",
      description: "Television seized in a smuggling case.",
      penaltyCost: 500,
      itemType: "Confiscated",
      stationName: "East Side Police Station",
      productId: "ST003",
    ),
    SeizedItem(
      name: "Stolen Jewelry",
      description: "Gold ring recovered by the police from a robbery case.",
      penaltyCost: 0,
      itemType: "Recovered",
      stationName: "North Side Police Station",
      productId: "ST004",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seized and Recovered Items'),
        backgroundColor: Colors.red[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seizedItems.length,
        itemBuilder: (context, index) {
          final item = _seizedItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(item.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  item.penaltyCost > 0
                      ? Text(
                          'Penalty Cost to Free: \$${item.penaltyCost.toStringAsFixed(2)}',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.red),
                        )
                      : const Text(
                          'This item has been recovered by the police.',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                  const SizedBox(height: 10),
                  Text(
                    'Item Type: ${item.itemType}',
                    style: TextStyle(
                      fontSize: 16,
                      color: item.itemType == "Confiscated"
                          ? Colors.orange
                          : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Station Name and ID
                  Text(
                    'Station Name: ${item.stationName}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Text(
                    'Station ID: ${item.productId}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// SeizedItem model to store item data
class SeizedItem {
  final String name;
  final String description;
  final double penaltyCost;
  final String itemType; // 'Confiscated' or 'Recovered'
  final String stationName;
  final String productId;

  SeizedItem({
    required this.name,
    required this.description,
    required this.penaltyCost,
    required this.itemType,
    required this.stationName,
    required this.productId,
  });
}
