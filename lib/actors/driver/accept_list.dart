import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localbasket/models/port.dart';
import 'package:localbasket/actors/common/order_details.dart';
import 'package:localbasket/actors/common/profile.dart'; // Import ProfileScreen
import 'package:provider/provider.dart';
import 'package:localbasket/providers/user_provider.dart';
import 'package:localbasket/actors/driver/driver_dashboard.dart'; // Import DriverDashboardPage

class AcceptedOrdersPage extends StatefulWidget {
  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  List<dynamic> _acceptedOrders = [];
  bool _isLoading = true;
  // int _selectedIndex = 1; // Index for the Orders page in bottom navigation
  late int userId; // Declare userId variable

  @override
  void initState() {
    super.initState();
    _fetchAcceptedOrders();
    _fetchUserId(); // Fetch userId
  }

  Future<void> _fetchUserId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.userId; // Fetch userId from provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Accepted Orders'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 120, // Adjust the height as per your requirement
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(2, 43, 96, 1),
                ),
                padding: EdgeInsets.zero,
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color.fromRGBO(2, 43, 96, 1)),
              title: const Text('Home', style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1))),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement( // Navigate to DriverDashboardPage
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverDashboardPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Color.fromRGBO(2, 43, 96, 1)),
              title: const Text('Orders', style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1))),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverDashboardPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color.fromRGBO(2, 43, 96, 1)),
              title: const Text('Profile', style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1))),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: userId)),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _acceptedOrders.isEmpty
              ? const Center(child: Text('No accepted orders found'))
              : ListView.builder(
                  itemCount: _acceptedOrders.length,
                  itemBuilder: (context, index) {
                    final order = _acceptedOrders[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID: ${order['order_id']}'),
                            const SizedBox(height: 8),
                            Text('Total Price: Rs. ${order['total_price']}'),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${order['order_status']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Product Count: ${order['product_count']}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _updateOrderStatus(
                                    order['order_id'], 'Delivered');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFFF9202),
                              ),
                              child: const Text(
                                'Mark as Delivered',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _navigateToOrderDetails(order['order_id']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 66, 165, 245),
                              ),
                              child: const Text(
                                'View Details',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _fetchAcceptedOrders() async {
    final url = Uri.parse('http://$ipAddress:$port/driver/orders/accepted');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('orders')) {
          List<dynamic> orders = responseData['orders'];

          // Filter out duplicate orders based on order_id
          final uniqueOrders = <dynamic>[];
          final uniqueOrderIds = Set<int>();

          for (var order in orders) {
            if (uniqueOrderIds.add(order['order_id'])) {
              uniqueOrders.add(order);
            }
          }

          setState(() {
            _acceptedOrders = uniqueOrders;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: missing "orders" key');
        }
      } else {
        throw Exception(
            'Failed to load accepted orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching accepted orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/status');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': status}),
      );

      if (response.statusCode == 200) {
        // Remove the delivered order from the local list
        setState(() {
          _acceptedOrders.removeWhere((order) => order['order_id'] == orderId);
        });
      } else {
        throw Exception(
            'Failed to update order status: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  void _navigateToOrderDetails(int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: orderId),
      ),
    );
  }
}
