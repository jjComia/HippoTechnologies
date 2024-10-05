import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/pages/ingredientsPage.dart';
import 'package:namer_app/pages/recipePage.dart';
import '../services/session_service.dart';
import 'dart:convert';
import '../models/ingredients.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class IngredientDetailsPage extends StatelessWidget {
  final Ingredient ingredient;

  IngredientDetailsPage({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Row(
              children: [
                Expanded(
                  flex: 2, // Increase flex for the label
                  child: Text(
                    'Name:',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1, // Reduce flex for the value to give more space to the label
                  child: Text(
                    ingredient.name,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.right,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2, // Increase flex for the label
                  child: Text(
                    'In Stock:',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1, // Reduce flex for the value to give more space to the label
                  child: Text(
                    '${ingredient.quantity}',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.right,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2, // Increase flex for the label
                  child: Text(
                    'Purchase Quantity:',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1, // Reduce flex for the value to give more space to the label
                  child: Text(
                    '${ingredient.purchaseQuantity}',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.right,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2, // Increase flex for the label
                  child: Text(
                    'Cost Per Purchase Unit:',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1, // Reduce flex for the value
                  child: Text(
                    '${ingredient.costPerPurchaseUnit} \$',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.right,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Add functionality to order more of the ingredient
              },
              child: Text('Order More', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(color: Color.fromARGB(175, 0, 0, 0), fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    // Add delete functionality
                    // Delete the ingredient from the database using AwesomeDialogue
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.scale,
                      title: 'Delete Ingredient',
                      desc: 'Are you sure you want to remove this ingredient?',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        // Add delete recipe functionality here
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
                            print('Recipe deleted successfully');
                            Navigator.of(context).pop(true);
                          } else {
                            print('Failed to delete recipe: ${response.statusCode}');
                          }
                        });
                      },
                    ).show();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
