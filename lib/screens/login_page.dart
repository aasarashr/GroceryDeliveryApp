import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailOrUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showPassword = false;

  // Fake user data
  final List<Map<String, dynamic>> fakeUsers = [
    {'emailOrUsername': 'admin', 'password': 'admin123', 'role': 1, 'user_id': 1},
    {'emailOrUsername': 'vendor', 'password': 'vendor123', 'role': 2, 'user_id': 2},
    {'emailOrUsername': 'customer', 'password': 'customer123', 'role': 3, 'user_id': 3},
    {'emailOrUsername': 'driver', 'password': 'driver123', 'role': 4, 'user_id': 4},
  ];

  Future<void> _login(BuildContext context) async {
    final String emailOrUsername = emailOrUsernameController.text;
    final String password = passwordController.text;

    try {
      // Simulate checking the credentials against the fake user data
      final user = fakeUsers.firstWhere(
        (user) =>
            user['emailOrUsername'] == emailOrUsername &&
            user['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        final int roleId = user['role'];
        final int userId = user['user_id'];

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.user = User(userId: userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login successful'),
              backgroundColor: Color.fromARGB(166, 3, 95, 6)),
        );

        _navigateToDashboard(context, roleId, userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email/username or password'),
            backgroundColor: Color.fromARGB(149, 238, 29, 15),
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error during login. Please try again later.')),
      );
    }
  }

  void _navigateToDashboard(BuildContext context, int roleId, int userId) {
    switch (roleId) {
      case 1:
        Navigator.pushNamed(context, '/adminDashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/vendorDashboard',
            arguments: {'userId': userId});
        break;
      case 3:
        Navigator.pushReplacementNamed(
          context,
          '/customerDashboard',
          arguments: {'userId': userId},
        );
        break;
      case 4:
        Navigator.pushNamed(context, '/driverDashboard',
            arguments: {'userId': userId});
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed role not found'),
            backgroundColor: Color.fromARGB(149, 238, 29, 15),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF022B60),
      appBar: AppBar(
        backgroundColor: const Color(0xFF022B60),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                Image.asset('assets/logo.png', height: 150),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: emailOrUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Email/Username',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      fillColor: const Color(0xFFC2CEDA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      fillColor: const Color(0xFFC2CEDA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF022B60),
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 115,
                  child: ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: const Color(0xFFFF9202),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 115,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: const Color(0xFFFF9202),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
