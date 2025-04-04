import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:currency_converter/Api_call/news_model.dart';

class NewsRepository {
  static const String _apiKey = 'cvfb809r01qtu9s3rjm0cvfb809r01qtu9s3rjmg';
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  static final Map<String, List<NewsModel>> _cache = {};

  Future<List<NewsModel>> fetchMarketNews(String category) async {
    // Check cache first
    if (_cache.containsKey(category)) {
      return _cache[category]!;
    }

    final Uri url =
        Uri.parse('$_baseUrl/news?category=$category&token=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final newsList = data.map((json) => NewsModel.fromJson(json)).toList();
        _cache[category] = newsList; // Cache results
        return newsList;
      } else {
        throw Exception('Failed to load news: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
