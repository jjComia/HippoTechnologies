// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import '../models/recipe.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

final SessionService sessionService = SessionService();
List<Recipe> recipes = [];

Future<void> getRecipes() async {
  var url = Uri.https('bakery.permavite.com', 'recipes');
  
  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': '${sessionService.getSessionID()}', // USE WHEN SESSIONID FOR AUTH IS FIXED
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
              // If the recipes list is empty, display a message
              return Center(
                child: Text('No recipes available'),
              );
            }
            // Display the list of recipes
            return ListView.builder(
              itemCount: recipes.length, // Set itemCount to the length of the recipes list
              itemBuilder: (context, index) {
                return 
                Padding(
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
                          fontWeight: FontWeight.bold, // Makes the text bold
                          fontSize: 20, // Sets the font size
                        ),
                      ),
                      textColor: const Color.fromARGB(255, 69, 145, 105),
                      subtitle: Text(
                        recipes[index].description ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 20, // Sets the font size
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            // Display an error message if the snapshot has an error
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Display a loading indicator while the data is loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      // Add the floating action button with speed dial
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color.fromARGB(255, 162, 185, 188).withOpacity(0.8),       //const Color.fromARGB(255, 69, 145, 105) Darker Green color
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          // Search Button
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
          // Add Recipe Button
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Add Recipe',
            labelBackgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            onTap: () {
              // Add functionality to add a recipe
              print('Add button tapped');
            },
          ),
          // Delete Recipe Button
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: 'Delete Recipe',
            labelBackgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            onTap: () {
              // Add functionality to delete a recipe
              print('Delete button tapped');
            },
          ),
        ],
      ),
    );
  }
}

