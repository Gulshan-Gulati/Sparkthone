// request_page.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_model.dart'; // Import the Request model

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  RequestPageState createState() => RequestPageState();
}

class RequestPageState extends State<RequestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Optionally, you can filter requests based on status or other criteria
  // For example, only fetch pending requests
  Stream<List<Request>> getRequestsStream() {
    return _firestore
        .collection('Requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Request.fromDocument(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request'),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<List<Request>>(
        stream: getRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching requests: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data;

          if (requests == null || requests.isEmpty) {
            return const Center(child: Text('No pending requests found.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Request request) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: request.status == 'approved'
          ? Colors.green.withOpacity(0.1)
          : request.status == 'denied'
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request ID: ${request.requestId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Station: ${request.stationName}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Requested Items:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...request.requestedItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                      '- ${item.name} (${item.category}): ${item.quantity}'),
                )),
            const SizedBox(height: 8),
            Text(
              'Status: ${_capitalize(request.status)}',
              style: TextStyle(
                color: _getStatusColor(request.status),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: request.status == 'pending'
                      ? () => _handleApprove(request)
                      : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: request.status == 'pending'
                      ? () => _handleDeny(request)
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Deny'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> _handleApprove(Request request) async {
    try {
      // Approve the request by updating the status
      await _firestore
          .collection('Requests')
          .doc(request.requestId)
          .update({'status': 'approved'});

      // Find the police station by stationName from the request
      QuerySnapshot stationQuerySnapshot = await _firestore
          .collection('policestations')
          .where('stationName', isEqualTo: request.stationName)
          .get();

      if (stationQuerySnapshot.docs.isEmpty) {
        throw Exception('Station not found!');
      }

      // Get the first matching station document
      DocumentSnapshot stationSnapshot = stationQuerySnapshot.docs.first;
      DocumentReference stationRef = stationSnapshot.reference;

      // Fetch the current inventory or initialize as an empty list if it doesn't exist
      List<dynamic> stationInventory =
          stationSnapshot.get('stationInventory') ?? [];

      // Process each requested item and fetch the serial numbers from the Central collection
      for (var item in request.requestedItems) {
        // Fetch serial numbers (pserialNo) from the Central collection for this pid
        List<String> serialNumbers =
            await _fetchSerialNumbersFromCentral(item.id, item.quantity);

        // Create a new item map for the inventory
        Map<String, dynamic> newItem = {
          'productName': item.name,
          'productID': item.id, // Assuming the product ID is correct
          'quantity': item.quantity,
          'serialNumbers': serialNumbers,
        };

        // Check if the product already exists in the inventory
        bool productExists = false;
        for (var inventoryItem in stationInventory) {
          if (inventoryItem['productID'] == item.id) {
            // Update the existing item's quantity and serial numbers
            inventoryItem['quantity'] += item.quantity;
            inventoryItem['serialNumbers'].addAll(serialNumbers);
            productExists = true;
            break;
          }
        }

        // If the product does not exist, add a new entry to the inventory
        if (!productExists) {
          stationInventory.add(newItem);
        }
      }

      // Update the station's inventory in Firestore
      await stationRef.update({'stationInventory': stationInventory});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Request ${request.requestId} approved and inventory updated successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error approving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve request: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

// Fetch available serial numbers (pserialNo) from the Central collection for a given pid (productID)
  Future<List<String>> _fetchSerialNumbersFromCentral(
      String pid, int quantity) async {
    List<String> serialNumbers = [];

    try {
      // Query the Central collection to get serial numbers for the given pid
      QuerySnapshot centralSnapshot = await _firestore
          .collection('Central')
          .where('pid', isEqualTo: pid) // Filter by the product ID (pid)
          .where('isAssigned',
              isEqualTo:
                  false) // Assuming you have a flag to indicate unassigned serial numbers
          .limit(
              quantity) // Limit the number of serial numbers to the quantity requested
          .get();

      if (centralSnapshot.docs.isEmpty) {
        throw Exception(
            'No available serial numbers found for product ID: $pid');
      }

      // Fetch the pserialNo from each document in the query results
      for (var doc in centralSnapshot.docs) {
        serialNumbers.add(doc['pserialNo']);

        // Update the document in Central to mark the serial number as assigned
        await doc.reference.update({'isAssigned': true});
      }

      return serialNumbers;
    } catch (e) {
      print('Error fetching serial numbers from Central: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<void> _handleDeny(Request request) async {
    try {
      await _firestore
          .collection('Requests')
          .doc(request.requestId)
          .update({'status': 'denied'});

      // Optionally, you can perform additional actions here, such as:
      // - Sending notifications

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${request.requestId} denied successfully!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error denying request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to deny request: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
