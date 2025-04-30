import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsArticle {
  final String headline;
  final String source;
  final String url;
  final String datetime;

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
      datetime: DateTime.fromMillisecondsSinceEpoch(json['datetime'] * 1000).toString(),
    );
  }
}

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  static const String _apiKey = 'd08ikc9r01qju5m6nftgd08ikc9r01qju5m6nfu0';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  final List<NewsArticle> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlistAndFetchNews();
  }

  Future<void> _loadWatchlistAndFetchNews() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final watchlist = List<String>.from(doc['watchlist'] ?? []);

      await _fetchAllNews(watchlist);
    } catch (e) {
      debugPrint('Error loading watchlist or fetching news: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllNews(List<String> watchlist) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: 7)).toIso8601String().split('T').first;
    final to = now.toIso8601String().split('T').first;

    for (final symbol in watchlist) {
      final url = '$_baseUrl/company-news?symbol=$symbol&from=$from&to=$to&token=$_apiKey';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          final List<NewsArticle> news = data.map((e) => NewsArticle.fromJson(e)).take(3).toList();
          setState(() => _articles.addAll(news));
        }
      } catch (e) {
        debugPrint('Error fetching news for $symbol: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch article')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News Feed', style: TextStyle(color: Colors.greenAccent),)),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? Center(child: Text("No news found", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(article.headline, style: TextStyle(color: Colors.white)),
                        subtitle: Text('${article.source} • ${article.datetime}', style: TextStyle(color: Colors.grey)),
                        trailing: Icon(Icons.open_in_new, color: Colors.greenAccent),
                        onTap: () => _launchUrl(article.url),
                      ),
                    );
                  },
                ),
    );
  }
}
