// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'theme.dart';

import 'screens/login_page.dart';
import 'screens/signup_page.dart';

import 'actors/admin/admin_dashboard.dart';
import 'actors/customer/customer_dashboard.dart';
import 'actors/driver/driver_dashboard.dart';
import 'actors/vendor/vendor_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'localbasket',
      theme: myTheme, // Apply the custom theme
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/vendorDashboard': (context) => const VendorDashboardScreen(),
        '/customerDashboard': (context) => DashboardScreen(),
        '/driverDashboard': (context) => DriverDashboardPage(),
      },
    );
  }
}
