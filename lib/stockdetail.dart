import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';

class StockDetailPage extends StatelessWidget {
  final String symbol;

  const StockDetailPage({required this.symbol, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stockService = StockService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          symbol.toUpperCase(),
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF2C6B2F),
        iconTheme: IconThemeData(color: Colors.greenAccent),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<StockData>(
        future: stockService.getStockData(symbol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading stock data',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final stock = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock Info
                Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Price',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${stock.currentPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${stock.change >= 0 ? '+' : ''}${stock.change.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        stock.change >= 0
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '(${stock.percentChange >= 0 ? '+' : ''}${stock.percentChange.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                    color:
                                        stock.percentChange >= 0
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey[800], thickness: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPriceInfo('Open', stock.openPrice),
                            _buildPriceInfo('High', stock.highPrice),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPriceInfo('Low', stock.lowPrice),
                            _buildPriceInfo('Prev Close', stock.previousClose),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Analyst Recommendations (Moved up)
                FutureBuilder<StockRecommendation>(
                  future: stockService.getRecommendations(symbol),
                  builder: (context, recSnap) {
                    if (recSnap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.greenAccent,
                        ),
                      );
                    }

                    if (recSnap.hasError || !recSnap.hasData) {
                      return SizedBox.shrink();
                    }

                    final rec = recSnap.data!;
                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analyst Recommendations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildRecommendationBar(
                              'Strong Buy',
                              rec.strongBuy,
                              Colors.greenAccent,
                              rec.strongBuy +
                                  rec.buy +
                                  rec.hold +
                                  rec.sell +
                                  rec.strongSell,
                            ),
                            _buildRecommendationBar(
                              'Buy',
                              rec.buy,
                              Colors.green,
                              rec.strongBuy +
                                  rec.buy +
                                  rec.hold +
                                  rec.sell +
                                  rec.strongSell,
                            ),
                            _buildRecommendationBar(
                              'Hold',
                              rec.hold,
                              Colors.yellow,
                              rec.strongBuy +
                                  rec.buy +
                                  rec.hold +
                                  rec.sell +
                                  rec.strongSell,
                            ),
                            _buildRecommendationBar(
                              'Sell',
                              rec.sell,
                              Colors.orange,
                              rec.strongBuy +
                                  rec.buy +
                                  rec.hold +
                                  rec.sell +
                                  rec.strongSell,
                            ),
                            _buildRecommendationBar(
                              'Strong Sell',
                              rec.strongSell,
                              Colors.red,
                              rec.strongBuy +
                                  rec.buy +
                                  rec.hold +
                                  rec.sell +
                                  rec.strongSell,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last updated: ${rec.period}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Price History Chart (Moved down)
                Text(
                  "Price History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<double>>(
                  future: stockService.getPriceHistory(symbol),
                  builder: (context, chartSnap) {
                    if (chartSnap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.greenAccent,
                        ),
                      );
                    }

                    if (chartSnap.hasError || !chartSnap.hasData) {
                      return Text(
                        'Error loading chart data',
                        style: TextStyle(color: Colors.redAccent),
                      );
                    }

                    final prices = chartSnap.data!;
                    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line Chart Section
                          Text(
                            "Line Chart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              height: 220,
                              child: LineChart(
                                LineChartData(
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          int index =
                                              value.toInt() % daysOfWeek.length;
                                          return Text(
                                            daysOfWeek[index],
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toStringAsFixed(2),
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        prices.length,
                                        (i) => FlSpot(i.toDouble(), prices[i]),
                                      ),
                                      isCurved: true,
                                      color: Colors.greenAccent,
                                      barWidth: 2,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.greenAccent.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ), // Add spacing between the charts
                          // Bar Chart Section
                          Text(
                            "Bar Chart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          int index =
                                              value.toInt() % daysOfWeek.length;
                                          return Text(
                                            daysOfWeek[index],
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toStringAsFixed(2),
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                  barGroups: List.generate(
                                    prices.length,
                                    (i) => BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: prices[i],
                                          color: Colors.greenAccent,
                                          width: 8,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildRecommendationBar(
    String label,
    int value,
    Color color,
    int total,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(label, style: TextStyle(color: Colors.grey)),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: total > 0 ? value / total : 0,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  value.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}