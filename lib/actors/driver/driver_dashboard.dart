import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localbasket/actors/common/order_details.dart';
import 'package:localbasket/actors/common/profile.dart';
import 'package:localbasket/actors/driver/accept_list.dart';
import 'package:localbasket/models/port.dart';
import 'package:localbasket/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({Key? key}) : super(key: key);

  @override
  _DriverDashboardPageState createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final Set<int> _uniqueOrderIds = {};
  List<dynamic> _orders = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // Manage selected index for bottom navigation bar
  late int userId;

  @override
  void initState() {
    super.initState();
    _fetchPlacedOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId; // Assign to class-level variable
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(2, 43, 96, 1),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Color.fromRGBO(2, 43, 96, 1),
              ),
              child: Center(
                child: Text(
                  'Driver Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color.fromRGBO(2, 43, 96, 1)),
              title: Text(
                'Home',
                style: TextStyle(
                  color: Color.fromRGBO(2, 43, 96, 1),
                ),
              ),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Color.fromRGBO(2, 43, 96, 1)),
              title: Text(
                'Orders',
                style: TextStyle(
                  color: Color.fromRGBO(2, 43, 96, 1),
                ),
              ),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color.fromRGBO(2, 43, 96, 1)),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Color.fromRGBO(2, 43, 96, 1),
                ),
              ),
              onTap: () {
                _onItemTapped(2); // Update index to match Profile navigation
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No placed orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];

                    // Display orders only with status 'Placed'
                    if (order['order_status'] != 'Placed') {
                      return SizedBox.shrink(); // Return an empty widget
                    }

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          _navigateToOrderDetails(order['order_id']);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order ID: ${order['order_id']}'),
                              const SizedBox(height: 8),
                              Text(
                                'Total Price: Rs. ${order['total_price']}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${order['order_status']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateOrderStatus(
                                            order['order_id'], 'Accept');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9202),
                                      ),
                                      child: const Text(
                                        'Accept',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateOrderStatus(
                                            order['order_id'], 'Reject');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9202),
                                      ),
                                      child: const Text(
                                        'Reject',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTabTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home screen (DriverDashboardPage)
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AcceptedOrdersPage(),
          ),
        );
        break;
      case 2: // Update to match Profile navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userId),
          ),
        );
        break;
    }
  }

  Future<void> _fetchPlacedOrders() async {
    final url = Uri.parse('http://$ipAddress:$port/driver/orders/placed');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('orders')) {
          List<dynamic> orders = responseData['orders'];

          // Filter out duplicate orders
          orders = orders
              .where((order) => _uniqueOrderIds.add(order['order_id']))
              .toList();

          setState(() {
            _orders = orders;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: missing "orders" key');
        }
      } else {
        throw Exception('Failed to load placed orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching placed orders: $e');
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
        // Update the local orders list
        setState(() {
          _orders = _orders.map((order) {
            if (order['order_id'] == orderId) {
              order['order_status'] = status;
            }
            return order;
          }).toList();
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

  // Function to handle logout
  void _logout(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.user = null; // Clear the user
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(2, 43, 96, 1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        widget.onTabTapped(index);
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
