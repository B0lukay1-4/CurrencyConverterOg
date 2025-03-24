import 'package:flutter/material.dart';
import 'package:currency_converter/Api_call/news_repository.dart';
import 'package:currency_converter/Api_call/news_model.dart';

class NewsProvider extends ChangeNotifier {
  // Provider class
  final NewsRepository _newsRepository = NewsRepository(); // API fetcher
  List<NewsModel> _newsList = []; // Stores news
  bool _isLoading = false; // Loading status
  String _errorMessage = ''; // Error message

  List<NewsModel> get newsList => _newsList; // Get news list
  bool get isLoading => _isLoading; // Get loading status
  String get errorMessage => _errorMessage; // Get error message

  Future<void> fetchNews(String category) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Notify UI

    try {
      _newsList = await _newsRepository.fetchMarketNews(category);
    } catch (e) {
      _errorMessage = e.toString();
      print("Error: $_errorMessage");
      _newsList = [];
    }

    _isLoading = false;
    notifyListeners(); // Update UI
  }
}
