import 'package:flutter/material.dart';
import 'package:currency_converter/Api_call/news_repository.dart';
import 'package:currency_converter/Api_call/news_model.dart';

// Manages the state of news data and notifies UI of changes
class NewsProvider extends ChangeNotifier {
  // Instance of NewsRepository to fetch news data from an API
  final NewsRepository _newsRepository;

  // List to store fetched news items, initialized as empty
  List<NewsModel> _newsList = [];

  // Tracks whether news is currently being fetched
  bool _isLoading = false;

  // Stores error message if fetching fails
  String _errorMessage = '';

  // Constructor with optional dependency injection for testing
  NewsProvider({NewsRepository? newsRepository})
      : _newsRepository = newsRepository ?? NewsRepository();

  // Getter for the news list (immutable from outside)
  List<NewsModel> get newsList => List.unmodifiable(_newsList);

  // Getter for loading status
  bool get isLoading => _isLoading;

  // Getter for error message
  String get errorMessage => _errorMessage;

  // Fetches news for a given category and updates state
  Future<void> fetchNews(String category) async {
    // Set loading state and clear previous error
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Notify UI to show loading indicator

    try {
      // Fetch news from the repository (assumed to be an async API call)
      final fetchedNews = await _newsRepository.fetchMarketNews(category);

      // Update news list only if fetch is successful
      _newsList = fetchedNews ?? []; // Fallback to empty list if null
    } catch (e) {
      // Handle error, store message, and reset news list
      _errorMessage = 'Failed to fetch news: ${e.toString()}';
      _newsList = [];
      debugPrint("News fetch error: $_errorMessage"); // Use debugPrint for logs
    } finally {
      // Ensure loading state is reset, even if an error occurs
      _isLoading = false;
      notifyListeners(); // Notify UI to update (e.g., hide loading, show error)
    }
  }

  // Optional: Clear news data manually (e.g., for refresh or logout)
  void clearNews() {
    _newsList = [];
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
}
