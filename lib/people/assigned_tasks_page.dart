import 'package:flutter/material.dart';

class AssignedTasksPage extends StatelessWidget {
  const AssignedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Your UI here
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assigned Tasks'),
        backgroundColor: Colors.red[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.task),
            title: Text('Shelf Restocking'),
            subtitle: Text('Restock dairy and frozen goods in Aisle 5.'),
            trailing: Text('09:00 AM'),
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text('Customer Support Desk'),
            subtitle: Text('Assist customers with returns and queries.'),
            trailing: Text('12:00 PM'),
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Inventory Count'),
            subtitle: Text('Check inventory in Electronics section.'),
            trailing: Text('05:00 PM'),
          ),
        ],
      ),
    );
  }
}
