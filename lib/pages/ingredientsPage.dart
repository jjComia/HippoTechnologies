// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/pages/recipePage.dart';
import '../services/session_service.dart';
import 'dart:convert';
import '../models/ingredients.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'ingredientDetails.dart'; // Import ingredientDetails.dart page file

final SessionService sessionService = SessionService();
List<Ingredient> ingredients = [];

Future<void> getIngredients() async {
  var url = Uri.https('bakery.permavite.com', 'api/inventory');

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  print('Response Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);

    // Check if the parsed data is a list
    if (jsonData is List) {
      ingredients.clear(); // Clear the list to avoid duplicates

      for (var eachIngredient in jsonData) {
        // Print each ingredient to ensure it has the expected fields
        print('Processing ingredient: $eachIngredient');

        if (eachIngredient.containsKey('id') &&
            eachIngredient.containsKey('name') &&
            eachIngredient.containsKey('quantity') &&
            eachIngredient.containsKey('purchaseQuantity') &&
            eachIngredient.containsKey('costPerPurchaseUnit') &&
            eachIngredient.containsKey('unit') &&
            eachIngredient.containsKey('notes')) {
          final ingredient = Ingredient(
            id: eachIngredient['id'],
            name: eachIngredient['name'],
            quantity: (eachIngredient['quantity'] as num).toDouble(), // Safely convert to int
            purchaseQuantity: (eachIngredient['purchaseQuantity'] as num).toInt(), // Safely convert to int
            costPerPurchaseUnit: (eachIngredient['costPerPurchaseUnit'] as num).toDouble(), // Safely convert to double
            unit: eachIngredient['unit'],
            notes: eachIngredient['notes'],
          );

          // Print to confirm that the ingredient object was created successfully
          print('Adding ingredient: ${ingredient.name}');
          ingredients.add(ingredient);
        } else {
          print('Ingredient data missing required fields: $eachIngredient');
        }
      }

      print('Number of Ingredients loaded: ${ingredients.length}');
    } else {
      print('Unexpected JSON format. Expected a list but got: ${jsonData.runtimeType}');
    }
  } else {
    print('Failed to load Ingredients: ${response.statusCode}');
  }
}

// Text editing controllers for user input
final TextEditingController _nameController = TextEditingController();
final TextEditingController _quantityController = TextEditingController();
final TextEditingController _purchaseQuantityController = TextEditingController();
final TextEditingController _costPerPurchaseUnitController = TextEditingController();
final TextEditingController _unitController = TextEditingController();
final TextEditingController _notesController = TextEditingController();

Future<void> addIngredient() async {
  try {
    // Parsing input fields
    var name = _nameController.text.trim(); // Trim whitespace
    var quantityStr = _quantityController.text.trim();
    var purchaseQuantityStr = _purchaseQuantityController.text.trim();
    var costPerPurchaseUnitStr = _costPerPurchaseUnitController.text.trim();

    // Convert quantity and purchaseQuantity to int
    double quantity = double.tryParse(quantityStr) ?? 0;
    int purchaseQuantity = int.tryParse(purchaseQuantityStr) ?? 0;

    // Convert costPerPurchaseUnit to double
    double costPerPurchaseUnit = double.tryParse(costPerPurchaseUnitStr) ?? 0.0;

    // Print parsed values to debug
    print('Adding Ingredient with:');
    print('Name: $name');
    print('Quantity: $quantity');
    print('Purchase Quantity: $purchaseQuantity');
    print('Cost Per Purchase Unit: $costPerPurchaseUnit');
    print('Session ID: ${await sessionService.getSessionID()}');

    // Ensure quantity and purchaseQuantity are integers without decimal points
    if (purchaseQuantityStr.contains('.')) {
      print('Error: Quantity and Purchase Quantity must be whole numbers.');
      return; // Exit early if the input is not valid
    }

    var unit = _unitController.text.trim();
    var notes = _notesController.text.trim();

    var url = Uri.parse('https://bakery.permavite.com/api/inventory');

    // POST request to add the ingredient to the database
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
      body: jsonEncode({
        'name': name,
        'quantity': quantity, // Send as int
        'purchaseQuantity': purchaseQuantity, // Send as int
        'costPerPurchaseUnit': costPerPurchaseUnit, // Send as double
        'unit': unit,
        'notes': notes,
      }),
    );

    // Handle the response and print detailed logs
    if (response.statusCode == 201) {
      print('Ingredient added successfully');
      await getIngredients(); // Reload the ingredient list after adding a new one
    } else {
      // Error handling: log details for troubleshooting
      print('Failed to add Ingredient');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    // Catch any other unexpected errors and log them
    print('Error while adding ingredient: $e');
  }
}

// Function to show the add ingredient dialog with a fade and scale transition
Future<bool> _showAddIngredientDialog(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Add Ingredient",
    barrierColor: Color.fromARGB(255, 37, 3, 3).withOpacity(0.5), // Darkens the background
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return AlertDialog(
        title: Text('Add Ingredient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Ingredient Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: _unitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Unit (e.g. kg, g, L, mL, etc.)'),
              ),
              TextField(
                controller: _purchaseQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Purchase Quantity'),
              ),
              TextField(
                controller: _costPerPurchaseUnitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cost Per Purchase Unit'),
              ),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Close without refresh
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await addIngredient(); // Add the Ingredient Item

              Navigator.of(context).pop(true); // Close and trigger refresh
            },
            child: Text('Add'),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
          child: child,
        ),
      );
    },
  ).then((value) => value as bool? ?? false); // Ensure a bool is always returned
}

// Ingredient Detail Page
class IngredientsPage extends StatefulWidget {
  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  TextEditingController searchController = TextEditingController();
  List<Ingredient> filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    // Initialize the filteredIngredients with the full list
    filteredIngredients = ingredients;
  }

  void filterSearch(String query) {
    List<Ingredient> tempList = ingredients.where((ingredient) {
      return ingredient.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredIngredients = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ingredients',
        style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)),  // Set the text color to black
      ),
      backgroundColor: Color.fromARGB(255, 255, 253, 241),
    ),
    body: FutureBuilder(
      future: getIngredients(),
      builder: (context, snapshot) {
        print('Ingredients: $ingredients');
        if (snapshot.connectionState == ConnectionState.done) {
          if (ingredients.isEmpty) {
            return Center(
              child: Text('No Ingredient Items available'),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) {
                      filterSearch(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Ingredients',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          title: Text(
                            filteredIngredients[index].name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          textColor: const Color.fromARGB(255, 32, 3, 3),
                          subtitle: Text(
                            'In stock: ${filteredIngredients[index].quantity.toString()} ${filteredIngredients[index].unit}' ?? 'No quantity available',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IngredientDetailsPage(ingredient: ingredients[index]),
                              ),
                            ).then((shouldRefresh) {
                              if (shouldRefresh == true) {
                                setState(() {
                                  // Reload the data or refresh the page
                                  getIngredients();
                                });
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ),
    floatingActionButton: SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      foregroundColor: const Color.fromARGB(255, 37, 3, 3),
      backgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
      overlayColor: Color.fromARGB(255, 37, 3, 3),
      overlayOpacity: 0.5,
      spacing: 12,
      spaceBetweenChildren: 12,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          label: 'Add Ingredient',
          labelBackgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
          backgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
          labelStyle: const TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
          onTap: () {
            _showAddIngredientDialog(context); // Show the add ingredient dialog
          },
        ),
      ],
    ),
  );
  }
}
