import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';


class RegistrationPage extends StatelessWidget {
  final VoidCallback onBackToLogin;
  final VoidCallback onRegisterSuccess;
  final SessionService sessionService = SessionService();

  RegistrationPage({required this.onRegisterSuccess, required this.onBackToLogin});

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> registerUser() async {
    var firstName = _firstNameController.text;
    var lastName = _lastNameController.text;
    var username = _usernameController.text;
    var password = _passwordController.text;
    var confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      print('Passwords do not match');
      return;
    }

    // Prepare the request body
    var params = {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'password': password,
      'passSalt': '', // Add logic for password salt if needed
      'perms': 0,
    };

    // Make API call to register user
    var url = Uri.parse('https://bakery.permavite.com/users');
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(params),
      );

      // Handle the response
      if (response.statusCode == 201) {
        print('Registration successful');
        print('Response: ${response.body}');
        sessionService.saveSession(jsonDecode(response.body)['id']);
        onRegisterSuccess();
      } else {
        print('Failed to register: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _firstNameController, // First Name
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _lastNameController, // Last Name
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  registerUser(); // Register user
                },
                child: Text('Register'),
              ),
              SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: onBackToLogin, // Go back to login page
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
