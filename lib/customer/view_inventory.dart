import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewInventoryScreen extends StatefulWidget {
  const ViewInventoryScreen({super.key});

  @override
  State<ViewInventoryScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<ViewInventoryScreen> {
  String searchQuery = "";
  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Electronics',
    'Grocery',
    'Clothing',
    'Shoes',
    'Toys',
    'Sports',
    'Pharmacy',
    'Furniture'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Inventory Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              searchController.clear();
              searchQuery = "";
              selectedCategory = 'All';
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // 🔹 Search Box
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search by item name",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 🔹 Category Dropdown (Keep it beside the search box)
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 🔹 Search Button (placed below the search bar)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text("Search"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        searchQuery =
                            searchController.text.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Inventory List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inventory')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final category = doc['category'].toString();

                  final nameMatch = name.contains(searchQuery);
                  final categoryMatch =
                      selectedCategory == 'All' || selectedCategory == category;

                  return nameMatch && categoryMatch;
                }).toList();

                if (documents.isEmpty) {
                  return const Center(child: Text("No items found."));
                }

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final item = documents[index];
                    final name = item['name'];
                    final category = item['category'];
                    final quantity = item['quantity'];
                    final restockDate = item['lastRestocked'];

                    final isLowStock = quantity < 10;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.inventory,
                          color: isLowStock ? Colors.red : Colors.teal,
                          size: 30,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "Category: $category\nQuantity: $quantity\nLast Restocked: $restockDate",
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: isLowStock
                            ? const Icon(Icons.warning, color: Colors.red)
                            : const Icon(Icons.check_circle,
                                color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
