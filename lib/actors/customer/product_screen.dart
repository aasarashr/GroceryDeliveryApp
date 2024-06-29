import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localbasket/actors/customer/addto_cart.dart';
import 'package:localbasket/actors/customer/customer_dashboard.dart';
import 'package:localbasket/actors/common/profile.dart';
import 'package:localbasket/models/port.dart';
import 'package:localbasket/providers/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  final int vendorId;
  final int userId;
  final String? selectedArea;

  const ProductsScreen({
    required this.vendorId,
    required this.userId,
    this.selectedArea, // Add this line
    super.key,
  });

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> _products = [];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchProductsByVendor(widget.vendorId);
  }

  Future<void> _fetchProductsByVendor(int vendorId) async {
    final url = Uri.parse('http://$ipAddress:$port/products/vendor/$vendorId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _products = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    if (product['quantity'] > 0) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addToCart({
        'product_id': product['product_id'],
        'vendor_id': widget.vendorId, // Added vendor_id to cart item
        'name': product['name'],
        'description': product['description'],
        'rate': product['rate'],
        'image_url': product['image_url'],
      });
      print(
          'Product added to cart successfully: ${product['name']} with ID: ${product['product_id']}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry, this product is out of stock.'),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    // Get the selected area from the widget
    final selectedArea = widget.selectedArea;

    // Check if the selected area matches the product's address for each product in the cart
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;

    if (index == 1 && selectedArea != null) {
      for (var item in cartItems) {
        if (item['address'] != null &&
            !item['address']
                .toLowerCase()
                .contains(selectedArea.toLowerCase())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('You can only select products from $selectedArea')),
          );
          return;
        }
      }
    }
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the appropriate page based on the tapped index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
            settings: RouteSettings(arguments: {'userId': widget.userId}),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(userId: widget.userId),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(
                    userId: widget.userId,
                  )),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products by Vendor ${widget.vendorId}'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(
            product: product,
            addToCart: _addToCart,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(2, 43, 96, 1),
        selectedItemColor: Colors.white, // Color of selected item
        unselectedItemColor: Colors.grey, // Color of unselected items
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) addToCart;

  const ProductCard({
    required this.product,
    required this.addToCart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enlarge image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: product['image_url'] != null &&
                      product['image_url'].isNotEmpty
                  ? Image.network(
                      product['image_url']!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'assets/default_image.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/default_image.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RS.${product['rate'] ?? ''}',
                      style: const TextStyle(
                        color: Color.fromRGBO(2, 43, 96, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Qty: ${product['quantity'] ?? ''}',
                      style: TextStyle(
                        color: product['quantity'] == 0
                            ? Colors.red
                            : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Centered Add to Cart button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  addToCart(product);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(2, 43, 96, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
