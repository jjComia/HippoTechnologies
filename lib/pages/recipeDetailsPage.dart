import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/models/recipeIngredient.dart';
import '../services/session_service.dart';
import 'dart:convert';
import '../models/recipe.dart';
import '../models/cookStep.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../functions/showSlidingGeneralDialog.dart';

final SessionService sessionService = SessionService();

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;
  final List<RecipeIngredient> recipeIngredients;
  final List<CookStep> steps;

  RecipeDetailsPage({required this.recipe, required this.recipeIngredients, required this.steps});

  @override
  _RecipedetailspageState createState() => _RecipedetailspageState();
}

class _RecipedetailspageState extends State<RecipeDetailsPage> {
  late Recipe recipe;
  late List<RecipeIngredient> recipeIngredients;
  late List<CookStep> steps;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    recipeIngredients = widget.recipeIngredients;
    steps = widget.steps;
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
                      color: Color.fromARGB(255, 204,198,159),
                      fontSize: 30,
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
                          'Prep Time:\n${recipe.prepTime} ${recipe.prepUnit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'CookTime:\n${recipe.cookTime} ${recipe.cookUnit}',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DashedLine(height: 2, color: Color.fromARGB( 255, 204,198,159)),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8), // Add some space between the title and description
                      Text(
                        recipe.description,
                        style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 204,198,159)),
                        textAlign: TextAlign.center,  // Align to the left (optional)
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
                          'Rating',
                          style: TextStyle(fontSize: 20, color: Color.fromARGB( 255, 204,198,159)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          recipe.rating.toString(),
                          style: TextStyle(fontSize: 20, color: Color.fromARGB( 255, 204,198,159)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Buttons at the bottom
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
                  color: Color.fromARGB(255,204,198,159)),
              ),
              TextButton(
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.scale,
                    title: 'Delete Ingredient',
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
                  color: Color.fromARGB(255,204,198,159)),
              ),
            ],
          ),
        ],
      ),
    );
  }
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