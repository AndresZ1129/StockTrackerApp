import 'dart:convert';
import 'package:http/http.dart' as http;

class FinnhubAPI {
  static final String _apiKey = 'your_finnhub_api_key';

  // Get real-time stock data
  static Future<Map<String, dynamic>> getStockData(String symbol) async {
    final response = await http.get(
      Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  // Get news related to the stock symbol
  static Future<List<dynamic>> getNewsForStock(String symbol) async {
    final response = await http.get(
      Uri.parse('https://finnhub.io/api/v1/company-news?symbol=$symbol&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load news');
    }
  }
}
