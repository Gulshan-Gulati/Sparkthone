import 'package:flutter/material.dart';

// Item Model for Auction
class AuctionItem {
  String name;
  String description;
  double startingBid;
  double currentBid;
  String stationName;
  String productId;

  AuctionItem({
    required this.name,
    required this.description,
    required this.startingBid,
    required this.stationName,
    required this.productId,
  }) : currentBid = startingBid;
}

// Auction Simulation Page
class AuctionPage extends StatefulWidget {
  const AuctionPage({super.key});

  @override
  _AuctionPageState createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> {
  // List of auction items (simulated)
  final List<AuctionItem> auctionItems = [
    AuctionItem(
      name: 'Seized Car',
      description: '2018 Ford Mustang, low mileage, excellent condition.',
      startingBid: 10000,
      stationName: 'Central Station',
      productId: 'ST001',
    ),
    AuctionItem(
      name: 'Confiscated Jewelry',
      description: 'Diamond necklace with 18k gold.',
      startingBid: 5000,
      stationName: 'West Side Station',
      productId: 'ST002',
    ),
    AuctionItem(
      name: 'Seized Cloths',
      description: 'Apple MacBook Pro 2021, barely used.',
      startingBid: 2000,
      stationName: 'East Side Station',
      productId: 'ST003',
    ),
    AuctionItem(
      name: 'Seized Bike',
      description: '2021 Ducati Monster 821, used.',
      startingBid: 8000,
      stationName: 'North Side Station',
      productId: 'ST004',
    ),
    // Adding old furniture to the auction
    AuctionItem(
      name: 'Old Furniture Set',
      description: 'Vintage wooden dining table set, minor wear.',
      startingBid: 1500,
      stationName: 'South Station',
      productId: 'ST005',
    ),
    // Adding computer cards to the auction
    AuctionItem(
      name: 'Seized Computer Graphics Card',
      description: 'NVIDIA GeForce RTX 3080, new condition.',
      startingBid: 1000,
      stationName: 'West Side Station',
      productId: 'ST006',
    ),
    AuctionItem(
      name: 'Seized Computer Network Card',
      description: 'Intel X540-T2 Dual Port 10GbE, used.',
      startingBid: 300,
      stationName: 'Central Station',
      productId: 'ST007',
    ),
  ];

  // Function to place a bid on an item
  void _placeBid(AuctionItem item) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _bidController = TextEditingController();
        return AlertDialog(
          title: Text('Place a Bid for ${item.name}'),
          content: TextField(
            controller: _bidController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter your bid'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final double? bid = double.tryParse(_bidController.text);
                if (bid != null && bid > item.currentBid) {
                  setState(() {
                    item.currentBid = bid;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Bid placed successfully for ${item.name}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bid must be higher than the current bid!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Place Bid'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction Simulation'),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: auctionItems.length,
          itemBuilder: (context, index) {
            final item = auctionItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Starting Bid: \$${item.startingBid.toStringAsFixed(2)}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      'Current Highest Bid: \$${item.currentBid.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Station Name: ${item.stationName}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      'Station ID: ${item.productId}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: () => _placeBid(item),
                      child: const Text(
                        'Place a Bid',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
