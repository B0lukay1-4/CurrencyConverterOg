import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:currency_converter/Api_call/news_model.dart';

class NewsRepository {
  final String _apiKey = 'cvfb809r01qtu9s3rjm0cvfb809r01qtu9s3rjmg';
  final String _baseUrl = 'https://finnhub.io/api/v1';

  Future<List<NewsModel>> fetchMarketNews(String category) async {
    final Uri url =
        Uri.parse('$_baseUrl/news?category=$category&token=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
