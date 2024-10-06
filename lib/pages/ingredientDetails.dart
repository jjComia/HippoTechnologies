import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/pages/ingredientsPage.dart';
import 'package:namer_app/pages/recipePage.dart';
import '../services/session_service.dart';
import 'dart:convert';
import '../models/ingredients.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../functions/showSlidingGeneralDialog.dart';

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

class IngredientDetailsPage extends StatelessWidget {
  final Ingredient ingredient;

  IngredientDetailsPage({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Ingredient Details for\n',
                    style: TextStyle(
                      color: Color.fromARGB(125, 0, 0, 0),
                      fontSize: 22,
                    ),
                  ),
                  TextSpan(
                    text: ingredient.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 32),
            // Your ingredient details go here
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name:',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          ingredient.name,
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 1, color: Colors.grey),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'In Stock:',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${ingredient.quantity} ${ingredient.unit}',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 1, color: Colors.grey),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Purchase Quantity:',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${ingredient.purchaseQuantity} ${ingredient.unit}',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 1, color: Colors.grey),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cost Per Purchase:',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '\$${getPrice(ingredient)} / ${ingredient.purchaseQuantity} ${ingredient.unit}',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  showOrderMoreDialogue(context, ingredient);
                },
                child: Text('Order More', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Color.fromARGB(175, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add delete functionality using AwesomeDialog
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.scale,
                      title: 'Delete Ingredient',
                      desc: 'Are you sure you want to remove this ingredient?',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        print('Deleting Ingredient: ${ingredient.id}');
                        final url = Uri.https('bakery.permavite.com', 'api/inventory/id/${ingredient.id}');
                        http.delete(
                          url,
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization': '24201287-A54D-4D16-9CC3-5920A823FF12',
                          },
                        ).then((response) {
                          if (response.statusCode == 200) {
                            print('Ingredient deleted successfully');
                            Navigator.of(context).pop(true);
                          } else {
                            print('Failed to delete ingredient: ${response.statusCode}');
                          }
                        });
                      },
                    ).show();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ],
            ),
            SizedBox(height: 24), // Adds a small padding at the bottom
          ],
        ),
      ),
    );
  }
}

void showOrderMoreDialogue (context, ingredient) {
  showSlidingGeneralDialog(
    context: context,
    barrierLabel: "Order More",
    pageBuilder: (context) {
      return AlertDialog(
        title: Center(child: Text('Order More')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Order more ${ingredient.name}?'),
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
                  //Add order more functionality here
                  Navigator.of(context).pop(); // Close the dialog
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