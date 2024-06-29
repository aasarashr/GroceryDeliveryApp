import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localbasket/models/port.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  OrderDetailsPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Color(0xFF022B60),
      ),
      body: FutureBuilder(
        future: _fetchOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orderDetails = snapshot.data as List<dynamic>?;

          if (orderDetails == null || orderDetails.isEmpty) {
            return Center(child: Text('No order details available'));
          }

          return ListView.builder(
            itemCount: orderDetails.length,
            itemBuilder: (context, index) {
              final item = orderDetails[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product: ${item['name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Quantity: ${item['quantity']}'),
                      Text('Rate: ${item['rate']}'),
                      Text('Ordered Date: ${item['order_date']}'),
                      Text('Delivery Date: ${item['delivery_time']}'),
                      Text('Delivery Address: ${item['delivery_address']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchOrderDetails(int orderId) async {
    final url = Uri.parse('http://$ipAddress:$port/vendor/orders/$orderId/details');

    final response = await http.get(url);
    final responseData = jsonDecode(response.body);

    return responseData['order_items'];
  }
}
