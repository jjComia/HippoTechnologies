// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import '../models/recipe.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

final SessionService sessionService = SessionService();
List<Recipe> recipes = [];

Future<void> getRecipes() async {
  var url = Uri.https('bakery.permavite.com', 'api/recipes');

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
  );

  var jsonData = jsonDecode(response.body);

  if (response.statusCode == 200) {
    recipes.clear(); // Clear the list to avoid duplicates

    for (var eachRecipe in jsonData) {
      final recipe = Recipe(
        name: eachRecipe['name'],
        description: eachRecipe['description'],
      );
      recipes.add(recipe);
    }
    print('Number of recipes loaded: ${recipes.length}');
  } else {
    print('Failed to load recipes: ${response.statusCode}');
  }
}

// Text editing controllers for user input
final TextEditingController _recipeNameController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
final TextEditingController _prepUnitController = TextEditingController();
final TextEditingController _cookUnitController = TextEditingController();
final TextEditingController _ratingController = TextEditingController();
final TextEditingController _prepTimeController = TextEditingController();
final TextEditingController _cookTimeController = TextEditingController();

// Function to check if parameters are valid
bool checkRecipeParams() {
  var name = _recipeNameController.text;
  var description = _descriptionController.text;
  var prepUnit = _prepUnitController.text;
  var cookUnit = _cookUnitController.text;
  var rating = double.tryParse(_ratingController.text) ?? 0.0;
  var prepTime = double.tryParse(_prepTimeController.text) ?? 0.0;
  var cookTime = double.tryParse(_cookTimeController.text) ?? 0.0;

  if (name.isEmpty || description.isEmpty || prepUnit.isEmpty || cookUnit.isEmpty || rating < 0 || rating > 5 || prepTime < 0 || cookTime < 0) {
    print('Please fill in all fields');
    return false;
  }
  return true;
}

// Function to add a recipe to the database
Future<bool> addRecipe() async {
  var name = _recipeNameController.text;
  var description = _descriptionController.text;
  var prepUnit = _prepUnitController.text;
  var cookUnit = _cookUnitController.text;
  var rating = double.tryParse(_ratingController.text) ?? 0.0;
  var prepTime = double.tryParse(_prepTimeController.text) ?? 0.0;
  var cookTime = double.tryParse(_cookTimeController.text) ?? 0.0;

  print('Adding recipe: $name, $description, $prepUnit, $cookUnit, $rating, $prepTime, $cookTime');

  var url = Uri.parse('https://bakery.permavite.com/api/recipes');
  // POST request to add the recipe to the database
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}', // USE WHEN SESSIONID FOR AUTH IS FIXED
    },
    body: jsonEncode({
      'name': name,
      'description': description,
      'prepUnit': prepUnit,
      'cookUnit': cookUnit,
      'rating': rating,
      'prepTime': prepTime,
      'cookTime': cookTime,
    }),
  );

  if (response.statusCode == 201) {
    print('Recipe added successfully');
    getRecipes(); // Reload the recipes after adding a new one
    return true;
  } else {
    print('Failed to add recipe: ${response.statusCode}');
    return false;
  }
}

void _showAddRecipeDialog(BuildContext context) {
  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Add Recipe",
    pageBuilder: (context) {
      return AlertDialog(
        title: Text('Add Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _recipeNameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _prepUnitController,
                decoration: InputDecoration(labelText: 'Prep Unit (e.g. Minutes, Hours)'),
              ),
              TextField(
                controller: _cookUnitController,
                decoration: InputDecoration(labelText: 'Cook Unit (e.g. Minutes, Hours)'),
              ),
              TextField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Rating (0-5)'),
              ),
              TextField(
                controller: _prepTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Prep Time (e.g. 15 for 15 minutes)'),
              ),
              TextField(
                controller: _cookTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cook Time (e.g. 30 for 30 minutes)'),
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
              if (checkRecipeParams() == false) {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.scale,
                  title: 'Error',
                  desc: 'Not all fields populated.\nPlease fill in all fields.',
                  btnOkOnPress: () {},
                ).show();
              } else {
                // Slide to the next dialog by first popping the current one
                Navigator.of(context).pop();

                // Delay to ensure the first dialog closes completely before opening the next
                Future.delayed(Duration(milliseconds: 200), () {
                  _showAddIngredientsDialog(context); // Show the next dialog for adding ingredients
                });
              }
            },
            child: Text('Next'),
          ),
        ],
      );
    },
  );
}



void _showAddIngredientsDialog(BuildContext context) {
  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Add Ingredients",
    pageBuilder: (context) {
      final TextEditingController _ingredientController = TextEditingController();
      final TextEditingController _quantityController = TextEditingController();

      return AlertDialog(
        title: Text('Add Ingredients'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _ingredientController,
                decoration: InputDecoration(labelText: 'Ingredient'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              SizedBox(height: 10),
              // You can add additional TextFields for multiple ingredients if needed
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
              if (_ingredientController.text.isEmpty || _quantityController.text.isEmpty) {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.scale,
                  title: 'Error',
                  desc: 'Please add at least one ingredient and quantity.',
                  btnOkOnPress: () {},
                ).show();
              } else {
                // Slide to the next dialog by first popping the current one
                Navigator.of(context).pop();

                // Delay to ensure the first dialog closes completely before opening the next
                Future.delayed(Duration(milliseconds: 200), () {
                  _showAddStepsDialog(context); // Show the next dialog for adding ingredients
                });
              }
            },
            child: Text('Next'),
          ),
        ],
      );
    },
  );
}

void _showAddStepsDialog(BuildContext context) {
  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Add Steps",
    pageBuilder: (context) {
      final TextEditingController _stepController = TextEditingController();

      return AlertDialog(
        title: Text('Add Steps'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _stepController,
                decoration: InputDecoration(labelText: 'Step'),
              ),
              SizedBox(height: 10),
              // You can add additional TextFields for multiple steps if needed
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
              if (_stepController.text.isEmpty) {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.scale,
                  title: 'Error',
                  desc: 'Please add at least one step.',
                  btnOkOnPress: () {},
                ).show();
              } else {
                // Slide to the next dialog by first popping the current one
                Navigator.of(context).pop();

                // Delay to ensure the first dialog closes completely before opening the next
                Future.delayed(Duration(milliseconds: 200), () {
                  _showAddRecipeDialog(context); // Show the next dialog for adding ingredients
                });
              }
            },
            child: Text('Next'),
          ),
        ],
      );
    },
  );
}


// Recipes Detail Page
class RecipesDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes')),
      body: FutureBuilder(
        future: getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (recipes.isEmpty) {
              return Center(
                child: Text('No recipes available'),
              );
            }
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        recipes[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      textColor: const Color.fromARGB(255, 69, 145, 105),
                      subtitle: Text(
                        recipes[index].description ?? 'No description available',
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
        backgroundColor: const Color.fromARGB(255, 162, 185, 188).withOpacity(0.8),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.search),
            label: 'Search Recipes',
            labelBackgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            onTap: () {
              // Add search functionality here
              print('Search button tapped');
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Add Recipe',
            labelBackgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            onTap: () {
              _showAddRecipeDialog(context); // Show the add recipe dialog
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: 'Delete Recipe',
            labelBackgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            onTap: () {
              print('Delete button tapped');
            },
          ),
        ],
      ),
    );
  }
}

void showSlidingGeneralDialog({
  required BuildContext context,
  required WidgetBuilder pageBuilder,
  Duration transitionDuration = const Duration(milliseconds: 300),
  Color barrierColor = Colors.black54,
  bool barrierDismissible = true,
  String barrierLabel = '',
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (context, anim1, anim2) => pageBuilder(context),
    transitionBuilder: (context, anim1, anim2, child) {
      final curvedAnimation = CurvedAnimation(parent: anim1, curve: Curves.easeInOut);
      return SlideTransition(
        position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(curvedAnimation),
        child: child,
      );
    },
  );
}


class AddIngredientsPage extends StatelessWidget {
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Ingredients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(labelText: 'Ingredient'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Add recipe logic here
                if (_ingredientController.text.isEmpty || _quantityController.text.isEmpty) {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.scale,
                    title: 'Error',
                    desc: 'Please add at least one ingredient and quantity.',
                    btnOkOnPress: () {},
                  ).show();
                } else {
                  // You can add the logic to save the recipe and ingredients here

                  // Pop back to the previous page or show a success message
                  Navigator.of(context).pop();
                  getRecipes();
                }
              },
              child: Text('Add Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
