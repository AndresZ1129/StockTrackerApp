import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

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
  static const String _apiKey = 'd08ikc9r01qju5m6nftgd08ikc9r01qju5m6nfu0';
  static const String _baseUrl = 'https://finnhub.io/api/v1/quote';

  Future<StockData> getStockData(String symbol) async {
    final response = await http.get(Uri.parse('$_baseUrl?symbol=$symbol&token=$_apiKey'));

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

  // Fetch news for a specific symbol
  Future<List<NewsArticle>> getNews(String symbol) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: 7)).toIso8601String(); // 7 days ago
    final to = now.toIso8601String(); // current date

    final url = '$_baseUrl/company-news?symbol=$symbol&from=$from&to=$to&token=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => NewsArticle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch news');
    }
  }
}

// News article model
class NewsArticle {
  final String headline;
  final String source;
  final String url;
  final DateTime datetime;

  NewsArticle({
    required this.headline,
    required this.source,
    required this.url,
    required this.datetime,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      headline: json['headline'],
      source: json['source'],
      url: json['url'],
      datetime: DateTime.fromMillisecondsSinceEpoch(json['datetime'] * 1000),
    );
  }
}
