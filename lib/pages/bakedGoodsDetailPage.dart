import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bakedGoods.dart';  // Ensure BakedGoods model is imported
import '../services/session_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

int rating = 0;

Future<void> getRating(String bakedGoodsID) async {
  var url = Uri.https('bakery.permavite.com', '/api/recipes/id/$bakedGoodsID');

  var response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await SessionService().getSessionID()}',
    },
  );

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    rating = jsonData['rating'];
  } else {
    print('Failed to get rating: ${response.statusCode}');
  }
}

class BakedGoodsDetailsPage extends StatefulWidget {
  final BakedGoods bakedGoods;

  BakedGoodsDetailsPage({required this.bakedGoods});

  @override
  _BakedGoodsDetailsPageState createState() => _BakedGoodsDetailsPageState();
}

class _BakedGoodsDetailsPageState extends State<BakedGoodsDetailsPage> {
  final TextEditingController _decreaseStockController = TextEditingController();
  late BakedGoods updatedBakedGoods; // Create a new BakedGoods object for updated quantity

  @override
  void initState() {
    super.initState();
    updatedBakedGoods = widget.bakedGoods; // Initialize it with the current baked good
    getRating(updatedBakedGoods.recipeID); // Fetch the rating for the baked good
  }

  Future<void> decreaseStock(String bakedGoodsName, int amount) async {
    // Build the correct API endpoint based on the provided path
    var url = Uri.https('bakery.permavite.com', 'api/cookedgoods/$bakedGoodsName/consume/$amount');
    
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '${await SessionService().getSessionID()}',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        // Create a new BakedGoods object with the updated quantity
        updatedBakedGoods = BakedGoods(
          id: updatedBakedGoods.id,
          name: updatedBakedGoods.name,
          recipeID: updatedBakedGoods.recipeID,
          quantity: updatedBakedGoods.quantity - amount,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock updated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update stock')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 70, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Center(
                  child: Text(
                    updatedBakedGoods.name, // Use the updated object
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 204, 198, 159), // Cream color
                    ),
                  ),
                ),
                SizedBox(height: 10),
                RatingBarIndicator(
                  rating: (rating).toDouble(), // Display the recipe's current rating
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
                SizedBox(height: 10),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'In Stock: ', 
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 204, 198, 159), // Cream color
                          ),
                        ),
                        TextSpan(
                          text: '${updatedBakedGoods.quantity}', 
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 204, 198, 159), // Cream color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                DashedLine(height: 2, color: Color.fromARGB(255, 204, 198, 159)),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color.fromARGB(255, 204, 198, 159)),
                  ),
                  child: TextField(
                    controller: _decreaseStockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'How much have you sold?',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 37, 3, 3)), // Cream label color
                      border: InputBorder.none,  // No default border
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding inside the box
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity, // Set the width to fill the parent container
                  child: ElevatedButton(
                    onPressed: () {
                      int decreaseAmount = int.tryParse(_decreaseStockController.text) ?? 0;
                      if (decreaseAmount > 0 && decreaseAmount <= updatedBakedGoods.quantity) {
                        decreaseStock(updatedBakedGoods.name, decreaseAmount);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid amount')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                    ),
                    child: Text(
                      'Update Stock',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 37, 3, 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 204, 198, 159), size: 40),
                  onPressed: () {
                    Navigator.of(context).pop(true);  // Pass true when going back to indicate that stock was updated
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever, color: Color.fromARGB(255, 204, 198, 159), size: 40),
                  onPressed: () {
                    // Show dialogue to confirm deletion
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: RichText(
                            textAlign: TextAlign.center, // Center the title text
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Remove all\n',
                                  style: TextStyle(
                                    fontSize: 16, // Smaller font size for 'Remove all'
                                    color: Colors.black, // Use a color that matches your theme
                                  ),
                                ),
                                TextSpan(
                                  text: '${updatedBakedGoods.name}s?',
                                  style: TextStyle(
                                    fontSize: 20, // Larger font size for the name
                                    fontStyle: FontStyle.italic, // Italicized for the name
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: Text(
                            '(This action cannot be undone.)',
                            textAlign: TextAlign.center, // Center the content text
                          ),
                          actionsAlignment: MainAxisAlignment.center, // Center align the action buttons
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Call the delete API
                                int decreaseAmount = updatedBakedGoods.quantity;
                                if (decreaseAmount > 0 && decreaseAmount <= updatedBakedGoods.quantity) {
                                  decreaseStock(updatedBakedGoods.name, decreaseAmount);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid amount')));
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
