import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import '../services/session_service.dart';

class RegistrationPage extends StatefulWidget {
  final VoidCallback onBackToLogin;
  final VoidCallback onRegisterSuccess;
  final SessionService sessionService = SessionService();

  RegistrationPage({required this.onRegisterSuccess, required this.onBackToLogin});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordsMatch = true;

  void _checkPasswords() {
    setState(() {
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> registerUser(BuildContext context) async {
    var firstName = _firstNameController.text;
    var lastName = _lastNameController.text;
    var username = _usernameController.text;
    var password = _passwordController.text;
    var confirmPassword = _confirmPasswordController.text;

    List<String> errorMessages = [];
    if (firstName.length < 2) {
      errorMessages.add('First Name must be 2 or more characters.');
    }
    if (lastName.length < 2) {
      errorMessages.add('Last Name must be 2 or more characters.');
    }
    if (username.length < 3) {
      errorMessages.add('Username must be 3 or more characters.');
    }
    if (password.length < 6) {
      errorMessages.add('Password must be 6 or more characters.');
    }
    if (confirmPassword.isEmpty) {
      errorMessages.add('Confirm Password is required.');
    } else if (password != confirmPassword) {
      errorMessages.add('Passwords do not match.');
    }

    if (errorMessages.isNotEmpty) {
      // Show error dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Incorrect Input(s)',
        desc: errorMessages.join('\n'),
        btnOkOnPress: () {},
      ).show();
      return;
    }

    // Prepare the request body
    var params = {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'password': password,
      'passSalt': '',
      'perms': 0,
    };

    // Make API call to register user
    var url = Uri.parse('https://bakery.permavite.com/api/register/user');
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
        widget.sessionService.saveSession(jsonDecode(response.body)['id']);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'Success',
          desc: 'Registration successful',
          btnOkOnPress: widget.onRegisterSuccess,
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Error',
          desc: 'Registration Failed. Please try again.',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _lastNameController,
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
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: !_passwordsMatch ? Colors.red : Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: !_passwordsMatch ? Colors.red : Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  errorText: !_passwordsMatch ? 'Passwords do not match' : null,
                ),
                onChanged: (value) => _checkPasswords(),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: !_passwordsMatch ? Colors.red : Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: !_passwordsMatch ? Colors.red : Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  errorText: !_passwordsMatch ? 'Passwords do not match' : null,
                ),
                onChanged: (value) => _checkPasswords(),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  registerUser(context); // Register user
                },
                child: Text('Register'),
              ),
              SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: widget.onBackToLogin,
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
