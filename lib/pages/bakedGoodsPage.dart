import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session_service.dart';
import '../models/bakedGoods.dart';

final SessionService sessionService = SessionService();
List<BakedGoods> bakedGoods = [];

Future<void> getBakedGoods() async {
  var url = Uri.https('bakery.permavite.com', 'api/cookedgoods');

  // Include the session ID in the headers
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${await sessionService.getSessionID()}',
    },
  );

  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);

    bakedGoods.clear(); // Clear the list to avoid duplicates

    for (var eachBakedGood in jsonData) {
      final good = BakedGoods(
        id: eachBakedGood['id'],
        name: eachBakedGood['name'],
        quantity: eachBakedGood['quantity'],
      );
      bakedGoods.add(good);
    }
    print('Number of Baked Goods loaded: ${bakedGoods.length}');
  } else {
    print('Failed to load baked goods: ${response.statusCode}');
  }
}

class BakedGoodsDetailPage extends StatefulWidget {
  @override
  _BakedGoodsPageState createState() => _BakedGoodsPageState();
}

class _BakedGoodsPageState extends State<BakedGoodsDetailPage> {
  TextEditingController searchController = TextEditingController();
  List<BakedGoods> filteredBakedGoods = [];
  bool isLoaded = false;
  bool isSearching = false; // New state to track the search progress

  @override
  void initState() {
    super.initState();
    fetchBakedGoods();
  }

  Future<void> fetchBakedGoods() async {
    await getBakedGoods();
    setState(() {
      filteredBakedGoods = bakedGoods; // Only set this after the data is loaded
      isLoaded = true;
    });
  }

  // Function to filter search results
  void filterSearch(String query) async {
    setState(() {
      isSearching = true; // Start search
    });

    await Future.delayed(Duration(milliseconds: 500)); // Simulate loading time

    List<BakedGoods> tempList = bakedGoods.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredBakedGoods = tempList;
      isSearching = false; // End search
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
      body: isLoaded
          ? Column(
              children: [
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
                        filterSearch(value); // Search when "Enter" is pressed
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
                isSearching
                    ? Center(child: CircularProgressIndicator()) // Show loading circle while searching
                    : Expanded(
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
                                  textColor: const Color.fromARGB(255, 32, 3, 3),
                                  subtitle: Text(
                                    'In stock: ${filteredBakedGoods[index].quantity}',
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
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
