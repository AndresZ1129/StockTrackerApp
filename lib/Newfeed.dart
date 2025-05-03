import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsArticle {
  final String headline;
  final String source;
  final String url;
  final String datetime;
  final String image;
  final String summary; // Added summary field
  final String related; // Added related field
  final bool isWatchlist;

  NewsArticle({
    required this.headline,
    required this.source,
    required this.url,
    required this.datetime,
    required this.image,
    required this.summary, // Added to constructor
    required this.related, // Added to constructor
    this.isWatchlist = false,
  });

  factory NewsArticle.fromJson(
    Map<String, dynamic> json, {
    bool isWatchlist = false,
  }) {
    return NewsArticle(
      headline:
          json['headline'] ?? 'No headline', // Default if headline is missing
      source:
          json['source'] ?? 'Unknown source', // Default if source is missing
      url: json['url'] ?? '', // Default if URL is missing
      datetime:
          json['datetime'] != null
              ? _formatDate(json['datetime'])
              : 'Unknown date', // Default if datetime is missing
      image: json['image'] ?? '', // Default if image is missing
      summary: json['summary'] ?? '', // Parse summary from JSON
      related: json['related'] ?? '', // Parse related from JSON
      isWatchlist: isWatchlist,
    );
  }

  static String _formatDate(int unixTimestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    return '${date.day}/${date.month}/${date.year}'; // Format as DD/MM/YYYY
  }
}

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  static const String _apiKey = 'd0aftv9r01qm3l9l62g0d0aftv9r01qm3l9l62gg';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  final List<NewsArticle> _articles = [];
  final List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  int _articlesPerLoad = 5; // Number of articles to load per request
  int _currentIndex = 0; // Tracks the current index for loading more articles
  String _currentCategory = 'general'; // Default category
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllNews();
  }

  Future<void> _fetchAllNews() async {
    setState(() => _isLoading = true);
    final url = '$_baseUrl/news?category=$_currentCategory&token=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final List<NewsArticle> news =
            data.map((e) => NewsArticle.fromJson(e)).toList();
        setState(
          () =>
              _articles
                ..clear()
                ..addAll(news),
        );
      }
    } catch (e) {
      debugPrint('Error fetching $_currentCategory news: $e');
    }
    setState(() => _isLoading = false);
  }

  void _applyFilter(String category) {
    setState(() {
      _currentCategory = category;
      _isSearching = false;
      _searchController.clear();
    });
    _fetchAllNews();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _filteredArticles.clear();
      _currentCategory = 'general';
    });
    _fetchAllNews();
  }

  void _loadMoreArticles() {
    setState(() => _isLoadingMore = true);

    // Simulate loading more articles
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _currentIndex += _articlesPerLoad;
        _isLoadingMore = false;
      });
    });
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch article')));
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();

    // Check if query matches any category filter
    if (query == 'forex' || query == 'crypto' || query == 'merger') {
      _applyFilter(query);
      return;
    }

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredArticles.clear();
        _filteredArticles.addAll(_articles);
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredArticles.clear();
      _filteredArticles.addAll(
        _articles.where(
          (article) =>
              article.headline.toLowerCase().contains(query) ||
              article.source.toLowerCase().contains(query) ||
              article.summary.toLowerCase().contains(query) ||
              article.related.toLowerCase().contains(query),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Feed', style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Search by headline, source, summary or filter (forex/crypto/merger)...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.greenAccent,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _clearSearch();
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Text('Search', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
          // Filter Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TextButton(
                  onPressed: _clearSearch,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _currentCategory == 'general'
                            ? Colors.greenAccent
                            : Colors.transparent,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color:
                          _currentCategory == 'general'
                              ? Colors.black
                              : Colors.greenAccent,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _applyFilter('forex'),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _currentCategory == 'forex'
                            ? Colors.greenAccent
                            : Colors.transparent,
                  ),
                  child: Text(
                    'Forex',
                    style: TextStyle(
                      color:
                          _currentCategory == 'forex'
                              ? Colors.black
                              : Colors.greenAccent,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _applyFilter('crypto'),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _currentCategory == 'crypto'
                            ? Colors.greenAccent
                            : Colors.transparent,
                  ),
                  child: Text(
                    'Crypto',
                    style: TextStyle(
                      color:
                          _currentCategory == 'crypto'
                              ? Colors.black
                              : Colors.greenAccent,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _applyFilter('merger'),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _currentCategory == 'merger'
                            ? Colors.greenAccent
                            : Colors.transparent,
                  ),
                  child: Text(
                    'Merger',
                    style: TextStyle(
                      color:
                          _currentCategory == 'merger'
                              ? Colors.black
                              : Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // News Articles
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_isSearching && _filteredArticles.isEmpty) ||
                        (!_isSearching && _articles.isEmpty)
                    ? Center(
                      child: Text(
                        "No news found",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      itemCount:
                          _isSearching
                              ? _filteredArticles.length
                              : min(
                                _currentIndex + _articlesPerLoad,
                                _articles.length,
                              ),
                      itemBuilder: (context, index) {
                        if (!_isSearching &&
                            index ==
                                min(
                                  _currentIndex + _articlesPerLoad - 1,
                                  _articles.length - 1,
                                ) &&
                            _currentIndex + _articlesPerLoad <
                                _articles.length) {
                          return _isLoadingMore
                              ? Center(child: CircularProgressIndicator())
                              : TextButton(
                                onPressed: _loadMoreArticles,
                                child: Text(
                                  "Load More",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              );
                        }

                        final article =
                            _isSearching
                                ? _filteredArticles[index]
                                : _articles[index];

                        return Card(
                          color: Colors.grey[900],
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            leading:
                                article.image.isNotEmpty
                                    ? Image.network(
                                      article.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                            title: Text(
                              article.headline,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${article.source} • ${article.datetime}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: Icon(
                              Icons.open_in_new,
                              color: Colors.greenAccent,
                            ),
                            onTap: () => _launchUrl(article.url),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
