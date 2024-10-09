// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'pages/registration.dart'; // Import the RegistrationPage
import 'pages/login.dart';        // Import the LoginPage
import 'pages/inventoryPage.dart'; //Import the Inventory Page
import 'services/session_service.dart';
import 'pages/recipePage.dart'; // Import the Recipes Page
import 'pages/ingredientsPage.dart'; // Import the Ingredients Page

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
            title: 'Namer App',
            theme: appState.isDarkMode 
              ? ThemeData.dark().copyWith(colorScheme: ColorScheme.dark().copyWith(secondary: const Color.fromARGB(255, 26,67,131))) 
              : ThemeData.light().copyWith(scaffoldBackgroundColor: Color.fromARGB(255, 26,67,131), colorScheme: ColorScheme.light().copyWith(secondary: Color.fromARGB(255,246, 232, 177))),
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

  bool isDarkMode = false; // Flag for Dark Mode

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
        selectedItemColor: Color.fromARGB(255, 26,67,131),
        unselectedItemColor: Color.fromARGB(255, 0,0,0),
        backgroundColor: Color.fromARGB(255, 213,172,76),
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
  final Function(Widget) onPageTap;   // Function to hangle page navigation

  const HomePage({required this.onPageTap});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
              // Use the onPageTap function for navigation
              onPageTap(InventoryDetailPage());
            },
          ),
          _buildRoundedButton(
            context,
            'Employees',
            Icons.person,
            onTap: () {
              // Use the onPageTap function for navigation
              onPageTap(EmployeesPage());
            },
          ),
          _buildRoundedButton(
            context,
            'Recipes',
            Icons.local_dining,
            onTap: () {
              // Use the onPageTap function for navigation
              onPageTap(RecipesDetailPage());
            },
          ),
          _buildRoundedButton(
            context,
            'Ingredients',
            Icons.list,
            onTap: () {
              // Use the onPageTap function for navigation
              onPageTap(IngredientsDetailPage());
            },
          ),
        ],
      ),
    );
  }

//Updated Button builder, rounded corners and has icons
 Widget _buildRoundedButton(BuildContext context, String text, IconData icon, {required VoidCallback onTap}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),  // Rounded corners
      ),
      backgroundColor: const Color.fromARGB(255,213,172,76),  // Soft background color
      elevation: 0.0,  // Slight elevation for softer shadow
    ),
    child: Row(  // Icon and text side by side
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Color.fromARGB(255, 0,0,0),  // Icon color to match text
        ),
        SizedBox(width: 8.0),  // Space between icon and text
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 0,0,0),  // White text color
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
             ListTile(
              title: Text(
                'LOGOUT',
                style: TextStyle(
                 color: Colors.red, // Change this to any color you like
                ),
              ),

              onTap: () {
                appState.logout();
              },
            ),
              
          
          ]
        )
      )
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