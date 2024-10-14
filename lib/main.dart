// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'pages/registration.dart'; // Import the RegistrationPage
import 'pages/registerEmailAndPhone.dart'; // Import the RegisterEmailAndPhone Page
import 'pages/login.dart';        // Import the LoginPage
import 'pages/inventoryPage.dart'; //Import the Inventory Page
import 'services/session_service.dart';
import 'pages/recipePage.dart'; // Import the Recipes Page
import 'pages/ingredientsPage.dart'; // Import the Ingredients Page
import 'pages/ingredientDetails.dart';

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
  final SessionService sessionService = SessionService();
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

  Future<void> checkSessionID() async {
    String? sessionID = await sessionService.getSessionID();
    if (sessionID != null) {
      isLoggedIn = true; // Mark as logged in
    }
    notifyListeners(); // Rebuild the UI
  }
  
  void login() {
    isLoggedIn = true; // Mark as logged in
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

// Employees Page
class EmployeesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employees')),
      body: Center(child: Text('Employees Page')),
    );
  }
}


//Home Page on nav bar. Contains subpages of inventory, recipes, ingredients and employees
class HomePage extends StatelessWidget {
  final Function(Widget) onPageTap;

  const HomePage({required this.onPageTap});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Add the image from assets at the top
          Image.asset(
            'assets/images/clearhippo.png', // Path to your image in the assets folder
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20), // Add some spacing between the image and grid

          // Grid layout for buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,  // 2 buttons per row
              mainAxisSpacing: 20.0,  // Vertical spacing between buttons
              crossAxisSpacing: 20.0,  // Horizontal spacing between buttons
              children: [
                _buildRoundedButton(
                  context,
                  'Inventory',
                  Icons.inventory,
                  onTap: () {
                    onPageTap(InventoryDetailPage());
                  },
                ),
                _buildRoundedButton(
                  context,
                  'Employees',
                  Icons.person,
                  onTap: () {
                    onPageTap(EmployeesPage());
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
    );
  }

Widget _buildRoundedButton(BuildContext context, String text, IconData icon, {required VoidCallback onTap}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      fixedSize: Size(200, 200),  // Set the fixed size here
      padding: const EdgeInsets.all(18.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),  // Rounded corners
      ),
      backgroundColor: const Color.fromARGB(255, 255, 253, 241),  // Background color
      elevation: 0.0,  // Shadow elevation
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 40.0,  // Adjust icon size
          color: const Color.fromARGB(255, 37, 3, 3),  // Icon color
        ),
        const SizedBox(height: 8.0),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 37, 3, 3),
          ),
        ),
      ],
    ),
  );
}
}

class ProfileSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
      ),
      body: Center(
        child: Text('This is the Profile Settings Page'),
      ), 
    );
  }
}


// Account Settings Page
class AccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255,253,241),  // White background color
                borderRadius: BorderRadius.circular(8.0),  // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),  // Slight shadow for elevation effect
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),  // Offset to add a shadow below the button
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  appState.logout();  // Call the logout method
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,  // Center text horizontally
                    children: [
                      Text(
                        'LOGOUT',
                        style: TextStyle(
                          color: Color.fromARGB(255, 154,51,52),  // Red text color
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,  // Bold text
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
  String _selectedPreference = 'Pickup'; // Order preference state
  Color _selectedAccentColor = Colors.lightBlue; // Accent color state

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Enable Dark Mode'),
              value: appState.isDarkMode,
              onChanged: (bool value) {
                appState.toggleDarkMode(value);
              },
            ),
            ListTile(
              title: Text('Account Settings'),
              onTap: () {
                widget.onPageTap(AccountSettingsPage());
              },
            ),
            ListTile(
              title: Text('Order Preference'),
              trailing: DropdownButton<String>(
                value: _selectedPreference,
                items: <String>['Pickup', 'Delivery'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPreference = newValue!;
                  });
                  print('Order preference: $newValue');
                },
              ),
            ),
            ListTile(
              title: Text('New Product Notifications'),
              trailing: Switch(
                value: true, // Replace with actual state
                onChanged: (bool value) {
                  // Toggle notifications
                  print('New product notifications: $value');
                },
              ),
            ),
            ListTile(
              title: Text('Accent Color'),
              trailing: DropdownButton<Color>(
                value: _selectedAccentColor,
                items: <Color>[Colors.lightBlue, Colors.green, Colors.pink].map<DropdownMenuItem<Color>>((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 24,
                      height: 24,
                      color: color,
                    ),
                  );
                }).toList(),
                onChanged: (Color? newValue) {
                  setState(()  {
                    _selectedAccentColor = newValue!;
                  });
                  print('Accent color changed to: $newValue');
                },
              ),
            ),
            ListTile(
              title: Text('Privacy Policy'),
              onTap: () {
                // Show Privacy Policy
                print('Privacy Policy Tapped');
              },
            ),
            ListTile(
              title: Text('Terms of Service'),
              onTap: () {
                // Show Terms of Service
                print('Terms of Service Tapped');
              },
            ),
          ],
        ),
      ),
    );
  }
}