import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_converter/Api_call/news_provider.dart';
import 'package:currency_converter/Api_call/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For image caching

// Displays a paginated list of news items with lazy loading, search, and refresh
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // Number of news items currently visible
  int _visibleNewsCount = 10;

  // Increment for "Show More" button
  static const int _increment = 10;

  // Search query to filter news
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch news after the first frame to avoid blocking the UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews('general');
    });
  }

  // Filters news list based on search query
  List<NewsModel> _filterNews(List<NewsModel> newsList) {
    if (_searchQuery.isEmpty) return newsList;
    return newsList.where((news) {
      return news.headline.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          news.summary.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money News"),
        elevation: 2, // Slight shadow for depth
      ),
      body: Column(
        children: [
          // Search bar for filtering news
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search news...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _visibleNewsCount = 10; // Reset pagination on search
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
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
                    setState(() {
                      _visibleNewsCount = 10; // Reset pagination on refresh
                    });
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentDisplayCount,
                          itemBuilder: (context, index) {
                            // Precache image for the next item (if it exists)
                            if (index + 1 < totalNewsCount &&
                                filteredNews[index + 1].image.isNotEmpty) {
                              precacheImage(
                                NetworkImage(filteredNews[index + 1].image),
                                context,
                              );
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
                            onPressed: () {
                              setState(() {
                                _visibleNewsCount += _increment;
                              });
                            },
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

  // Builds a news card with image, headline, and summary
  Widget _buildNewsCard(BuildContext context, NewsModel news) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: news.image.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners
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
                  errorWidget: (context, url, error) {
                    debugPrint(
                        "Failed to load image: ${news.image}, error: $error");
                    return const Icon(Icons.broken_image, size: 50);
                  },
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(news: news),
            ),
          );
        },
      ),
    );
  }
}
