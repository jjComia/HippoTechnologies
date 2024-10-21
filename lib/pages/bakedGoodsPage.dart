import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/bakedGoods.dart';
import '../services/session_service.dart';
import '../pages/bakedGoodsDetailPage.dart'; // Import the BakedGoodsDetailsPage

final SessionService sessionService = SessionService();
List<BakedGoods> bakedGoodsItems = [];
List<BakedGoods> filteredBakedGoods = [];

Future<void> getBakedGoods() async {
  var url = Uri.https('bakery.permavite.com', 'api/cookedgoods');
  print(await sessionService.getSessionID());

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  var jsonData = jsonDecode(response.body);
  print(jsonData);

  if (response.statusCode == 200) {
    bakedGoodsItems.clear(); // Clear the list to avoid duplicates

    for (var eachBakedGoods in jsonData) {
      final bakedGoods = BakedGoods(
        id: eachBakedGoods['id'],
        name: eachBakedGoods['name'],
        recipeID: eachBakedGoods['recipeId'],
        quantity: eachBakedGoods['quantity'],
      );
      bakedGoodsItems.add(bakedGoods);
    }

    bakedGoodsItems.sort((a, b) => a.name.compareTo(b.name));

    filteredBakedGoods = List.from(bakedGoodsItems); // Initialize filtered list
    print('Number of Baked Goods loaded: ${bakedGoodsItems.length}');
  } else {
    print('Failed to load Baked Goods: ${response.statusCode}');
  }
}

// Text editing controller for search input
final TextEditingController searchController = TextEditingController();

class BakedGoodsDetailPage extends StatefulWidget {
  @override
  _BakedGoodsPageState createState() => _BakedGoodsPageState();
}

class _BakedGoodsPageState extends State<BakedGoodsDetailPage> {
  @override
  void initState() {
    super.initState();
    getBakedGoods(); // Fetch baked goods data when the page initializes
  }

  void filterSearch(String query) {
    List<BakedGoods> tempList = bakedGoodsItems.where((bakedGood) {
      return bakedGood.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredBakedGoods = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Baked Goods',
          style: TextStyle(color: Color.fromARGB(255, 37, 3, 3)),
        ),
        backgroundColor: Color.fromARGB(255, 255, 253, 241),
      ),
      body: FutureBuilder(
        future: getBakedGoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (bakedGoodsItems.isEmpty) {
              return Center(
                child: Text('No Baked Goods available'),
              );
            }
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 253, 241).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (value) {
                        filterSearch(value); // Trigger search when the enter key is pressed
                      },
                      decoration: InputDecoration(
                        labelText: 'Search Baked Goods',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredBakedGoods.length,
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
                              filteredBakedGoods[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            textColor: const Color.fromARGB(255, 37, 3, 3),
                            subtitle: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'In stock: ', 
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: '${filteredBakedGoods[index].quantity}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                            onTap: () async {
                              bool? shouldRefresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BakedGoodsDetailsPage(bakedGoods: bakedGoodsItems[index]),
                                ),
                              );

                              if (shouldRefresh == true) {
                                // Refresh the BakedGoods list by calling the API again
                                await getBakedGoods();
                                setState(() {});
                              }
                            },

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
    );
  }
}
