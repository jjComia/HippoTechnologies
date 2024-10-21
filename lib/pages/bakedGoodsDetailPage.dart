import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bakedGoods.dart';  // Ensure BakedGoods model is imported
import '../services/session_service.dart';

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
      appBar: AppBar(
        title: Text(
          'Baked Goods Details',
          style: TextStyle(color: Color.fromARGB(255, 204, 198, 159)), // Cream title
        ),
        backgroundColor: Color.fromARGB(255, 255, 253, 241),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                SizedBox(height: 20),
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
                      labelText: 'Enter amount to decrease stock by:',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 37, 3, 3)), // Cream label color
                      border: InputBorder.none,  // No default border
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding inside the box
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
                  icon: Icon(Icons.delete_forever, color: Colors.red, size: 40),
                  onPressed: () {
                    int decreaseAmount = int.tryParse(_decreaseStockController.text) ?? 0;
                    if (decreaseAmount > 0 && decreaseAmount <= updatedBakedGoods.quantity) {
                      decreaseStock(updatedBakedGoods.name, decreaseAmount);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid amount')));
                    }
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
