import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart'; // StockService for fetching stock data
import 'stockdetail.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  Map<String, List<String>> _categories = {}; // Store categories and their stocks
  List<String> _watchlist = []; // List to store stock symbols fetched from Firestore
  bool _categoriesLoaded = false; // Flag to check if categories are already loaded

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
    if (!_categoriesLoaded) {
      _loadCategories();
    }
  }

  // Load watchlist from Firestore
  _loadWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _watchlist = List<String>.from(doc['watchlist'] ?? []);  // Fetch watchlist
        });
      }
    }
  }

  // Load categories from Firestore if not already loaded
  _loadCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !_categoriesLoaded) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _categories = Map<String, List<String>>.from(doc['categories'] ?? {});
          _categoriesLoaded = true; // Set the flag to true after loading
        });
      }
    }
  }

  // Save categories to Firestore
  _saveCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'categories': _categories,
      }, SetOptions(merge: true));  // Save categories to Firestore
    }
  }

  // Add stock to a category
  _addToCategory(String symbol, String category) {
    setState(() {
      if (_categories[category] == null) {
        _categories[category] = [];
      }
      if (!_categories[category]!.contains(symbol)) {
        _categories[category]!.add(symbol);
      }
    });
    _saveCategories();  // Save categories to Firestore immediately
  }

  // Remove stock from a category
  _removeFromCategory(String symbol, String category) {
    setState(() {
      _categories[category]?.remove(symbol);
      if (_categories[category]?.isEmpty ?? true) {
        _categories.remove(category);
      }
    });
    _saveCategories();  // Save categories to Firestore immediately
  }

  // Show dialog to add category
  _showAddCategoryDialog() {
    TextEditingController _categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newCategory = _categoryController.text.trim();
                if (newCategory.isNotEmpty && !_categories.containsKey(newCategory)) {
                  setState(() {
                    _categories[newCategory] = [];
                  });
                  _saveCategories();  // Save new category to Firestore immediately
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to assign a stock to a category
  void _showAssignCategoryDialog(String symbol) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $symbol to Category'),
          content: _categories.isEmpty
              ? Text('No categories available. Please add one first.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _categories.keys.map((category) {
                    return ListTile(
                      title: Text(category),
                      onTap: () {
                        _addToCategory(symbol, category);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Unassigned stocks
    List<String> unassigned = _watchlist
        .where((symbol) =>
            !_categories.values.any((stocks) => stocks.contains(symbol)))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Watchlist', style: TextStyle(color: Colors.greenAccent),),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.add,
            color: Color(0xFF39FF14),),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Show unassigned stocks
          if (unassigned.isNotEmpty)
            Card(
              margin: EdgeInsets.all(12),
              color: Colors.blueGrey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                title: Text(
                  'Unassigned Stocks',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                children: unassigned.map((symbol) {
                  return ListTile(
                    onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(symbol:symbol),
      ),
    );
  },
                    title: Text(symbol, style: TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showAssignCategoryDialog(symbol),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Show categorized stocks
          ..._categories.keys.map((category) {
            List<String> categoryStocks = _categories[category]!;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: Colors.blueGrey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(
                    category,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  children: categoryStocks.map((symbol) {
                    return FutureBuilder<StockData>(  // Fetch stock data using your API service
                      future: StockService().getStockData(symbol),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: LinearProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error loading $symbol',
                              style: TextStyle(color: Colors.red));
                        } else if (snapshot.hasData) {
                          final stockData = snapshot.data!;
                          return ListTile(
                             onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(symbol: stockData.symbol),
      ),
    );
  },
                            title: Text(
                              '${stockData.symbol}: \$${stockData.currentPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${stockData.percentChange.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: stockData.percentChange >= 0
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: Colors.white),
                              onPressed: () {
                                _removeFromCategory(symbol, category);
                              },
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
