import 'package:flutter/material.dart';
import 'api_service.dart';

class NewsFeedPage extends StatefulWidget {
  final List<String> watchlist; // List of symbols in the user's watchlist

  const NewsFeedPage({required this.watchlist, Key? key}) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  late StockService _stockService;
  Map<String, List<NewsArticle>> _newsMap = {}; // To store news for each symbol

  @override
  void initState() {
    super.initState();
    _stockService = StockService();
    _fetchNews();
  }

  // Fetch news for each stock in the watchlist
  Future<void> _fetchNews() async {
    for (String symbol in widget.watchlist) {
      try {
        List<NewsArticle> news = await _stockService.getNews(symbol);
        setState(() {
          _newsMap[symbol] = news;
        });
      } catch (e) {
        print('Error fetching news for $symbol: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial News Feed'),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: widget.watchlist.length,
        itemBuilder: (context, index) {
          final symbol = widget.watchlist[index];
          final newsList = _newsMap[symbol];

          if (newsList == null) {
            return ListTile(
              title: Text('No news available for $symbol', style: TextStyle(color: Colors.white)),
            );
          }

          return ExpansionTile(
            title: Text(symbol, style: TextStyle(color: Colors.white)),
            children: newsList.map((news) {
              return ListTile(
                title: Text(news.headline, style: TextStyle(color: Colors.white)),
                subtitle: Text(news.source, style: TextStyle(color: Colors.white60)),
                onTap: () => _launchURL(news.url), // Navigate to the article
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _launchURL(String url) {
    // Launch URL in the browser (You can use url_launcher package)
    print('Launching URL: $url');
  }
}
