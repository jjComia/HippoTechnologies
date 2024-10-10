// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session_service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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

    // Clear and repopulate finished goods list
    finishedGoods.clear();
    for (var item in jsonData) {
      final good = FinishedGood.fromJson(item);
      finishedGoods.add(good);
    }
    print('Number of Finished Goods loaded: ${finishedGoods.length}');
  } else {
    print('Failed to load finished goods: ${response.statusCode}');
  }
}

// Finished Goods Page
class FinishedGoodsPage extends StatefulWidget {
  @override
  _FinishedGoodsPageState createState() => _FinishedGoodsPageState();
}

class _FinishedGoodsPageState extends State<FinishedGoodsPage> {
  TextEditingController searchController = TextEditingController();
  List<FinishedGood> filteredFinishedGoods = [];

  @override
  void initState() {
    super.initState();
    filteredFinishedGoods = finishedGoods; // Initialize filteredFinishedGoods
  }

  void filterSearch(String query) {
    List<FinishedGood> tempList = finishedGoods.where((finishedGood) {
      return finishedGood.recipeName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFinishedGoods = tempList;
    });
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) {
                      filterSearch(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Finished Goods',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFinishedGoods.length,
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
                              filteredFinishedGoods[index].recipeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                              'Quantity: ${filteredFinishedGoods[index].quantity}',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
        backgroundColor: const Color.fromARGB(255, 162, 185, 188).withOpacity(0.8),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.refresh),
            label: 'Refresh Finished Goods',
            labelBackgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            backgroundColor: const Color.fromARGB(255, 198, 255, 196).withOpacity(0.8),
            onTap: () {
              setState(() {
                getFinishedGoods(); // Refresh finished goods list
              });
            },
          ),
        ],
      ),
    );
  }
}
