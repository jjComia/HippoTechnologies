import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import '../services/session_service.dart';
import 'dart:async';  // Make sure to add this import at the top of your file
import 'package:flutter/services.dart';

var sessionID;

// Create a stateful page that takes 4 parameters (firstName, lastName, username, password) when called
class RegisterEmailAndPhone extends StatefulWidget {
  final SessionService sessionService = SessionService();
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final VoidCallback onCancelTap;
  final VoidCallback onRegisterSuccess;

  RegisterEmailAndPhone({required this.firstName, required this.lastName, required this.username, required this.password, required this.onCancelTap, required this.onRegisterSuccess});

  @override
  _RegisterEmailAndPhoneState createState() => _RegisterEmailAndPhoneState();
}

// Create a state for the RegisterEmailAndPhone page
class _RegisterEmailAndPhoneState extends State<RegisterEmailAndPhone> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); 

  final SessionService sessionService = SessionService();

  bool _emailsMatch = true;

  void _checkEmails() {
    setState(() {
      _emailsMatch = _emailController.text == _confirmEmailController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Email and Phone', 
          style: TextStyle(fontSize: 25,
          color: Color.fromARGB(255, 37,3,3)
        ),
      ),
        backgroundColor: Color.fromARGB(255, 249, 251, 250),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/clearhippo.png',
                height: 225.0, // Adjust the height as needed
              ),
              TextField(
                controller: _emailController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'example@example.com',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 204,198,159),  // Default label color
                    fontSize: 14.0,
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 255,253,241),  // Default label color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 255,253,241), width: 2.0)
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color.fromARGB(255, 204,198,159),  // Label color when the field is focused
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 204,198,159)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 204,198,159)),
                  ),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 204, 198, 159), // Change the color of the inputted text
                ),
                onChanged: (value) => _checkEmails(),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmEmailController,
                decoration: InputDecoration(
                  labelText: 'Confirm Email',
                  
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 255,253,241),  // Default label color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 255,253,241), width: 2.0)
                  ),
                  floatingLabelStyle: TextStyle(
                    color: !_emailsMatch ? Color.fromARGB(255, 255,253,241) : Color.fromARGB(255, 204,198,159),  // Label color when the field is focused
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: !_emailsMatch ? Color.fromARGB(255, 255,253,241) : Color.fromARGB(255, 204,198,159)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: !_emailsMatch ? Color.fromARGB(255, 255,253,241) : Color.fromARGB(255, 204,198,159)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 37,3,3), width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 37,3,3), width: 1.0),
                  ),
                  errorText: !_emailsMatch ? 'Emails Must Match' : null,
                  errorStyle: TextStyle(
                    color: Color.fromARGB(255, 37,3,3),  // Custom error text color
                    fontSize: 14.0,  // Adjust font size if needed
                ),
              ),
              style: TextStyle(
                  color: Color.fromARGB(255, 204, 198, 159), // Change the color of the inputted text
                ),
              onChanged: (value) => _checkEmails(),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '(123) 456-7890',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 204,198,159),
                    fontSize: 14.0,
                  ),
                  labelText: 'Phone (Optional)',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 255,253,241),  // Default label color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 255,253,241), width: 2.0)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 204,198,159), width: 2.0),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color.fromARGB(255, 204,198,159),
                  ),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 204, 198, 159), // Change the color of the inputted text
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,  // Only allow digits initially
                ],
                onChanged: (value) {
                  final formattedNumber = _formatPhoneNumber(value); // Format phone number
                  _phoneController.value = TextEditingValue(
                    text: formattedNumber,
                    selection: TextSelection.collapsed(offset: formattedNumber.length), // Keep cursor at correct position
                  );
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  var phone = '';
                  if (_phoneController.text.isNotEmpty) {
                    //Check if the phone number is valid
                    if (!isValidPhoneNumber(_phoneController.text)) {
                      // Show an error message using awesome dialog
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.bottomSlide,
                        title: 'Error',
                        desc: 'Invalid phone number',
                        btnOkOnPress: () {},
                      ).show();
                      return;
                    }
                    phone = _phoneController.text;
                  }
                  // Check if the email and confirm email fields match
                  if (_emailController.text != _confirmEmailController.text || !isValidEmail(_emailController.text)) {
                    var message = '';
                    if(!isValidEmail(_emailController.text)) {
                      message += 'Invalid email\n';
                    }
                    if (_emailController.text != _confirmEmailController.text) {
                      message += 'Emails do not match';
                    }
                    // Show an error message using awesome dialog
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.bottomSlide,
                      title: 'Error',
                      desc: message,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                    return;
                  }

                  var response = await finishRegistration(context, _emailController.text, phone, widget.firstName, widget.lastName, widget.username, widget.password);

                  if (response == 'error1') {
                    // Show an error message using awesome dialog
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.bottomSlide,
                      title: 'Error',
                      desc: 'Failed to register user. Please try again',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                    return;
                  } else if (response == 'error2') {
                    // Show an error message using awesome dialog
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.bottomSlide,
                      title: 'Error',
                      desc: 'Failed to register email. Please try again in the app',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                    return;
                  } else if (response == 'error3') {
                    // Show an error message using awesome dialog
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.bottomSlide,
                      title: 'Error',
                      desc: 'Failed to register phone. Please try again in the app',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                    return;
                  } else {
                    widget.sessionService.saveSession(sessionID);
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
                  }
                },
                child: Text('Register', style: TextStyle( color: Color.fromARGB(255, 37, 3, 3))),
              ),
              TextButton(
                onPressed: () {
                  print('Cancel registration');
                  widget.onCancelTap();
                },
                child: Text('Cancel registration', style: TextStyle(color: Color.fromARGB(255, 204,198,159)),),
              ),
            ],
          ),
        ),
      )
    );
  }
}

Future<String> finishRegistration (context, email, phone, firstName, lastName, username, password) async {
  print('Registering user with email: $email and phone: $phone');
  print('First name: $firstName, Last name: $lastName, Username: $username, Password: $password');
  // Add your registration logic here
  Map<String, dynamic> result = await registerUser(context, firstName, lastName, username, password);
  if (result['error'] == 'error') {
    return 'error1';
  }

  print('Result: $result');

  sessionID = result['id'];
  var userID = result['userId'];
  var addEmailResponse = await registerEmail(sessionID, userID, email);
  if (addEmailResponse == 'error') {
    return 'error2';
  }
  var addPhoneResponse = await registerPhone(sessionID, userID, phone);
  if (addPhoneResponse == 'error') {
    return 'error3';
  } else {
    return sessionID;
  }
}

Future<Map<String, dynamic>> registerUser(context, firstName, lastName, username, password) async {
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
      print('Response: ${response.statusCode}');
      return jsonDecode(response.body);
    } else {
      return {
        'error': 'error',
      };
    }
  } catch (e) {
    print('Error occurred: $e');
    return {
      'error': 'error',
    };
  }
}

Future<String> registerEmail (id, userID, email) async {
  // Print parameters
  print(id);
  print(userID);
  print(email);
  // Prepare the request body
  var params = {
    'userId': userID,
    'emailAddress': email,
  };

  print(params);

  // Make API call to register email
  var url = Uri.parse('https://bakery.permavite.com/api/register/email');
  try {
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // Authorization header using sessionID
        'Authorization': id,
      },
      body: jsonEncode(params),
    );

    print('Response: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle the response
    if (response.statusCode == 201) {
      return 'success';
    } else {
      return 'error';
    }
  } catch (e) {
    print('Error occurred: $e');
    return '';
  }
}

Future<String> registerPhone(id, userID, phone) async {
  print(phone);
  var numbers = phone.replaceAll(RegExp(r'\D'), '');
  print(numbers);
  // Prepare the request body
  var params = {
    'userId': userID,
    'countryCode': 1,
    'number': numbers,
  };

  // Make API call to register phone
  var url = Uri.parse('https://bakery.permavite.com/api/register/phone');
  try {
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // Might need an authorization header here
        'Authorization': id,
      },
      body: jsonEncode(params),
    );

    print('Response: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle the response
    if (response.statusCode == 201) {
      return 'success';
    } else {
      return 'error';
    }
  } catch (e) {
    print('Error occurred: $e');
    return '';
  }
}

bool isValidEmail(String email) {
  // Define the email regex pattern
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  // Create a RegExp object
  RegExp regex = RegExp(pattern);
  
  // Return true if the email matches the pattern, otherwise false
  return regex.hasMatch(email);
}

bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression pattern for (123) 456-7890 format
  String pattern = r'^\(\d{3}\) \d{3}-\d{4}$';
  
  // Create a RegExp object
  RegExp regex = RegExp(pattern);
  
  // Return true if the phone number matches the pattern, otherwise false
  return regex.hasMatch(phoneNumber);
}


// The function to format phone number as (123) 456-7890
String _formatPhoneNumber(String input) {
  // Remove any non-digit characters
  input = input.replaceAll(RegExp(r'\D'), '');

  if (input.length >= 7) {
    // Format as (123) 456-7890
    return '(${input.substring(0, 3)}) ${input.substring(3, 6)}-${input.substring(6, input.length)}';
  } else if (input.length >= 4) {
    // Format as (123) 456
    return '(${input.substring(0, 3)}) ${input.substring(3, input.length)}';
  } else if (input.isNotEmpty) {
    // Format as (123
    return '(${input.substring(0, input.length)}';
  }
  
  return input; // Return unformatted input if less than 1 digit
}