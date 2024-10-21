// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../functions/showSlidingGeneralDialog.dart';
import '../models/recipe.dart';
import '../models/recipeIngredient.dart';
import '../models/cookStep.dart';
import 'recipeDetailsPage.dart';

final SessionService sessionService = SessionService();
List<Recipe> recipes = [];

Future<void> getRecipes() async {
  var url = Uri.https('bakery.permavite.com', 'api/recipes');

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      //'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  var jsonData = jsonDecode(response.body);

  if (response.statusCode == 200) {
    recipes.clear(); // Clear the list to avoid duplicates

    for (var eachRecipe in jsonData) {
      final recipe = Recipe(
        id: eachRecipe['id'],
        name: eachRecipe['name'],
        description: eachRecipe['description'],
        rating: eachRecipe['rating'],
        prepTime: eachRecipe['prepTime'],
        prepUnit: eachRecipe['prepUnit'],
        cookTime: eachRecipe['cookTime'],
        cookUnit: eachRecipe['cookUnit'],
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
List<TextEditingController> ingredientControllers = [TextEditingController()];
List<TextEditingController> quantityControllers = [TextEditingController()];

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
Future<String?> addRecipe() async {
  var name = _recipeNameController.text;
  var description = _descriptionController.text;
  var prepUnit = _prepUnitController.text;
  var cookUnit = _cookUnitController.text;
  var rating = double.tryParse(_ratingController.text) ?? 0.0;
  var prepTime = double.tryParse(_prepTimeController.text) ?? 0.0;
  var cookTime = double.tryParse(_cookTimeController.text) ?? 0.0;

  print('Adding recipe: $name, $description, $prepUnit, $cookUnit, $rating, $prepTime, $cookTime');

  var url = Uri.https('bakery.permavite.com', 'api/recipes');

  // POST request to add the recipe to the database
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
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
    
    // Decode the response to get the recipe ID
    var responseData = jsonDecode(response.body);
    String recipeId = responseData['id'];
    
    print('New Recipe ID: $recipeId');

    // Return the new recipe ID
    return recipeId;
  } else {
    print('Failed to add recipe: ${response.statusCode}');
    return null;
  }
}

//Add steps function to handle api call for each cook step
Future<void> addSteps(String recipeId, List<String> steps) async {
  for (String step in steps) {
    var url = Uri.https('bakery.permavite.com', 'api/cookstep');

    // Create the request body
    var requestBody = jsonEncode({
      'description': step,
      'recipeId': recipeId,
    });

    // POST request to add each step to the recipe
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
      body: requestBody,
    );

    if (response.statusCode == 201) {
      print('Step added successfully: $step');
    } else {
      print('Failed to add step: $step');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }
}

//Function to search for inv. item name and return inv. item id, quanitity, and unit
Future<Map<String, dynamic>?> searchInventoryByName(String ingredientName) async {
  var url = Uri.https('bakery.permavite.com', 'api/inventory/name/$ingredientName');

  // GET request to fetch ingredient by name
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);

    // Extract required fields (id, quantity, unit)
    var ingredientData = {
      'id': jsonData['id'],
      'quantity': jsonData['quantity'],
      'unit': jsonData['unit'],
    };

    print('Found ingredient: ${jsonData['name']} with ID: ${jsonData['id']}');
    return ingredientData;
  } else if (response.statusCode == 404) {
    print('Ingredient not found: $ingredientName');
    return null;
  } else {
    print('Failed to load ingredient: ${response.statusCode}');
    return null;
  }
}

//Function to add Ingredients to database
// Function to add Ingredients to database with double quantity
Future<void> addIngredientToRecipe({
  required String recipeId,
  required String inventoryId,
  required String name,
  required double quantity, // Update to double
  required String unit,
  double minQuantity = 0.0, // Update to double with a default value
}) async {
  var url = Uri.https('bakery.permavite.com', 'api/ingredients');

  // POST request to link the ingredient to the recipe
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
    body: jsonEncode({
      'recipeId': recipeId,
      'inventoryId': inventoryId,
      'name': name,
      'quantity': quantity, // Send as double
      'minQuantity': minQuantity, // Send as double
      'unit': unit,
    }),
  );

  if (response.statusCode == 201) {
    print('Ingredient added to recipe successfully: $name');
  } else {
    print('Failed to add ingredient to recipe: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}

void _showAddRecipeDialog(BuildContext context) {
  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Add Recipe",
    pageBuilder: (context) {
      return AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.97),
        title: Text('Add Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _recipeNameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
                maxLines: null,
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null,
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _prepTimeController,
                decoration: InputDecoration(labelText: 'Prep Time (e.g. 15 for 15 minutes)'),
                maxLines: null,
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _prepUnitController,
                decoration: InputDecoration(labelText: 'Prep Unit (e.g. Minutes, Hours)'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              TextField(
                controller: _cookTimeController,
                decoration: InputDecoration(labelText: 'Cook Time (e.g. 30 for 30 minutes)'),
                maxLines: null,
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _cookUnitController,
                decoration: InputDecoration(labelText: 'Cook Unit (e.g. Minutes, Hours)'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating (0-5)'),
                maxLines: null,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
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
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.97),
            title: Text('Add Ingredients'),
            content: SizedBox(
              width: 100,  // Set a fixed width
              height: 392, // Set a fixed height
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < ingredientControllers.length; i++) ...[
                      TextField(
                        controller: ingredientControllers[i],
                        decoration: InputDecoration(labelText: 'Ingredient ${i + 1}'),
                      ),
                      TextField(
                        controller: quantityControllers[i],
                        decoration: InputDecoration(labelText: 'Quantity ${i + 1}'),
                      ),
                      SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (ingredientControllers.length > 1) {
                          // Remove the last ingredient and quantity text fields
                          ingredientControllers.removeLast();
                          quantityControllers.removeLast();
                        }
                      });
                    },
                    child: Text('Remove Ingredient'),
                  ),
                )
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ingredientControllers.add(TextEditingController());
                      quantityControllers.add(TextEditingController());
                    });
                  },
                  child: Text('Add Ingredient'),
                ),
                )
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                      
                            // Delay before showing the next dialog
                            Future.delayed(Duration(milliseconds: 200), () {
                              _showAddRecipeDialog(context); // Transition to the next dialog
                            });
                        },
                        child: Text('Back'),
                      ),
                     TextButton(
                        onPressed: () {
                          bool isValid = true;
                          for (int i = 0; i < ingredientControllers.length; i++) {
                            if (ingredientControllers[i].text.isEmpty || quantityControllers[i].text.isEmpty) {
                              isValid = false;
                              break;
                            }
                          }
                      
                          if (!isValid) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.scale,
                              title: 'Error',
                              desc: 'Please add at least one ingredient and quantity.',
                              btnOkOnPress: () {},
                            ).show();
                          } else {
                            Navigator.of(context).pop();
                      
                            // Delay before showing the next dialog
                            Future.delayed(Duration(milliseconds: 200), () {
                              _showAddStepsDialog(context); // Transition to the next dialog
                            });
                          }
                        },
                        child: Text('Next'),
                      ),
                    ],
                  ),
                )
              )
            ],
          );
        },
      );
    },
  );
}


void _showAddStepsDialog(BuildContext context) {
  List<TextEditingController> stepControllers = [TextEditingController()];

  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Add Steps",
    pageBuilder: (context) {
      return StatefulBuilder(
        builder: (Context, setState) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.97),
            title: Text('Add Steps'),
            content: SizedBox(
              width: 100,  // Same fixed width as Add Ingredients dialog
              height: 392, // Same fixed height as Add Ingredients dialog
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < stepControllers.length; i++) ...[
                      TextField(
                        controller: stepControllers[i],
                        decoration: InputDecoration(labelText: 'Step ${i + 1}'),
                      ),
                      SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (stepControllers.length > 1) {
                          // Remove the last ingredient and quantity text fields
                          stepControllers.removeLast();
                        }
                      });
                    },
                    child: Text('Remove Step'),
                  ),
                )
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      stepControllers.add(TextEditingController());
                    });
                  },
                  child: Text('Add Step'),
                ),
                )
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                      
                          // Delay before showing the next dialog
                          Future.delayed(Duration(milliseconds: 200), () {
                            _showAddIngredientsDialog(context); // Transition to the next dialog
                          });
                        },
                        child: Text('Back'),
                      ),
                      TextButton(
                        onPressed: () async {
                          bool isValid = true;
                          List<Map<String, String>> ingredientsToAdd = [];
                          List<String> steps = [];

                          // Capture context and other UI-related variables
                          final localContext = context;  // Store context for later use

                          // Collect cook steps from user input
                          for (int i = 0; i < stepControllers.length; i++) {
                            String step = stepControllers[i].text;
                            if (step.isEmpty) {
                              isValid = false;
                              break;
                            } else {
                              steps.add(step);
                            }
                          }

                          // Collect ingredients and quantities from user input
                          for (int i = 0; i < ingredientControllers.length; i++) {
                            String ingredientName = ingredientControllers[i].text;
                            String quantity = quantityControllers[i].text;  // User-entered quantity

                            if (ingredientName.isEmpty || quantity.isEmpty) {
                              isValid = false;
                              break;
                            } else {
                              ingredientsToAdd.add({
                                'name': ingredientName,
                                'quantity': quantity,
                              });
                            }
                          }

                          // Check if valid
                          if (!isValid) {
                            AwesomeDialog(
                              context: localContext,
                              dialogType: DialogType.error,
                              animType: AnimType.scale,
                              title: 'Error',
                              desc: 'Please add at least one step, ingredient, and quantity.',
                              btnOkOnPress: () {},
                            ).show();
                          } else {
                            Navigator.of(localContext).pop(); // Use stored context

                            // First, add the recipe and get the recipe ID
                            String? recipeId = await addRecipe();

                            if (recipeId != null) {
                              // Add the recipe to the cookedGoods table
                              await addCookedGoods(recipeId);

                              // After recipe is added, we proceed with cook steps
                              await addSteps(recipeId, steps);
                              print('Steps added for Recipe ID: $recipeId');

                              // Now, we proceed with adding the ingredients after cook steps
                              // Collect ingredient details from user input and convert quantity and minQuantity to double
                              for (var ingredient in ingredientsToAdd) {
                                String ingredientName = ingredient['name']!;
                                String quantityStr = ingredient['quantity']!;

                                // Convert user-entered quantity to double
                                double quantity = double.tryParse(quantityStr) ?? 0.0;

                                if (quantity == 0.0) {
                                  // Handle case where the quantity is invalid or zero
                                  print("Error: Invalid quantity for ingredient $ingredientName");
                                  continue; // Skip this ingredient if quantity is invalid
                                }

                                // Search for the ingredient in the inventory
                                Map<String, dynamic>? ingredientData = await searchInventoryByName(ingredientName);

                                if (ingredientData != null) {
                                  // If found, add it to the recipe with double quantity
                                  await addIngredientToRecipe(
                                    recipeId: recipeId,
                                    inventoryId: ingredientData['id'],
                                    name: ingredientName,
                                    quantity: quantity, // Use user-entered double quantity
                                    unit: ingredientData['unit'],
                                    minQuantity: 0.0, // Optional minQuantity, set as double
                                  );
                                } else {
                                  // Handle ingredient not found
                                  AwesomeDialog(
                                    context: localContext,
                                    dialogType: DialogType.error,
                                    animType: AnimType.scale,
                                    title: 'Error',
                                    desc: 'Ingredient not found: $ingredientName. Please add it to the inventory first.',
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              }

                              // Reload the recipes after adding a new one
                              await getRecipes();

                              
                              // Optionally, you can display a success message when all operations are done
                              // AwesomeDialog(
                              //   context: localContext,
                              //   dialogType: DialogType.success,
                              //   animType: AnimType.scale,
                              //   title: 'Success',
                              //   desc: 'Recipe, Cook Steps, and Ingredients added successfully!',
                              //   btnOkOnPress: () {},
                              // ).show();

                            } else {
                              // Handle recipe addition failure
                              // AwesomeDialog(
                              //   context: localContext,
                              //   dialogType: DialogType.error,
                              //   animType: AnimType.scale,
                              //   title: 'Error',
                              //   desc: 'Failed to add recipe. Please try again.',
                              //   btnOkOnPress: () {},
                              // ).show();
                            }
                          }
                        },
                        child: Text('Add'),
                      )
                    ],
                  ),
                )
              )
            ],
          );
        }
      );
    },
  );
}


// Recipes Detail Page
class RecipesDetailPage extends StatefulWidget {
  @override
  _RecipesDetailPageState createState() => _RecipesDetailPageState();
}

class _RecipesDetailPageState extends State<RecipesDetailPage> {
  TextEditingController searchController = TextEditingController();
  List<Recipe> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    // Initialize the filteredRecipes with the full list of recipes
    filteredRecipes = recipes;
  }

  void filterSearch(String query) {
    List<Recipe> tempList = recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredRecipes = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipes',
          style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)), // Set the text color to black
        ),
        backgroundColor: Color.fromARGB(255, 255,253,241),
      ),
      body: FutureBuilder(
        future: getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (recipes.isEmpty) {
              return Center(
                child: Text('No recipes available'),
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
                        labelText: 'Search Recipes',
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
                    itemCount: filteredRecipes.length,
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
                              filteredRecipes[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            textColor: const Color.fromARGB(255, 37, 3, 3),
                            subtitle: Text(
                              filteredRecipes[index].description,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onTap: () async {
                             try {
                              // Get ingredients for the selected recipe
                              List<RecipeIngredient> ingredients = await getIngredientsForRecipe(filteredRecipes[index].id);

                              // Get the cook steps for the selected recipe
                              List<CookStep> cookSteps = await getCookStepsForRecipe(filteredRecipes[index].id);

                              // If ingredients are successfully fetched, navigate to the details page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailsPage(recipe: recipes[index], recipeIngredients: ingredients, steps: cookSteps),  // Pass ingredients to the details page
                                ),
                              ).then((shouldRefresh) {
                                if (shouldRefresh == true) {
                                  setState(() {
                                    // Reload the data or refresh the page
                                    getRecipes();
                                  });
                                }
                              });
                            } catch (e) {
                              // Handle the error (show a dialog or a snackbar)
                              print('Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to load ingredients. Please try again later.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
        backgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
        overlayColor: Color.fromARGB(255, 37, 3, 3),
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add, color:Color.fromARGB(255, 37,3, 3)),
            label: 'Add Recipe',
            labelBackgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            labelStyle: const TextStyle(color: Color.fromARGB(255, 37,3, 3)),
            onTap: () {
              _showAddRecipeDialog(context); // Show the add recipe dialog
            },
          ),
        ],
      ),
    );
  }
}

Future<List<RecipeIngredient>> getIngredientsForRecipe(String recipeID) async {
  try {
    // Create the URL for the GET request
    var url = Uri.https('bakery.permavite.com', 'api/ingredients/recipeid/$recipeID');

    // Include the session ID in the headers
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      // Create a new List of RecipeIngredients
      List<RecipeIngredient> ingredients = [];

      // Iterate through the JSON data adding each ingredient to the list
      for (var eachIngredient in jsonData) {
        final ingredient = RecipeIngredient(
          id: eachIngredient['id'],
          recipeID: eachIngredient['recipeId'],
          inventoryID: eachIngredient['inventoryId'],
          name: eachIngredient['name'],
          quantity: eachIngredient['quantity'],
          minQuantity: eachIngredient['minQuantity'],
          unit: eachIngredient['unit'],
        );
        ingredients.add(ingredient);
      }

      // Print the number of ingredients loaded
      print('Number of ingredients loaded: ${ingredients.length}');
      return ingredients;
    } else {
      throw Exception('Failed to load ingredients: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while fetching ingredients: $e');
    throw Exception('Error fetching ingredients: $e');
  }
}

Future<List<CookStep>> getCookStepsForRecipe(String recipeID) async {
  try {
    // Create the URL for the GET request
    var url = Uri.https('bakery.permavite.com', 'api/cookstep/recipeid/$recipeID');

    // Include the session ID in the headers
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      // Create a new List of CookSteps
      List<CookStep> steps = [];

      // Iterate through the JSON data adding each step to the list
      for (var eachStep in jsonData) {
        final step = CookStep(
          id: eachStep['id'],
          recipeID: eachStep['recipeId'],
          description: eachStep['description'],
        );
        steps.add(step);
      }

      // Print the number of steps loaded
      print('Number of steps loaded: ${steps.length}');
      return steps;
    } else {
      throw Exception('Failed to load steps: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while fetching steps: $e');
    throw Exception('Error fetching steps: $e');
  }
}

Future<void> addCookedGoods(String recipeId) async {
  var url = Uri.https('bakery.permavite.com', 'api/cookedgoods');

  // POST request to add the recipe to the cookedGoods table
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
    body: jsonEncode({
      'recipeId': recipeId,
      'quantity': 0, // Default quantity
    }),
  );

  if (response.statusCode == 201) {
    print('Recipe added to cookedGoods successfully');
  } else {
    print('Failed to add recipe to cookedGoods: ${response.statusCode}');
  }
}