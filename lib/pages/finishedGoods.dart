// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session_service.dart';

final SessionService sessionService = SessionService();
List<FinishedGood> finishedGoods = [];

// Define a FinishedGood class to represent each cooked item
class FinishedGood {
  final String id;
  final String recipeName;
  final int quantity;

  FinishedGood({required this.id, required this.recipeName, required this.quantity});

  factory FinishedGood.fromJson(Map<String, dynamic> json) {
    return FinishedGood(
      id: json['id'],
      recipeName: json['recipeName'],
      quantity: json['quantity'],
    );
  }
}

// Fetch finished goods from the API
Future<void> getFinishedGoods() async {
  var url = Uri.https('bakery.permavite.com', 'api/cookedgoods');

  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    finishedGoods.clear();
    for (var item in jsonData) {
      final good = FinishedGood.fromJson(item);
      finishedGoods.add(good);
    }
  } else {
    print('Failed to load finished goods: ${response.statusCode}');
  }
}

// Create FinishedGoodsPage to display cooked items
class FinishedGoodsPage extends StatefulWidget {
  @override
  _FinishedGoodsPageState createState() => _FinishedGoodsPageState();
}

class _FinishedGoodsPageState extends State<FinishedGoodsPage> {
  @override
  void initState() {
    super.initState();
    getFinishedGoods(); // Fetch finished goods on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finished Goods'),
        backgroundColor: Color.fromARGB(255, 249, 251, 250),
      ),
      body: FutureBuilder(
        future: getFinishedGoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (finishedGoods.isEmpty) {
              return Center(
                child: Text('No cooked goods available.'),
              );
            }
            return ListView.builder(
              itemCount: finishedGoods.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        finishedGoods[index].recipeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        'Quantity: ${finishedGoods[index].quantity}',
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
    );
  }
}
