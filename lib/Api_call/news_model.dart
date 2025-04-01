// Represents a news item with relevant metadata
class NewsModel {
  // Category of the news (e.g., "Technology", "Sports")
  final String category;

  // Timestamp of the news in seconds or milliseconds since epoch
  final int datetime;

  // Main title or headline of the news article
  final String headline;

  // Unique identifier for the news article
  final int id;

  // URL or path to the news article's image
  final String image;

  // Related topics or tags associated with the news
  final String related;

  // Source of the news (e.g., "BBC", "CNN")
  final String source;

  // Brief summary or excerpt of the news article
  final String summary;

  // URL linking to the full news article
  final String url;

  // Constructor with required fields to ensure all properties are provided
  const NewsModel({
    required this.category,
    required this.datetime,
    required this.headline,
    required this.id,
    required this.image,
    required this.related,
    required this.source,
    required this.summary,
    required this.url,
  });

  // Factory method to create a NewsModel instance from JSON data
  // Handles null values gracefully with default fallbacks
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      category: json['category'] as String? ?? '', // Empty string if null
      datetime: json['datetime'] as int? ?? 0, // 0 if null
      headline: json['headline'] as String? ?? '', // Empty string if null
      id: json['id'] as int? ?? 0, // 0 if null
      image: json['image'] as String? ?? '', // Empty string if null
      related: json['related'] as String? ?? '', // Empty string if null
      source: json['source'] as String? ?? '', // Empty string if null
      summary: json['summary'] as String? ?? '', // Empty string if null
      url: json['url'] as String? ?? '', // Empty string if null
    );
  }

  // Optional: Convert NewsModel back to JSON (useful for serialization)
  Map<String, dynamic> toJson() => {
        'category': category,
        'datetime': datetime,
        'headline': headline,
        'id': id,
        'image': image,
        'related': related,
        'source': source,
        'summary': summary,
        'url': url,
      };

  // Optional: Override toString for better debugging output
  @override
  String toString() {
    return 'NewsModel(id: $id, headline: "$headline", category: "$category")';
  }
}
