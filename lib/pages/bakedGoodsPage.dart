// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import '../models/bakedGoods.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

final SessionService sessionService = SessionService();
List<BakedGoods> bakedGoodsItems = [];

Future<void> getBakedGoodsItems() async {
  var url = Uri.https('bakery.permavite.com', 'api/cookedgoods');
  print(await sessionService.getSessionID());

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}', // Use session ID for authorization
    },
  );

  var jsonData = jsonDecode(response.body);

  if (response.statusCode == 200) {
    bakedGoodsItems.clear(); // Clear the list to avoid duplicates

    for (var eachBakedGoods in jsonData) {
      final bakedGoods = BakedGoods(
        id: eachBakedGoods['id'],
        name: eachBakedGoods['name'],
        quantity: eachBakedGoods['quantity'],
      );
      bakedGoodsItems.add(bakedGoods);
    }
    print('Number of Baked Goods Items loaded: ${bakedGoodsItems.length}');
  } else {
    print('Failed to load Baked Goods Items: ${response.statusCode}');
  }
}

// Text editing controllers for user input
final TextEditingController _bakedGoodsNameController = TextEditingController();
final TextEditingController _quantityController = TextEditingController();

// Function to add a baked goods item to the database
Future<void> addBakedGoodsItem() async {
  var name = _bakedGoodsNameController.text;
  var quantity = _quantityController.text;

  print('Name: $name');
  print('Quantity: $quantity');

  print('Session ID: ${await sessionService.getSessionID()}');

  var url = Uri.parse('https://bakery.permavite.com/api/cookedgoods');
  
  // POST request to add the baked goods item to the database
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}', // Use session ID for authorization
    },
    body: jsonEncode({
      'name': name,
      'quantity': quantity,
    }),
  );

  if (response.statusCode == 201) {
    print('Baked Goods Item added successfully');
    getBakedGoodsItems(); // Reload the baked goods after adding a new one
  } else {
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Failed to add Baked Goods Item');
  }
}

// Function to show the add baked goods dialog with a fade and scale transition
void _showAddBakedGoodsDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Add Baked Goods Item",
    barrierColor: Color.fromARGB(255, 37, 3, 3).withOpacity(0.5), // Darkens the background
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return AlertDialog(
        title: Text('Add Baked Goods Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _bakedGoodsNameController,
                decoration: InputDecoration(labelText: 'Baked Goods Item Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
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
              addBakedGoodsItem(); // Add the Baked Goods Item
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

// Baked Goods Detail Page
class BakedGoodsDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Baked Goods',
          style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)),  // Set the text color to black
        ),
        backgroundColor: Color.fromARGB(255, 255, 253, 241),
      ),
      body: FutureBuilder(
        future: getBakedGoodsItems(),
        builder: (context, snapshot) {
          print('bakedGoodsItems: $bakedGoodsItems');
          if (snapshot.connectionState == ConnectionState.done) {
            if (bakedGoodsItems.isEmpty) {
              return Center(
                child: Text('No Baked Goods Items available'),
              );
            }
            return ListView.builder(
              itemCount: bakedGoodsItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        bakedGoodsItems[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      textColor: const Color.fromARGB(255, 37, 3, 3),
                      subtitle: Text(
                        'In Stock: ${bakedGoodsItems[index].quantity}',
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
        backgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
        foregroundColor: const Color.fromARGB(255, 37, 3, 3),
        overlayColor: Color.fromARGB(255, 37, 3, 3),
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.search, color: Color.fromARGB(255, 37, 3, 3)),
            label: 'Search Baked Goods',
            labelBackgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
            labelStyle: const TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
            onTap: () {
              // Add search functionality here
              print('Search button tapped');
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add, color: Color.fromARGB(255, 37, 3, 3)),
            label: 'Add Baked Goods Item',
            labelBackgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
            labelStyle: const TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
            onTap: () {
              _showAddBakedGoodsDialog(context); // Show the add baked goods dialog
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete, color: Color.fromARGB(255, 37, 3, 3)),
            label: 'Delete Baked Goods Item',
            labelBackgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
            labelStyle: const TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
            onTap: () {
              print('Delete button tapped');
            },
          ),
        ],
      ),
    );
  }
}
