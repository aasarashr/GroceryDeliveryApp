import 'package:flutter/material.dart';
import 'package:localbasket/actors/admin/ordermmt.dart';

import 'productmmt.dart';

void main() {
  runApp(const AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardScreen();
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF022B60),
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF022B60),
                ),
                child: Center(
                  child: Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Color.fromRGBO(2, 43, 96, 1)), // Grey when unselected
                title: const Text(
                  'Home',
                  style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Grey when unselected
                ),
                onTap: () => _onTap(0),
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag, color: Color.fromRGBO(2, 43, 96, 1)), // Grey when unselected
                title: const Text(
                  'Products',
                  style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Grey when unselected
                ),
                onTap: () => _onTap(1),
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.grey), // Grey when unselected
                title: const Text(
                  'Orders',
                  style: TextStyle(color: Color.fromRGBO(2, 43, 96, 1)), // Grey when unselected
                ),
                onTap: () => _onTap(2),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF022B60),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
        selectedItemColor: Colors.white, // White when selected
        unselectedItemColor: Colors.grey, // Grey when unselected
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ProductManagementScreen();
      case 2:
        return OrderManagementScreen(orders: [],); // Replace with Orders screen
      default:
        return Container(); 
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.pop(context);
    });
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildContainer('Total Orders', '100')),
            Expanded(child: _buildContainer('Dispatched Orders', '50')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildContainer('Pending Orders', '30')),
            Expanded(child: _buildContainer('Orders Delivered', '20')),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.8,
          child: const Card(
            child: Center(
              child: Text('Pie Chart Placeholder'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.8,
          child: const Card(
            child: Center(
              child: Text('Bar Graph Placeholder'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainer(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF022B60),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
