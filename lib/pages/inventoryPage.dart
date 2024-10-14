// Importing dart:convert to use jsonDecode function
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import '../models/inventory.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

final SessionService sessionService = SessionService();
List<Inventory> inventoryItems = [];

Future<void> getInventoryItems() async {
  var url = Uri.https('bakery.permavite.com', 'api/inventory');
  print(await sessionService.getSessionID());

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
    inventoryItems.clear(); // Clear the list to avoid duplicates

    for (var eachInventory in jsonData) {
      final inventory = Inventory(
        name: eachInventory['name'],
        quantity: eachInventory['quantity'],
        purchaseQuantity: eachInventory['purchaseQuantity'],
        costPerPurchaseUnit: eachInventory['costPerPurchaseUnit'],
        unit: eachInventory['unit'],
        notes: eachInventory['notes']
      );
      inventoryItems.add(inventory);
    }
    print('Number of Inventory Items loaded: ${inventoryItems.length}');
  } else {
    print('Failed to load Inventory Items: ${response.statusCode}');
  }
}

// Text editing controllers for user input
final TextEditingController _inventoryNameController = TextEditingController();
final TextEditingController _quantityController = TextEditingController();
final TextEditingController _purchaseQuantityController = TextEditingController();
final TextEditingController _costPerPurchaseUnitController = TextEditingController();
final TextEditingController _unitController = TextEditingController();
final TextEditingController _notesController = TextEditingController();

// Function to add an inventory item to the database
Future<void> addInventoryItem() async {
  var name = _inventoryNameController.text;
  var quantity = int.tryParse(_quantityController.text) ?? 0;
  var purchaseQuantity = int.tryParse(_purchaseQuantityController.text) ?? 0;
  var costPerPurchaseUnit = int.tryParse(_costPerPurchaseUnitController.text) ?? 0;
  var unit = _unitController.text;
  var notes = _notesController.text;

  print('Name: $name');
  print('Quantity: $quantity');
  print('Purchase Quantity: $purchaseQuantity');
  print('Cost Per Purchase Unit: $costPerPurchaseUnit');
  print('Unit: $unit');
  print('Notes: $notes');

  print ('Session ID: ${await sessionService.getSessionID()}');

   var url = Uri.parse('https://bakery.permavite.com/api/inventory');
  // POST request to add the inventory item to the database
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}', // USE WHEN SESSIONID FOR AUTH IS FIXED
      //'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
    body: jsonEncode({
      'name': name,
      'quantity': quantity,
      'purchaseQuantity': purchaseQuantity,
      'costPerPurchaseUnit': costPerPurchaseUnit,
      'unit': unit,
      'notes': notes,
    }),
  );

  if (response.statusCode == 201) {
    print('Inventory Item added successfully');
    getInventoryItems(); // Reload the inventory after adding a new one
  } else {
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Failed to add Inventory Item');
  }
}

// Function to show the add inventory dialog with a fade and scale transition
void _showAddInventoryDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Add Inventory Item",
    barrierColor: Color.fromARGB(255, 37, 3, 3).withOpacity(0.5), // Darkens the background
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return AlertDialog(
        // backgroundColor:  Color.fromARGB(255, 162, 185, 188).withOpacity(1.0), COLOR FOR POPUP BG?
        title: Text('Add Inventory Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _inventoryNameController,
                decoration: InputDecoration(labelText: 'Inventory Item Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: _purchaseQuantityController,
                decoration: InputDecoration(labelText: 'Purchase Quantity'),
              ),
              TextField(
                controller: _costPerPurchaseUnitController,
                decoration: InputDecoration(labelText: 'Cost Per Purchase Unit)'),
              ),
              TextField(
                controller: _unitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: _notesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Notes'),
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
              addInventoryItem(); // Add the Inventory Item

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

// Inventory Detail Page
class InventoryDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory',
        style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)),  // Set the text color to black
      ),
      backgroundColor: Color.fromARGB(255, 255,253,241),
    ),
      body: FutureBuilder(
        future: getInventoryItems(),
        builder: (context, snapshot) {
          print('inventoryItems: $inventoryItems');
          if (snapshot.connectionState == ConnectionState.done) {
            if (inventoryItems.isEmpty) {
              return Center(
                child: Text('No Inventory Items available'),
              );
            }
            return ListView.builder(
              itemCount: inventoryItems.length,
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
                        inventoryItems[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      textColor: const Color.fromARGB(255, 37,3,3),
                      subtitle: Text(
                        inventoryItems[index].quantity.toString() ?? 'No quantity available',
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
        backgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
        foregroundColor: const Color.fromARGB(255, 37, 3, 3),
        overlayColor: Color.fromARGB(255, 37, 3, 3),
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.search, color:Color.fromARGB(255, 37, 3, 3)),
            label: 'Search Inventory Items',
            labelBackgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            labelStyle: const TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
            onTap: () {
              // Add search functionality here
              print('Search button tapped');
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add, color:Color.fromARGB(255, 37, 3, 3)),
            label: 'Add Inventory Item',
            labelBackgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            labelStyle: const TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
            onTap: () {
              _showAddInventoryDialog(context); // Show the add inventory dialog
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete, color:Color.fromARGB(255, 37, 3, 3)),
            label: 'Delete Inventory Item',
            labelBackgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 255,253,241).withOpacity(0.8),
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