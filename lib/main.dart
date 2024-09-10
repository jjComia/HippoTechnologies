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
  bool showRegistrationPage = false; // Control showing registration page

  @override
  Widget build(BuildContext context) {
    Widget page; 
    if (selectedIndex == 0) {
      // Toggle between Login and Registration page
      if (showRegistrationPage) {
        page = RegistrationPage(
          onBackToLogin: () {
            setState(() {
              showRegistrationPage = false;
            });
          },
        );
      } else {
        page = LoginPage(
          onRegisterTap: () {
            setState(() {
              showRegistrationPage = true;
            });
          },
        );
      }
    } else if (selectedIndex == 1) {
      page = InventoryPage();
    } else if (selectedIndex == 2) {
      page = RecipesPage();
    } else if (selectedIndex == 3) {
      page = SettingsPage();
    } else {
      throw UnimplementedError('no widget for $selectedIndex');
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
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                      showRegistrationPage = false; // Reset to login if nav changes
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class LoginPage extends StatelessWidget {
  final VoidCallback onRegisterTap;

  LoginPage({required this.onRegisterTap});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            },
            child: Text('Login'),
          ),
          SizedBox(height: 8.0),
          OutlinedButton(
            onPressed: onRegisterTap,
            child: Text('Register'),
          ),
        ],
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
    return Padding(
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
            onPressed: onBackToLogin,
            child: Text('Back to Login'),
          ),
        ],
      ),
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