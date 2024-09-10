import 'dart:convert'; // Importing dart:convert to use jsonDecode function
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else  {
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
  bool showRegistration = false; // Flag to show registration page

  @override
  Widget build(BuildContext context) {
    Widget page;

    // Conditionally show the registration page or selected page
    if (showRegistration) {
      page = RegistrationPage(
        onBack: () {
          setState(() {
            showRegistration = false;
          });
        },
      );
    } else {
      switch (selectedIndex) {
        case 0:
          page = LoginPage(
            onRegisterClicked: () {
              setState(() {
                showRegistration = true;
              });
            },
          );
          break;
        case 1:
          page = InventoryPage();
          break;
        case 2:
          page = RecipesPage();
          break;
        default:
          throw UnimplementedError('No widget for $selectedIndex');
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.login),
                      label: Text('Login'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.kitchen),
                      label: Text('Inventory'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_dining),
                      label: Text('Recipes'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                      showRegistration = false; // Hide registration if switching
                    });
                  },
                ),
              ),
              Expanded(
                child: page, // Directly show the page here without a Container
              ),
            ],
          ),
        );
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final VoidCallback onRegisterClicked;

  LoginPage({required this.onRegisterClicked});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Add Scaffold for proper theme handling
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRegisterClicked, // Navigate to registration
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}


class RegistrationPage extends StatelessWidget {
  final VoidCallback onBack;

  RegistrationPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack, // Call back to go back to login
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                // Handle registration logic
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}


class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('No Inventory Yet.'),
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