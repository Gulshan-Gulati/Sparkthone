import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteProduct extends StatefulWidget {
  const DeleteProduct({super.key});

  @override  
  DeleteProductState createState() => DeleteProductState();
}

class DeleteProductState extends State<DeleteProduct> {
  final TextEditingController _quantityController = TextEditingController();
  List<TextEditingController> _serialNoControllers = [];
  String _selectedProductId = '';
  String _selectedCategory = '';
  String _selectedProductName = '';
  int _availableQuantity = 0;

  List<String> _categories = [];
  List<Map<String, dynamic>> _products = []; // Holds product names and their IDs

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    // Fetch all categories from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('productcatelog').get();
    Set<String> categoriesSet = {}; // Use Set to avoid duplicates

    for (var document in snapshot.docs) {
      String category = document['category'];
      categoriesSet.add(category);
    }

    setState(() {
      _categories = categoriesSet.toList(); // Convert Set to List
    });
  }

  Future<void> _fetchProductsByCategory(String category) async {
    // Fetch products based on the selected category
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('productcatelog')
        .where('category', isEqualTo: category)
        .get();

    List<Map<String, dynamic>> productsList = [];
    for (var document in snapshot.docs) {
      productsList.add({
        'pName': document['pName'],
        'pID': document['pID'],
      });
    }

    setState(() {
      _products = productsList;
      _selectedProductName = ''; // Reset product name when category changes
      _selectedProductId = ''; // Reset product ID when category changes
      _availableQuantity = 0; // Reset available quantity when category changes
    });
  }

  Future<void> _fetchProductDetails(String productId) async {
    // Fetch the product details to get the actual quantity
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('productcatelog')
        .where('pID', isEqualTo: productId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming quantity is stored in the product document
      var productData = snapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _availableQuantity = productData['quantity'] ?? 0; // Update available quantity
      });
    } else {
      setState(() {
        _availableQuantity = 0; // No product found, reset available quantity
      });
    }
  }

  void _onProductNameSelected(String productName) {
    // Find the product ID corresponding to the selected product name
    final product = _products.firstWhere((product) => product['pName'] == productName);
    setState(() {
      _selectedProductId = product['pID'];
      _fetchProductDetails(_selectedProductId); // Fetch the quantity for this product ID
    });
  }

  void _addSerialNumberFields(int quantity) {
    setState(() {
      // Clear previous controllers before generating new ones
      _serialNoControllers = List.generate(quantity, (index) => TextEditingController());
    });
  }

  Future<void> _submitForm() async {
    // Validate that all fields are filled
    if (_selectedProductId.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _serialNoControllers.isNotEmpty &&
        _serialNoControllers.every((controller) => controller.text.isNotEmpty)) {
      
      bool confirmed = await _showDeleteConfirmationDialog();
      if (confirmed) {
        // Iterate through the serial number controllers
        for (var controller in _serialNoControllers) {
          String serialNo = controller.text;

          // Delete the document from the 'central' collection based on the serial number
          try {
            // Assuming 'pserialNo' is the field you want to match
            QuerySnapshot snapshot = await FirebaseFirestore.instance
                .collection('Central')
                .where('pserialNo', isEqualTo: serialNo)
                .get();

            // Delete each matching document
            for (var doc in snapshot.docs) {
              await doc.reference.delete();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product with Serial No: $serialNo deleted successfully!')),
            );

          } catch (e) {
            // Handle any errors that occur during the deletion
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error deleting product. Please try again.')),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All specified products deleted successfully from police inventory!')),
        );

        // Clear input fields after successful deletion
        _quantityController.clear();
        _serialNoControllers.forEach((controller) => controller.clear());
        setState(() {
          _serialNoControllers = [];
          _availableQuantity = 0; // Reset available quantity if needed
          _selectedProductId = '';
          _selectedCategory = '';
          _selectedProductName = '';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields.')),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product from the inventory?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color for delete action
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed without an answer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Product'),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Dropdown for Category selection
              DropdownButtonFormField<String>(
                value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value != null) {
                    _selectedCategory = value;
                    _fetchProductsByCategory(value);
                  }
                },
              ),
              const SizedBox(height: 10),

              // Dropdown for Product Name selection (based on category)
              if (_products.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedProductName.isNotEmpty ? _selectedProductName : null,
                  items: _products.map((product) {
                    return DropdownMenuItem(
                      value: product['pName'] as String,
                      child: Text(product['pName']),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedProductName = value;
                      _onProductNameSelected(value);
                    }
                  },
                ),
              const SizedBox(height: 10),

              if (_selectedProductId.isNotEmpty)
                Text(
                  'Product ID: $_selectedProductId',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),

              if (_availableQuantity > 0)
                Text(
                  'Quantity Present: $_availableQuantity units',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Delete',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  int quantity = int.tryParse(value) ?? 0;
                  _addSerialNumberFields(quantity);
                },
              ),
              const SizedBox(height: 20),

              // Dynamic TextFields for Serial Numbers
              Column(
                children: _serialNoControllers.map((controller) {
                  return TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter Serial No',
                      border: OutlineInputBorder(),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Delete Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
