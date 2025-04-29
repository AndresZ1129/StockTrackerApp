import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package in pubspec.yaml!
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {

    void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('My Portfolio', style: TextStyle(color: Color(0xFF39FF14)),),
        actions: [
          IconButton(
  icon: Icon(Icons.logout_outlined, color: Color(0xFF39FF14)),
  onPressed: () {
    _logout(context);
  },
),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Card
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

            // Mini Chart
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

            // Market Summary
            Text('Market Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  MarketCard(title: 'AAPL', price: '\$172', change: '+2.3%'),
                  MarketCard(title: 'GOOGL', price: '\$138', change: '+1.2%'),
                  MarketCard(title: 'TSLA', price: '\$900', change: '-0.7%'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Watchlist
            Text('Your Watchlist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.greenAccent),
              title: Text('MSFT', style: TextStyle(color: Colors.white)),
              subtitle: Text('Microsoft Corp.', style: TextStyle(color: Colors.white54)),
              trailing: Text('+1.8%', style: TextStyle(color: Colors.greenAccent)),
            ),
            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.redAccent),
              title: Text('AMZN', style: TextStyle(color: Colors.white)),
              subtitle: Text('Amazon.com', style: TextStyle(color: Colors.white54)),
              trailing: Text('-0.5%', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
  backgroundColor: Colors.white, // <-- White background
  selectedItemColor: Colors.greenAccent, // <-- Selected items green
  unselectedItemColor: Colors.black, // <-- Unselected items black
  type: BottomNavigationBarType.fixed, // <-- Important! Prevents shifting
  selectedFontSize: 14, // <-- Make text visible
  unselectedFontSize: 12,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Watchlist'),
    BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'News'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ],
),
    );
  }
}

class MarketCard extends StatelessWidget {
  final String title, price, change;

  const MarketCard({required this.title, required this.price, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(price, style: TextStyle(color: Colors.white)),
          SizedBox(height: 4),
          Text(change, style: TextStyle(color: change.startsWith('+') ? Colors.greenAccent : Colors.redAccent)),
        ],
      ),
    );
  }
}
