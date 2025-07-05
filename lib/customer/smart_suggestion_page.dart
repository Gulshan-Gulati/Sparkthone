import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SmartSuggestionPage extends StatelessWidget {
  const SmartSuggestionPage({super.key});

  Future<List<Map<String, dynamic>>> getLowStockSuggestions() async {
    final firestore = FirebaseFirestore.instance;

    // Step 1: Get products with low quantity
    final lowStockSnapshot = await firestore
        .collection('products')
        .where('quantity', isLessThan: 5)
        .get();

    List<Map<String, dynamic>> suggestions = [];

    for (var doc in lowStockSnapshot.docs) {
      final product = doc.data();
      final item = product['item'];
      final brand = product['brand'];
      final category = product['category'];

      // Step 2: Search for similar items with different brand and available stock
      final altSnapshot = await firestore
          .collection('products')
          .where('item', isEqualTo: item)
          .where('category', isEqualTo: category)
          .where('brand', isNotEqualTo: brand)
          .where('quantity', isGreaterThan: 0)
          .get();

      if (altSnapshot.docs.isNotEmpty) {
        final replacement = altSnapshot.docs.first.data();

        suggestions.add({
          "original": product,
          "alternative": replacement,
        });
      }
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Suggestions"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getLowStockSuggestions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final suggestions = snapshot.data!;
          if (suggestions.isEmpty) {
            return const Center(child: Text("No low stock alerts found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final original = suggestions[index]["original"];
              final alternative = suggestions[index]["alternative"];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text("${original['item']} (${original['brand']}) is low"),
                  subtitle: Text("Try ${alternative['brand']} (In Stock: ${alternative['quantity']})"),
                  trailing: const Icon(Icons.swap_horiz),
                  onTap: () {
                    // TODO: You can redirect to product order or view screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
