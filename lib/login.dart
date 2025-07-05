import 'dart:async';
import 'package:flutter/material.dart';
import 'package:policeinventory/admindashboard.dart';
import 'package:policeinventory/peopledashboard.dart';
import 'package:policeinventory/managerdashboard.dart';
import 'package:policeinventory/admins/register_screen.dart'; // NEW IMPORT

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showSecurityCheck() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Security Check'),
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Verifying credentials...')),
          ],
        ),
      ),
    );

    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authorized! Redirecting to Admin Dashboard...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      });
    });
  }

  void _staffLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PeopleDashboard()),
    );
  }

  void _managerLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomerDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0071CE); // Walmart Blue
    final secondaryColor = const Color(0xFFFFB81C); // Walmart Yellow

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Walmart Inventory System',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Email Field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 30),

                // Admin Login
                _buildLoginButton(
                  label: 'Admin Login',
                  color: Colors.red[700],
                  onTap: _showSecurityCheck,
                ),

                const SizedBox(height: 12),

                // Staff Login
                _buildLoginButton(
                  label: 'Staff Login',
                  color: primaryColor,
                  onTap: _staffLogin,
                ),

                const SizedBox(height: 12),

                // Customer Login
                _buildLoginButton(
                  label: 'Customer Login',
                  color: Colors.green[700],
                  onTap: _managerLogin,
                ),

                const SizedBox(height: 20),

                // ✅ Register Navigation
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "New user? Create an account",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 123, 142, 162)),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  Widget _buildLoginButton({
    required String label,
    required Color? color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
