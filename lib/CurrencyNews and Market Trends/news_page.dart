import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_converter/Api_call/news_provider.dart';
import 'package:currency_converter/Api_call/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int _visibleNewsCount = 10;
  static const int _increment = 10;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews('general');
    });
  }

  List<NewsModel> _filterNews(List<NewsModel> newsList) {
    if (_searchQuery.isEmpty) return newsList;
    return newsList.where((news) {
      return news.headline.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          news.summary.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
        _visibleNewsCount = 10;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money News"),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search news...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.newsList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage.isNotEmpty) {
                  return Center(child: Text(provider.errorMessage));
                }

                final filteredNews = _filterNews(provider.newsList);
                final totalNewsCount = filteredNews.length;
                final currentDisplayCount =
                    _visibleNewsCount.clamp(0, totalNewsCount);

                return RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<NewsProvider>(context, listen: false)
                        .fetchNews('general');
                    setState(() => _visibleNewsCount = 10);
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentDisplayCount +
                              1, // +1 for loading indicator
                          itemBuilder: (context, index) {
                            if (index == currentDisplayCount &&
                                totalNewsCount > currentDisplayCount) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (index >= currentDisplayCount) {
                              return SizedBox.shrink();
                            }
                            return _buildNewsCard(context, filteredNews[index]);
                          },
                          physics: const AlwaysScrollableScrollPhysics(),
                        ),
                      ),
                      if (currentDisplayCount < totalNewsCount)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _visibleNewsCount += _increment),
                            child: const Text("Show More"),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsModel news) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: news.image.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: news.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              )
            : const Icon(Icons.newspaper, size: 50),
        title: Text(
          news.headline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          news.summary,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailPage(news: news)),
        ),
      ),
    );
  }
}
