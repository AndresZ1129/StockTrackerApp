import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Newfeed.dart';
import 'login_screen.dart';
import 'api_service.dart'; // Import the StockService
import 'stockdetail.dart';
import 'watch_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StockService _stockService;
  Future<StockData>? _stockData;
  late TextEditingController _searchController;
  List<String> _watchlist = [];

   int _selectedIndex = 0;

   // Create a single instance of WatchlistScreen
  late WatchlistScreen _watchlistScreen;

  
  @override
  void initState() {
    super.initState();
    _stockService = StockService();
    _searchController = TextEditingController();
    _loadWatchlist();
    _watchlistScreen = WatchlistScreen(); // Initialize once
  }

  // Method to handle the bottom navigation bar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define your screens
  final List<Widget> _screens = [
    HomeScreen(),
    NewsFeedPage(),
  ];

  // Load watchlist from Firestore
  _loadWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _watchlist = List<String>.from(doc['watchlist'] ?? []);
        });
      }
    }
  }

  // Add stock to watchlist and update Firestore
  _addToWatchlist(String symbol) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !_watchlist.contains(symbol)) {
      setState(() {
        _watchlist.add(symbol);
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'watchlist': _watchlist,
      }, SetOptions(merge: true));
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _searchStock() {
    setState(() {
      _stockData = _stockService.getStockData(_searchController.text.toUpperCase());
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text('Stock Tracker', style: TextStyle(color: Color(0xFF39FF14))),
      actions: [
        IconButton(
          icon: Icon(Icons.logout_outlined, color: Color(0xFF39FF14)),
          onPressed: () => _logout(context),
        ),
      ],
    ),
    body: _selectedIndex == 0
        ? SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Value', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('\$12,500', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('+3.5% Today', style: TextStyle(color: Colors.greenAccent)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search Stock Symbol',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.blueGrey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _searchStock(),
                ),
                SizedBox(height: 20),
                _stockData == null
                    ? Text('Search for a stock to begin.', style: TextStyle(color: Colors.white))
                    : FutureBuilder<StockData>(
                        future: _stockData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
                          } else if (snapshot.hasData) {
                            final stockData = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Stock: ${stockData.symbol}', style: TextStyle(color: Colors.white, fontSize: 20)),
                                SizedBox(height: 10),
                                Text('Price: \$${stockData.currentPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                                SizedBox(height: 10),
                                Text(
                                  'Change: ${stockData.percentChange.toStringAsFixed(2)}%',
                                  style: TextStyle(color: stockData.percentChange > 0 ? Colors.greenAccent : Colors.redAccent),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _addToWatchlist(stockData.symbol);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${stockData.symbol} added to watchlist')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                  child: Text('Add to Watchlist'),
                                ),
                              ],
                            );
                          } else {
                            return Text('No stock data available', style: TextStyle(color: Colors.white));
                          }
                        },
                      ),
                SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 1),
                            FlSpot(1, 1.5),
                            FlSpot(2, 1.4),
                            FlSpot(3, 3.4),
                            FlSpot(4, 2),
                            FlSpot(5, 2.2),
                            FlSpot(6, 1.8),
                          ],
                          isCurved: true,
                          color: Colors.greenAccent,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Your Watchlist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Column(
                  children: _watchlist.map((symbol) {
                    return FutureBuilder<StockData>(
                      future: _stockService.getStockData(symbol),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: LinearProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error loading $symbol', style: TextStyle(color: Colors.red));
                        } else if (snapshot.hasData) {
                          final stock = snapshot.data!;
                          return MarketCard(
                            symbol: stock.symbol,
                            price: stock.currentPrice,
                            change: stock.percentChange,
                            onDelete: () {
                              setState(() {
                                _watchlist.remove(symbol);
                                _updateWatchlistFirestore();
                              });
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => StockDetailPage(symbol: stock.symbol)),
                              );
                            },
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],
            ),
          )
        : IndexedStack(
        index: _selectedIndex, // The screen that corresponds to the selected index
        children: [ 
          ..._screens,
          _watchlistScreen, // Add WatchlistScreen as a fixed screen
        ], // List of screens
      ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'News'),
        BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Watchlist'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );
}
  // Update Firestore after watchlist modification
  _updateWatchlistFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'watchlist': _watchlist,
      }, SetOptions(merge: true));
    }
  }
}

class MarketCard extends StatelessWidget {
  final String symbol;
  final double price;
  final double change;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MarketCard({
    required this.symbol,
    required this.price,
    required this.change,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = change >= 0 ? Colors.greenAccent : Colors.redAccent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.blueGrey.shade900,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('\$${price.toStringAsFixed(2)}', style: TextStyle(color: Colors.white70)),
                  Text('${change.toStringAsFixed(2)}%', style: TextStyle(color: changeColor)),
                ],
              ),
              IconButton(icon: Icon(Icons.close, color: Colors.white70), onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
