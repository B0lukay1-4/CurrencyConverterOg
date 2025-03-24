import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_converter/Api_call/news_provider.dart';
import 'package:currency_converter/Api_call/news_model.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int _visibleNewsCount = 10;
  static const int _increment = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews('general');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Money News")),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          final totalNewsCount = provider.newsList.length;
          final currentDisplayCount =
              _visibleNewsCount.clamp(0, totalNewsCount);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: currentDisplayCount,
                  itemBuilder: (context, index) =>
                      _buildNewsCard(provider.newsList[index]),
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
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: news.image.isNotEmpty
            ? Image.network(
                news.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Failed to load image: ${news.image}, error: $error");
                  return const Icon(Icons.broken_image, size: 50);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              )
            : const Icon(Icons.newspaper),
        title:
            Text(news.headline, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle:
            Text(news.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
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
