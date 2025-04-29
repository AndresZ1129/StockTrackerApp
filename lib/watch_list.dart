import 'package:flutter/material.dart';

class WatchlistScreen extends StatelessWidget {
  final Map<String, List<String>> watchlistCategories;

  const WatchlistScreen({required this.watchlistCategories, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Your Watchlist', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: watchlistCategories.keys.map((category) {
            return CategoryCard(category: category, stocks: watchlistCategories[category]!);
          }).toList(),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;
  final List<String> stocks;

  const CategoryCard({required this.category, required this.stocks, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: stocks.map((stockSymbol) {
                return Chip(
                  label: Text(stockSymbol, style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blueGrey[700],
                  deleteIcon: Icon(Icons.close, color: Colors.white),
                  onDeleted: () {
                    // Handle stock removal logic (update state and Firebase)
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
