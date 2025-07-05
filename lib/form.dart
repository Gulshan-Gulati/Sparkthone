// import 'package:flutter/material.dart';
// import 'database_services.dart'; // Import the DatabaseServices class

// class SimpleForm extends StatelessWidget {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final DatabaseServices _databaseServices = DatabaseServices();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Form Page'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _ageController,
//               decoration: const InputDecoration(labelText: 'Age'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _locationController,
//               decoration: const InputDecoration(labelText: 'Location'),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: () async {
//                 final name = _nameController.text;
//                 final age = _ageController.text;
//                 final location = _locationController.text;

//                 if (name.isNotEmpty && age.isNotEmpty && location.isNotEmpty) {
//                   try {
//                     await _databaseServices.addProduct(name, age, location);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('Data submitted successfully')),
//                     );
//                     _nameController.clear();
//                     _ageController.clear();
//                     _locationController.clear();
//                   } catch (e) {
//                     debugPrint(
//                         'Error: $e'); // Add this line for additional debugging
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error submitting data: $e')),
//                     );
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill all fields')),
//                   );
//                 }
//               },

//               child: const Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
