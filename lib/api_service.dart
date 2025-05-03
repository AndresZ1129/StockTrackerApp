import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class StockData {
  final String symbol;
  final double currentPrice;
  final double priceChange;
  final double percentChange;

  StockData({
    required this.symbol,
    required this.currentPrice,
    required this.priceChange,
    required this.percentChange,
  });

  // Factory method to create StockData from a JSON response
  factory StockData.fromJson(String symbol, Map<String, dynamic> json) {
    return StockData(
      symbol: symbol,
      currentPrice: (json['c'] ?? 0).toDouble(),
      priceChange: (json['d'] ?? 0).toDouble(),
      percentChange: (json['dp'] ?? 0).toDouble(),
    );
  }
}

class StockService {
  static const String _apiKey = 'd0aftv9r01qm3l9l62g0d0aftv9r01qm3l9l62gg';
  static const String _baseUrl = 'https://finnhub.io/api/v1/quote';

  Future<StockData> getStockData(String symbol) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?symbol=$symbol&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StockData.fromJson(symbol, data);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  // Inside StockService class
  Future<List<double>> getPriceHistory(String symbol) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    final random = Random();
    List<double> prices = [];
    double base = 100 + random.nextDouble() * 100; // Start between 100–200

    for (int i = 0; i < 7; i++) {
      // Simulate daily price change
      double change = random.nextDouble() * 4 - 2; // -2 to +2
      base += change;
      prices.add(double.parse(base.toStringAsFixed(2)));
    }

    return prices;
  }
}
