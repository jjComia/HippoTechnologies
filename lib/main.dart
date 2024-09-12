import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';  // For BackdropFilter

void main() {
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
              ? ThemeData.dark().copyWith(colorScheme: ColorScheme.dark().copyWith(secondary: Colors.lightBlue)) 
              : ThemeData.light().copyWith(colorScheme: ColorScheme.light().copyWith(secondary: Colors.lightBlue)),
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  bool isLoggedIn = false; // Flag for login status
  bool showRegistrationPage = false; // Flag for registration page

  bool isDarkMode = false; // Flag for Dark Mode
  
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
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  Widget? selectedPage; // Track which page is selected, including buttons on HomePage

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // If not logged in, show either login or registration page
    if (!appState.isLoggedIn) {
      if (appState.showRegistrationPage) {
        // Show Registration Page
        return RegistrationPage(
          onBackToLogin: () {
            appState.showLoginPage(); // Go back to login page
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
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

class LoginPage extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onRegisterTap;

  LoginPage({required this.onLoginSuccess, required this.onRegisterTap});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
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
                onLoginSuccess(); // Simulate successful login
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
    );
  }
}

class RegistrationPage extends StatelessWidget {
  final VoidCallback onBackToLogin;

  RegistrationPage({required this.onBackToLogin});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
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
                // Add registration logic here
                print('Registering with username: ${_usernameController.text}');
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
    );
  }
}

// Ingredients Page
class IngredientsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingredients')),
      body: Center(child: Text('Ingredients Page')),
    );
  }
}

// Inventory Detail Page
class InventoryDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory')),
      body: Center(child: Text('Inventory Details Page')),
    );
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

// Recipes Detail Page
class RecipesDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes')),
      body: Center(child: Text('Recipes Detail Page')),
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
              onPageTap(IngredientsPage());
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
      backgroundColor: const Color.fromARGB(255, 253, 169, 90).withOpacity(0.8),  // Soft background color
      elevation: 0.0,  // Slight elevation for softer shadow
    ),
    child: Row(  // Icon and text side by side
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,  // Icon color to match text
        ),
        SizedBox(width: 8.0),  // Space between icon and text
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,  // White text color
          ),
        ),
      ],
    ),
  );
 }
}

class RecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('No recipes yet.'),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function(Widget) onPageTap;

  const SettingsPage({required this.onPageTap});
  
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
              value: appState.isDarkMode, // Assuming you've added this field in MyAppState
              onChanged: (bool value) {
                appState.toggleDarkMode(value); // Toggle Dark Mode
              },
            ),
            ListTile(
              title: Text('Notification Settings'),
              onTap: () {
                // Add navigation to a more detailed notification settings page if required
                print('Tapped Notification Settings');
              },
            ),
            ListTile(
              title: Text('Account Settings'),
              onTap: () {
                // Add more detailed settings if needed
                print('Tapped Account Settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}



void parseJson() {
  // JSON data as a string
  String jsonData = '''
  {
    "inventory": [
      {
        "item_id": "001",
        "name": "Croissant",
        "quantity": 50,
        "price": 2.5,
        "ingredients": ["flour", "butter", "sugar", "yeast"]
      },
      {
        "item_id": "002",
        "name": "Chocolate Cake",
        "quantity": 20,
        "price": 15.0,
        "ingredients": ["flour", "cocoa", "sugar", "eggs", "butter"]
      },
      {
        "item_id": "003",
        "name": "Bagel",
        "quantity": 100,
        "price": 1.5,
        "ingredients": ["flour", "water", "yeast", "salt"]
      }
    ]
  }
  ''';

  // Decoding the JSON data
  var inventoryData = jsonDecode(jsonData);

  // Iterating over the items in the inventory
  for (var item in inventoryData['inventory']) {
    print("Item: ${item['name']}");
    print("Quantity: ${item['quantity']}");
    print("Price: \$${item['price']}");
    print("Ingredients: ${item['ingredients'].join(', ')}");
    print("");
  }
}