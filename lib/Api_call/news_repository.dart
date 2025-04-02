import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:currency_converter/Api_call/news_model.dart';

// Repository class responsible for fetching news data from the Finnhub API
class NewsRepository {
  // API key for Finnhub (consider storing this in a secure config file)
  static const String _apiKey = 'cvfb809r01qtu9s3rjm0cvfb809r01qtu9s3rjmg';

  // Base URL for the Finnhub API
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  // Fetches market news for a given category from the Finnhub API
  Future<List<NewsModel>> fetchMarketNews(String category) async {
    // Construct the API URL with query parameters
    final Uri url =
        Uri.parse('$_baseUrl/news?category=$category&token=$_apiKey');

    try {
      // Perform the HTTP GET request
      final response = await http.get(url);

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        // Decode JSON response into a list of dynamic objects
        final List<dynamic> data = jsonDecode(response.body);

        // Convert each JSON object into a NewsModel instance
        return data.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        // Throw a specific exception with status code for non-200 responses
        throw Exception('Failed to load news: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      // Handle network-related errors (e.g., no internet)
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      // Handle JSON decoding errors
      throw Exception('Invalid response format: $e');
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Unexpected error: $e');
    }
  }
}
