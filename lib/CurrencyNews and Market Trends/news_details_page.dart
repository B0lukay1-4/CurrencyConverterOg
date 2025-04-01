import 'package:flutter/material.dart';
import 'package:currency_converter/Api_call/news_model.dart';
import 'package:url_launcher/url_launcher.dart';

// Displays detailed information about a single news item
class NewsDetailPage extends StatelessWidget {
  // The news item to display
  final NewsModel news;

  const NewsDetailPage({super.key, required this.news});

  // Launches the news article URL in an external browser
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint(
          'Could not launch $url'); // Use debugPrint for production safety
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          news.headline,
          overflow: TextOverflow.ellipsis, // Prevent overflow in AppBar
        ),
        elevation: 2, // Slight shadow for depth
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image.isNotEmpty) // Show image only if URL exists
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners
                child: Image.network(
                  news.image,
                  fit: BoxFit.cover,
                  width: double.infinity, // Full width for consistency
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              news.headline,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, // Emphasize headline
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Source: ${news.source}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600, // Subtle source text
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              news.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (news.url.isNotEmpty) // Show button only if URL exists
              ElevatedButton(
                onPressed: () => _launchUrl(news.url),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ), // Consistent padding
                ),
                child: const Text("Read Full Article"),
              ),
          ],
        ),
      ),
    );
  }
}
