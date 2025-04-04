import 'package:flutter/material.dart';
import 'package:currency_converter/Api_call/news_repository.dart';
import 'package:currency_converter/Api_call/news_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsRepository _newsRepository;
  List<NewsModel> _newsList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  NewsProvider({NewsRepository? newsRepository})
      : _newsRepository = newsRepository ?? NewsRepository();

  List<NewsModel> get newsList => List.unmodifiable(_newsList);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchNews(String category) async {
    if (_isLoading) return; // Prevent concurrent fetches
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _newsList = await _newsRepository.fetchMarketNews(category) ?? [];
    } catch (e) {
      _errorMessage = 'Failed to fetch news: $e';
      _newsList = [];
      debugPrint("News fetch error: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNews() {
    _newsList = [];
    _errorMessage = '';
    _isLoading = false;
    _newsRepository.clearCache();
    notifyListeners();
  }
}
