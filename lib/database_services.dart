import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // For generating random request ID

class DatabaseServices {
  // Function to add a product to the "Central" collection
  Future<void> addProduct(Map<String, dynamic> productInfoMap, String id,
      BuildContext context) async {
    // Check if a product with the same serial number already exists
    final existingProductSnapshot = await FirebaseFirestore.instance
        .collection("Central")
        .where('pserialNo', isEqualTo: productInfoMap['pserialNo'])
        .limit(1)
        .get();

    if (existingProductSnapshot.docs.isNotEmpty) {
      // Show a SnackBar if the product exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unit already present in Inventory"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Add additional fields to the product information
    productInfoMap['status'] = 'In Service';
    productInfoMap['isAssigned'] = false;
    productInfoMap['purchaseDate'] = DateTime.now();
    productInfoMap['lastMaintenance'] = 'None';
    productInfoMap['nextMaintenanceDue'] =
        DateTime.now().add(Duration(days: 30));
    productInfoMap['maintenanceHistory'] = 'None';

    // Set the document in Firestore
    return await FirebaseFirestore.instance
        .collection("Central")
        .doc(id)
        .set(productInfoMap);
  }

  // Function to make a request
  Future<void> makeRequest({
    required String productId,
    required String stationName,
    required List<Map<String, dynamic>> requestedItems,
  }) async {
    // Generate a random request ID
    String requestId = _generateRequestId();

    // Create the request map
    Map<String, dynamic> requestMap = {
      "requestId": requestId, // Generated request ID
      "productId": productId, // ID of the requesting station
      "stationName": stationName, // Name of the requesting station
      "requestedItems": requestedItems, // List of requested items
      "requestDate": DateTime.now(), // Current date and time
      "status": "pending", // Status is always "pending"
    };

    // Add the request to the "Requests" collection in Firestore
    return await FirebaseFirestore.instance
        .collection("Requests")
        .doc(requestId)
        .set(requestMap);
  }

  // Private function to generate a random request ID
  String _generateRequestId() {
    var random = Random();
    String requestId = '';
    for (int i = 0; i < 8; i++) {
      requestId += random.nextInt(9).toString();
    }
    return requestId;
  }
}
