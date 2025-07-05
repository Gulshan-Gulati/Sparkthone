import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:policeinventory/database_services.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Product model for demonstration purposes
class Product {
  final String pid; // Updated to use pid
  final String name;
  final String serialNo;
  final String category;

  Product({
    required this.pid,
    required this.name,
    required this.serialNo,
    required this.category,
  });
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  AddProductState createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {
  final _dbService = DatabaseServices();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();

  String? _selectedCategory;
  List<String> _categories = [];
  List<Product> _products = [];
  String? _selectedProductPid;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('productcatelog').get();

      final fetched = snapshot.docs
          .map((doc) => doc['category'] as String)
          .toSet()
          .toList();

      final defaultCategories = [
        "Grocery main",
        "Beauty Product",
        "Decoration",
        "Clothes",
        "Shoes",
        "Toys",
        "Sports",
        "Pharmacy",
        "Furniture",
        "Electronic",
      ];

      setState(() {
        _categories = {
          ...defaultCategories,
          ...fetched,
        }.toList();
      });
    } catch (e) {
      setState(() {
        _categories = [
          "Grocery main",
          "Beauty Product",
          "Decoration",
          "Clothes",
          "Shoes",
          "Toys",
          "Sports",
          "Pharmacy",
          "Furniture",
          "Electronic",
        ];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to fetch categories. Using defaults.')),
      );
    }
  }

  Future<void> _fetchProducts(String category) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('productcatelog')
          .where('category', isEqualTo: category)
          .get();

      setState(() {
        _products = snapshot.docs
            .map((doc) => Product(
                  pid: doc['pID'],
                  name: doc['pName'],
                  serialNo: doc['pID'],
                  category: doc['category'],
                ))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch products')),
      );
    }
  }

  Future<void> _scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      if (scanResult.rawContent.isNotEmpty) {
        setState(() {
          _productIdController.text = scanResult.rawContent;
          _productNameController.text = "Sample Product Name";
          _serialNoController.text = "SN-123456";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode')),
      );
    }
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      setState(() {
        _selectedCategory = newCategory;
        _selectedProductPid = null;
        _productNameController.clear();
        _productIdController.clear();
      });
      _fetchProducts(newCategory);
    }
  }

  void _onProductChanged(String? selectedProductPid) {
    if (selectedProductPid != null) {
      final selectedProduct =
          _products.firstWhere((product) => product.pid == selectedProductPid);
      setState(() {
        _selectedProductPid = selectedProduct.pid;
        _productNameController.text = selectedProduct.name;
        _productIdController.text = selectedProduct.pid;
        _serialNoController.clear();
      });
    }
  }

  void _selectBarcodeFromFile() {
    setState(() {
      if (_selectedCategory == "Beauty Product") {
        _productIdController.text = "BP001";
        _productNameController.text = "Maybelline Fit Me Matte + Poreless Foundation";
        _serialNoController.text = "BP001A";
        _selectedProductPid = "BP001";

        _products = [
          Product(pid: "BP001", name: "Foundation", serialNo: "BP001A", category: "Beauty Product"),
          Product(pid: "BP002", name: "Face wash", serialNo: "BP002A", category: "Beauty Product"),
          Product(pid: "BP003", name: "Lipstick", serialNo: "BP003A", category: "Beauty Product"),
          Product(pid: "BP004", name: "Gentle Skin Cleanser", serialNo: "BP004A", category: "Beauty Product"),
          Product(pid: "BP005", name: "Sun's Cream ", serialNo: "BP005A", category: "Beauty Product"),
          Product(pid: "BP006", name: "Dove Beauty", serialNo: "BP006A", category: "Beauty Product"),
          Product(pid: "BP007", name: "Hail Oil", serialNo: "BP007A", category: "Beauty Product"),
          Product(pid: "BP008", name: " Micro-Sculpting Cream", serialNo: "BP008A", category: "Beauty Product"),
          Product(pid: "BP009", name: "Cleansing Water", serialNo: "BP009A", category: "Beauty Product"),
        ];
      } else if (_selectedCategory == "Clothes") {
        _productIdController.text = "LV001";
        _productNameController.text = "Louis Vuitton";
        _serialNoController.text = "LV001A";
        _selectedProductPid = "LV001";

        _products = [
          Product(pid: "Z001", name: "Zara", serialNo: "Z001A", category: "Clothes"),
          Product(pid: "G001", name: "Gucci", serialNo: "G001A", category: "Clothes"),
          Product(pid: "D001", name: "Dior", serialNo: "D001A", category: "Clothes"),
          Product(pid: "LV001", name: "Louis Vuitton", serialNo: "LV001A", category: "Clothes"),
        ];
      }
      else if (_selectedCategory == "Grocery main") {
        _productIdController.text = "GR001";
        _productNameController.text = "Rice";
        _serialNoController.text = "GR001A";
        _selectedProductPid = "GR001";

        _products = [
          Product(pid: "GR001", name: "Rice", serialNo: "GR001A", category: "Grocery main"),
          Product(pid: "GR002", name: "Wheat", serialNo: "GR002A", category: "Grocery main"),
          Product(pid: "GR003", name: "Flour", serialNo: "GR003A", category: "Grocery main"),
          Product(pid: "GR004", name: "Fruits", serialNo: "GR004A", category: "Grocery main"),
          Product(pid: "GR005", name: "Vegetables", serialNo: "GR005A", category: "Grocery main"),
          Product(pid: "GR009", name: "Butter", serialNo: "GR009A", category: "Grocery main"),
          Product(pid: "GR010", name: "Bread", serialNo: "GR010A", category: "Grocery main"),
          Product(pid: "GR013", name: "Eggs", serialNo: "GR013A", category: "Grocery main"),
          Product(pid: "GR016", name: "Oils", serialNo: "GR016A", category: "Grocery main"),
          Product(pid: "GR018", name: "Salt", serialNo: "GR018A", category: "Grocery main"),
          Product(pid: "GR019", name: "Sugar", serialNo: "GR019A", category: "Grocery main"),
          Product(pid: "GR020", name: "Chips", serialNo: "GR020A", category: "Grocery main"),
          Product(pid: "GR021", name: "Biscuits", serialNo: "GR021A", category: "Grocery main"),
          Product(pid: "GR022", name: "Chocolates", serialNo: "GR022A", category: "Grocery main"),
        ];
      }
      else if (_selectedCategory == "Decoration") {
        _productIdController.text = "DC001";
        _productNameController.text = "Wall art";
        _serialNoController.text = "DC001A";
        _selectedProductPid = "DC001";

        _products = [
          Product(pid: "DC001", name: "Wall art", serialNo: "DC001A", category: "Decoration"),
          Product(pid: "DC002", name: "Posters", serialNo: "DC002A", category: "Decoration"),
          Product(pid: "DC003", name: "Photo frames", serialNo: "DC003A", category: "Decoration"),
          Product(pid: "DC004", name: "Candles", serialNo: "DC004A", category: "Decoration"),
          Product(pid: "DC005", name: "Fairy lights", serialNo: "DC005A", category: "Decoration"),
          Product(pid: "DC006", name: "Lanterns", serialNo: "DC006A", category: "Decoration"),
          Product(pid: "DC007", name: "Flower vases", serialNo: "DC007A", category: "Decoration"),
          Product(pid: "DC008", name: "Artificial flowers", serialNo: "DC008A", category: "Decoration"),
          Product(pid: "DC009", name: "Clocks", serialNo: "DC009A", category: "Decoration"),
          Product(pid: "DC010", name: "Showpieces", serialNo: "DC010A", category: "Decoration"),
          Product(pid: "DC011", name: "Decorative cushions", serialNo: "DC011A", category: "Decoration"),
          Product(pid: "DC012", name: "Cushion covers", serialNo: "DC012A", category: "Decoration"),
          Product(pid: "DC013", name: "Wall stickers", serialNo: "DC013A", category: "Decoration"),
        ];
      }
      else if (_selectedCategory == "Toys") {
        _productIdController.text = "TH001";
        _productNameController.text = "Teddy Bears";
        _serialNoController.text = "TH001A";
        _selectedProductPid = "TH001";
        _products = [
          Product(pid: "TH001", name: "Teddy Bears", serialNo: "TH001A", category: "Toys"),
          Product(pid: "TH002", name: "Building blocks", serialNo: "TH002A", category: "Toys"),
          Product(pid: "TH003", name: "Dolls", serialNo: "TH003A", category: "Toys"),
          Product(pid: "TH004", name: "Remote control cars", serialNo: "TH004A", category: "Toys"),
          Product(pid: "TH005", name: "Art & Craft Kits", serialNo: "TH005A", category: "Toys"),
          Product(pid: "TH006", name: "Toy Kitchen Sets", serialNo: "TH006A", category: "Toys"),
          Product(pid: "TH007", name: "Doctorr Sets", serialNo: "TH007A", category: "Toys"),
        ];
      }

    else if (_selectedCategory == "Shoes") {
        _productIdController.text = "SH001";
        _productNameController.text = "Casual Shoes";
        _serialNoController.text = "SH001A";
        _selectedProductPid = "SH001";
        _products = [
          Product(pid: "SH001", name: "Casual shoes, sneakers", serialNo: "SH001A", category: "Shoes"),
          Product(pid: "SH002", name: "Sandals, slippers", serialNo: "SH002A", category: "Shoes"),
          Product(pid: "SH003", name: "Heels, boots", serialNo: "SH003A", category: "Shoes"),
          Product(pid: "SH004", name: "Sports shoes, running shoes", serialNo: "SH004A", category: "Shoes"),
          Product(pid: "SH005", name: "Kids' footwear", serialNo: "SH005A", category: "Shoes"),
          Product(pid: "SH006", name: "School shoes", serialNo: "SH006A", category: "Shoes"),
          Product(pid: "SH007", name: "Flip-flops, crocs", serialNo: "SH007A", category: "Shoes"),
          Product(pid: "SH008", name: "Office/formal shoes", serialNo: "SH008A", category: "Shoes"),
        ];
      }
    else if (_selectedCategory == "Sports") {
        _productIdController.text = "SP001";
        _productNameController.text = "Football";
        _serialNoController.text = "SP001A";
        _selectedProductPid = "SP001";
        _products = [
          Product(pid: "SP001", name: "Football", serialNo: "SP001A", category: "Sports"),
          Product(pid: "SP002", name: "Cricket Bat", serialNo: "SP002A", category: "Sports"),
          Product(pid: "SP003", name: "Badminton Racket", serialNo: "SP003A", category: "Sports"),
          Product(pid: "SP004", name: "Shuttle Cocks", serialNo: "SP004A", category: "Sports"),
          Product(pid: "SP005", name: "Skipping Rope", serialNo: "SP005A", category: "Sports"),
        ];
      }
      else if (_selectedCategory == "Pharmacy") {
        _productIdController.text = "PH001";
        _productNameController.text = "Thermometer";
        _serialNoController.text = "PH001A";
        _selectedProductPid = "PH001";
        _products = [
          Product(pid: "PH001", name: "Thermometer", serialNo: "PH001A", category: "Pharmacy"),
          Product(pid: "PH002", name: "Paracetamol", serialNo: "PH002A", category: "Pharmacy"),
          Product(pid: "PH003", name: "Cough Syrup", serialNo: "PH003A", category: "Pharmacy"),
          Product(pid: "PH004", name: "Pain Relif Sprays", serialNo: "PH004A", category: "Pharmacy"),
          Product(pid: "PH005", name: "Mask", serialNo: "PH005A", category: "Pharmacy"),
          Product(pid: "PH006", name: "Hand Sanitizers", serialNo: "PH006A", category: "Pharmacy"),
        ];
      }
      else if (_selectedCategory == "Furniture") {
        _productIdController.text = "FH001";
        _productNameController.text = "Chair";
        _serialNoController.text = "FH001A";
        _selectedProductPid = "FH001";
        _products = [
          Product(pid: "FH001", name: "Chair", serialNo: "FH001A", category: "Furniture"),
          Product(pid: "FH002", name: "Office Desk", serialNo: "FH002A", category: "Furniture"),
          Product(pid: "FH003", name: "Beds", serialNo: "FH003A", category: "Furniture"),
          Product(pid: "FH004", name: "Table", serialNo: "FH004A", category: "Furniture"),
          Product(pid: "FH005", name: "Shoes Racks", serialNo: "FH005A", category: "Furniture"),
          Product(pid: "FH006", name: "Almirahs", serialNo: "FH006A", category: "Furniture"),
        ];
      }
      else if (_selectedCategory == "Electronic") {
        _productIdController.text = "EH001";
        _productNameController.text = "Televisions";
        _serialNoController.text = "EH001A";
        _selectedProductPid = "EH001";
        _products = [
          Product(pid: "FH001", name: "Televisions", serialNo: "FH001A", category: "Furniture"),
          Product(pid: "FH002", name: "Mobile Phone", serialNo: "FH002A", category: "Furniture"),
          Product(pid: "FH003", name: "Smart Watch", serialNo: "FH003A", category: "Furniture"),
          Product(pid: "FH004", name: "Washing machine", serialNo: "FH004A", category: "Furniture"),
          Product(pid: "FH005", name: "Ceiling Fan", serialNo: "FH005A", category: "Furniture"),
          Product(pid: "FH006", name: "Refrigerators", serialNo: "FH006A", category: "Furniture"),
          Product(pid: "FH007", name: "Induction Cookers", serialNo: "FH007A", category: "Furniture"),

        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: ElevatedButton.icon(
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Barcode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/b1.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _selectBarcodeFromFile,
                        child: const Text('Select'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: _onCategoryChanged,
                items: _categories
                    .map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedProductPid,
                onChanged: _onProductChanged,
                items:
                    _products.map<DropdownMenuItem<String>>((Product product) {
                  return DropdownMenuItem<String>(
                    value: product.pid,
                    child: Text(product.name),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(
                  labelText: 'Product ID',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _serialNoController,
                decoration: const InputDecoration(
                  labelText: 'Serial No.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    if (_selectedCategory == null ||
                        _selectedProductPid == null ||
                        _productIdController.text.isEmpty ||
                        _productNameController.text.isEmpty ||
                        _serialNoController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all the fields')),
                      );
                      return;
                    }

                    Map<String, dynamic> productInfoMap = {
                      'pid': _selectedProductPid,
                      'pname': _productNameController.text,
                      'pserialNo': _serialNoController.text,
                      'pcategory': _selectedCategory,
                    };

                    var uuid = Uuid();
                    String uniqueProductId = uuid.v4();

                    try {
                      await _dbService.addProduct(
                          productInfoMap, uniqueProductId, context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data added successfully')),
                      );
                      _disposeFields();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add data')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _disposeFields() {
    _productNameController.clear();
    _productIdController.clear();
    _serialNoController.clear();

    setState(() {
      _selectedCategory = null;
      _selectedProductPid = null;
      _products.clear();
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productIdController.dispose();
    _serialNoController.dispose();
    super.dispose();
  }
}