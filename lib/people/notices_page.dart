import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notice {
  final String type;
  final String message;
  final DateTime date;

  Notice({required this.type, required this.message, required this.date});
}

class NoticesPage extends StatelessWidget {
  NoticesPage({super.key});

  final List<Notice> notices = [
    Notice(
      type: "Shift Change",
      message:
          "Shift for Aisle 3 staff updated to 10:00 AM - 6:00 PM from 15 June.",
      date: DateTime(2025, 6, 15),
    ),
    Notice(
      type: "Inventory Alert",
      message: "Low stock alert: Milk & Dairy section.",
      date: DateTime(2025, 6, 16),
    ),
    Notice(
      type: "Maintenance",
      message: "POS terminal 4 will be under maintenance on 17 June.",
      date: DateTime(2025, 6, 17),
    ),
    Notice(
      type: "Policy Update",
      message: "New dress code policy effective from 20 June.",
      date: DateTime(2025, 6, 20),
    ),
    Notice(
      type: "Announcement",
      message: "Monthly team meeting on 18 June at 4:00 PM in Meeting Room A.",
      date: DateTime(2025, 6, 18),
    ),
    Notice(
      type: "Emergency Alert",
      message: "Fire drill scheduled for 19 June at 11:00 AM.",
      date: DateTime(2025, 6, 19),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Notices"),
        backgroundColor: Colors.red[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.red),
              title: Text(
                notice.type,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(notice.message),
              trailing: Text(
                DateFormat('dd MMM').format(notice.date),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
