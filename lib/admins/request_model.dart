import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String requestId;
  final String productId;
  final String stationName;
  final List<RequestedItem> requestedItems;
  final DateTime requestDate;
  final String status;

  Request({
    required this.requestId,
    required this.productId,
    required this.stationName,
    required this.requestedItems,
    required this.requestDate,
    required this.status,
  });

  // Factory constructor to create a Request from Firestore DocumentSnapshot
  factory Request.fromDocument(DocumentSnapshot doc) {
    return Request(
      requestId: doc['requestId'] ?? '',
      productId: doc['productId'] ?? '',
      stationName: doc['stationName'] ?? '',
      requestedItems: (doc['requestedItems'] as List<dynamic>?)
              ?.map((item) => RequestedItem.fromMap(item))
              .toList() ??
          [],
      requestDate:
          (doc['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: doc['status'] ?? 'pending',
    );
  }
}

class RequestedItem {
  final String category;
  final String name;
  final String id;
  final int quantity;

  RequestedItem({
    required this.category,
    required this.name,
    required this.id,
    required this.quantity,
  });

  factory RequestedItem.fromMap(Map<String, dynamic> map) {
    return RequestedItem(
      category: map['category'] ?? '',
      name: map['name'] ?? '',
      id: map['id'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }
}
