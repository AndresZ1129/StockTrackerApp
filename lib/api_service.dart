import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class StockData {
  final String symbol;
  final double currentPrice; // c
  final double change; // d
  final double percentChange; // dp
  final double highPrice; // h
  final double lowPrice; // l
  final double openPrice; // o
  final double previousClose; // pc

  StockData({
    required this.symbol,
    required this.currentPrice,
    required this.change,
    required this.percentChange,
    required this.highPrice,
    required this.lowPrice,
    required this.openPrice,
    required this.previousClose,
  });

  factory StockData.fromJson(Map<String, dynamic> json, String symbol) {
    return StockData(
      symbol: symbol,
      currentPrice: (json['c'] ?? 0.0).toDouble(),
      change: (json['d'] ?? 0.0).toDouble(),
      percentChange: (json['dp'] ?? 0.0).toDouble(),
      highPrice: (json['h'] ?? 0.0).toDouble(),
      lowPrice: (json['l'] ?? 0.0).toDouble(),
      openPrice: (json['o'] ?? 0.0).toDouble(),
      previousClose: (json['pc'] ?? 0.0).toDouble(),
    );
  }
}

class StockRecommendation {
  final String symbol;
  final String period;
  final int strongBuy;
  final int buy;
  final int hold;
  final int sell;
  final int strongSell;

  StockRecommendation({
    required this.symbol,
    required this.period,
    required this.strongBuy,
    required this.buy,
    required this.hold,
    required this.sell,
    required this.strongSell,
  });

  factory StockRecommendation.fromJson(Map<String, dynamic> json) {
    return StockRecommendation(
      symbol: json['symbol'] ?? '',
      period: json['period'] ?? '',
      strongBuy: json['strongBuy']?.toInt() ?? 0,
      buy: json['buy']?.toInt() ?? 0,
      hold: json['hold']?.toInt() ?? 0,
      sell: json['sell']?.toInt() ?? 0,
      strongSell: json['strongSell']?.toInt() ?? 0,
    );
  }
}

class StockService {
  static const String _apiKey = 'd0aftv9r01qm3l9l62g0d0aftv9r01qm3l9l62gg';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  Future<StockData> getStockData(String symbol) async {
    final url = '$_baseUrl/quote?symbol=$symbol&token=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return StockData.fromJson(data, symbol); // Pass symbol to fromJson
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Error fetching stock data: $e');
    }
  }

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

  Future<StockRecommendation> getRecommendations(String symbol) async {
    final url = '$_baseUrl/stock/recommendation?symbol=$symbol&token=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          throw Exception('No recommendation data available');
        }
        // Get the most recent recommendation
        return StockRecommendation.fromJson(data.first);
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}
