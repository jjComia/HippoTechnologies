import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:async';  // Make sure to add this import at the top of your file


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
  
    var url = Uri.parse('https://bakery.permavite.com/api/login');      //Username: HippoTechnologies Password: Mickey2024!
    try {
        var response = await http.post(
          url,
          headers:  <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(params),
        );

      print ('Response: ${response.statusCode}');
        
      // Handle the response
      if (response.statusCode == 201) {
        print('Login successful');
        sessionService.saveSession(jsonDecode(response.body)['id']);
        // Make a awesome dialog to show the success, then call onLoginSuccess
        if (context.mounted) {
          AwesomeDialog dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Login successful',
            showCloseIcon: false,
            autoDismiss: false,  // Prevents the dialog from auto-dismiss
            onDismissCallback: (DismissType type) {
              print('Dialog dismissed with type: $type');
            },
          );

          // Show the dialog
          dialog.show();

          // Delay of 1 second before dismissing the dialog and calling onLoginSuccess
          Timer(Duration(seconds: 2), () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();  // Close the dialog manually
              onLoginSuccess();  // Call your success handler
            }
          });
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
      appBar: AppBar(title: Text('Login'), backgroundColor: Color.fromARGB(255, 249, 251, 250)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/HippoTechnologiesLogo.png',
                height: 225.0, // Adjust the height as needed
              ),
              SizedBox(height: 24.0), // Space between image and text fields
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    color: Colors.black,  // Default label color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),       // Change the color of the border when focused
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Colors.blue,  // Label color when the field is focused
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.black,  // Default label color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),       // Change the color of the border when focused
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Colors.blue,  // Label color when the field is focused
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Add forgot password logic here
                    print('Forgot password');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue, // Text color
                  ),
                  child: Text('Forgot password?'),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distributes the buttons evenly
                children: [
                  SizedBox(
                    width: 150, // Set the desired width for the ElevatedButton
                    child: ElevatedButton(
                      onPressed: () {
                        // Add login logic here
                        print('Logging in with username: ${_usernameController.text}');
                        loginUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: Text('Login'),
                    ),
                  ),
                  SizedBox(
                    width: 150, // Set the desired width for the OutlinedButton
                    child: OutlinedButton(
                      onPressed: onRegisterTap, // Go to registration page
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue, // Text color
                        side: BorderSide(color: Colors.blue), // Border color
                      ),
                      child: Text('Register'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}