import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import '../services/session_service.dart';
import 'dart:async';  // Make sure to add this import at the top of your file
import 'registerEmailAndPhone.dart';  // Import the RegisterEmailAndPhone page

typedef RegisterNextCallback = void Function(String firstName, String lastName, String username, String password);

class RegistrationPage extends StatefulWidget {
  final VoidCallback onBackToLogin;
  final RegisterNextCallback onRegisterNext; // Updated to pass parameters
  final SessionService sessionService = SessionService();

  RegistrationPage({required this.onRegisterNext, required this.onBackToLogin});

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

  Future<void> nextRegisterPage(BuildContext context) async {
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
    } else {
      widget.onRegisterNext(firstName, lastName, username, password);  // Call the next registration page
      /*// Navigate to the next registration page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterEmailAndPhone(
            firstName: firstName,
            lastName: lastName,
            username: username,
            password: password,
          ),
        ),
      );*/
    }
  }
  
  /*
  Future<void> registerUser(BuildContext context) async {
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
        if (context.mounted) {
          AwesomeDialog dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Registration successful',
            showCloseIcon: false,
            autoDismiss: false,  // Prevents the dialog from auto-dismiss
            onDismissCallback: (DismissType type) {
              print('Dialog dismissed with type: $type');
            },
          );

          // Show the dialog
          dialog.show();

          // Delay of 1 second before dismissing the dialog and calling onRegisterSuccess
          Timer(Duration(seconds: 1), () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();  // Manually close the dialog
              widget.onRegisterSuccess();  // Call your success handler
            }
          });
        }
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
*/
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
      appBar: AppBar(
        title: Text('Register', style: TextStyle(fontSize: 25),),
        backgroundColor: Color.fromARGB(255, 249, 251, 250),
        centerTitle: true,
      ),
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
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
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
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
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
                  floatingLabelStyle: TextStyle(
                    color:Colors.blue,  // Label color when the field is focused
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:Colors.blue),
                  ),
                ),
                onChanged: (value) => _checkPasswords(),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  floatingLabelStyle: TextStyle(
                    color: !_passwordsMatch ? Colors.red : Colors.blue,  // Label color when the field is focused
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: !_passwordsMatch ? Colors.red : Colors.blue),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: widget.onBackToLogin,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue, // Text color
                        side: BorderSide(color: Colors.blue), // Border color
                      ),
                    child: Text('Back to Login'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      nextRegisterPage(context); // Register user
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color
                        foregroundColor: Colors.white, // Text color
                      ),
                    child: Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
