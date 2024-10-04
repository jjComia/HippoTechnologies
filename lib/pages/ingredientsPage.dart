// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import '../models/ingredients.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

final SessionService sessionService = SessionService();
List<Ingredient> ingredients = [];

Future<void> getIngredients() async {
  var url = Uri.https('bakery.permavite.com', 'api/ingredients');

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}', // USE WHEN SESSIONID FOR AUTH IS FIXED 
      //'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
  );

  var jsonData = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print('here');
    ingredients.clear(); // Clear the list to avoid duplicates

    for (var eachIngredient in jsonData) {
      final ingredient = Ingredient(
        recipeId: eachIngredient['recipeId'],
        inventoryId: eachIngredient['inventoryId'],
        name: eachIngredient['name'],
        quantity: eachIngredient['quantity'],
        minQuantity: eachIngredient['minQuantity'],
        unit: eachIngredient['unit']
        );
      ingredients.add(ingredient);
    }
    print('Number of Ingredients loaded: ${ingredients.length}');
  } else {
    print('Failed to load Ingredients: ${response.statusCode}');
  }
}

// Text editing controllers for user input
final TextEditingController _recipeIdController = TextEditingController();
final TextEditingController _inventoryIdController = TextEditingController();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _quantityController = TextEditingController();
final TextEditingController _minQuantityController = TextEditingController();
final TextEditingController _unitController = TextEditingController();

// Function to add an ingredient to the database
Future<void> addIngredient() async {
  var recipeId = _recipeIdController.text;
  var inventoryId = _inventoryIdController.text;
  var name = _nameController.text;
  var quantity = int.tryParse(_quantityController.text) ?? 0;
  var minQuantity = int.tryParse(_minQuantityController.text) ?? 0;
  var unit = _unitController.text;

  print('RecipeID: $recipeId');
  print('InventoryID: $inventoryId');
  print('Name: $name');
  print('Quantity: $quantity');
  print('Minimum Quantity: $minQuantity');
  print('Unit: $unit');

  print ('Session ID: ${await sessionService.getSessionID()}');

   var url = Uri.parse('https://bakery.permavite.com/api/ingredients');
  // POST request to add the ingredient to the database
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}', // USE WHEN SESSIONID FOR AUTH IS FIXED
      //'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
    body: jsonEncode({
      'recipeID': recipeId,
      'inventoryID': inventoryId,
      'name': name,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'unit': unit,
    }),
  );

  if (response.statusCode == 201) {
    print('Ingredient added successfully');
    getIngredients(); // Reload the ingredient page after adding a new one
  } else {
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Failed to add Ingredient');
  }
}

// Function to show the add ingredient dialog with a fade and scale transition
void _showAddIngredientDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Add Ingredient",
    barrierColor: Colors.black.withOpacity(0.5), // Darkens the background
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return AlertDialog(
        // backgroundColor:  Color.fromARGB(255, 162, 185, 188).withOpacity(1.0), COLOR FOR POPUP BG?
        title: Text('Add Ingredient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _recipeIdController,
                decoration: InputDecoration(labelText: 'Recipe ID'),
              ),
              TextField(
                controller: _inventoryIdController,
                decoration: InputDecoration(labelText: 'Inventory ID'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Ingredient Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity)'),
              ),
              TextField(
                controller: _minQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Minimum Quantity'),
              ),
              TextField(
                controller: _unitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Unit'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              addIngredient(); // Add the Ingredient Item

              Navigator.of(context).pop(); // Close the dialog after adding
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
  );
}

// Ingredient Detail Page
class IngredientsDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingredient')),
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
            return ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        ingredients[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      textColor: const Color.fromARGB(255, 0, 0, 0),
                      subtitle: Text(
                        ingredients[index].quantity.toString() ?? 'No quantity available',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
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
        backgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.search, color:Colors.white),
            label: 'Search Ingredient',
            labelBackgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () {
              // Add search functionality here
              print('Search button tapped');
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add, color:Colors.white),
            label: 'Add Ingredient',
            labelBackgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () {
              _showAddIngredientDialog(context); // Show the add ingredient dialog
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete, color:Colors.white),
            label: 'Delete Ingredient',
            labelBackgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 49, 108, 244).withOpacity(0.8),
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () {
              print('Delete button tapped');
            },
          ),
        ],
      ),
    );
  }
}