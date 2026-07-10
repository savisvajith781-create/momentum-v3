import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/quote_model.dart';

class QuoteService {
  List<QuoteModel> _quotes = [];
  int _currentIndex = 0;
  final Random _random = Random();

  Future<void> init() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/quotes.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final quoteList = data['quotes'] as List<dynamic>;
      _quotes = quoteList
          .map((q) => QuoteModel.fromJson(q as Map<String, dynamic>))
          .toList();
      _currentIndex = _random.nextInt(_quotes.length);
    } catch (e) {
      _quotes = [
        const QuoteModel(
          text: 'The secret of getting ahead is getting started.',
          author: 'Mark Twain',
          category: 'discipline',
        ),
      ];
    }
  }

  QuoteModel get currentQuote {
    if (_quotes.isEmpty) {
      return const QuoteModel(
        text: 'Stay focused. Stay consistent.',
        author: 'Momentum',
        category: 'discipline',
      );
    }
    return _quotes[_currentIndex % _quotes.length];
  }

  QuoteModel nextQuote() {
    if (_quotes.isEmpty) return currentQuote;
    _currentIndex = (_currentIndex + 1) % _quotes.length;
    return _quotes[_currentIndex];
  }

  QuoteModel randomQuote() {
    if (_quotes.isEmpty) return currentQuote;
    _currentIndex = _random.nextInt(_quotes.length);
    return _quotes[_currentIndex];
  }

  List<QuoteModel> getQuotesByCategory(String category) {
    return _quotes.where((q) => q.category == category).toList();
  }

  List<String> get categories =>
      _quotes.map((q) => q.category).toSet().toList();
}
