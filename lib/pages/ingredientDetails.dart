import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';
import 'dart:convert';
import '../models/ingredients.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../functions/showSlidingGeneralDialog.dart';

final SessionService sessionService = SessionService();

Future<void> addStock(ingredient, purchaseQuantity) async {
  print('Adding stock for ${ingredient.name}');
  var url = Uri.parse('https://bakery.permavite.com/api/inventory');

  print(ingredient.name);

  var params = {
    'id': ingredient.id,
    'name': ingredient.name,
    'quantity': ingredient.quantity + purchaseQuantity,
    'purchaseQuantity': ingredient.purchaseQuantity,
    'costPerPurchaseUnit': ingredient.costPerPurchaseUnit,
    'unit': ingredient.unit,
    'notes': ingredient.notes,
  };

  print(params);

  print(await sessionService.getSessionID());

  try {
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await sessionService.getSessionID()}',
      },
      body: jsonEncode(params),
    );

    if (response.statusCode == 200) {
      print('Stock added successfully');
    } else {
      print('Failed to add stock: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to add stock: $e');
  }
}

Future<Ingredient> getUpdatedIngredient(ingredientID) {
  print('Getting updated ingredient');
  var url = Uri.parse('https://bakery.permavite.com/api/inventory/id/$ingredientID');

  return http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
  ).then((response) {
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);

      return Ingredient(
        id: data['id'],
        name: data['name'],
        quantity: (data['quantity'] is int) ? (data['quantity'] as int).toDouble() : data['quantity'],
        purchaseQuantity: data['purchaseQuantity'],
        costPerPurchaseUnit: (data['costPerPurchaseUnit'] is int) ? (data['costPerPurchaseUnit'] as int).toDouble() : data['costPerPurchaseUnit'],
        unit: data['unit'],
        notes: data['notes'],
      );
    } else {
      print('Failed to get updated ingredient: ${response.statusCode}');
      return Ingredient(
        id: '',
        name: '',
        quantity: 0,
        purchaseQuantity: 0,
        costPerPurchaseUnit: 0,
        unit: '',
        notes: '',
      );
    }
  });
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

Future<void> editIngredient(ingredient, editQuantity, editUnit, editPurchaseQuantity, editCostPerPurchaseUnit, editNotes) {
  print('Editing ingredient');
  var url = Uri.parse('https://bakery.permavite.com/api/inventory');

  var params = {
    'id': ingredient.id,
    'name': ingredient.name,
    'quantity': int.parse(editQuantity),
    'purchaseQuantity': int.parse(editPurchaseQuantity),
    'costPerPurchaseUnit': double.parse(editCostPerPurchaseUnit),
    'unit': editUnit,
    'notes': editNotes,
  };

  return http.put(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
    },
    body: jsonEncode(params),
  ).then((response) {
    if (response.statusCode == 200) {
      print('Ingredient edited successfully');
    } else {
      print('Failed to edit ingredient: ${response.statusCode}');
    }
  });
}

// Function that returns a string
String getPrice(Ingredient ingredient) {
  // Define a regular expression to match a number with one decimal place
  RegExp regex = RegExp(r'^\d+\.\d$');
  
  // Check if the value matches the pattern
  if (regex.hasMatch(ingredient.costPerPurchaseUnit.toString())) {
    // Add a '0' after the single decimal digit
    return '${ingredient.costPerPurchaseUnit}0';
  }
  
  // Return the original value if it doesn't match the pattern
  return ingredient.costPerPurchaseUnit.toString();
}

class IngredientDetailsPage extends StatefulWidget {
  final Ingredient ingredient;

  IngredientDetailsPage({required this.ingredient});

  @override
  _IngredientDetailsPageState createState() => _IngredientDetailsPageState();
}

class _IngredientDetailsPageState extends State<IngredientDetailsPage> {
  late Ingredient ingredient;

  @override
  void initState() {
    super.initState();
    ingredient = widget.ingredient;
  }

  void refreshPage() async {
    Ingredient updatedIngredient = await getUpdatedIngredient(ingredient.id);
    setState(() {
      ingredient = updatedIngredient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    text: 'Ingredient Details:\n',
                    style: TextStyle(
                      color: Color.fromARGB(180, 204,198,159),
                      fontSize: 30,
                    ),
                  ),
                  TextSpan(
                    text: ingredient.name,
                    style: TextStyle(
                      color: Color.fromARGB(255,204,198,159),
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Color.fromARGB(255, 204,198,159),
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
                          'Name:',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159), fontWeight: FontWeight.w700),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          ingredient.name,
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB( 255, 204,198,159)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'In Stock:',
                          style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 204,198,159), fontWeight: FontWeight.w700),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${ingredient.quantity} ${ingredient.unit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB( 255, 204,198,159)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Purchase Quantity:',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB( 255, 204,198,159), fontWeight: FontWeight.w700),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${ingredient.purchaseQuantity} ${ingredient.unit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB( 255, 204,198,159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB( 255, 204,198,159)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cost Per Purchase:',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB( 255, 204,198,159), fontWeight: FontWeight.w700),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '\$${getPrice(ingredient)} / ${ingredient.purchaseQuantity} ${ingredient.unit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB( 255, 204,198,159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB( 255, 204,198,159)),
                  SizedBox(height: 20),
                 Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text from the top
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Notes:',
                        style: TextStyle(
                          fontSize: 20, 
                          color: Color.fromARGB(255, 204,198,159), 
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8), // Add some space between "Notes:" and the bullet
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ', // Bullet point symbol
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 204,198,159),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  ingredient.notes.trim(), // Show the full notes as one string
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 204,198,159),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )


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
                      showEditDialogue(context, ingredient, refreshPage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                    ),
                    child: Text('Edit Ingredient Details', style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 37, 3, 3))),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      showOrderMoreDialogue(context, ingredient, refreshPage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                    ),
                    child: Text('Order More', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 37, 3, 3))),
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
                        size: 40,
                        color: Color.fromARGB(255,204,198,159)),
                    ),
                    TextButton(
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.scale,
                          title: 'Delete Ingredient',
                          desc: 'Are you sure you want to remove this ingredient?',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            final url = Uri.https('bakery.permavite.com', 'api/inventory/id/${ingredient.id}');
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
                                print('Failed to delete ingredient: ${response.statusCode}');
                              }
                            });
                          },
                        ).show();
                      },
                      child: Icon(
                        Icons.delete_forever,
                        size: 40,
                        color: Color.fromARGB(255,204,198,159)),
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

void showOrderMoreDialogue (context, ingredient, VoidCallback onOrderMore) {
  int currentPurchaseQuantity = ingredient.purchaseQuantity; // Current quantity for the order
  int ingredientPurchaseQuantity = ingredient.purchaseQuantity; // The Purchase Quantity of the ingredient
  double currentCost = ingredient.costPerPurchaseUnit; // Current cost for the  order
  double ingredientCost = ingredient.costPerPurchaseUnit; // The cost per purchase unit of the ingredient
  
  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Order More",
    pageBuilder: (context) {
      return AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.97),
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Centers the content
            children: <Widget>[
              Text(
                'Order More', // First text
                style: TextStyle(
                  color: Color.fromARGB(255, 37, 3, 3), // Style for "Order More"
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${ingredient.name}?', // Second text
                style: TextStyle(
                  color: Color.fromARGB(200, 154, 51, 52), // Style for ingredient name
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
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (currentPurchaseQuantity > ingredientPurchaseQuantity) {
                            setState(() {
                              currentPurchaseQuantity = currentPurchaseQuantity - ingredientPurchaseQuantity; // Decrease quantity
                              currentCost = currentCost - ingredientCost; // Update cost
                            });
                          }
                        },
                        child: Text('-'),
                      ),
                      Text(
                        '$currentPurchaseQuantity ${ingredient.unit}', // Display updated quantity and unit
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                          ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPurchaseQuantity = currentPurchaseQuantity + ingredientPurchaseQuantity; // Increase quantity
                            currentCost = currentCost + ingredientCost; // Update cost
                          });
                        },
                        child: Text('+'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Total Cost:', // Display cost
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.values[3]
                        ),
                      ),
                      Text(
                        '\$${currentCost.toStringAsFixed(2)}', // Display updated cost
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
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
                child: Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)) ),
              ),
              TextButton(
                onPressed: () async{
                  // You can pass the updated `purchaseQuantity` here to update the order logic
                  print('Ordering $currentPurchaseQuantity ${ingredient.unit}');
                  print(currentPurchaseQuantity);
                  await addStock(ingredient, currentPurchaseQuantity);
                  onOrderMore(); // Trigger page refresh
                  if(context.mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
                child: Text('Confirm Order', style: TextStyle(color: Color.fromARGB(200, 154, 51, 52))),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void showEditDialogue(context, ingredient, VoidCallback onEdit) {
  final TextEditingController editQuantityController = TextEditingController(text: ingredient.quantity.toString());
  final TextEditingController editUnitController = TextEditingController(text: ingredient.unit);
  final TextEditingController editPurchaseQuantityController = TextEditingController(text: ingredient.purchaseQuantity.toString());
  final TextEditingController editCostPerPurchaseUnitController = TextEditingController(text: ingredient.costPerPurchaseUnit.toString());
  final TextEditingController editNotesController = TextEditingController(text: ingredient.notes);

  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Order More",
    pageBuilder: (context) {
      return AlertDialog(
        
        backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.98),
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Centers the content
            children: <Widget>[
              Text(
                'Edit Details For', // First text
                style: TextStyle(
                  color: Color.fromARGB(255, 37, 3, 3), // Style for "Order More"
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${ingredient.name}?', // Second text
                style: TextStyle(
                  color: Color.fromARGB(200, 154, 51, 52), // Style for ingredient name
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
                    controller: editQuantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: editUnitController,
                    decoration: InputDecoration(labelText: 'Unit (e.g. kg, g, L, mL, etc.)'),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  TextField(
                    controller: editPurchaseQuantityController,
                    decoration: InputDecoration(labelText: 'Purchase Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: editCostPerPurchaseUnitController,
                    decoration: InputDecoration(labelText: 'Cost Per Purchase Unit'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: editNotesController,
                    decoration: InputDecoration(labelText: 'Notes'),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
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
                  if (editQuantityController.text.isEmpty || editUnitController.text.isEmpty || editPurchaseQuantityController.text.isEmpty || editCostPerPurchaseUnitController.text.isEmpty) {
                    print('Please fill in all fields');
                    displayEditError(context);
                    return;
                  }

                  print('Editing ingredient details');
                  await editIngredient(ingredient, editQuantityController.text, editUnitController.text, editPurchaseQuantityController.text, editCostPerPurchaseUnitController.text, editNotesController.text);
                  onEdit(); // Trigger page refresh
                  if(context.mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
                child: Text('Finish Edit', style: TextStyle(color: Color.fromARGB(200, 154, 51, 52))),
              ),
            ],
          ),
        ],
      );
    },
  );
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