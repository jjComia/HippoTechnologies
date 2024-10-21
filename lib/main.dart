// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'pages/registration.dart'; // Import the RegistrationPage
import 'pages/registerEmailAndPhone.dart'; // Import the RegisterEmailAndPhone Page
import 'pages/login.dart';        // Import the LoginPage
import 'pages/bakedGoodsPage.dart'; //Import the Inventory Page
import 'services/session_service.dart';
import 'pages/recipePage.dart'; // Import the Recipes Page
import 'pages/ingredientsPage.dart'; // Import the Ingredients Page
import 'package:http/http.dart' as http;
import 'dart:convert'; // Importing dart:convert to use jsonDecode function

final SessionService sessionService = SessionService();
var userID = '';


void main() {
  debugPaintSizeEnabled = false; // Set to true for visual layout debugging
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Bakery App',
            theme: appState.isDarkMode 
              ? ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark().copyWith(
                    primary: const Color.fromARGB(200, 154, 51, 52),
                    secondary: const Color.fromARGB(255, 255,253,241)
                ),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                    color: const Color.fromARGB(255, 255, 253, 241)
                ),
              )
              : ThemeData.light().copyWith(
                scaffoldBackgroundColor: Color.fromARGB(200, 154,51,52), 
                colorScheme: ColorScheme.light().copyWith(
                    primary: const Color.fromARGB(255, 154, 51, 52),
                    secondary: Color.fromARGB(255,255,253,241)
                ),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                    color: const Color.fromARGB(255, 255, 253, 241)
                ),
            ),
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  bool isLoggedIn = false; // Flag for login status
  bool showRegistrationPage = false; // Flag for registration page
  bool showNextPage = false; // Flag for next registration page

  bool isDarkMode = false; // Flag for Dark Mode

  // Variables to store user data
  String firstName = '';
  String lastName = '';
  String username = '';
  String password = '';

  // Nullable Type Function - Can be null or have function reference - Used to reset navigation  
  Function? resetNavigation;

  // Gets user information to display username, name, email, and phone number
  Future<void> getUserInfo() async {
    // Get userID from sessionID
    var url = Uri.https('bakery.permavite.com', '/api/session/${await sessionService.getSessionID()}');

    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if(response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      userID = jsonData['userId'];

      // Get user information from userID
      url = Uri.https('bakery.permavite.com', '/api/users/$userID');

      var response2 = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '${await sessionService.getSessionID()}',
        },
      );

      print('Response Status: ${response2.statusCode}');
      print('Response Body: ${response2.body}');

      if (response2.statusCode == 200) {
        var jsonData2 = jsonDecode(response2.body);
        firstName = jsonData2['firstName'];
        lastName = jsonData2['lastName'];
        username = jsonData2['username'];
        notifyListeners(); // Rebuild the UI
      } else {
        print('Failed to get user information: ${response.statusCode}');
      }
    } else {
      print('Failed to get user information: ${response.statusCode}');
    }
  }

  Future<void> checkSessionID() async {
    String? sessionID = await sessionService.getSessionID();
    if (sessionID != null) {
      isLoggedIn = true; // Mark as logged in
      getUserInfo(); // Get user information
    }
    notifyListeners(); // Rebuild the UI
  }
  
  void login() {
    isLoggedIn = true; // Mark as logged in
    getUserInfo();
    notifyListeners(); // Rebuild the UI
  }

  void showRegisterPage() {
    showRegistrationPage = true; // Show registration page
    notifyListeners();
  }

  void showLoginPage() {
    showRegistrationPage = false; // Show login page
    showNextPage = false; // Hide next registration page
    notifyListeners();
  }

  void showNextRegisterPage(String firstName, String lastName, String username, String password) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.username = username;
    this.password = password;

    showRegistrationPage = false;
    showNextPage = true;
    notifyListeners();
  }


  void toggleDarkMode(bool value) {
    isDarkMode = value; // Toggle Dark Mode
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    sessionService.deleteSessionID();

    if (resetNavigation != null) {
      resetNavigation!(); // Reset navigation to HomePage
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  Widget? selectedPage; // Track which page is selected, including buttons on HomePage

  @override
  void initState() {
    super.initState();

    // Register the reset navigation function in MyAppState
    var appState = context.read<MyAppState>();
    appState.resetNavigation = resetToHomePage;

    //Check if user is logged in
    appState.checkSessionID();
  }

  void resetToHomePage() {
    setState(() {
      selectedIndex = 0;
      selectedPage = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // If not logged in, show either login or registration page
    if (!appState.isLoggedIn) {
      if (appState.showRegistrationPage) {
        return RegistrationPage(
          onBackToLogin: () {
            appState.showLoginPage(); // Go back to login page
          },
          onRegisterNext: (String firstName, String lastName, String username, String password) {
            // Pass the parameters to the next page
            appState.showNextRegisterPage(firstName, lastName, username, password);
          },
        );
      } else if (appState.showNextPage) {
        // Pass the stored values to the next page
        return RegisterEmailAndPhone(
          firstName: appState.firstName,
          lastName: appState.lastName,
          username: appState.username,
          password: appState.password,
          onCancelTap: () {
            appState.showLoginPage(); // Go back to registration page
          },
          onRegisterSuccess: () {
            appState.login(); // Mark as logged in
          },
        );
      } else {

        // Show Login Page
        return LoginPage(
          onLoginSuccess: () {
            appState.login(); // Mark as logged in
          },
          onRegisterTap: () {
            appState.showRegisterPage(); // Go to registration page
          },
        );
      }
    }

    return Scaffold(
      body: getPageForIndex(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
            selectedPage = null; // Reset selectedPage when tapping bottom nav items
          });
        },
        selectedItemColor: Color.fromARGB(255, 154,51,52),
        unselectedItemColor: Color.fromARGB(255, 37,3, 3),
        backgroundColor: Color.fromARGB(255, 255,253,241),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Function to return the selected page based on selectedIndex or button taps
  Widget getPageForIndex(int index) {
    // If a button was clicked on HomePage, show the selected page
    if (selectedPage != null) {
      return selectedPage!;
    }

    // Handle BottomNavigationBar page switching
    if (index == 0) {
      return HomePage(
        onPageTap: (Widget page) {
          setState(() {
            selectedPage = page; // Change the selectedPage to the clicked button's page
          });
        },
      );
    } else if (index == 1) {
      return SettingsPage(
        onPageTap: (Widget page) {
          setState(() {
            selectedPage = page;
          });
        },
      );
    } else {
      return HomePage(
        onPageTap: (Widget page) {
          setState(() {
            selectedPage = page;
          });
        },
      );
    }
  }
}




class HomePage extends StatelessWidget {
  final Function(Widget) onPageTap;

  const HomePage({required this.onPageTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)), // Set the text color to black
        ),
        backgroundColor: Color.fromARGB(255, 255,253,241),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              // Add the image from assets at the top
              Image.asset(
                'assets/images/clearhippo.png', // Path to your image in the assets folder
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20), // Add some spacing between the image and grid

              // Grid layout for buttons wrapped in a container with fixed height
              Container(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
                  crossAxisCount: 1, // 1 button per row
                  mainAxisSpacing: 20.0, // Vertical spacing between buttons
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 2.6, // Aspect ratio for buttons
                  children: [
                    _buildRoundedButton(
                      context,
                      'Baked Goods',
                      Icons.inventory,
                      onTap: () {
                        onPageTap(BakedGoodsDetailPage());
                      },
                    ),
                    _buildRoundedButton(
                      context,
                      'Recipes',
                      Icons.local_dining,
                      onTap: () {
                        onPageTap(RecipesDetailPage());
                      },
                    ),
                    _buildRoundedButton(
                      context,
                      'Ingredients',
                      Icons.list,
                      onTap: () {
                        onPageTap(IngredientsPage());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton(BuildContext context, String text, IconData icon, {required VoidCallback onTap}) {
    return SizedBox(
      height: 200.0,
      width: 200.0,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          backgroundColor: const Color.fromARGB(255, 255, 253, 241),
          elevation: 0.0, // Shadow elevation
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: const Color.fromARGB(255, 37, 3, 3),
            ),
            const SizedBox(height: 8.0),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 37, 3, 3),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final Function(Widget) onPageTap;

  const SettingsPage({required this.onPageTap});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)), // Set the text color to black
        ),
        backgroundColor: Color.fromARGB(255, 255,253,241),
      ),
      body: Column(
        children: [
          // Scrollable content in the middle
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display User Information
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Color.fromARGB(255, 255, 253, 241), // Light background for info cards
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Information',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 154, 51, 52),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildUserInfoRow('Username:', appState.username),
                          _buildUserInfoRow('Name:', '${appState.firstName} ${appState.lastName}'),
                        ],
                      ),
                    ),
                  ),
                  /*
                  // Update Email
                  ListTile(
                    title: Text(
                      'Update Email',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 253, 241)),
                    ),
                    onTap: () {
                      widget.onPageTap(UpdateEmailPage());
                    },
                  ),
                  // Update Phone Number
                  ListTile(
                    title: Text(
                      'Update Phone Number',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 253, 241)),
                    ),
                    onTap: () {
                      widget.onPageTap(UpdatePhonePage());
                    },
                  ),
                  */
                ],
              ),
            ),
          ),
          
          // Buttons at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add functionality here, e.g., logging out
                      appState.logout();  // Call the logout method
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                    ),
                    child: Text('Log Out', style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 37, 3, 3))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build rows for user information
  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 20),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/*
// Update Email Page
class UpdateEmailPage extends StatefulWidget {
  @override
  _UpdateEmailPageState createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Email'),
        backgroundColor: Color.fromARGB(255, 154, 51, 52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 255,253,241),  // Default label color
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 255,253,241), width: 2.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 204,198,159), width: 2.0),       // Change the color of the border when focused
                ),
                floatingLabelStyle: TextStyle(
                  color: Color.fromARGB(255, 204,198,159),  // Label color when the field is focused
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                // Handle email saving or updating logic here
                updateEmail(email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
              ),
              child: Text('Save', style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 37, 3, 3))),
            ),
          ],
        ),
      ),
    );
  }
}

void updateEmail(String email) async {
  // Add functionality here to update the email
  print('Updating Email: $email');

  // Construct the URL for updating the email using the userId
  var url = Uri.https('bakery.permavite.com', '/api/email/${await sessionService.getSessionID()}/$email');

  // Make the PUT request to update the email
  var response = await http.put(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
    body: jsonEncode({
      'id': await sessionService.getSessionID(),
      'userId': await sessionService.getSessionID(),
      'address': email,
      'verified': false,
    }),
  );

  print('Response Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print('Email updated successfully');
  } else {
    print('Failed to update email: ${response.statusCode}');
  }
}


// Update Phone Page
class UpdatePhonePage extends StatefulWidget {
  @override
  _UpdatePhonePageState createState() => _UpdatePhonePageState();
}

class _UpdatePhonePageState extends State<UpdatePhonePage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Phone Number'),
        backgroundColor: Color.fromARGB(255, 154, 51, 52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 255,253,241),  // Default label color
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 255,253,241), width: 2.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 204,198,159), width: 2.0),       // Change the color of the border when focused
                ),
                floatingLabelStyle: TextStyle(
                  color: Color.fromARGB(255, 204,198,159),  // Label color when the field is focused
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                String phone = _phoneController.text;
                // Handle email saving or updating logic here
                updatePhone(phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
              ),
              child: Text('Save', style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 37, 3, 3))),
            ),
          ],
        ),
      ),
    );
  }
}

void updatePhone(String phone) async {
  // Add functionality here to update the phone number
  print('Updating Phone Number: $phone')
}*/