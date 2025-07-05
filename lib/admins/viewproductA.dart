import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SerialNumberScreen extends StatelessWidget {
  final String productId;

  SerialNumberScreen({required this.productId});

  // Function to fetch serial numbers for a specific product ID
  Stream<QuerySnapshot> getSerialNumbers() {
    return FirebaseFirestore.instance
        .collection("Central")
        .where('pid', isEqualTo: productId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serial Numbers'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getSerialNumbers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final serialNumbers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: serialNumbers.length,
            itemBuilder: (context, index) {
              final serialNumber = serialNumbers[index];
              String serialNo = serialNumber['pserialNo'];
              bool isAssigned = serialNumber['isAssigned'];

              // Determine text and color based on isAssigned status
              String allocationStatus = isAssigned ? 'Allocated' : 'Not Allocated';
              Color textColor = isAssigned ? Colors.red : Colors.green;

              return ListTile(
                title: Text(
                  '$serialNo - $allocationStatus',
                  style: TextStyle(color: textColor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
