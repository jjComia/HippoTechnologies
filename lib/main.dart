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
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  bool isLoggedIn = false; // Flag for login status
  bool showRegistrationPage = false; // Flag for registration page

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

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
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

    // After login, show the main app with navigation
    Widget page;
    if (selectedIndex == 0) {
      page = HomePage();
    } else if (selectedIndex == 1) {
      page = RecipesPage();
    } else if (selectedIndex == 2) {
      page = SettingsPage();
    } else {
      throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: page, // Display the page based on selectedIndex
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
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
            icon: Icon(Icons.local_dining),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
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

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:')
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

//Home Page on nav bar. Contains subpages of inventory, recipes, ingredients and employees
class HomePage extends StatelessWidget {
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryDetailPage()),
              );
            },
          ),
          _buildRoundedButton(
            context,
            'Employees',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeesPage()),
              );
            },
          ),
          _buildRoundedButton(
            context,
            'Recipes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipesDetailPage()),
              );
            },
          ),
          _buildRoundedButton(
            context,
            'Ingredients',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IngredientsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create a rounded button
  Widget _buildRoundedButton(BuildContext context, String text, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),  // Rounded corners
        ),
        minimumSize: Size(0, 120),  // Makes the buttons uniform in height
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
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
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('No settings yet.'),
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