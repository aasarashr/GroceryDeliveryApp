import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:localbasket/models/port.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  File? _imageFile; // Declare _imageFile as nullable File variable
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _rateController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _vendorIdController = TextEditingController();
  TextEditingController _productIdController = TextEditingController();
  String? _selectedCategory;
  String? category_id;
  String? _imageUrl;
  List<Map<String, dynamic>> _category = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _imageFile = null; // Initialize image file to null
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('http://$ipAddress:$port/category');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _category = List<Map<String, dynamic>>.from(responseData['category']);
          print(_category);
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description'),
              const SizedBox(height: 16),
              _buildTextField(_rateController, 'Rate', TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(
                  _quantityController, 'Quantity', TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(
                  _vendorIdController, 'Vendor ID', TextInputType.number),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    _buildDropdownButton(),
                    const SizedBox(height: 16),
                    _buildTextField(
                        TextEditingController(text: category_id),
                        'Category ID',
                        TextInputType.text),
                    const SizedBox(height: 16),
                    _imageFile == null
                        ? ElevatedButton(
                            onPressed: _selectImage,
                            child: const Text('Select Image'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromRGBO(2, 43, 96, 1),
                              minimumSize: const Size(115, 50),
                            ),
                          )
                        : Image.file(_imageFile!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _addProduct(context),
                      child: const Text('Add Product'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFF9202),
                        minimumSize: const Size(115, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 26),
                    _buildTextField(
                        _productIdController, 'Search Product by ID', TextInputType.number),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _searchProductById(context),
                      child: const Text('Search Product'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFF9202),
                        minimumSize: const Size(115, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 1,
                    ),
                  ],
                ),
              ),
              _buildProductTable(),
              const SizedBox(height: 26),
              _imageUrl == null || _imageUrl!.isEmpty
                  ? const SizedBox()
                  : Image.network(
                      'http://$ipAddress:$port/$_imageUrl',
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset('assets/default_image.jpg');
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(
        color: Color.fromRGBO(2, 43, 96, 1), // Text color
      ),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: const Color(0xFFC2CEDA), // Background color
        labelStyle: const TextStyle(
          color: Color.fromRGBO(2, 43, 96, 1), // Label color
        ),
      ),
    );
  }

  Widget _buildDropdownButton() {
    
  return DropdownButtonFormField<String>(
    value: _selectedCategory,
    
    onChanged: (newValue) {
      setState(() {
        
        _selectedCategory = newValue;
        _updateInputFieldValue(newValue);
      });
    },
    items: [
      const DropdownMenuItem(
        value: 'Fruits',
        child: Text(
          'Fruits',
          style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Dropdown text color
        ),
      ),
      const DropdownMenuItem(
        value: 'Vegetables',
        child: Text(
          'Vegetables',
          style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Dropdown text color
        ),
      ),
      const DropdownMenuItem(
        value: 'Beverages',
        child: Text(
          'Beverages',
          style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Dropdown text color
        ),
      ),
      const DropdownMenuItem(
        value: 'Dairy',
        child: Text(
          'Dairy',
          style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Dropdown text color
        ),
      ),
    ],
    decoration: InputDecoration(
      labelText: 'Select Category',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: const Color(0xFFC2CEDA), // Background color
      labelStyle: const TextStyle(
        color: Color.fromRGBO(2, 43, 96, 1), // Label color
      ),
    ),
  );
}


  Widget _buildProductTable() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      margin: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Product ID')),
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('Description')),
            const DataColumn(label: Text('Rate')),
            const DataColumn(label: Text('Quantity')),
            const DataColumn(label: Text('Vendor ID')),
            const DataColumn(label: Text('Category ID')),
            const DataColumn(
                label: Text('Edit', style: TextStyle(color: Colors.white))),
            const DataColumn(
                label: Text('Delete', style: TextStyle(color: Colors.white))),
          ],
          rows: _products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text('${product['product_id']}')),
                DataCell(Text('${product['name']}')),
                DataCell(Text('${product['description']}')),
                DataCell(Text('${product['rate']}')),
                DataCell(Text('${product['quantity']}')),
                DataCell(Text('${product['vendor_id']}')),
                DataCell(Text('${product['category_id']}')),
                DataCell(
                  ElevatedButton(
                    onPressed: () => _editProduct(product),
                    child: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFFF9202),
                      minimumSize: const Size(115, 50),
                    ),
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () => _deleteProduct(product),
                    child: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFFF9202),
                      minimumSize: const Size(115, 50),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addProduct(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _rateController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _vendorIdController.text.isEmpty ||
        _selectedCategory == null ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('http://$ipAddress:$port/addProduct');
    final request = http.MultipartRequest('POST', url);
    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['rate'] = _rateController.text;
    request.fields['quantity'] = _quantityController.text;
    request.fields['vendor_id'] = _vendorIdController.text;
    request.fields['category_id'] = category_id!;
    request.files.add(await http.MultipartFile.fromPath(
        'image', _imageFile!.path)); // Add image file to request

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _nameController.clear();
          _descriptionController.clear();
          _rateController.clear();
          _quantityController.clear();
          _vendorIdController.clear();
          _selectedCategory = null;
          _imageFile = null;
          _fetchProducts();
        });
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add product. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editProduct(Map<String, dynamic> product) {
    _productIdController.text = product['product_id'].toString();
    _nameController.text = product['name'];
    _descriptionController.text = product['description'];
    _rateController.text = product['rate'].toString();
    _quantityController.text = product['quantity'].toString();
    _vendorIdController.text = product['vendor_id'].toString();
    _selectedCategory = product['category_id'];
    category_id = product['category_id'];
    setState(() {
      _imageUrl = product['image'];
    });
  }

  void _deleteProduct(Map<String, dynamic> product) async {
    final productId = product['product_id'];

    final url = Uri.parse('http://$ipAddress:$port/deleteProduct');
    try {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'product_id': productId}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _fetchProducts();
        });
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete product. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _searchProductById(BuildContext context) async {
    if (_productIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product ID to search.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse(
        'http://$ipAddress:$port/searchProduct/${_productIdController.text}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _products.clear();
          _products.add(responseData);
        });
      } else {
        throw Exception('Failed to search product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to search product. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _fetchProducts() async {
    final url = Uri.parse('http://$ipAddress:$port/products');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _products = List<Map<String, dynamic>>.from(responseData['products']);
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _updateInputFieldValue(String? newValue) {
    final found = _category.firstWhere((element) => element['name'] == newValue);
    category_id = found['category_id'];
  }
}
