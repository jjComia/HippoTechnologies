import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/models/recipeIngredient.dart';
import '../services/session_service.dart';
import 'dart:convert';
import '../models/recipe.dart';
import '../models/cookStep.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../functions/showSlidingGeneralDialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

final SessionService sessionService = SessionService();
List<Map<String, int>> ingredientsStock = [];

// Gets this recipe's ingredients and their stock for checking if there is enough stock to start baking
Future<void> getIngredientsStock(recipeIngredients) async {
  // Get all ingredients and their stocks
  for (var ingredient in recipeIngredients) {
    var url = Uri.https('bakery.permavite.com', '/api/inventory/id/${ingredient.inventoryID}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('Ingredient: ${ingredient.id}');
      print('Ingredient stock: ${jsonData['quantity']}');
      ingredientsStock.add({
        'id': ingredient.id,
        'stock': jsonData['quantity'],
      });
    } else {
      print('Failed to get ingredient stock: ${response.statusCode}');
    }
  }
}

void displayEditError(context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.scale,
    title: 'Error',
    desc: 'Please fill in all fields',
    btnOkOnPress: () {},
  ).show();
}

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;
  final List<RecipeIngredient> recipeIngredients;
  final List<CookStep> steps;

  RecipeDetailsPage({
    required this.recipe,
    required this.recipeIngredients,
    required this.steps,
  });

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late Recipe recipe;
  late List<RecipeIngredient> recipeIngredients;
  late List<CookStep> steps;

  void refreshPage() async {
    Recipe updatedRecipe = await getUpdatedRecipe(recipe.id);
    setState(() {
      recipe = updatedRecipe;
    });
  }

  @override
  void initState() {
    super.initState();
    ingredientsStock = [];
    recipe = widget.recipe;
    recipeIngredients = widget.recipeIngredients;
    steps = widget.steps;
    getIngredientsStock(recipeIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between content and buttons
        children: [
          // Non-scrollable RichText at the top
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: recipe.name,
                    style: TextStyle(
                      color: Color.fromARGB(255, 204, 198, 159),
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          RatingBarIndicator(
            rating: (recipe.rating ?? 0).toDouble(), // Display the recipe's current rating
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Color.fromARGB(255, 204, 198, 159),
            ),
            itemCount: 5,
            itemSize: 40.0,
            direction: Axis.horizontal,
          ),
          Divider(
            color: Color.fromARGB(255, 204, 198, 159),
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
          // Scrollable content in the middle
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Prep Time:\n${recipe.prepTime} ${recipe.prepUnit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204, 198, 159)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cook Time:\n${recipe.cookTime} ${recipe.cookUnit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204, 198, 159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB(255, 204, 198, 159)),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204, 198, 159)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8), // Add some space between the title and description
                      Text(
                        recipe.description,
                        style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204, 198, 159)),
                        textAlign: TextAlign.center,  // Align to the left (optional)
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB(255, 204, 198, 159)),
                  SizedBox(height: 20),
                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204, 198, 159)),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recipeIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = recipeIngredients[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Baseline(
                            baselineType: TextBaseline.alphabetic,
                            baseline: 18.0, // Adjust to match the text's baseline
                            child: Text(
                              '•',  // Unicode for bullet point
                              style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 204, 198, 159)),
                            ),
                          ),
                          SizedBox(width: 8),  // Adjust the space between bullet and text
                          Expanded(
                            child: Baseline(
                              baselineType: TextBaseline.alphabetic,
                              baseline: 18.0, // Same value as above for proper alignment
                              child: Text(
                                '${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 204, 198, 159),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB(255, 204, 198, 159)),
                  SizedBox(height: 20),
                  // Cook Steps Section
                  Text(
                    'Cook Steps',
                    style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204, 198, 159)),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      return ListTile(
                        title: Text(
                          'Step ${index + 1}: ${step.description}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 204, 198, 159),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Buttons at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add functionality here to edit the recipe
                      showEditDialogue(context, recipe, refreshPage);
                    },
                    child: Text('Edit Recipe', style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 37, 3, 3))),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add functionality here to start baking
                      print(ingredientsStock);
                      showStartBakingDialogue(context, recipe, recipeIngredients, steps, ingredientsStock);
                    },
                    child: Text('Start Baking!', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 37, 3, 3))),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 52,
                        color: Color.fromARGB(255, 204, 198, 159),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.scale,
                          title: 'Delete Recipe',
                          desc: 'Are you sure you want to remove this recipe?',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            final url = Uri.https('bakery.permavite.com', 'api/recipes/${recipe.id}');
                            http.delete(
                              url,
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                                'Authorization': '${await sessionService.getSessionID()}',
                              },
                            ).then((response) {
                              if (response.statusCode == 200) {
                                Navigator.of(context).pop(true);
                              } else {
                                print('Failed to delete recipe: ${response.statusCode}');
                              }
                            });
                          },
                        ).show();
                      },
                      child: Icon(
                        Icons.delete_forever,
                        size: 60,
                        color: Color.fromARGB(255, 204, 198, 159),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showEditDialogue(context, recipe, VoidCallback onEdit) {
  final TextEditingController editNameController = TextEditingController(text: recipe.name);
  final TextEditingController editDescriptionController = TextEditingController(text: recipe.description);
  final TextEditingController prepUnitController = TextEditingController(text: recipe.prepUnit);
  final TextEditingController editCookUnitController = TextEditingController(text: recipe.cookUnit);
  final TextEditingController prepTimeController = TextEditingController(text: recipe.prepTime.toString());
  final TextEditingController editCookTimeController = TextEditingController(text: recipe.cookTime.toString());
  final TextEditingController editRatingController = TextEditingController(text: recipe.rating.toString());

  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Edit Recipe",
    pageBuilder: (context) {
      return AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Centers the content
            children: <Widget>[
              Text(
                'Edit Details For', // First text
                style: TextStyle(
                  color: Color.fromARGB(255, 37, 3, 3), // Style for "Edit Details For"
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${recipe.name}?', // Second text
                style: TextStyle(
                  color: Colors.blue, // Style for recipe name
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: editNameController,
                    decoration: InputDecoration(labelText: 'Recipe Name'),
                    keyboardType: TextInputType.multiline,
                  ),
                  TextField(
                    controller: editDescriptionController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    maxLines: null,
                    controller: prepTimeController,
                    decoration: InputDecoration(labelText: 'Prep Time (e.g. 15 for 15 minutes)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: prepUnitController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: 'Prep Unit'),
                  ),
                  TextField(
                    maxLines: null,
                    controller: editCookTimeController,
                    decoration: InputDecoration(labelText: 'Cook Time (e.g. 15 for 15 minutes)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: editCookUnitController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: 'Cook Unit'),
                  ),
                  TextField(
                    controller: editRatingController,
                    decoration: InputDecoration(labelText: 'Rating (0-5)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-5]')),  // Filters out anything that is not a digit (0-9)
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },  
                child: Text('Cancel', style: TextStyle(color: Colors.grey) ),
              ),
              TextButton(
                onPressed: () async{
                  // Check to make sure the fields are not empty
                  if (editNameController.text.isEmpty || editDescriptionController.text.isEmpty || prepUnitController.text.isEmpty || editCookUnitController.text.isEmpty || prepTimeController.text.isEmpty || editCookTimeController.text.isEmpty || editRatingController.text.isEmpty) {
                    print('Please fill in all fields');
                    displayEditError(context);
                    return;
                  }

                  print('Editing Recipe');
                  await editRecipe(recipe, editNameController.text, editDescriptionController.text, prepUnitController.text, editCookUnitController.text, prepTimeController.text, editCookTimeController.text, editRatingController.text);
                  onEdit(); // Trigger page refresh
                  if(context.mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
                child: Text('Finish Edit', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> editRecipe(recipe, editName, editDescription, prepUnit, editCookUnit, prepTime, editCookTime, editRating) async {
  print('Editing ingredient');
  var url = Uri.parse('https://bakery.permavite.com/api/recipes');

  var params = {
    'id': recipe.id,
    'name': editName,
    'description': editDescription,
    'prepUnit': prepUnit,
    'cookUnit': editCookUnit,
    'prepTime': prepTime,
    'cookTime': editCookTime,
    'rating': editRating,
  };

  print(params);

  return http.put(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
    body: jsonEncode(params),
  ).then((response) {
    if (response.statusCode == 200) {
      print('Recipe edited successfully');
    } else {
      print('Failed to edit Recipe: ${response.statusCode}');
    }
  });
}

Future<Recipe> getUpdatedRecipe(recipeID) {
  print('Getting updated ingredient');
  var url = Uri.parse('https://bakery.permavite.com/api/recipes/id/$recipeID');

  return http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
  ).then((response) {
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Recipe(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        rating: data['rating'],
        prepTime: data['prepTime'],
        prepUnit: data['prepUnit'],
        cookTime: data['cookTime'],
        cookUnit: data['cookUnit'],
      );
    } else {
      print('Failed to get updated ingredient: ${response.statusCode}');
      return Recipe(
        id: '',
        name: '',
        description: '',
        rating: 0,
        prepTime: 0,
        prepUnit: '',
        cookTime: 0,
        cookUnit: '',
      );
    }
  });
}

void showStartBakingDialogue(context, recipe, recipeIngredients, steps, List<Map<String, int>> ingredientsStock) {
  // Initialize the quantity to 1
  int currentQuantity = 1;

  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Start Baking",
    pageBuilder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Centers the content
                children: <Widget>[
                  Text(
                    'Start Baking', // First text
                    style: TextStyle(
                      color: Color.fromARGB(255, 37, 3, 3), // Style for "Start Baking"
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${recipe.name}?', // Second text
                    style: TextStyle(
                      color: Colors.blue, // Style for recipe name
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  DashedLine(height: 2, color: Color.fromARGB(255, 204, 198, 159)),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients Required:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Display each ingredient in the list
                  ...recipeIngredients.map<Widget>((ingredient) {
                    // Find the stock for this ingredient
                    print(ingredientsStock);
                    int ingredientStock = ingredientsStock.firstWhere(
                      (stockItem) => stockItem['id'] == ingredient.id,
                      orElse: () => {'id': ingredient.id, 'stock': 0},
                    )['stock']!;

                    print(ingredientStock);

                    // Calculate required quantity
                    int requiredQuantity = ingredient.quantity * currentQuantity;

                    // Determine text color
                    Color textColor = requiredQuantity > ingredientStock ? Colors.red : Colors.black;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '- $requiredQuantity ${ingredient.unit} ${ingredient.name}', // Display quantity, unit, and ingredient name
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DashedLine(height: 2, color: Color.fromARGB(255, 204, 198, 159)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scale Recipe?', // Display text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (currentQuantity > 1) {
                              currentQuantity--; // Decrease quantity
                            }
                          });
                        },
                        child: Text('-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '$currentQuantity', // Display updated quantity
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentQuantity++; // Increase quantity
                          });
                        },
                        child: Text('+'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the buttons
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Check if there is enough stock to start baking
                          print('1');
                          bool canBake = true;
                          for (var ingredient in recipeIngredients) {
                            int requiredQuantity = ingredient.quantity * currentQuantity;
                            int ingredientStock = ingredientsStock.firstWhere(
                              (stockItem) => stockItem['id'] == ingredient.id,
                              orElse: () => {'id': ingredient.id, 'stock': 0},
                            )['stock']!;

                            if (requiredQuantity > ingredientStock) {
                              canBake = false;
                              break;
                            }
                          }

                          if (!canBake) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.scale,
                              title: 'Error',
                              desc: 'Not enough stock to start baking',
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          }

                          print('2');
                          // Remove the required stock from the inventory
                          for (var ingredient in recipeIngredients) {
                            int requiredQuantity = ingredient.quantity * currentQuantity;
                            int ingredientStock = ingredientsStock.firstWhere(
                              (stockItem) => stockItem['id'] == ingredient.id,
                              orElse: () => {'id': ingredient.id, 'stock': 0},
                            )['stock']!;

                            // Calculate the new stock
                            int newStock = ingredientStock - requiredQuantity;

                            // Update the inventory
                            bool blnCheck =  await editIngredientStock(ingredient, newStock);
                            if (!blnCheck) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.scale,
                                title: 'Error',
                                desc: 'Failed to update inventory',
                                btnOkOnPress: () {},
                              ).show();
                              return;
                            }
                          }

                          print('3');
                          // Add Goods to Inventory
                          // Add Goods to Inventory
                          bool blnCheck = await addFinsihedGoods(recipe, currentQuantity);
                          if (!blnCheck) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.scale,
                              title: 'Error',
                              desc: 'Failed to add finished goods',
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          } else {
                            showSuccessDialog(context, recipe.name);
                          }
                        },
                        child: Text('Start Baking'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

void showSuccessDialog(BuildContext context, String recipeName) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.scale,
    title: 'Baking successful',
    desc: '$recipeName has been successfully baked!',
    btnOkText: 'Awesome!',
    btnOkOnPress: () {
      Navigator.of(context).pop(); // Pop after confirming success
    },
  ).show();
}


Future<bool> addFinsihedGoods(recipe, int finishedQuantity) async {
  // First get the current amount of this finished good in the inventory
  var url = Uri.https('bakery.permavite.com', '/api/cookedgoods/recipeid/${recipe.id}');

  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    int currentQuantity = jsonData['quantity'];

    // Add the new quantity to the current quantity
    int newQuantity = currentQuantity + finishedQuantity;

    // Update the inventory
    var params = {
      'recipeId': recipe.id,
      'quantity': newQuantity,
    };

    var url = Uri.parse('https://bakery.permavite.com/api/cookedgoods');

    var response2 = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
      body: jsonEncode(params),
    );

    if (response2.statusCode == 200) {
      print('Finished goods added successfully');
    } else {
      print('Failed to add finished goods: ${response2.statusCode}');
      return false;
    }
  } else {
    print('Failed to get finished goods: ${response.statusCode}');
    return false;
  }

  return true;
}

Future<bool> editIngredientStock(ingredient, stock) async {
  // First get the current information for this ingredient
  var url = Uri.https('bakery.permavite.com', '/api/inventory/id/${ingredient.inventoryID}');
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    print(jsonData);

    // Update the stock
    var params = {
      'id': jsonData['id'],
      'name': jsonData['name'],
      'quantity': stock,
      'purchaseQuantity': jsonData['purchaseQuantity'],
      'costPerPurchaseUnit': jsonData['costPerPurchaseUnit'],
      'unit':jsonData['unit'],
      'notes': jsonData['notes'],
    };

    var url = Uri.parse('https://bakery.permavite.com/api/inventory');

    var response2 = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
      body: jsonEncode(params),
    );

    if (response2.statusCode == 200) {
      print('Stock updated successfully');
    } else {
      print('Failed to update stock: ${response2.statusCode}');
      return false;
    }
  } else {
    print('Failed to get ingredient stock: ${response.statusCode}');
    return false;
  }

  return true;
}

class DashedLine extends StatelessWidget {
  final double height;
  final Color color;

  const DashedLine({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: DashedLinePainter(color: color, height: height),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double height;

  DashedLinePainter({required this.color, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = height;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}