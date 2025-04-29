import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';

class StockDetailPage extends StatelessWidget {
  final String symbol;

  const StockDetailPage({required this.symbol, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stockService = StockService();

    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<StockData>(
        future: stockService.getStockData(symbol),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final stock = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock Info
                Text('Price: \$${stock.currentPrice}', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('Change: ${stock.percentChange.toStringAsFixed(2)}%', style: TextStyle(color: stock.percentChange >= 0 ? Colors.greenAccent : Colors.redAccent)),
                SizedBox(height: 24),
                // Price Chart
                FutureBuilder<List<double>>(
                  future: stockService.getPriceHistory(symbol),
                  builder: (context, chartSnap) {
                    if (!chartSnap.hasData) {
                      return CircularProgressIndicator();
                    }

                    if (chartSnap.hasError) {
                      print('Error fetching price history: ${chartSnap.error}');
                      return Text('Error fetching price history');
                    }

                    final prices = chartSnap.data!;
                    print('Price History: $prices');  // Add this line to debug

                    // Mock day labels
                    List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                    return SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          backgroundColor: Colors.black,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Show day labels based on the X-axis value
                                  return Text(
                                    daysOfWeek[value.toInt()],
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(2),
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(prices.length, (i) => FlSpot(i.toDouble(), prices[i])),
                              isCurved: true,
                              dotData: FlDotData(show: false),
                              color: Colors.greenAccent,
                              belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.3)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
