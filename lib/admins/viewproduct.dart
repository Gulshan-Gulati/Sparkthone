import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart'; // Add this package to your pubspec.yaml
import 'viewproductA.dart'; // Import the SerialNumberScreen

class ViewProducts extends StatefulWidget {
  @override
  _ViewProductsState createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  // Function to fetch product data from Firestore
  Stream<QuerySnapshot> getProducts() {
    return FirebaseFirestore.instance.collection('Central').snapshots();
  }

  // Function to group products by product ID
  Map<String, List<QueryDocumentSnapshot>> groupProducts(List<QueryDocumentSnapshot> products) {
    return groupBy(products, (QueryDocumentSnapshot product) => product['pid']);
  }

  // Function to calculate available quantity
  int calculateAvailable(int quantity, int allotted) {
    return quantity - allotted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Products'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Group products by product ID
          final products = snapshot.data!.docs;
          final groupedProducts = groupProducts(products);

          return ListView.builder(
            itemCount: groupedProducts.length,
            itemBuilder: (context, index) {
              // Get the group key (product ID)
              final productId = groupedProducts.keys.elementAt(index);
              final productGroup = groupedProducts[productId]!;

              // Calculate totals for the grouped product
              String productName = productGroup.first['pname'];
              String productCategory = productGroup.first['pcategory'];

              // Initialize totals
              int totalQuantity = 0;
              int totalAllotted = 0;

              // Loop through each product in the group to calculate totals
              for (var product in productGroup) {
                totalQuantity += 1;
                String assignedTo = (product.data() as Map<String, dynamic>)['assignedTo'] as String? ?? 'None';
                if (assignedTo != 'None') {
                  totalAllotted += 1; // Increment allocated count if assigned
                }
              }

              // Calculate available units
              int available = calculateAvailable(totalQuantity, totalAllotted);

              return Card(
                elevation: 5,
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('Product ID: $productId'),
                      Text('Category: $productCategory'),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Allotted: $totalAllotted'),
                          GestureDetector(
                            onTap: () {
                              // Navigate to SerialNumberScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SerialNumberScreen(productId: productId),
                                ),
                              );
                            },
                            child: Text(
                              'Quantity: $totalQuantity',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('Available: $available'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
