import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../main.dart';


class LoginPage extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onRegisterTap;
  final SessionService sessionService = SessionService();

  LoginPage({required this.onLoginSuccess, required this.onRegisterTap});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    var username = _usernameController.text;
    var password = _passwordController.text;

    var strError = '';
    if (username.length < 3) {
      strError += 'Username must be 3 or more characters.\n';
    } if (password.length < 6) {
      strError += 'Password must be 6 or more characters.\n';
    }

    if (strError != '') {
      // Make a awesome dialog to show the error
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Error',
        desc: strError,
        btnOkOnPress: () {},
      ).show();
      return;
    }

    var params = {
      'username': username,
      'password': password,
    };
  
    var url = Uri.parse('https://bakery.permavite.com/login');      //Username: HippoTechnologies Password: Mickey2024!
    try {
        var response = await http.post(
          url,
          headers:  <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(params),
        );

      print ('Response: ${response.body}');
        
      // Handle the response
      if (response.statusCode == 201) {
        print('Login successful');
        sessionService.saveSession(jsonDecode(response.body)['id']);
        // Make a awesome dialog to show the success, then call onLoginSuccess
        if (context.mounted){
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Login successful',
            btnOkOnPress: onLoginSuccess,
          ).show();
        }
      } else if (response.statusCode == 404) {
        print('Failed to Login: ${response.body}');
        // Make a awesome dialog to show the error
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Error',
          desc: 'Invalid username or password',
          btnOkOnPress: () {},
        ).show();
      } else {
        print('Failed to Login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // Add login logic here
                  print('Logging in with username: ${_usernameController.text}');
                  loginUser(context);
                },
                child: Text('Login'),
              ),
              SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: onRegisterTap, // Go to registration page
                child: Text('Register'),
              ),
            ],
          ),
        ),
      )
    );
  }
}