import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _vendorIdController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      // appBar: AppBar(
      //   title: const Text('Product Management'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                _nameController,
                'Name',
              ),
              SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
              ),
              SizedBox(height: 16),
              _buildTextField(
                _rateController,
                'Rate',
                TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField(
                _quantityController,
                'Quantity',
                TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField(
                _vendorIdController,
                'Vendor ID',
                TextInputType.number,
              ),
              SizedBox(height: 26),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addProduct(context),
                  child: Text('Add Product', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9202),
                    minimumSize: Size(115, 50),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 1,
              ),
              SizedBox(height: 26),
              _buildTextField(
                _productIdController,
                'Search Product by ID',
                TextInputType.number,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _searchProductById(context),
                  child: Text('Search Product', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9202),
                    minimumSize: Size(115, 50),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    return scaffold;
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(
        color: Color.fromRGBO(2, 43, 96, 1), // Text color
      ),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Color(0xFFC2CEDA), // Background color
        labelStyle: TextStyle(
          color: Color.fromRGBO(2, 43, 96, 1), // Label color
        ),
      ),
    );
  }

  void _addProduct(BuildContext context) async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final vendorId = int.tryParse(_vendorIdController.text) ?? 0;

    final url = Uri.parse('http://192.168.1.113:3000/products');
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'description': description,
      'rate': rate,
      'quantity': quantity,
      'vendor_id': vendorId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        _showSuccessDialog(context, 'Product added successfully.');
      } else {
        _showErrorDialog(context, 'Failed to add product.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to add product. Please try again.');
    }
  }

  void _searchProductById(BuildContext context) async {
    final productId = int.tryParse(_productIdController.text) ?? 0;
    final url = Uri.parse('http://192.168.1.113:3000/products/$productId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        _showProductDetailsDialog(context, productData);
      } else {
        _showErrorDialog(context, 'Product not found.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to search product. Please try again.');
    }
  }

  void _showProductDetailsDialog(BuildContext context, dynamic productData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Details'),
          content: Text(
              'Product ID: ${productData['product_id']}\nName: ${productData['name']}\nDescription: ${productData['description']}\nRate: ${productData['rate']}\nQuantity: ${productData['quantity']}\nVendor ID: ${productData['vendor_id']}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    _nameController.clear();
    _descriptionController.clear();
    _rateController.clear();
    _quantityController.clear();
    _vendorIdController.clear();
    _productIdController.clear();
  }
}

